import { Router } from 'express';
import bcrypt from 'bcryptjs';
import multer from 'multer';
import { z } from 'zod';
import supabase from '../services/supabaseClient';
import { ok } from '../utils/respond';
import { requireAuth, signUserToken } from '../utils/jwt';
import type { Request, Response } from 'express';

// Extend Request type with userId
declare module 'express-serve-static-core' {
  interface Request {
    userId?: string;
  }
}

const router = Router();
const upload = multer({ storage: multer.memoryStorage() });

// ---------- Helpers ----------
function uid(req: Request): string {
  return String((req as any).userId || '');
}

async function fetchUserById(userId: string) {
  const { data, error } = await supabase
    .from('users')
    .select('*')
    .eq('id', userId)
    .maybeSingle();
  return { data, error };
}

// ---------- Auth / User ----------
const registerBody = z.object({
  email: z.string().email().optional().or(z.literal('')),
  username: z.string().min(1),
  password: z.string().min(6),
  contact: z.string().optional().or(z.literal('')),
  full_name: z.string().optional().or(z.literal('')),
});

router.post('/api/user/register/', async (req: Request, res: Response) => {
  const parsed = registerBody.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ success: false, message: 'Invalid payload', errors: parsed.error.flatten() });

  const { email, username, password, contact, full_name } = parsed.data;
  const password_hash = bcrypt.hashSync(password, 10);

  // Try to insert into existing Supabase table; if it doesn't exist yet, return a helpful error.
  const { data: user, error } = await supabase
    .from('users')
    .insert({
      email: email || null,
      username,
      contact: contact || null,
      full_name: full_name || null,
      password_hash,
      is_active: true,
      is_admin: false,
      is_registered: true,
      is_deleted: false,
      user_type: 'user',
      is_profile_completed: false,
    })
    .select('*')
    .maybeSingle();

  if (error || !user) {
    return res.status(500).json({ success: false, message: 'Failed to register', error: (error as any)?.message || 'unknown' });
  }

  const token = signUserToken({ sub: String(user.id), username: user.username });
  return res.status(201).json({ success: true, message: 'Registered', token, data: user });
});

const loginBody = z.object({
  username: z.string().min(1).optional(),
  email: z.string().email().optional(),
  password: z.string().min(1),
}).refine(data => data.username || data.email, {
  message: "Either username or email is required",
  path: ["username"],
});

router.post('/api/user/login/', async (req: Request, res: Response) => {
  const parsed = loginBody.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ success: false, message: 'Invalid payload', errors: parsed.error.flatten() });

  const { username, email, password } = parsed.data;

  // Build query - check username or email
  let query = supabase.from('users').select('*');
  
  if (username) {
    query = query.ilike('username', username);
  } else if (email) {
    query = query.ilike('email', email);
  }

  const { data: user, error } = await query.maybeSingle();

  if (error || !user) return res.status(401).json({ success: false, message: 'Invalid credentials' });

  const okPass = bcrypt.compareSync(password, String((user as any).password_hash || ''));
  if (!okPass) return res.status(401).json({ success: false, message: 'Invalid credentials' });

  const token = signUserToken({ sub: String(user.id), username: user.username });
  return res.json({ success: true, message: 'Logged in', token, data: user });
});

// Social login/register placeholder (kept for compatibility)
router.post('/api/user/api/social_login_or_register/', async (_req: Request, res: Response) => {
  return res.status(501).json({ success: false, message: 'Not implemented on this backend yet' });
});

router.post('/api/user/account/activation/', async (_req: Request, res: Response) => {
  return res.json({ success: true, message: 'Activated' });
});

router.get('/api/user/me/', requireAuth, async (req: Request, res: Response) => {
  const userId = uid(req);
  const { data: user, error } = await fetchUserById(userId);
  if (error || !user) return res.status(404).json({ success: false, message: 'User not found' });
  return res.json(ok('OK', user));
});

