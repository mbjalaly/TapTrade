import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseServiceRoleKey) {
  throw new Error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY');
}

export const supabase = createClient(supabaseUrl, supabaseServiceRoleKey, {
  db: { 
    schema: process.env.SUPABASE_SCHEMA || 'public',
    // Increase timeout for large data operations
  },
  auth: { autoRefreshToken: false, persistSession: false },
  global: {
    // Set fetch timeout to 60 seconds for large operations
    fetch: (url, options = {}) => {
      return fetch(url, {
        ...options,
        signal: AbortSignal.timeout(60000), // 60 second timeout
      });
    },
  },
});

export default supabase;

