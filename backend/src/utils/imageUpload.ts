import { supabase } from '../services/supabaseClient';
import { v4 as uuidv4 } from 'uuid';

/**
 * Upload an image buffer to Supabase Storage and return the public URL
 * @param buffer - Image file buffer
 * @param mimetype - MIME type (e.g., 'image/jpeg')
 * @param folder - Optional folder path (e.g., 'products', 'profiles')
 * @returns Public URL of the uploaded image
 */
export async function uploadImageToStorage(
  buffer: Buffer,
  mimetype: string,
  folder: string = 'products'
): Promise<string> {
  // Generate unique filename with extension
  const extension = mimetype.split('/')[1] || 'jpg';
  const filename = `${folder}/${uuidv4()}.${extension}`;

  // Upload to Supabase Storage
  const { data, error } = await supabase.storage
    .from('product-images') // Bucket name
    .upload(filename, buffer, {
      contentType: mimetype,
      upsert: false,
    });

  if (error) {
    console.error('Supabase Storage upload error:', error);
    throw new Error(`Failed to upload image: ${error.message}`);
  }

  // Get public URL
  const { data: { publicUrl } } = supabase.storage
    .from('product-images')
    .getPublicUrl(filename);

  return publicUrl;
}

/**
 * Upload multiple images and return array of public URLs
 */
export async function uploadMultipleImages(
  files: Array<{ buffer: Buffer; mimetype: string }>,
  folder: string = 'products'
): Promise<string[]> {
  const uploadPromises = files.map(file =>
    uploadImageToStorage(file.buffer, file.mimetype, folder)
  );

  return Promise.all(uploadPromises);
}

/**
 * Delete an image from Supabase Storage by URL
 */
export async function deleteImageFromStorage(imageUrl: string): Promise<void> {
  // Extract path from URL
  const url = new URL(imageUrl);
  const pathMatch = url.pathname.match(/\/storage\/v1\/object\/public\/product-images\/(.+)/);

  if (!pathMatch) {
    console.warn('Invalid image URL format, skipping deletion:', imageUrl);
    return;
  }

  const filePath = pathMatch[1];

  const { error } = await supabase.storage
    .from('product-images')
    .remove([filePath]);

  if (error) {
    console.error('Failed to delete image from storage:', error);
    // Don't throw - deletion failure shouldn't block the main operation
  }
}

/**
 * Check if a string is a base64 data URI (legacy format)
 */
export function isBase64Image(str: string): boolean {
  return str.startsWith('data:image/');
}

/**
 * Check if a string is a valid Supabase Storage URL
 */
export function isStorageUrl(str: string): boolean {
  return str.startsWith('http') && str.includes('/storage/v1/object/public/');
}