router.post('/api/user/updateProfile/', requireAuth, upload.single('image'), async (req: Request, res: Response) => {
  const userId = uid(req);
  const body = req.body || {};

  // Accept most fields as-is; Flutter sends JSON or multipart fields
  const update: any = {};
  const allowed = [
    'email', 'username', 'contact', 'full_name', 'address',
    'longitude', 'latitude', 'dob', 'gender', 'is_profile_completed',
  ];
  for (const k of allowed) {
    if (typeof body[k] !== 'undefined') update[k] = body[k];
  }

  // If an image file is uploaded, process it as base64 data URI
  if ((req as any).file) {
    const file = (req as any).file as Express.Multer.File;
    const imageUrl = `data:${file.mimetype};base64,${file.buffer.toString('base64')}`;
    update.image = imageUrl;
  }

  const { data: user, error } = await supabase
    .from('users')
    .update(update)
    .eq('id', userId)
    .select('*')
    .maybeSingle();

  if (error || !user) return res.status(500).json({ success: false, message: 'Failed to update profile' });
  return res.json(ok('Profile updated', user));
});

router.get('/api/user/check-user/', async (req: Request, res: Response) => {
  const username = String(req.query.username || '').trim();
  const email = String(req.query.email || '').trim();

  if (!username && !email) return res.status(400).json({ success: false, message: 'username or email is required' });

  let query = supabase.from('users').select('id, username, email');
  if (username) query = (query as any).ilike('username', username);
  if (email) query = (query as any).ilike('email', email);

  const { data, error } = await (query as any).maybeSingle();
  if (error) return res.status(500).json({ success: false, message: 'Lookup failed' });
  return res.json({ success: true, message: 'OK', exists: !!data });
});

router.delete('/api/user/delete/', requireAuth, async (req: Request, res: Response) => {
  const userId = uid(req);
  const { error } = await supabase.from('users').delete().eq('id', userId);
  if (error) return res.status(500).json({ success: false, message: 'Failed to delete user' });
  return res.json({ success: true, message: 'Deleted' });
});

router.post('/api/user/forgotpassword/', async (_req: Request, res: Response) => {
  // Placeholder (your PythonAnywhere service can remain for payment; this is auth only)
  return res.json({ success: true, message: 'If the account exists, reset instructions were sent.' });
});

// ---------- Categories / Interests ----------
router.get('/getallcategories/', async (_req: Request, res: Response) => {
  const { data, error } = await supabase.from('categories').select('id, name, description').order('id');
  if (error) {
    // Fallback dummy values if table doesn't exist yet
    return res.json({ success: true, message: 'OK', data: [{ id: 1, name: 'General', description: '' }] });
  }
  return res.json({ success: true, message: 'OK', data: data || [] });
});

router.get('/getallinterests/', async (_req: Request, res: Response) => {
  const { data, error } = await supabase.from('interests').select('id, name').order('id');
  if (error) {
    return res.json({ success: true, message: 'OK', data: [{ id: 1, name: 'Trading' }] });
  }
  return res.json({ success: true, message: 'OK', data: data || [] });
});

router.post('/add-interests/', requireAuth, async (req: Request, res: Response) => {
  const userId = uid(req);
  const body = req.body || {};
  
  // Support both interest_ids and interest_names
  let interestIds: number[] = [];
  
  if (Array.isArray(body.interest_ids)) {
    // If IDs are provided, use them directly
    interestIds = body.interest_ids.map((id: any) => Number(id));
  } else if (Array.isArray(body.interest_names)) {
    // If names are provided, look them up to get IDs
    const names = body.interest_names;
    const { data: interests, error: lookupError } = await supabase
      .from('interests')
      .select('id')
      .in('name', names);
    
    if (lookupError || !interests) {
      return res.status(400).json({ success: false, message: 'Failed to find interest IDs' });
    }
    
    interestIds = interests.map((i: any) => Number(i.id));
  }
  
  // Store as join table if it exists, else return OK
  if (!interestIds.length) return res.json({ success: true, message: 'OK', data: [] });

  // Delete existing user interests first to avoid duplicates
  await supabase.from('user_interests').delete().eq('user_id', userId);
  
  const rows = interestIds.map((interestId: number) => ({ user_id: userId, interest_id: interestId }));
  const { error } = await supabase.from('user_interests').insert(rows);
  if (error) return res.status(500).json({ success: false, message: 'Failed to save interests' });
  
  // Mark profile as completed after adding interests (assuming image was already added)
  await supabase.from('users').update({ is_profile_completed: true }).eq('id', userId);
  
  return res.json({ success: true, message: 'Saved', data: interestIds });
});

