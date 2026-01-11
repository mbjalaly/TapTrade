// @ts-ignore - Module resolution in sandbox environment
import { Router } from 'express';
// @ts-ignore - Module resolution in sandbox environment
import bcrypt from 'bcryptjs';
// @ts-ignore - Module resolution in sandbox environment
import multer from 'multer';
// @ts-ignore - Module resolution in sandbox environment
import { z } from 'zod';
import supabase from '../services/supabaseClient';
import { ok } from '../utils/respond';
import { requireAuth, signUserToken } from '../utils/jwt';
import { logger } from '../utils/logger';
// @ts-ignore - Module resolution in sandbox environment
import type { Request, Response } from 'express';

// Extend Request type with userId
// @ts-ignore - Module augmentation in sandbox environment
declare module 'express-serve-static-core' {
  interface Request {
    userId?: string;
  }
}

// Type alias for multer file
type MulterFile = {
  fieldname: string;
  originalname: string;
  encoding: string;
  mimetype: string;
  buffer: any; // Buffer type - using any to avoid @types/node dependency in linter
  size: number;
};

const router = Router();
const upload = multer({ 
  storage: multer.memoryStorage(),
  limits: {
    fieldSize: 50 * 1024 * 1024, // 50MB for fields (to handle large base64 image arrays)
    fileSize: 10 * 1024 * 1024, // 10MB per file
    fields: 50, // Maximum number of non-file fields
    files: 20, // Maximum number of file fields
  }
});

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
    await logger.error('User registration failed', undefined, { 
      error: (error as any)?.message || 'unknown',
      username 
    });
    return res.status(500).json({ success: false, message: 'Failed to register', error: (error as any)?.message || 'unknown' });
  }

  const token = signUserToken({ sub: String(user.id), username: user.username });
  await logger.success('New user registered', String(user.id), { username: user.username });
  return res.status(201).json({ success: true, message: 'Registered', token, data: user });
});

// ---------- Email OTP System ----------
// In-memory OTP storage (for production, use Redis or database)
const otpStore: Map<string, { otp: string; expiresAt: number; attempts: number }> = new Map();

// Generate a 6-digit OTP
function generateOtp(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Clean up expired OTPs periodically
setInterval(() => {
  const now = Date.now();
  for (const [email, data] of otpStore.entries()) {
    if (data.expiresAt < now) {
      otpStore.delete(email);
    }
  }
}, 60000); // Clean every minute

// Send OTP to email
router.post('/api/email/send-otp/', async (req: Request, res: Response) => {
  try {
    const { email } = req.body;
    
    if (!email || typeof email !== 'string') {
      return res.status(400).json({ success: false, message: 'Email is required' });
    }
    
    // Validate email format
    const emailRegex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({ success: false, message: 'Invalid email format' });
    }
    
    // Check rate limiting (max 3 OTPs per 5 minutes)
    const existingOtp = otpStore.get(email.toLowerCase());
    if (existingOtp && existingOtp.attempts >= 3) {
      const remainingTime = Math.ceil((existingOtp.expiresAt - Date.now()) / 1000);
      if (remainingTime > 0) {
        return res.status(429).json({ 
          success: false, 
          message: `Too many attempts. Please wait ${remainingTime} seconds.` 
        });
      }
    }
    
    // Generate OTP
    const otp = generateOtp();
    const expiresAt = Date.now() + 5 * 60 * 1000; // 5 minutes
    
    // Store OTP
    otpStore.set(email.toLowerCase(), {
      otp,
      expiresAt,
      attempts: (existingOtp?.attempts || 0) + 1,
    });
    
    // TODO: In production, send actual email using nodemailer or similar
    // For now, log the OTP (in development) and simulate email sent
    console.log(`[Email OTP] Sending OTP ${otp} to ${email}`);
    await logger.info('Email OTP sent', undefined, { email, otp_preview: `${otp.substring(0, 2)}****` });
    
    // In development mode, include the OTP in response for testing
    // REMOVE THIS IN PRODUCTION!
    const isDevelopment = process.env.NODE_ENV !== 'production';
    
    return res.json({ 
      success: true, 
      message: 'OTP sent to your email',
      ...(isDevelopment && { otp }) // Only include OTP in development
    });
  } catch (error: any) {
    await logger.error('Failed to send email OTP', undefined, { error: error?.message });
    return res.status(500).json({ success: false, message: 'Failed to send OTP' });
  }
});

