import supabase from '../services/supabaseClient';

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

    const { error } = await supabase.from('logs').insert([logEntry]);

    if (error) {
      // Fallback to console if database insert fails
      console.error(`[Logger] Failed to write to database:`, error);
      console.log(`[${level.toUpperCase()}] ${message}`, metadata || '');
    }
  } catch (error) {
    // Fallback to console if database insert fails
    console.error(`[Logger] Error writing log:`, error);
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