router.get('/getuserinterests/', requireAuth, async (req: Request, res: Response) => {
  const userId = uid(req);
  const { data, error } = await supabase
    .from('user_interests')
    .select('interest_id, interests(name)')
    .eq('user_id', userId);
  if (error) return res.json({ success: true, message: 'OK', data: [] });
  const out = (data || []).map((r: any) => ({ id: r.interest_id, interest_name: r.interests?.name || '' }));
  return res.json({ success: true, message: 'OK', data: out });
});

// ---------- Products ----------
router.post('/add_products/', requireAuth, upload.any(), async (req: Request, res: Response) => {
  const userId = uid(req);
  const body: any = req.body || {};
  const files = ((req as any).files as Express.Multer.File[]) || [];

  // Process uploaded files
  // First file with fieldname 'image' is the primary image
  // All files with fieldname 'images' are additional images
  let primaryImageUrl = '';
  const imageUrls: string[] = [];
  
  // Extract primary image (fieldname: 'image')
  const primaryFile = files.find(f => f.fieldname === 'image');
  if (primaryFile) {
    // Store as base64 data URI (temporary - should use Supabase Storage or S3 in production)
    primaryImageUrl = `data:${primaryFile.mimetype};base64,${primaryFile.buffer.toString('base64')}`;
    imageUrls.push(primaryImageUrl);
  }
  
  // Extract additional images (fieldname: 'images')
  const additionalFiles = files.filter(f => f.fieldname === 'images');
  for (const file of additionalFiles) {
    const imageUrl = `data:${file.mimetype};base64,${file.buffer.toString('base64')}`;
    if (!imageUrls.includes(imageUrl)) { // Avoid duplicates
      imageUrls.push(imageUrl);
    }
  }

  // Handle category - can be ID (number) or name (string)
  let categoryId: number | null = null;
  if (body.category_id) {
    categoryId = typeof body.category_id === 'string' ? parseFloat(body.category_id) || null : body.category_id;
  } else if (body.category) {
    // If category is a string (name), look it up
    if (typeof body.category === 'string') {
      const { data: categoryData } = await supabase
        .from('categories')
        .select('id')
        .ilike('name', body.category)
        .maybeSingle();
      if (categoryData) {
        categoryId = Number(categoryData.id);
      }
    } else if (typeof body.category === 'number') {
      categoryId = body.category;
    }
  }

  const insertData: any = {
    user_id: userId,
    category_id: categoryId,
    title: body.title ?? '',
    min_price: typeof body.min_price === 'string' ? parseFloat(body.min_price) || parseFloat(body.minPrice || '0') : (body.min_price ?? body.minPrice ?? 0),
    max_price: typeof body.max_price === 'string' ? parseFloat(body.max_price) || parseFloat(body.maxPrice || '0') : (body.max_price ?? body.maxPrice ?? 0),
    product_condition: body.product_condition ?? body.productCondition ?? '',
    status: body.status ?? 'active',
    image: primaryImageUrl || body.image || '',
    images: imageUrls.length > 0 ? imageUrls : (body.images || []),
  };

  const { data, error } = await supabase.from('products').insert(insertData).select('*').maybeSingle();
  if (error) {
    console.error('Error inserting product:', error);
    return res.status(500).json({ success: false, message: 'Failed to create product', error: error.message });
  }
  if (!data) {
    console.error('Product insert returned no data');
    return res.status(500).json({ success: false, message: 'Failed to create product' });
  }
  return res.status(201).json({ success: true, message: 'Created', data });
});

