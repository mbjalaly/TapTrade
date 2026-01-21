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
import { uploadImageToStorage } from '../utils/imageUpload';
import {
  sendMatchNotification,
  sendMessageNotification,
  sendTradeCompletedNotification,
  sendTradeConfirmationNeededNotification
} from '../services/pushNotificationService';
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
  console.log('Profile update body:', JSON.stringify(body));
  const update: any = {};
  const allowed = [
    'email', 'username', 'contact', 'full_name', 'address',
    'longitude', 'latitude', 'dob', 'gender', 'is_profile_completed',
    'fcm_token', // For push notifications
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

  if (error || !user) {
    console.error('Update profile error:', error);
    return res.status(500).json({ success: false, message: 'Failed to update profile', error });
  }
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

  // Process uploaded files - upload to Supabase Storage
  // First file with fieldname 'image' is the primary image
  // All files with fieldname 'images' are additional images
  let primaryImageUrl = '';
  const imageUrls: string[] = [];

  try {
    // Extract primary image (fieldname: 'image')
    const primaryFile = files.find(f => f.fieldname === 'image');
    if (primaryFile) {
      primaryImageUrl = await uploadImageToStorage(primaryFile.buffer, primaryFile.mimetype, 'products');
      imageUrls.push(primaryImageUrl);
    }

    // Extract additional images (fieldname: 'images')
    const additionalFiles = files.filter(f => f.fieldname === 'images');
    for (const file of additionalFiles) {
      const imageUrl = await uploadImageToStorage(file.buffer, file.mimetype, 'products');
      if (!imageUrls.includes(imageUrl)) { // Avoid duplicates
        imageUrls.push(imageUrl);
      }
    }
  } catch (uploadError: any) {
    console.error('Image upload error:', uploadError);
    return res.status(500).json({
      success: false,
      message: 'Failed to upload images',
      error: uploadError.message
    });
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

  // Process uploaded files - upload to Supabase Storage
  let primaryImageUrl = '';
  const imageUrls: string[] = [];

  try {
    // Extract primary image (fieldname: 'image')
    const primaryFile = files.find(f => f.fieldname === 'image');
    if (primaryFile) {
      primaryImageUrl = await uploadImageToStorage(primaryFile.buffer, primaryFile.mimetype, 'products');
      imageUrls.push(primaryImageUrl);
    }

    // Extract additional images (fieldname: 'images')
    const additionalFiles = files.filter(f => f.fieldname === 'images');
    for (const file of additionalFiles) {
      const imageUrl = await uploadImageToStorage(file.buffer, file.mimetype, 'products');
      if (!imageUrls.includes(imageUrl)) { // Avoid duplicates
        imageUrls.push(imageUrl);
      }
    }
  } catch (uploadError: any) {
    console.error('Image upload error:', uploadError);
    return res.status(500).json({
      success: false,
      message: 'Failed to upload images',
      error: uploadError.message
    });
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

    // Process uploaded files (new images) - upload to Supabase Storage
    let primaryImageUrl = '';
    const imageUrls: string[] = [];

    try {
      // Extract primary image (fieldname: 'image')
      const primaryFile = files.find(f => f.fieldname === 'image');
      if (primaryFile) {
        primaryImageUrl = await uploadImageToStorage(primaryFile.buffer, primaryFile.mimetype, 'products');
        imageUrls.push(primaryImageUrl);
      }

      // Extract additional images (fieldname: 'images')
      const additionalFiles = files.filter(f => f.fieldname === 'images');
      for (const file of additionalFiles) {
        const imageUrl = await uploadImageToStorage(file.buffer, file.mimetype, 'products');
        if (!imageUrls.includes(imageUrl)) {
          imageUrls.push(imageUrl);
        }
      }
    } catch (uploadError: any) {
      console.error('Image upload error:', uploadError);
      return res.status(500).json({
        success: false,
        message: 'Failed to upload images',
        error: uploadError.message
      });
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
  const userId = uid(req);
  const includeInteracted = req.query.include_interacted === 'true'; // Query param to include already-liked products

  try {
    // Get current user's info (location and trade radius)
    const { data: currentUser } = await supabase
      .from('users')
      .select('latitude, longitude')
      .eq('id', userId)
      .maybeSingle();

    if (!currentUser || !currentUser.latitude || !currentUser.longitude) {
      return res.json({
        success: true,
        message: 'User location not set',
        matching_products: [],
      });
    }

    // Get current user's trade radius preference
    const { data: tradePreference } = await supabase
      .from('trade_preferences')
      .select('trade_radius')
      .eq('user_id', userId)
      .maybeSingle();

    const tradeRadiusKm = tradePreference?.trade_radius
      ? parseFloat(tradePreference.trade_radius)
      : 50; // Default 50km

    // Get current user's products
    const { data: userProducts } = await supabase
      .from('products')
      .select('*')
      .eq('user_id', userId)
      .eq('status', 'active');

    if (!userProducts || userProducts.length === 0) {
      return res.json({
        success: true,
        message: 'No products found',
        matching_products: [],
      });
    }

    // Get user's existing feedback to filter out already-interacted products
    const { data: existingFeedback } = await supabase
      .from('match_feedback')
      .select('user_product_id, other_product_id, has_like, has_dislike')
      .eq('user_id', userId);

    // Create sets of interacted product pairs
    const likedPairs = new Set<string>(); // Products user liked (can show again)
    const dislikedPairs = new Set<string>(); // Products user disliked (don't show)
    if (existingFeedback) {
      for (const feedback of existingFeedback) {
        const pairKey = `${feedback.user_product_id}-${feedback.other_product_id}`;
        if (feedback.has_like) {
          likedPairs.add(pairKey);
        }
        if (feedback.has_dislike) {
          dislikedPairs.add(pairKey);
        }
      }
    }

    // Get all other users' products with user location info
    const { data: otherProducts } = await supabase
      .from('products')
      .select('*, users!inner(id, username, latitude, longitude)')
      .neq('user_id', userId)
      .eq('status', 'active');

    if (!otherProducts || otherProducts.length === 0) {
      return res.json({
        success: true,
        message: 'No nearby products found',
        matching_products: [],
      });
    }

    // Helper function to calculate distance using Haversine formula
    function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
      const R = 6371; // Earth's radius in km
      const dLat = (lat2 - lat1) * Math.PI / 180;
      const dLon = (lon2 - lon1) * Math.PI / 180;
      const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
      const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
      return R * c; // Distance in km
    }

    // Build matching products array
    const matchingProducts: any[] = [];
    const alreadyLikedProducts: any[] = []; // Products user already liked (for fallback)
    let skippedDisliked = 0;

    for (const userProduct of userProducts) {
      for (const otherProduct of otherProducts) {
        const otherUser = (otherProduct as any).users;

        // Skip if other user doesn't have location
        if (!otherUser || !otherUser.latitude || !otherUser.longitude) {
          continue;
        }

        // Calculate distance
        const distance = calculateDistance(
          parseFloat(currentUser.latitude),
          parseFloat(currentUser.longitude),
          parseFloat(otherUser.latitude),
          parseFloat(otherUser.longitude)
        );

        // Filter by trade radius
        if (distance > tradeRadiusKm) {
          continue;
        }

        const pairKey = `${userProduct.id}-${otherProduct.id}`;
        const wasDisliked = dislikedPairs.has(pairKey);
        const wasLiked = likedPairs.has(pairKey);

        // Always skip disliked products
        if (wasDisliked) {
          skippedDisliked++;
          continue;
        }

        const productData = {
          user_product: {
            id: userProduct.id,
            title: userProduct.title || '',
            min_price: String(userProduct.min_price || '0'),
            max_price: String(userProduct.max_price || '0'),
            image: userProduct.image || '',
            product_condition: userProduct.product_condition || '',
            status: userProduct.status || 'active',
            category: userProduct.category_id || 0,
            user: userProduct.user_id || '',
          },
          other_product: {
            id: otherProduct.id,
            title: otherProduct.title || '',
            min_price: String(otherProduct.min_price || '0'),
            max_price: String(otherProduct.max_price || '0'),
            image: otherProduct.image || '',
            product_condition: otherProduct.product_condition || '',
            status: otherProduct.status || 'active',
            category: otherProduct.category_id || 0,
            user: otherProduct.user_id || '',
          },
          nearby_user: {
            id: otherUser.id || '',
            username: otherUser.username || '',
            latitude: parseFloat(otherUser.latitude) || 0.0,
            longitude: parseFloat(otherUser.longitude) || 0.0,
            trade_radius: String(tradeRadiusKm),
          },
          matching_interest_count: 0,
          already_liked: wasLiked,
        };

        // Separate already-liked products from new products
        if (wasLiked && !includeInteracted) {
          alreadyLikedProducts.push(productData);
        } else {
          matchingProducts.push(productData);
        }
      }
    }

    console.log(`Found ${matchingProducts.length} new products, ${alreadyLikedProducts.length} already liked, ${skippedDisliked} disliked for user ${userId}`);

    return res.json({
      success: true,
      message: 'OK',
      matching_products: matchingProducts,
      already_liked_products: alreadyLikedProducts, // Send liked products separately for fallback
      total_nearby: matchingProducts.length + alreadyLikedProducts.length,
      skipped_disliked: skippedDisliked,
    });
  } catch (error) {
    console.error('Error fetching nearby users:', error);
    return res.json({
      success: true,
      message: 'Error fetching products',
      matching_products: [],
    });
  }
});

router.post('/api/trade/create-matchfeedback/', requireAuth, async (req: Request, res: Response) => {
  const userId = uid(req);
  const body = req.body;

  console.log('=== CREATE MATCH FEEDBACK ===');
  console.log('User ID from token:', userId);
  console.log('Request body:', JSON.stringify(body, null, 2));

  try {
    // Extract fields from request body
    const nearbyUserId = body.nearby_user || body.nearbyUser;
    const userProductId = body.user_product || body.userProduct;
    const nearbyUserProductId = body.nearby_user_product || body.nearbyUserProduct;
    const feedback = body.feedback; // 'like' or 'dislike'
    const hasLike = body.has_like === true || body.hasLike === true || feedback === 'like';
    const hasDislike = body.has_dislike === true || body.hasDislike === true || feedback === 'dislike';

    console.log('Parsed values:', { nearbyUserId, userProductId, nearbyUserProductId, feedback, hasLike, hasDislike });

    // Validate required fields
    if (!nearbyUserId || !userProductId || !nearbyUserProductId || !feedback) {
      console.log('Validation failed - missing fields');
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: nearby_user, user_product, nearby_user_product, feedback'
      });
    }

    // Ensure product IDs are integers
    const userProductIdInt = typeof userProductId === 'number' ? userProductId : parseInt(String(userProductId), 10);
    const nearbyUserProductIdInt = typeof nearbyUserProductId === 'number' ? nearbyUserProductId : parseInt(String(nearbyUserProductId), 10);

    console.log('Parsed product IDs:', { userProductIdInt, nearbyUserProductIdInt });

    // Use upsert to handle both insert and update
    // First, delete any existing feedback for this combination to avoid constraint issues
    const { error: deleteError } = await supabase
      .from('match_feedback')
      .delete()
      .eq('user_id', userId)
      .eq('nearby_user_id', nearbyUserId)
      .eq('user_product_id', userProductIdInt)
      .eq('other_product_id', nearbyUserProductIdInt);

    if (deleteError) {
      console.log('Delete error (may be OK if no existing record):', deleteError);
    }

    // Now insert the new feedback
    const insertData = {
      user_id: userId,
      nearby_user_id: nearbyUserId,
      user_product_id: userProductIdInt,
      other_product_id: nearbyUserProductIdInt,
      has_like: hasLike,
      has_dislike: hasDislike,
    };
    console.log('Insert data:', insertData);

    const { data: feedbackData, error: insertError } = await supabase
      .from('match_feedback')
      .insert(insertData)
      .select()
      .maybeSingle();

    if (insertError) {
      console.error('Error creating match feedback:', insertError);
      console.error('Full error details:', JSON.stringify(insertError, null, 2));
      return res.status(500).json({ success: false, message: 'Failed to save feedback', error: insertError.message });
    }
    console.log('Insert successful:', feedbackData);

    // Check for mutual match if this was a like
    let isMutualMatch = false;
    let mutualMatchData: any = null;

    if (hasLike) {
      // Check if the other user has also liked our product
      // The other user's feedback would have:
      // - user_id = nearbyUserId (the other user)
      // - nearby_user_id = userId (current user)
      // - user_product_id = nearbyUserProductId (their product that we liked)
      // - other_product_id = userProductId (our product)
      const { data: otherFeedback } = await supabase
        .from('match_feedback')
        .select('*')
        .eq('user_id', nearbyUserId)
        .eq('nearby_user_id', userId)
        .eq('user_product_id', nearbyUserProductId)
        .eq('other_product_id', userProductId)
        .eq('has_like', true)
        .maybeSingle();

      if (otherFeedback) {
        isMutualMatch = true;
        mutualMatchData = otherFeedback;
        console.log(`🎉 MUTUAL MATCH DETECTED! User ${userId} and ${nearbyUserId} both liked each other's products`);

        // Auto-create match record
        // Check if match already exists FOR THESE SPECIFIC PRODUCTS
        const { data: existingMatch } = await supabase
          .from('matches')
          .select('*')
          .or(`and(user1_id.eq.${userId},user2_id.eq.${nearbyUserId},user1_product_id.eq.${userProductIdInt},user2_product_id.eq.${nearbyUserProductIdInt}),and(user1_id.eq.${nearbyUserId},user2_id.eq.${userId},user1_product_id.eq.${nearbyUserProductIdInt},user2_product_id.eq.${userProductIdInt})`)
          .maybeSingle();

        if (!existingMatch) {
          // Create new match - insert without joins first
          const { data: newMatch, error: matchError } = await supabase
            .from('matches')
            .insert({
              user1_id: userId,
              user2_id: nearbyUserId,
              user1_product_id: userProductIdInt,
              user2_product_id: nearbyUserProductIdInt,
              status: 'active'
            })
            .select('*')
            .single();

          if (!matchError && newMatch) {
            console.log('Match record created:', newMatch.id);

            // Fetch users separately (no foreign keys needed)
            const { data: users } = await supabase
              .from('users')
              .select('id, username')
              .in('id', [userId, nearbyUserId]);

            // Fetch products separately (no foreign keys needed)
            const { data: products } = await supabase
              .from('products')
              .select('id, title, image, min_price, max_price, product_condition')
              .in('id', [userProductIdInt, nearbyUserProductIdInt]);

            const user1Data = users?.find((u: any) => u.id === userId);
            const user2Data = users?.find((u: any) => u.id === nearbyUserId);
            const product1Data = products?.find((p: any) => p.id === userProductIdInt);
            const product2Data = products?.find((p: any) => p.id === nearbyUserProductIdInt);

            mutualMatchData = {
              ...mutualMatchData,
              match: {
                id: newMatch.id,
                user1_id: newMatch.user1_id,
                user2_id: newMatch.user2_id,
                user1_product_id: newMatch.user1_product_id,
                user2_product_id: newMatch.user2_product_id,
                matched_at: newMatch.matched_at,
                status: newMatch.status,
                my_product: product1Data,
                their_product: product2Data,
                other_user: user2Data
              }
            };
            console.log('✅ Match data built successfully:', JSON.stringify(mutualMatchData, null, 2));

            // Send push notifications to BOTH users about the match
            try {
              // Fetch FCM tokens for both users
              const { data: usersForNotif } = await supabase
                .from('users')
                .select('id, fcm_token')
                .in('id', [userId, nearbyUserId]);

              const currentUserToken = usersForNotif?.find((u: any) => u.id === userId)?.fcm_token;
              const otherUserToken = usersForNotif?.find((u: any) => u.id === nearbyUserId)?.fcm_token;

              // Notify current user about their match
              if (currentUserToken && product2Data) {
                await sendMatchNotification(
                  currentUserToken,
                  product2Data.title || 'a product',
                  newMatch.id
                );
              }

              // Notify the other user about the match
              if (otherUserToken && product1Data) {
                await sendMatchNotification(
                  otherUserToken,
                  product1Data.title || 'a product',
                  newMatch.id
                );
              }
              console.log('[Push] Match notifications sent');
            } catch (notifError) {
              console.log('[Push] Failed to send match notifications:', notifError);
            }
          } else if (matchError) {
            console.error('Error creating match record:', matchError);
          }
        } else {
          console.log('Match already exists:', existingMatch.id);

          // Fetch match record
          const { data: fullMatch } = await supabase
            .from('matches')
            .select('*')
            .eq('id', existingMatch.id)
            .single();

          if (fullMatch) {
            // Fetch users separately
            const { data: users } = await supabase
              .from('users')
              .select('id, username')
              .in('id', [fullMatch.user1_id, fullMatch.user2_id]);

            // Fetch products separately
            const { data: products } = await supabase
              .from('products')
              .select('id, title, image, min_price, max_price, product_condition')
              .in('id', [fullMatch.user1_product_id, fullMatch.user2_product_id]);

            const isUser1 = fullMatch.user1_id === userId;
            const user1Data = users?.find((u: any) => u.id === fullMatch.user1_id);
            const user2Data = users?.find((u: any) => u.id === fullMatch.user2_id);
            const product1Data = products?.find((p: any) => p.id === fullMatch.user1_product_id);
            const product2Data = products?.find((p: any) => p.id === fullMatch.user2_product_id);

            mutualMatchData = {
              ...mutualMatchData,
              match: {
                id: fullMatch.id,
                user1_id: fullMatch.user1_id,
                user2_id: fullMatch.user2_id,
                user1_product_id: fullMatch.user1_product_id,
                user2_product_id: fullMatch.user2_product_id,
                matched_at: fullMatch.matched_at,
                status: fullMatch.status,
                my_product: isUser1 ? product1Data : product2Data,
                their_product: isUser1 ? product2Data : product1Data,
                other_user: isUser1 ? user2Data : user1Data
              }
            };
            console.log('✅ Existing match data built successfully');
          }
        }
      }
    }

    return res.status(201).json({
      success: true,
      message: 'Saved',
      data: feedbackData,
      is_mutual_match: isMutualMatch,
      mutual_match_data: mutualMatchData,
    });
  } catch (error) {
    console.error('Error in create-matchfeedback:', error);
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

router.get('/api/trade/matchfeedback/user/', requireAuth, async (req: Request, res: Response) => {
  const userId = uid(req);

  // Only return products the user LIKED (not dislikes)
  // First, get the match feedback records
  const { data: feedbackData, error: feedbackError } = await supabase
    .from('match_feedback')
    .select('*')
    .eq('user_id', userId)
    .eq('has_like', true);

  if (feedbackError) {
    console.error('Error fetching liked products:', feedbackError);
    return res.json({ success: true, message: 'OK', data: [] });
  }

  if (!feedbackData || feedbackData.length === 0) {
    return res.json({ success: true, message: 'OK', data: [] });
  }

  // Now fetch the products for each feedback item
  const enrichedData = await Promise.all(feedbackData.map(async (item: any) => {
    const [userProductResult, otherProductResult] = await Promise.all([
      supabase.from('products').select('*').eq('id', item.user_product_id).maybeSingle(),
      supabase.from('products').select('*').eq('id', item.other_product_id).maybeSingle(),
    ]);

    return {
      ...item,
      user_product: userProductResult.data,
      other_product: otherProductResult.data,
    };
  }));

  const data = enrichedData;
  const error = null;

  // Transform data to match the Flutter model expectations
  // Flutter LikeData model expects specific field names and formats
  const transformedData = (data || []).map((item: any) => {
    // Transform user_product to match LikeUserProduct model
    const userProduct = item.user_product ? {
      id: item.user_product.id,
      title: item.user_product.title || '',
      min_price: String(item.user_product.min_price || '0'),
      max_price: String(item.user_product.max_price || '0'),
      image: item.user_product.image || '',
      product_condition: item.user_product.product_condition || '',
      status: item.user_product.status || 'active',
      category: item.user_product.category_id || 0,
      user: item.user_product.user_id || '',
    } : null;

    // Transform other_product to match LikeUserProduct model
    // Flutter expects 'nearby_user_product' key
    const otherProduct = item.other_product ? {
      id: item.other_product.id,
      title: item.other_product.title || '',
      min_price: String(item.other_product.min_price || '0'),
      max_price: String(item.other_product.max_price || '0'),
      image: item.other_product.image || '',
      product_condition: item.other_product.product_condition || '',
      status: item.other_product.status || 'active',
      category: item.other_product.category_id || 0,
      user: item.other_product.user_id || '',
    } : null;

    return {
      id: item.id,
      user_id: item.user_id,
      nearby_user_id: item.nearby_user_id,
      user_product_id: item.user_product_id,
      other_product_id: item.other_product_id,
      has_like: item.has_like,
      has_dislike: item.has_dislike,
      feedback: item.has_like ? 'like' : 'dislike',
      created_at: item.created_at,
      updated_at: item.updated_at,
      user_product: userProduct,
      nearby_user_product: otherProduct, // Flutter expects this key name
    };
  });

  console.log(`Found ${transformedData.length} liked products for user ${userId}`);
  return res.json({ success: true, message: 'OK', data: transformedData });
});

// GET /api/trade/trade-requests/:userId/ - Fetch all trade requests for a user
router.get('/api/trade/trade-requests/:userId/', requireAuth, async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;
    const currentUserId = uid(req);

    await logger.info('Fetching trade requests', currentUserId, { userId });

    // Fetch trade requests where user is either requester or receiver
    const { data: tradeRequests, error } = await supabase
      .from('trade_requests')
      .select('*')
      .or(`requester_id.eq.${userId},receiver_id.eq.${userId}`)
      .order('created_at', { ascending: false });

    if (error) {
      await logger.error('Error fetching trade requests', currentUserId, { error: error.message });
      return res.status(500).json({ success: false, message: 'Failed to fetch trade requests' });
    }

    if (!tradeRequests || tradeRequests.length === 0) {
      return res.json({ success: true, message: 'OK', data: [] });
    }

    // Fetch product and user details for each trade request
    const enrichedData = await Promise.all(
      tradeRequests.map(async (trade) => {
        // Fetch user product
        const { data: userProduct } = await supabase
          .from('products')
          .select('id, title, min_price, max_price, image, product_condition, status, category, user_id')
          .eq('id', trade.user_product_id)
          .maybeSingle();

        // Fetch other product
        const { data: otherProduct } = await supabase
          .from('products')
          .select('id, title, min_price, max_price, image, product_condition, status, category, user_id')
          .eq('id', trade.other_product_id)
          .maybeSingle();

        return {
          id: trade.id,
          requester: trade.requester_id,
          receiver: trade.receiver_id,
          user_product: userProduct ? {
            id: userProduct.id,
            title: userProduct.title,
            min_price: userProduct.min_price,
            max_price: userProduct.max_price,
            image: userProduct.image,
            product_condition: userProduct.product_condition,
            status: userProduct.status,
            category: userProduct.category,
            user: userProduct.user_id,
          } : null,
          other_product: otherProduct ? {
            id: otherProduct.id,
            title: otherProduct.title,
            min_price: otherProduct.min_price,
            max_price: otherProduct.max_price,
            image: otherProduct.image,
            product_condition: otherProduct.product_condition,
            status: otherProduct.status,
            category: otherProduct.category,
            user: otherProduct.user_id,
          } : null,
          status: trade.status,
          payment_status: trade.payment_status,
          completed_by_requester: trade.completed_by_requester,
          completed_by_receiver: trade.completed_by_receiver,
          requester_completed_at: trade.requester_completed_at,
          receiver_completed_at: trade.receiver_completed_at,
          created_at: trade.created_at,
          type: 'direct',
        };
      })
    );

    await logger.success('Trade requests fetched successfully', currentUserId, { count: enrichedData.length });
    return res.json({ success: true, message: 'OK', data: enrichedData });
  } catch (error: any) {
    await logger.error('Exception in trade requests fetch', uid(req), { error: error.message });
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// POST /api/trade/trade-requests/create/ - Create a new trade request
router.post('/api/trade/trade-requests/create/', requireAuth, async (req: Request, res: Response) => {
  try {
    const currentUserId = uid(req);
    const { user_product_id, other_product_id, receiver_id, requester_id } = req.body;

    await logger.info('Creating trade request', currentUserId, { user_product_id, other_product_id });

    // Validate required fields
    if (!user_product_id || !other_product_id || !receiver_id || !requester_id) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: user_product_id, other_product_id, receiver_id, requester_id'
      });
    }

    // Verify requester is current user
    if (requester_id !== currentUserId) {
      return res.status(403).json({ success: false, message: 'Unauthorized: Cannot create request for another user' });
    }

    // Check if trade request already exists
    const { data: existing } = await supabase
      .from('trade_requests')
      .select('id')
      .eq('requester_id', requester_id)
      .eq('receiver_id', receiver_id)
      .eq('user_product_id', user_product_id)
      .eq('other_product_id', other_product_id)
      .in('status', ['pending', 'accepted', 'in_progress', 'pending_confirmation'])
      .maybeSingle();

    if (existing) {
      return res.status(409).json({
        success: false,
        message: 'Trade request already exists for these products'
      });
    }

    // Create trade request
    const { data: tradeRequest, error } = await supabase
      .from('trade_requests')
      .insert({
        requester_id,
        receiver_id,
        user_product_id,
        other_product_id,
        status: 'pending',
        payment_status: 'unpaid',
      })
      .select()
      .single();

    if (error) {
      await logger.error('Error creating trade request', currentUserId, { error: error.message });
      return res.status(500).json({ success: false, message: 'Failed to create trade request' });
    }

    await logger.success('Trade request created', currentUserId, { tradeRequestId: tradeRequest.id });
    return res.status(201).json({ success: true, message: 'Trade request created successfully', data: tradeRequest });
  } catch (error: any) {
    await logger.error('Exception in trade request creation', uid(req), { error: error.message });
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// POST /api/trade/accept-requests/:tradeRequestId/ - Accept a trade request
router.post('/api/trade/accept-requests/:tradeRequestId/', requireAuth, async (req: Request, res: Response) => {
  try {
    const currentUserId = uid(req);
    const { tradeRequestId } = req.params;

    await logger.info('Accepting trade request', currentUserId, { tradeRequestId });

    // Fetch trade request
    const { data: tradeRequest, error: fetchError } = await supabase
      .from('trade_requests')
      .select('*')
      .eq('id', tradeRequestId)
      .maybeSingle();

    if (fetchError || !tradeRequest) {
      return res.status(404).json({ success: false, message: 'Trade request not found' });
    }

    // Verify current user is the receiver
    if (tradeRequest.receiver_id !== currentUserId) {
      return res.status(403).json({ success: false, message: 'Unauthorized: Only receiver can accept' });
    }

    // Verify status is pending
    if (tradeRequest.status !== 'pending') {
      return res.status(400).json({
        success: false,
        message: `Cannot accept trade request with status: ${tradeRequest.status}`
      });
    }

    // Update status to accepted
    const { data: updatedTrade, error: updateError } = await supabase
      .from('trade_requests')
      .update({ status: 'accepted' })
      .eq('id', tradeRequestId)
      .select()
      .single();

    if (updateError) {
      await logger.error('Error accepting trade request', currentUserId, { error: updateError.message });
      return res.status(500).json({ success: false, message: 'Failed to accept trade request' });
    }

    await logger.success('Trade request accepted', currentUserId, { tradeRequestId });
    return res.json({ success: true, message: 'Trade request accepted successfully', data: updatedTrade });
  } catch (error: any) {
    await logger.error('Exception in trade request acceptance', uid(req), { error: error.message });
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// POST /api/trade/mark-complete/:tradeRequestId/ - First user marks trade as complete
router.post('/api/trade/mark-complete/:tradeRequestId/', requireAuth, async (req: Request, res: Response) => {
  try {
    const currentUserId = uid(req);
    const { tradeRequestId } = req.params;

    await logger.info('Marking trade as complete', currentUserId, { tradeRequestId });

    // Fetch trade request
    const { data: tradeRequest, error: fetchError } = await supabase
      .from('trade_requests')
      .select('*')
      .eq('id', tradeRequestId)
      .maybeSingle();

    if (fetchError || !tradeRequest) {
      return res.status(404).json({ success: false, message: 'Trade request not found' });
    }

    // Verify current user is part of the trade
    const isRequester = tradeRequest.requester_id === currentUserId;
    const isReceiver = tradeRequest.receiver_id === currentUserId;

    if (!isRequester && !isReceiver) {
      return res.status(403).json({ success: false, message: 'Unauthorized: Not part of this trade' });
    }

    // Verify status is accepted or in_progress
    if (!['accepted', 'in_progress'].includes(tradeRequest.status)) {
      return res.status(400).json({
        success: false,
        message: `Cannot mark complete. Current status: ${tradeRequest.status}`
      });
    }

    // Check if user already marked complete
    if ((isRequester && tradeRequest.completed_by_requester) || (isReceiver && tradeRequest.completed_by_receiver)) {
      return res.status(400).json({
        success: false,
        message: 'You have already marked this trade as complete'
      });
    }

    // Update completion status
    const updates: any = {
      status: 'pending_confirmation',
    };

    if (isRequester) {
      updates.completed_by_requester = true;
      updates.requester_completed_at = new Date().toISOString();
    } else {
      updates.completed_by_receiver = true;
      updates.receiver_completed_at = new Date().toISOString();
    }

    const { data: updatedTrade, error: updateError } = await supabase
      .from('trade_requests')
      .update(updates)
      .eq('id', tradeRequestId)
      .select()
      .single();

    if (updateError) {
      await logger.error('Error marking trade complete', currentUserId, { error: updateError.message });
      return res.status(500).json({ success: false, message: 'Failed to mark trade as complete' });
    }

    await logger.success('Trade marked as complete', currentUserId, { tradeRequestId });

    // Notify the other party to confirm
    try {
      const otherUserId = isRequester ? tradeRequest.receiver_id : tradeRequest.requester_id;
      const { data: otherUser } = await supabase
        .from('users')
        .select('fcm_token')
        .eq('id', otherUserId)
        .maybeSingle();

      // Fetch product info for the notification
      const productId = isRequester ? tradeRequest.receiver_product_id : tradeRequest.requester_product_id;
      const { data: product } = await supabase
        .from('products')
        .select('title')
        .eq('id', productId)
        .maybeSingle();

      if (otherUser?.fcm_token) {
        await sendTradeConfirmationNeededNotification(
          otherUser.fcm_token,
          product?.title || 'a product',
          parseInt(tradeRequestId)
        );
      }
    } catch (notifError) {
      console.log('[Push] Failed to send trade confirmation notification:', notifError);
    }

    return res.json({
      success: true,
      message: 'Trade marked as complete. Waiting for other party to confirm.',
      data: updatedTrade
    });
  } catch (error: any) {
    await logger.error('Exception in marking trade complete', uid(req), { error: error.message });
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// POST /api/trade/confirm-complete/:tradeRequestId/ - Second user confirms completion
router.post('/api/trade/confirm-complete/:tradeRequestId/', requireAuth, async (req: Request, res: Response) => {
  try {
    const currentUserId = uid(req);
    const { tradeRequestId } = req.params;

    await logger.info('Confirming trade completion', currentUserId, { tradeRequestId });

    // Fetch trade request
    const { data: tradeRequest, error: fetchError } = await supabase
      .from('trade_requests')
      .select('*')
      .eq('id', tradeRequestId)
      .maybeSingle();

    if (fetchError || !tradeRequest) {
      return res.status(404).json({ success: false, message: 'Trade request not found' });
    }

    // Verify current user is part of the trade
    const isRequester = tradeRequest.requester_id === currentUserId;
    const isReceiver = tradeRequest.receiver_id === currentUserId;

    if (!isRequester && !isReceiver) {
      return res.status(403).json({ success: false, message: 'Unauthorized: Not part of this trade' });
    }

    // Verify status is pending_confirmation
    if (tradeRequest.status !== 'pending_confirmation') {
      return res.status(400).json({
        success: false,
        message: `Cannot confirm. Current status: ${tradeRequest.status}`
      });
    }

    // Check if user already confirmed
    if ((isRequester && tradeRequest.completed_by_requester) || (isReceiver && tradeRequest.completed_by_receiver)) {
      return res.status(400).json({
        success: false,
        message: 'You have already confirmed this trade'
      });
    }

    // Update completion status
    const updates: any = {};

    if (isRequester) {
      updates.completed_by_requester = true;
      updates.requester_completed_at = new Date().toISOString();
    } else {
      updates.completed_by_receiver = true;
      updates.receiver_completed_at = new Date().toISOString();
    }

    // Check if both parties have now confirmed
    const bothConfirmed =
      (isRequester ? true : tradeRequest.completed_by_requester) &&
      (isReceiver ? true : tradeRequest.completed_by_receiver);

    if (bothConfirmed) {
      updates.status = 'completed';
      updates.payment_status = 'paid'; // For legacy compatibility
    }

    const { data: updatedTrade, error: updateError } = await supabase
      .from('trade_requests')
      .update(updates)
      .eq('id', tradeRequestId)
      .select()
      .single();

    if (updateError) {
      await logger.error('Error confirming trade completion', currentUserId, { error: updateError.message });
      return res.status(500).json({ success: false, message: 'Failed to confirm trade completion' });
    }

    await logger.success('Trade completion confirmed', currentUserId, { tradeRequestId, completed: bothConfirmed });

    if (bothConfirmed) {
      try {
        const { data: usersForNotif } = await supabase
          .from('users')
          .select('id, fcm_token')
          .in('id', [tradeRequest.requester_id, tradeRequest.receiver_id]);

        const requesterToken = usersForNotif?.find((u: any) => u.id === tradeRequest.requester_id)?.fcm_token;
        const receiverToken = usersForNotif?.find((u: any) => u.id === tradeRequest.receiver_id)?.fcm_token;

        // Fetch product title for the notification
        const { data: product } = await supabase
          .from('products')
          .select('title')
          .eq('id', tradeRequest.requester_product_id)
          .maybeSingle();

        const productTitle = product?.title || 'a product';

        if (requesterToken) {
          await sendTradeCompletedNotification(requesterToken, productTitle, parseInt(tradeRequestId));
        }
        if (receiverToken) {
          await sendTradeCompletedNotification(receiverToken, productTitle, parseInt(tradeRequestId));
        }
      } catch (notifError) {
        console.log('[Push] Failed to send trade completion notifications:', notifError);
      }
    }
    return res.json({
      success: true,
      message: bothConfirmed ? 'Trade completed successfully!' : 'Confirmation recorded. Waiting for other party.',
      data: updatedTrade
    });
  } catch (error: any) {
    await logger.error('Exception in confirming trade completion', uid(req), { error: error.message });
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// POST /api/trade/cancel/:tradeRequestId/ - Cancel a trade request
router.post('/api/trade/cancel/:tradeRequestId/', requireAuth, async (req: Request, res: Response) => {
  try {
    const currentUserId = uid(req);
    const { tradeRequestId } = req.params;

    await logger.info('Cancelling trade request', currentUserId, { tradeRequestId });

    // Fetch trade request
    const { data: tradeRequest, error: fetchError } = await supabase
      .from('trade_requests')
      .select('*')
      .eq('id', tradeRequestId)
      .maybeSingle();

    if (fetchError || !tradeRequest) {
      return res.status(404).json({ success: false, message: 'Trade request not found' });
    }

    // Verify current user is part of the trade
    if (tradeRequest.requester_id !== currentUserId && tradeRequest.receiver_id !== currentUserId) {
      return res.status(403).json({ success: false, message: 'Unauthorized: Not part of this trade' });
    }

    // Cannot cancel completed trades
    if (tradeRequest.status === 'completed') {
      return res.status(400).json({
        success: false,
        message: 'Cannot cancel a completed trade'
      });
    }

    // Update status to cancelled
    const { data: updatedTrade, error: updateError } = await supabase
      .from('trade_requests')
      .update({ status: 'cancelled' })
      .eq('id', tradeRequestId)
      .select()
      .single();

    if (updateError) {
      await logger.error('Error cancelling trade request', currentUserId, { error: updateError.message });
      return res.status(500).json({ success: false, message: 'Failed to cancel trade request' });
    }

    await logger.success('Trade request cancelled', currentUserId, { tradeRequestId });
    return res.json({ success: true, message: 'Trade request cancelled successfully', data: updatedTrade });
  } catch (error: any) {
    await logger.error('Exception in trade cancellation', uid(req), { error: error.message });
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Legacy endpoint - kept for backward compatibility
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

// =====================================================
// MATCHES & CHAT SYSTEM
// =====================================================

/**
 * Create a match when mutual like is detected
 * Called automatically by match detection logic
 */
router.post('/api/matches/create/', requireAuth, async (req: Request, res: Response) => {
  try {
    const userId = uid(req);
    const body: any = req.body || {};

    const { user1_id, user2_id, user1_product_id, user2_product_id } = body;

    if (!user1_id || !user2_id || !user1_product_id || !user2_product_id) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: user1_id, user2_id, user1_product_id, user2_product_id'
      });
    }

    // Check if match already exists (either direction)
    const { data: existingMatch } = await supabase
      .from('matches')
      .select('*')
      .or(`and(user1_id.eq.${user1_id},user2_id.eq.${user2_id},user1_product_id.eq.${user1_product_id},user2_product_id.eq.${user2_product_id}),and(user1_id.eq.${user2_id},user2_id.eq.${user1_id},user1_product_id.eq.${user2_product_id},user2_product_id.eq.${user1_product_id})`)
      .maybeSingle();

    if (existingMatch) {
      return res.json({
        success: true,
        message: 'Match already exists',
        data: existingMatch
      });
    }

    // Create new match
    const { data: match, error } = await supabase
      .from('matches')
      .insert({
        user1_id,
        user2_id,
        user1_product_id,
        user2_product_id,
        status: 'active'
      })
      .select()
      .single();

    if (error) {
      console.error('Error creating match:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to create match',
        error: error.message
      });
    }

    await logger.success('Match created', userId, {
      match_id: match.id,
      user1_id,
      user2_id
    });

    return res.status(201).json({
      success: true,
      message: 'Match created successfully',
      data: match
    });
  } catch (error: any) {
    console.error('Error in create match:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * Get all matches for the authenticated user
 * Returns matches with other user's name and product details
 */
router.get('/api/matches/', requireAuth, async (req: Request, res: Response) => {
  try {
    const userId = uid(req);
    const status = (req.query.status as string) || 'active';

    // Get matches where user is either user1 or user2
    const { data: matches, error } = await supabase
      .from('matches')
      .select(`
        *,
        user1:user1_id (id, username, first_name, last_name),
        user2:user2_id (id, username, first_name, last_name),
        user1_product:user1_product_id (id, title, image, images),
        user2_product:user2_product_id (id, title, image, images)
      `)
      .or(`user1_id.eq.${userId},user2_id.eq.${userId}`)
      .eq('status', status)
      .order('last_message_at', { ascending: false, nullsFirst: false });

    if (error) {
      console.error('Error fetching matches:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to fetch matches',
        error: error.message
      });
    }

    // Transform matches to include the "other" user's info
    const transformedMatches = await Promise.all((matches || []).map(async (match: any) => {
      const isUser1 = match.user1_id === userId;
      const otherUser = isUser1 ? match.user2 : match.user1;
      const myProduct = isUser1 ? match.user1_product : match.user2_product;
      const otherProduct = isUser1 ? match.user2_product : match.user1_product;
      const unreadCount = isUser1 ? match.user1_unread_count : match.user2_unread_count;

      // Fetch the last message for this match
      let lastMessage = null;
      const { data: lastMessageData } = await supabase
        .from('messages')
        .select('message_text')
        .eq('match_id', match.id)
        .order('sent_at', { ascending: false })
        .limit(1)
        .maybeSingle();

      if (lastMessageData) {
        lastMessage = lastMessageData.message_text;
      }

      return {
        match_id: match.id,
        user1_id: match.user1_id,
        user2_id: match.user2_id,
        matched_at: match.matched_at,
        last_message_at: match.last_message_at,
        last_message: lastMessage,
        status: match.status,
        unread_count: unreadCount,
        other_user: {
          id: otherUser?.id,
          username: otherUser?.username,
          first_name: otherUser?.first_name,
          last_name: otherUser?.last_name,
          full_name: `${otherUser?.first_name || ''} ${otherUser?.last_name || ''}`.trim() || otherUser?.username
        },
        my_product: myProduct,
        other_product: otherProduct
      };
    }));

    return res.json({
      success: true,
      message: 'OK',
      data: transformedMatches
    });
  } catch (error: any) {
    console.error('Error in get matches:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * Get a single match by ID
 * Used for navigation from notifications
 */
router.get('/api/matches/:matchId', requireAuth, async (req: Request, res: Response) => {
  try {
    const userId = uid(req);
    const { matchId } = req.params;

    // Get the specific match where user is either user1 or user2
    const { data: match, error } = await supabase
      .from('matches')
      .select(`
        *,
        user1:user1_id (id, username, first_name, last_name, profile_picture_url),
        user2:user2_id (id, username, first_name, last_name, profile_picture_url),
        user1_product:user1_product_id (id, title, image, images),
        user2_product:user2_product_id (id, title, image, images)
      `)
      .eq('id', matchId)
      .or(`user1_id.eq.${userId},user2_id.eq.${userId}`)
      .maybeSingle();

    if (error) {
      console.error('[Matches] Error fetching match:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to fetch match',
        error: error.message
      });
    }

    if (!match) {
      return res.status(404).json({
        success: false,
        message: 'Match not found'
      });
    }

    // Determine other user and unread count
    const isUser1 = match.user1_id === userId;
    const otherUser = isUser1 ? match.user2 : match.user1;
    const otherProduct = isUser1 ? match.user2_product : match.user1_product;
    const myProduct = isUser1 ? match.user1_product : match.user2_product;
    const unreadCount = isUser1 ? match.user1_unread_count : match.user2_unread_count;

    // Fetch the last message for this match
    let lastMessage = null;
    const { data: lastMessageData } = await supabase
      .from('messages')
      .select('message_text')
      .eq('match_id', match.id)
      .order('sent_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (lastMessageData) {
      lastMessage = lastMessageData.message_text;
    }

    return res.json({
      success: true,
      message: 'OK',
      data: {
        match_id: match.id,
        user1_id: match.user1_id,
        user2_id: match.user2_id,
        matched_at: match.matched_at,
        last_message_at: match.last_message_at,
        last_message: lastMessage,
        status: match.status,
        unread_count: unreadCount,
        other_user: {
          id: otherUser?.id,
          username: otherUser?.username,
          first_name: otherUser?.first_name,
          last_name: otherUser?.last_name,
          profile_picture_url: otherUser?.profile_picture_url,
          full_name: `${otherUser?.first_name || ''} ${otherUser?.last_name || ''}`.trim() || otherUser?.username
        },
        my_product: myProduct,
        other_product: otherProduct
      }
    });
  } catch (error: any) {
    console.error('[Matches] Unexpected error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * Get messages for a specific match
 */
router.get('/api/matches/:matchId/messages/', requireAuth, async (req: Request, res: Response) => {
  try {
    const userId = uid(req);
    const matchId = req.params.matchId;

    // Verify user is part of this match
    const { data: match, error: matchError } = await supabase
      .from('matches')
      .select('*')
      .eq('id', matchId)
      .or(`user1_id.eq.${userId},user2_id.eq.${userId}`)
      .single();

    if (matchError || !match) {
      return res.status(404).json({
        success: false,
        message: 'Match not found or access denied'
      });
    }

    // Get messages
    const { data: messages, error } = await supabase
      .from('messages')
      .select(`
        *,
        sender:sender_id (id, username, first_name, last_name)
      `)
      .eq('match_id', matchId)
      .order('sent_at', { ascending: true });

    if (error) {
      console.error('Error fetching messages:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to fetch messages',
        error: error.message
      });
    }

    return res.json({
      success: true,
      message: 'OK',
      data: messages || []
    });
  } catch (error: any) {
    console.error('Error in get messages:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * Send a message in a match
 */
router.post('/api/matches/:matchId/messages/', requireAuth, async (req: Request, res: Response) => {
  try {
    const userId = uid(req);
    const matchId = req.params.matchId;
    const body: any = req.body || {};

    const { message_text, message_type = 'text' } = body;

    if (!message_text || message_text.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Message text is required'
      });
    }

    // Verify user is part of this match and get receiver info
    const { data: match, error: matchError } = await supabase
      .from('matches')
      .select('*')
      .eq('id', matchId)
      .or(`user1_id.eq.${userId},user2_id.eq.${userId}`)
      .single();

    if (matchError || !match) {
      return res.status(404).json({
        success: false,
        message: 'Match not found or access denied'
      });
    }

    // Determine receiver (the other user in the match)
    const receiverId = match.user1_id === userId ? match.user2_id : match.user1_id;

    // Insert message
    const { data: message, error } = await supabase
      .from('messages')
      .insert({
        match_id: matchId,
        sender_id: userId,
        receiver_id: receiverId,
        message_text: message_text.trim(),
        message_type
      })
      .select(`
        *,
        sender:sender_id (id, username, first_name, last_name)
      `)
      .single();

    if (error) {
      console.error('Error sending message:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to send message',
        error: error.message
      });
    }

    await logger.info('Message sent', userId, {
      match_id: matchId,
      message_id: message.id
    });

    // Send push notification to receiver
    try {
      const { data: receiver } = await supabase
        .from('users')
        .select('fcm_token')
        .eq('id', receiverId)
        .maybeSingle();

      const { data: sender } = await supabase
        .from('users')
        .select('username')
        .eq('id', userId)
        .maybeSingle();

      if (receiver?.fcm_token) {
        await sendMessageNotification(
          receiver.fcm_token,
          sender?.username || 'Someone',
          message_text.trim(),
          parseInt(matchId)
        );
      }
    } catch (notifError) {
      console.log('[Push] Failed to send message notification:', notifError);
      // Don't fail the request if notification fails
    }

    return res.status(201).json({
      success: true,
      message: 'Message sent successfully',
      data: message
    });
  } catch (error: any) {
    console.error('Error in send message:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * Mark messages as read in a match
 */
router.put('/api/matches/:matchId/read/', requireAuth, async (req: Request, res: Response) => {
  try {
    const userId = uid(req);
    const matchId = req.params.matchId;

    // Verify user is part of this match
    const { data: match, error: matchError } = await supabase
      .from('matches')
      .select('*')
      .eq('id', matchId)
      .or(`user1_id.eq.${userId},user2_id.eq.${userId}`)
      .single();

    if (matchError || !match) {
      return res.status(404).json({
        success: false,
        message: 'Match not found or access denied'
      });
    }

    // Mark all messages as read
    const { error: updateError } = await supabase
      .from('messages')
      .update({
        is_read: true,
        read_at: new Date().toISOString()
      })
      .eq('match_id', matchId)
      .eq('receiver_id', userId)
      .eq('is_read', false);

    if (updateError) {
      console.error('Error marking messages as read:', updateError);
      return res.status(500).json({
        success: false,
        message: 'Failed to mark messages as read',
        error: updateError.message
      });
    }

    // Reset unread counter for this user
    const isUser1 = match.user1_id === userId;
    const updateField = isUser1 ? 'user1_unread_count' : 'user2_unread_count';

    await supabase
      .from('matches')
      .update({ [updateField]: 0 })
      .eq('id', matchId);

    return res.json({
      success: true,
      message: 'Messages marked as read'
    });
  } catch (error: any) {
    console.error('Error in mark read:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * TEST endpoint for notification testing
 * TODO: Remove this endpoint after testing
 */
router.post('/api/test/notification', requireAuth, async (req: Request, res: Response) => {
  try {
    const userId = uid(req);
    const { type } = req.body; // 'match', 'message', 'trade_completed', 'trade_pending'

    if (!type || !['match', 'message', 'trade_completed', 'trade_pending'].includes(type)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid notification type. Must be one of: match, message, trade_completed, trade_pending'
      });
    }

    // Get user's FCM token
    const { data: user, error: userError } = await supabase
      .from('users')
      .select('fcm_token, username')
      .eq('id', userId)
      .single();

    if (userError || !user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    if (!user.fcm_token) {
      return res.status(400).json({
        success: false,
        message: 'No FCM token found for user. Make sure notifications are enabled.'
      });
    }

    // Send test notification based on type
    let result;
    const testMatchId = 999;
    const testTradeRequestId = 888;

    try {
      if (type === 'match') {
        result = await sendMatchNotification(user.fcm_token, 'Test Product', testMatchId);
      } else if (type === 'message') {
        result = await sendMessageNotification(user.fcm_token, 'Test User', 'This is a test message', testMatchId);
      } else if (type === 'trade_completed') {
        result = await sendTradeCompletedNotification(user.fcm_token, 'Test Product', testTradeRequestId);
      } else if (type === 'trade_pending') {
        result = await sendTradeConfirmationNeededNotification(user.fcm_token, 'Test Product', testTradeRequestId);
      }

      return res.json({
        success: true,
        message: `Test ${type} notification sent`,
        data: {
          fcmToken: user.fcm_token,
          notificationType: type,
          result: result
        }
      });
    } catch (notificationError: any) {
      console.error('[Test] Notification send error:', notificationError);
      return res.status(500).json({
        success: false,
        message: 'Failed to send notification',
        error: notificationError.message
      });
    }
  } catch (error: any) {
    console.error('[Test] Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

export default router;

