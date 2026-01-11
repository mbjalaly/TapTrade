import supabase from '../services/supabaseClient';

// Check if logs table exists (for debugging)
let tableCheckDone = false;
async function checkLogsTable() {
  if (tableCheckDone) return;
  try {
    const { error } = await supabase.from('logs').select('id').limit(1);
    if (error) {
      console.error('[Logger] Logs table check failed:', {
        message: error.message,
        code: error.code,
        hint: error.hint,
        details: error.details,
      });
      console.error('[Logger] Make sure you have run CREATE_LOGS_TABLE.sql in Supabase');
    } else {
      console.log('[Logger] Logs table is accessible');
      tableCheckDone = true;
    }
  } catch (e) {
    console.error('[Logger] Exception checking logs table:', e);
  }
}

// Check on first import
if (typeof process !== 'undefined' && process.env.NODE_ENV !== 'test') {
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

    const { data, error } = await supabase.from('logs').insert([logEntry]).select();

    if (error) {
      // Log the error with full details
      console.error(`[Logger] Failed to write to database:`, {
        error: error.message,
        code: error.code,
        details: error.details,
        hint: error.hint,
        level,
        message,
      });
      // Still log to console as fallback
      console.log(`[${level.toUpperCase()}] ${message}`, metadata || '');
    } else {
      // Successfully logged
      if (process.env.NODE_ENV === 'development') {
        console.log(`[Logger] Successfully logged ${level}: ${message}`, data?.[0]?.id || '');
      }
    }
  } catch (error: any) {
    // Fallback to console if database insert fails
    console.error(`[Logger] Exception writing log:`, {
      error: error?.message || String(error),
      stack: error?.stack,
      level,
      message,
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