router.post('/add_user_products/', requireAuth, upload.any(), async (req: Request, res: Response) => {
  // Alias for compatibility - use same logic as /add_products/
  const userId = uid(req);
  const body: any = req.body || {};
  const files = ((req as any).files as Express.Multer.File[]) || [];

  // Process uploaded files (same as /add_products/)
  let primaryImageUrl = '';
  const imageUrls: string[] = [];
  
  // Extract primary image (fieldname: 'image')
  const primaryFile = files.find(f => f.fieldname === 'image');
  if (primaryFile) {
    // Store as base64 data URI (temporary - should use Supabase Storage or S3 in production)
    primaryImageUrl = `data:${primaryFile.mimetype};base64,${primaryFile.buffer.toString('base64')}`;
    imageUrls.push(primaryImageUrl);
  }
  
  // Extract additional images (fieldname: 'images')
  const additionalFiles = files.filter(f => f.fieldname === 'images');
  for (const file of additionalFiles) {
    const imageUrl = `data:${file.mimetype};base64,${file.buffer.toString('base64')}`;
    if (!imageUrls.includes(imageUrl)) { // Avoid duplicates
      imageUrls.push(imageUrl);
    }
  }

  // Handle category - can be ID (number) or name (string)
  let categoryId: number | null = null;
  if (body.category_id) {
    categoryId = typeof body.category_id === 'string' ? parseFloat(body.category_id) || null : body.category_id;
  } else if (body.category) {
    // If category is a string (name), look it up
    if (typeof body.category === 'string') {
      const { data: categoryData } = await supabase
        .from('categories')
        .select('id')
        .ilike('name', body.category)
        .maybeSingle();
      if (categoryData) {
        categoryId = Number(categoryData.id);
      }
    } else if (typeof body.category === 'number') {
      categoryId = body.category;
    }
  }

  const insertData: any = {
    user_id: userId,
    category_id: categoryId,
    title: body.title ?? '',
    min_price: typeof body.min_price === 'string' ? parseFloat(body.min_price) || parseFloat(body.minPrice || '0') : (body.min_price ?? body.minPrice ?? 0),
    max_price: typeof body.max_price === 'string' ? parseFloat(body.max_price) || parseFloat(body.maxPrice || '0') : (body.max_price ?? body.maxPrice ?? 0),
    product_condition: body.product_condition ?? body.productCondition ?? '',
    status: body.status ?? 'active',
    image: primaryImageUrl || body.image || '',
    images: imageUrls.length > 0 ? imageUrls : (body.images || []),
  };

  const { data, error } = await supabase.from('products').insert(insertData).select('*').maybeSingle();
  if (error) {
    console.error('Error inserting product:', error);
    return res.status(500).json({ success: false, message: 'Failed to create product', error: error.message });
  }
  if (!data) {
    console.error('Product insert returned no data');
    return res.status(500).json({ success: false, message: 'Failed to create product' });
  }
  return res.status(201).json({ success: true, message: 'Created', data });
});

router.get('/getallproducts/', requireAuth, async (req: Request, res: Response) => {
  const userId = uid(req);
  console.log('Fetching products for user:', userId);
  
  // Return only the authenticated user's products
  const { data: products, error } = await supabase
    .from('products')
    .select('*')
    .eq('user_id', userId)
    .order('id', { ascending: false });
    
  if (error) {
    console.error('Error fetching products:', error);
    return res.json({ success: true, message: 'OK', data: [] });
  }
  
  console.log(`Found ${products?.length || 0} products for user ${userId}`);
  
  // Fetch all categories to map IDs to names
  const { data: categories } = await supabase
    .from('categories')
    .select('id, name');
  
  const categoryMap = new Map((categories || []).map((cat: any) => [Number(cat.id), cat.name]));
  
  // Map the data to include category name as a string and convert prices to strings
  const mappedData = (products || []).map((product: any) => {
    const categoryName = product.category_id ? (categoryMap.get(Number(product.category_id)) || '') : '';
    return {
      id: product.id,
      user_id: product.user_id,
      category_id: product.category_id,
      category: categoryName,
      title: product.title || '',
      min_price: String(product.min_price ?? 0),
      max_price: String(product.max_price ?? 0),
      image: product.image || '',
      images: product.images || [],
      product_condition: product.product_condition || '',
      status: product.status || 'active',
      created_at: product.created_at,
      updated_at: product.updated_at,
    };
  });
  
  console.log(`Returning ${mappedData.length} mapped products`);
  return res.json({ success: true, message: 'OK', data: mappedData });
});