// Verify email OTP
router.post('/api/email/verify-otp/', async (req: Request, res: Response) => {
  try {
    const { email, otp } = req.body;
    
    if (!email || !otp) {
      return res.status(400).json({ success: false, message: 'Email and OTP are required' });
    }
    
    const storedData = otpStore.get(email.toLowerCase());
    
    if (!storedData) {
      return res.status(400).json({ success: false, message: 'OTP expired or not found. Please request a new one.' });
    }
    
    if (storedData.expiresAt < Date.now()) {
      otpStore.delete(email.toLowerCase());
      return res.status(400).json({ success: false, message: 'OTP has expired. Please request a new one.' });
    }
    
    if (storedData.otp !== otp) {
      return res.status(400).json({ success: false, message: 'Invalid OTP. Please try again.' });
    }
    
    // OTP verified - delete it
    otpStore.delete(email.toLowerCase());
    
    await logger.success('Email OTP verified', undefined, { email });
    
    return res.json({ 
      success: true, 
      message: 'Email verified successfully',
      email_verified: true 
    });
  } catch (error: any) {
    await logger.error('Failed to verify email OTP', undefined, { error: error?.message });
    return res.status(500).json({ success: false, message: 'Failed to verify OTP' });
  }
});

const loginBody = z.object({
  username: z.string().min(1).optional(),
  email: z.string().email().optional(),
  password: z.string().min(1),
}).refine((data: { username?: string; email?: string; password: string }) => data.username || data.email, {
  message: "Either username or email is required",
  path: ["username"],
});

