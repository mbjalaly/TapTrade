import supabase from '../services/supabaseClient';

// Type declaration for Node.js process (for environments where @types/node might not be available)
declare const process: {
  env: {
    NODE_ENV?: string;
  };
} | undefined;

// Check if logs table exists (for debugging)
let tableCheckDone = false;
async function checkLogsTable() {
  if (tableCheckDone) return;
  try {
    console.log('[Logger] 🔍 Checking if logs table exists...');
    const { data, error } = await supabase.from('logs').select('id').limit(1);
    if (error) {
      console.error('[Logger] ❌ Logs table check FAILED:', {
        message: error.message,
        code: error.code,
        hint: error.hint,
        details: error.details,
      });
      
      if (error.code === '42P01' || error.message.includes('does not exist')) {
        console.error('[Logger] ⚠️  ACTION REQUIRED: Logs table does not exist!');
        console.error('[Logger]    Run this SQL in Supabase SQL Editor:');
        console.error('[Logger]    See: backend/CREATE_LOGS_TABLE.sql');
      } else if (error.code === '42501' || error.message.includes('permission')) {
        console.error('[Logger] ⚠️  ACTION REQUIRED: Permission denied!');
        console.error('[Logger]    Check RLS policies for logs table');
        console.error('[Logger]    Service role should bypass RLS');
      }
    } else {
      console.log('[Logger] ✅ Logs table is accessible');
      console.log('[Logger]    Sample check returned:', data ? `${data.length} row(s)` : 'empty');
      tableCheckDone = true;
    }
  } catch (e: any) {
    console.error('[Logger] ❌ Exception checking logs table:', {
      error: e?.message || String(e),
      stack: e?.stack,
    });
  }
}

// Check on first import
if (typeof process !== 'undefined' && process.env?.NODE_ENV !== 'test') {
  checkLogsTable().catch(() => {});
}

export type LogLevel = 'info' | 'warning' | 'error' | 'debug' | 'success';

interface LogEntry {
  level: LogLevel;
  message: string;
  user_id?: string;
  metadata?: Record<string, any>;
}

/**
 * Logs a message to the database
 * @param level - Log level (info, warning, error, debug, success)
 * @param message - Log message
 * @param userId - Optional user ID
 * @param metadata - Optional metadata object
 */
export async function logToDatabase(
  level: LogLevel,
  message: string,
  userId?: string,
  metadata?: Record<string, any>
): Promise<void> {
  try {
    const logEntry: LogEntry = {
      level,
      message,
      ...(userId && { user_id: userId }),
      ...(metadata && { metadata }),
    };

    // Always log to console first as fallback
    console.log(`[${level.toUpperCase()}] ${message}`, metadata || '');

    const { data, error } = await supabase.from('logs').insert([logEntry]).select();

    if (error) {
      // ALWAYS log errors to console (even in production) for debugging
      console.error(`[Logger] ❌ FAILED to write to database:`, {
        error: error.message,
        code: error.code,
        details: error.details,
        hint: error.hint,
        level,
        message,
        logEntry: JSON.stringify(logEntry, null, 2),
      });
      
      // If it's a foreign key constraint error, set user_id to null and retry
      if (error.code === '23503' || error.message.includes('foreign key constraint')) {
        console.warn(`[Logger] ⚠️  Foreign key constraint error - user_id doesn't exist, logging without user_id`);
        try {
          const retryEntry = { ...logEntry };
          delete retryEntry.user_id; // Remove user_id to avoid FK constraint
          const { error: retryError } = await supabase.from('logs').insert([retryEntry]).select();
          if (retryError) {
            console.error(`[Logger] ❌ Retry also failed:`, retryError);
          } else {
            console.log(`[Logger] ✅ Successfully logged without user_id`);
          }
        } catch (retryErr) {
          console.error(`[Logger] ❌ Retry exception:`, retryErr);
        }
        return; // Don't log success since we had to retry
      }
      
      // If it's a permission error, provide helpful message
      if (error.code === '42501' || error.message.includes('permission') || error.message.includes('policy')) {
        console.error(`[Logger] ⚠️  RLS Policy Error - Service role should bypass RLS. Check:`);
        console.error(`[Logger]    1. SUPABASE_SERVICE_ROLE_KEY is set correctly`);
        console.error(`[Logger]    2. Logs table RLS policies allow service_role`);
        console.error(`[Logger]    3. Run CREATE_LOGS_TABLE.sql in Supabase SQL Editor`);
      }
      
      // If table doesn't exist
      if (error.code === '42P01' || error.message.includes('does not exist')) {
        console.error(`[Logger] ⚠️  Table Error - Logs table doesn't exist. Run CREATE_LOGS_TABLE.sql`);
      }
    } else {
      // Successfully logged - always confirm in console
      console.log(`[Logger] ✅ Successfully logged ${level}: ${message}`, data?.[0]?.id || '');
    }
  } catch (error: any) {
    // Fallback to console if database insert fails
    console.error(`[Logger] ❌ EXCEPTION writing log:`, {
      error: error?.message || String(error),
      stack: error?.stack,
      level,
      message,
      errorType: error?.constructor?.name,
    });
    console.log(`[${level.toUpperCase()}] ${message}`, metadata || '');
  }
}

/**
 * Convenience functions for different log levels
 */
export const logger = {
  info: (message: string, userId?: string, metadata?: Record<string, any>) =>
    logToDatabase('info', message, userId, metadata),
  
  warning: (message: string, userId?: string, metadata?: Record<string, any>) =>
    logToDatabase('warning', message, userId, metadata),
  
  error: (message: string, userId?: string, metadata?: Record<string, any>) =>
    logToDatabase('error', message, userId, metadata),
  
  debug: (message: string, userId?: string, metadata?: Record<string, any>) =>
    logToDatabase('debug', message, userId, metadata),
  
  success: (message: string, userId?: string, metadata?: Record<string, any>) =>
    logToDatabase('success', message, userId, metadata),
};