router.post('/update_products/', requireAuth, upload.any(), async (req: Request, res: Response) => {
  try {
    const userId = uid(req);
    const body: any = req.body || {};
    const files = ((req as any).files as Express.Multer.File[]) || [];
    const productId = Number(body.product_id || body.id || 0);
    
    if (!productId) {
      return res.status(400).json({ success: false, message: 'product_id is required' });
    }
    
    // Verify the product belongs to the user
    const { data: existingProduct, error: fetchError } = await supabase
      .from('products')
      .select('*')
      .eq('id', productId)
      .eq('user_id', userId)
      .maybeSingle();
    
    if (fetchError || !existingProduct) {
      return res.status(404).json({ success: false, message: 'Product not found or access denied' });
    }
    
    // Process uploaded files (new images)
    let primaryImageUrl = '';
    const imageUrls: string[] = [];
    
    // Extract primary image (fieldname: 'image')
    const primaryFile = files.find(f => f.fieldname === 'image');
    if (primaryFile) {
      primaryImageUrl = `data:${primaryFile.mimetype};base64,${primaryFile.buffer.toString('base64')}`;
      imageUrls.push(primaryImageUrl);
    }
    
    // Extract additional images (fieldname: 'images')
    const additionalFiles = files.filter(f => f.fieldname === 'images');
    for (const file of additionalFiles) {
      const imageUrl = `data:${file.mimetype};base64,${file.buffer.toString('base64')}`;
      if (!imageUrls.includes(imageUrl)) {
        imageUrls.push(imageUrl);
      }
    }
    
    // Handle existing images from body (if provided as URLs/base64 strings)
    // Multer parses arrays as strings, so we need to parse it
    let existingImagesArray: string[] = [];
    if (body.existing_images) {
      try {
        // If it's a string (JSON array), parse it
        if (typeof body.existing_images === 'string') {
          existingImagesArray = JSON.parse(body.existing_images);
        } else if (Array.isArray(body.existing_images)) {
          existingImagesArray = body.existing_images;
        }
      } catch (e) {
        console.error('Error parsing existing_images:', e);
        // If parsing fails, try to use it as a single string
        if (typeof body.existing_images === 'string' && body.existing_images.trim()) {
          existingImagesArray = [body.existing_images];
        }
      }
    }
    
    // Add existing images to the array
    for (const imgUrl of existingImagesArray) {
      if (typeof imgUrl === 'string' && imgUrl.trim() && !imageUrls.includes(imgUrl)) {
        imageUrls.push(imgUrl);
      }
    }
    
    // If no new files but existing_images provided, use those
    if (imageUrls.length === 0 && existingImagesArray.length > 0) {
      imageUrls.push(...existingImagesArray.filter((img: any) => typeof img === 'string' && img.trim()));
    }
    
    // If no images provided at all, keep existing images from database
    if (imageUrls.length === 0 && !primaryImageUrl) {
      primaryImageUrl = existingProduct.image || '';
      if (existingProduct.images && Array.isArray(existingProduct.images)) {
        imageUrls.push(...existingProduct.images);
      } else if (existingProduct.image) {
        imageUrls.push(existingProduct.image);
      }
    } else if (primaryImageUrl && imageUrls.length === 0) {
      // If only primary image provided, use it
      imageUrls.push(primaryImageUrl);
    } else if (!primaryImageUrl && imageUrls.length > 0) {
      // If only additional images provided, use first as primary
      primaryImageUrl = imageUrls[0];
    }
    
    // Handle category - can be ID (number) or name (string)
    let categoryId: number | null = existingProduct.category_id;
    if (body.category_id !== undefined) {
      categoryId = typeof body.category_id === 'string' ? parseFloat(body.category_id) || null : body.category_id;
    } else if (body.category) {
      if (typeof body.category === 'string') {
        const { data: categoryData } = await supabase
          .from('categories')
          .select('id')
          .ilike('name', body.category)
          .maybeSingle();
        if (categoryData) {
          categoryId = Number(categoryData.id);
        }
      } else if (typeof body.category === 'number') {
        categoryId = body.category;
      }
    }
    
    const updateData: any = {
      category_id: categoryId,
      title: body.title !== undefined ? body.title : existingProduct.title,
      min_price: body.min_price !== undefined 
        ? (typeof body.min_price === 'string' ? parseFloat(body.min_price) || parseFloat(body.minPrice || '0') : (body.min_price ?? body.minPrice ?? existingProduct.min_price))
        : existingProduct.min_price,
      max_price: body.max_price !== undefined
        ? (typeof body.max_price === 'string' ? parseFloat(body.max_price) || parseFloat(body.maxPrice || '0') : (body.max_price ?? body.maxPrice ?? existingProduct.max_price))
        : existingProduct.max_price,
      product_condition: body.product_condition !== undefined ? body.product_condition : existingProduct.product_condition,
      status: body.status !== undefined ? body.status : existingProduct.status,
    };
    
    // Update images only if new files were provided or existing_images were explicitly set
    if (primaryImageUrl || existingImagesArray.length > 0 || files.length > 0) {
      updateData.image = primaryImageUrl || existingProduct.image || '';
      updateData.images = imageUrls.length > 0 ? imageUrls : (existingProduct.images || []);
    }
    
    const { data, error } = await supabase
      .from('products')
      .update(updateData)
      .eq('id', productId)
      .eq('user_id', userId)
      .select('*')
      .maybeSingle();
    
    if (error) {
      console.error('Error updating product:', error);
      return res.status(500).json({ success: false, message: 'Failed to update product', error: error.message });
    }
    if (!data) {
      return res.status(500).json({ success: false, message: 'Failed to update product' });
    }
    
    return res.json({ success: true, message: 'Updated', data });
  } catch (error: any) {
    console.error('Unexpected error in update_products:', error);
    return res.status(500).json({ success: false, message: 'Internal server error', error: error?.message || String(error) });
  }
});