router.post('/api/user/login/', async (req: Request, res: Response) => {
  const parsed = loginBody.safeParse(req.body);
  if (!parsed.success) {
    await logger.warning('Invalid login payload', undefined, { errors: parsed.error.flatten() });
    return res.status(400).json({ success: false, message: 'Invalid payload', errors: parsed.error.flatten() });
  }

  const { username, email, password } = parsed.data;

  // Build query - check username or email
  let query = supabase.from('users').select('*');
  
  if (username) {
    query = query.ilike('username', username);
  } else if (email) {
    query = query.ilike('email', email);
  }

  const { data: user, error } = await query.maybeSingle();

  if (error || !user) {
    await logger.warning('Login failed - user not found', undefined, { username: username || email });
    return res.status(401).json({ success: false, message: 'Invalid credentials' });
  }

  const okPass = bcrypt.compareSync(password, String((user as any).password_hash || ''));
  if (!okPass) {
    await logger.warning('Login failed - invalid password', String(user.id), { username: user.username });
    return res.status(401).json({ success: false, message: 'Invalid credentials' });
  }

  const token = signUserToken({ sub: String(user.id), username: user.username });
  await logger.success('User logged in successfully', String(user.id), { username: user.username });
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
    const file = (req as any).file as MulterFile;
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
  const files = ((req as any).files as MulterFile[]) || [];
  
  await logger.info('Product creation request', userId, {
    title: body.title,
    category: body.category,
    files_count: files.length,
  });

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
  
  // Limit total images to 4 (including primary)
  const MAX_IMAGES = 4;
  if (imageUrls.length > MAX_IMAGES) {
    imageUrls.splice(MAX_IMAGES);
    await logger.warning('Images limited to maximum of 4', userId, { 
      attempted_count: imageUrls.length,
      limited_to: MAX_IMAGES 
    });
  }
  
  // Also check images from body if provided
  let finalImages = imageUrls.length > 0 ? imageUrls : (body.images || []);
  if (finalImages.length > MAX_IMAGES) {
    finalImages = finalImages.slice(0, MAX_IMAGES);
    await logger.warning('Images from body limited to maximum of 4', userId, { 
      limited_to: MAX_IMAGES 
    });
  }

  // Validate min_price < max_price
  const minPrice = typeof body.min_price === 'string' ? parseFloat(body.min_price) || parseFloat(body.minPrice || '0') : (body.min_price ?? body.minPrice ?? 0);
  const maxPrice = typeof body.max_price === 'string' ? parseFloat(body.max_price) || parseFloat(body.maxPrice || '0') : (body.max_price ?? body.maxPrice ?? 0);
  
  if (minPrice >= maxPrice) {
    await logger.warning('Invalid price range - min_price must be less than max_price', userId, {
      min_price: minPrice,
      max_price: maxPrice,
    });
    return res.status(400).json({ 
      success: false, 
      message: 'Minimum price must be less than maximum price' 
    });
  }

  const insertData: any = {
    user_id: userId,
    category_id: categoryId,
    title: body.title ?? '',
    min_price: minPrice,
    max_price: maxPrice,
    product_condition: body.product_condition ?? body.productCondition ?? '',
    status: body.status ?? 'active',
    image: primaryImageUrl || body.image || '',
    images: finalImages,
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
  const files = ((req as any).files as MulterFile[]) || [];

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
  
  // Limit total images to 4 (including primary)
  const MAX_IMAGES = 4;
  if (imageUrls.length > MAX_IMAGES) {
    imageUrls.splice(MAX_IMAGES);
    await logger.warning('Images limited to maximum of 4', userId, { 
      attempted_count: imageUrls.length,
      limited_to: MAX_IMAGES 
    });
  }
  
  // Also check images from body if provided
  let finalImages = imageUrls.length > 0 ? imageUrls : (body.images || []);
  if (finalImages.length > MAX_IMAGES) {
    finalImages = finalImages.slice(0, MAX_IMAGES);
    await logger.warning('Images from body limited to maximum of 4', userId, { 
      limited_to: MAX_IMAGES 
    });
  }

  // Validate min_price < max_price
  const minPrice = typeof body.min_price === 'string' ? parseFloat(body.min_price) || parseFloat(body.minPrice || '0') : (body.min_price ?? body.minPrice ?? 0);
  const maxPrice = typeof body.max_price === 'string' ? parseFloat(body.max_price) || parseFloat(body.maxPrice || '0') : (body.max_price ?? body.maxPrice ?? 0);
  
  if (minPrice >= maxPrice) {
    await logger.warning('Invalid price range - min_price must be less than max_price', userId, {
      min_price: minPrice,
      max_price: maxPrice,
    });
    return res.status(400).json({ 
      success: false, 
      message: 'Minimum price must be less than maximum price' 
    });
  }

  const insertData: any = {
    user_id: userId,
    category_id: categoryId,
    title: body.title ?? '',
    min_price: minPrice,
    max_price: maxPrice,
    product_condition: body.product_condition ?? body.productCondition ?? '',
    status: body.status ?? 'active',
    image: primaryImageUrl || body.image || '',
    images: finalImages,
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
  await logger.info('Fetching user products', userId);
  
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
    const files = ((req as any).files as MulterFile[]) || [];
    
    await logger.info('Product update request initiated', userId || undefined, {
      product_id: body.product_id || body.id,
      files_count: files.length,
      method: req.method,
      path: req.path,
    });
    
    const productId = Number(body.product_id || body.id || req.query.id || 0);
    
    if (!productId || isNaN(productId)) {
      await logger.error('Invalid product ID in update request', userId || undefined, { product_id: productId });
      return res.status(400).json({ success: false, message: 'product_id is required and must be a valid number' });
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
    
    // Limit total images to 4 (including primary)
    const MAX_IMAGES = 4;
    if (imageUrls.length > MAX_IMAGES) {
      imageUrls.splice(MAX_IMAGES);
      await logger.warning('Images limited to maximum of 4', userId || undefined, { 
        attempted_count: imageUrls.length,
        limited_to: MAX_IMAGES 
      });
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
    
    // Validate min_price < max_price
    const minPrice = body.min_price !== undefined 
      ? (typeof body.min_price === 'string' ? parseFloat(body.min_price) || parseFloat(body.minPrice || '0') : (body.min_price ?? body.minPrice ?? existingProduct.min_price))
      : existingProduct.min_price;
    const maxPrice = body.max_price !== undefined
      ? (typeof body.max_price === 'string' ? parseFloat(body.max_price) || parseFloat(body.maxPrice || '0') : (body.max_price ?? body.maxPrice ?? existingProduct.max_price))
      : existingProduct.max_price;
    
    if (minPrice >= maxPrice) {
      await logger.warning('Invalid price range - min_price must be less than max_price', userId || undefined, {
        min_price: minPrice,
        max_price: maxPrice,
        product_id: productId,
      });
      return res.status(400).json({ 
        success: false, 
        message: 'Minimum price must be less than maximum price' 
      });
    }
    
    const updateData: any = {
      category_id: categoryId,
      title: body.title !== undefined ? body.title : existingProduct.title,
      min_price: minPrice,
      max_price: maxPrice,
      product_condition: body.product_condition !== undefined ? body.product_condition : existingProduct.product_condition,
      status: body.status !== undefined ? body.status : existingProduct.status,
    };
    
    // Optimize image updates: Only update if images have actually changed
    // This prevents timeouts when re-writing large base64 arrays
    const hasNewFiles = files.length > 0;
    const existingDbImages = existingProduct.images && Array.isArray(existingProduct.images) 
      ? existingProduct.images 
      : (existingProduct.image ? [existingProduct.image] : []);
    
    // Only update images if:
    // 1. We have new files (need to add them)
    // 2. User explicitly provided existing_images AND they're different from DB
    // 3. Primary image changed
    if (hasNewFiles) {
      // New files provided - update images array
      if (primaryImageUrl) {
        updateData.image = primaryImageUrl;
      }
      if (imageUrls.length > 0) {
        updateData.images = imageUrls;
      }
    } else if (existingImagesArray.length > 0) {
      // User explicitly provided existing_images - check if different from DB
      const existingSet = new Set(existingDbImages.map((img: string) => img.substring(0, 100))); // Compare first 100 chars
      const newSet = new Set(existingImagesArray.map((img: string) => img.substring(0, 100)));
      const isDifferent = existingSet.size !== newSet.size || 
        !existingImagesArray.every((img: string) => {
          const prefix = img.substring(0, 100);
          return Array.from(existingSet).some(existing => existing === prefix);
        });
      
      if (isDifferent) {
        updateData.images = existingImagesArray;
        if (existingImagesArray.length > 0 && !primaryImageUrl) {
          updateData.image = existingImagesArray[0];
        }
      }
    } else if (primaryImageUrl && primaryImageUrl !== existingProduct.image) {
      // Only primary image changed
      updateData.image = primaryImageUrl;
      // Keep existing images array
      if (existingDbImages.length > 0) {
        updateData.images = existingDbImages;
      }
    }
    
    // Optimize: Only update fields that have actually changed
    // Remove undefined/null values to avoid unnecessary updates
    Object.keys(updateData).forEach(key => {
      if (updateData[key] === undefined || updateData[key] === null) {
        delete updateData[key];
      }
    });
    
    // If no actual changes, return existing product
    if (Object.keys(updateData).length === 0) {
      await logger.info('No changes detected in product update', userId || undefined, { product_id: productId });
      return res.json({ success: true, message: 'No changes', data: existingProduct });
    }
    
    // Perform the update with timeout handling
    let data: any = null;
    let error: any = null;
    
    try {
      const result = await supabase
        .from('products')
        .update(updateData)
        .eq('id', productId)
        .eq('user_id', userId)
        .select('*')
        .maybeSingle();
      
      data = result.data;
      error = result.error;
    } catch (updateError: any) {
      // Handle timeout or other errors
      const errorMessage = updateError?.message || String(updateError);
      if (errorMessage.includes('timeout') || errorMessage.includes('canceling statement')) {
        await logger.error('Product update timed out - likely due to large image data', userId || undefined, {
          product_id: productId,
          images_count: imageUrls.length,
          error: errorMessage,
        });
        return res.status(500).json({ 
          success: false, 
          message: 'Update timed out. The images may be too large. Try reducing the number of images or image sizes.',
          error: 'Database operation timeout'
        });
      }
      error = updateError;
    }
    
    if (error) {
      await logger.error('Failed to update product in database', userId || undefined, { 
        product_id: productId, 
        error: error.message 
      });
      return res.status(500).json({ success: false, message: 'Failed to update product', error: error.message });
    }
    if (!data) {
      await logger.error('Product update returned no data', userId || undefined, { product_id: productId });
      return res.status(500).json({ success: false, message: 'Failed to update product' });
    }
    
    await logger.success('Product updated successfully', userId || undefined, { 
      product_id: data.id, 
      title: data.title 
    });
    return res.json({ success: true, message: 'Updated', data });
  } catch (error: any) {
    const userId = uid(req);
    await logger.error('Unexpected error in update_products', userId || undefined, { 
      error: error?.message || String(error),
      stack: error?.stack 
    });
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

// Test endpoint for logging (for debugging)
router.get('/test-logging/', async (req: Request, res: Response) => {
  try {
    console.log('[Test-Logging] Starting test...');
    
    // Test write operations
    const writeResults = [];
    writeResults.push(await logger.info('Test log entry', undefined, { test: true, timestamp: new Date().toISOString() }));
    writeResults.push(await logger.warning('Test warning log', undefined, { test: true }));
    writeResults.push(await logger.error('Test error log', undefined, { test: true }));
    writeResults.push(await logger.success('Test success log', undefined, { test: true }));
    
    // Wait a bit for writes to complete
    await new Promise(resolve => setTimeout(resolve, 500));
    
    // Try to read logs to verify they were written
    console.log('[Test-Logging] Attempting to read logs...');
    const { data: logs, error: readError } = await supabase
      .from('logs')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(10);
    
    // Check table existence
    const { error: tableCheckError } = await supabase
      .from('logs')
      .select('id')
      .limit(1);
    
    if (readError || tableCheckError) {
      const error = readError || tableCheckError;
      console.error('[Test-Logging] Error:', error);
      return res.status(500).json({ 
        success: false, 
        message: 'Failed to access logs table',
        error: error?.message,
        code: error?.code,
        hint: error?.hint,
        details: error?.details,
        troubleshooting: {
          step1: 'Run CREATE_LOGS_TABLE.sql in Supabase SQL Editor',
          step2: 'Verify SUPABASE_SERVICE_ROLE_KEY is set correctly',
          step3: 'Check RLS policies allow service_role to insert/select',
          step4: 'Check backend console for [Logger] error messages'
        }
      });
    }
    
    // Filter test logs
    const testLogs = (logs || []).filter((log: any) => 
      log.message?.includes('Test') || 
      (log.metadata && typeof log.metadata === 'object' && (log.metadata as any).test === true)
    );
    
    return res.json({ 
      success: true, 
      message: 'Test logs created',
      logsWritten: 4,
      logsFound: logs?.length || 0,
      testLogsFound: testLogs.length,
      recentLogs: testLogs.slice(0, 5),
      allRecentLogs: (logs || []).slice(0, 5),
      tableExists: true,
      note: 'Check backend console for [Logger] messages to see if writes succeeded'
    });
  } catch (error: any) {
    console.error('[Test-Logging] Exception:', error);
    return res.status(500).json({ 
      success: false, 
      message: 'Error testing logs',
      error: error?.message || String(error),
      stack: error?.stack
    });
  }
});

export default router;