router.delete('/delete_products/', requireAuth, async (req: Request, res: Response) => {
  const productId = Number((req.query.id || req.body?.id) ?? 0);
  if (!productId) return res.status(400).json({ success: false, message: 'id is required' });
  const { error } = await supabase.from('products').delete().eq('id', productId);
  if (error) return res.status(500).json({ success: false, message: 'Failed to delete product' });
  return res.json({ success: true, message: 'Deleted' });
});

// ---------- Trade Preferences ----------
router.post('/api/trade/preferences/', requireAuth, async (req: Request, res: Response) => {
  const userId = uid(req);
  const tradeRadius = String(req.body?.trade_radius ?? req.body?.tradeRadius ?? '');
  const interests = Array.isArray(req.body?.interests) ? req.body.interests : [];

  // Upsert preference row
  await supabase.from('trade_preferences').upsert({ user_id: userId, trade_radius: tradeRadius });

  // Replace interests join if available
  if (interests.length) {
    await supabase.from('trade_preference_interests').delete().eq('user_id', userId);
    await supabase.from('trade_preference_interests').insert(
      interests.map((i: any) => ({ user_id: userId, interest_id: Number(i.id ?? i) }))
    );
  }

  return res.json({ success: true, message: 'Saved' });
});

router.get('/api/trade/getuserpreferences/', requireAuth, async (req: Request, res: Response) => {
  const userId = uid(req);
  const pref = await supabase.from('trade_preferences').select('trade_radius').eq('user_id', userId).maybeSingle();
  const ints = await supabase
    .from('trade_preference_interests')
    .select('interest_id, interests(name)')
    .eq('user_id', userId);

  const interests = (ints.data || []).map((r: any) => ({ id: r.interest_id, interest_name: r.interests?.name || '' }));
  return res.json({
    success: true,
    message: 'OK',
    trade_radius: (pref.data as any)?.trade_radius ?? '',
    interests,
  });
});

// ---------- Matching / Feedback / Trades (minimal compatible shapes) ----------
router.get('/api/trade/api/nearby-users/', requireAuth, async (req: Request, res: Response) => {
  // Minimal response compatible with MatchProductResponseModel
  return res.json({
    success: true,
    message: 'OK',
    matching_products: [],
  });
});

router.post('/api/trade/create-matchfeedback/', requireAuth, async (_req: Request, res: Response) => {
  return res.json({ success: true, message: 'OK' });
});

router.get('/api/trade/matchfeedback/user/', requireAuth, async (req: Request, res: Response) => {
  const userId = uid(req);
  const { data, error } = await supabase
    .from('match_feedback')
    .select('*, user_product:products!user_product_id_fkey(*), other_product:products!other_product_id_fkey(*)')
    .eq('user_id', userId);
  if (error) return res.json({ success: true, message: 'OK', data: [] });
  return res.json({ success: true, message: 'OK', data: data || [] });
});

router.get('/api/trade/trade-requests/', requireAuth, async (_req: Request, res: Response) => {
  return res.json({ success: true, message: 'OK', data: [] });
});

router.post('/api/trade/trade-requests/create/', requireAuth, async (_req: Request, res: Response) => {
  return res.status(201).json({ success: true, message: 'Created' });
});

router.post('/api/trade/accept-requests/', requireAuth, async (_req: Request, res: Response) => {
  return res.json({ success: true, message: 'OK' });
});

router.post('/api/trade/trade_payment_status/', requireAuth, async (_req: Request, res: Response) => {
  return res.json({ success: true, message: 'OK' });
});

// Trader public profile placeholder
router.get('/api/user/profile/', async (_req: Request, res: Response) => {
  return res.json({ success: true, message: 'OK', data: null });
});

export default router;

