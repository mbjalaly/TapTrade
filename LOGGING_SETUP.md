# Logging System Setup Guide

This guide explains how to set up and use the database logging system for TapTrade.

## Overview

The logging system stores application events and errors in a Supabase database table, which can be viewed and managed through the admin panel.

## Setup Steps

### 1. Create the Logs Table

Run the SQL script in your Supabase SQL Editor:

**File:** `backend/CREATE_LOGS_TABLE.sql`

Or manually run:

```sql
CREATE TABLE IF NOT EXISTS logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  level VARCHAR(20) DEFAULT 'info' NOT NULL,
  message TEXT NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_logs_created_at ON logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_logs_level ON logs(level);
CREATE INDEX IF NOT EXISTS idx_logs_user_id ON logs(user_id);

-- Enable RLS (Row Level Security)
ALTER TABLE logs ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Allow authenticated insert" ON logs 
  FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Allow service role insert" ON logs 
  FOR INSERT TO service_role WITH CHECK (true);

CREATE POLICY "Allow authenticated read" ON logs 
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow service role read" ON logs 
  FOR SELECT TO service_role USING (true);
```

### 2. Backend Integration

The logging system is already integrated into the backend routes. The logger automatically logs:

- **User Registration**: Success and failures
- **User Login**: Success, failures, and invalid credentials
- **Product Creation**: Success and failures
- **Product Updates**: Success, failures, and errors
- **Product Fetching**: Info and errors

#### Using the Logger in Your Code

```typescript
import { logger } from '../utils/logger';

// Log info
await logger.info('User action completed', userId, { action: 'view_product' });

// Log warning
await logger.warning('Unusual activity detected', userId, { ip: req.ip });

// Log error
await logger.error('Database query failed', userId, { error: error.message });

// Log success
await logger.success('Payment processed', userId, { amount: 100 });

// Log debug
await logger.debug('Cache hit', userId, { key: 'product_123' });
```

### 3. Admin Panel Configuration

The admin panel already has a logs screen configured. To view logs:

1. Open the admin panel
2. Navigate to the "Logs" section
3. Use the filter dropdown to filter by log level (All, Error, Warning, Info, Debug)
4. Click "Refresh" to manually reload logs
5. Toggle "Auto-refresh" to automatically update logs every 5 seconds

#### Log Display Features

- **Color-coded levels**: Each log level has a distinct color
- **Icons**: Visual indicators for different log types
- **Metadata**: Additional context information is displayed when available
- **User tracking**: Shows which user triggered the log (if applicable)
- **Timestamp**: Shows when the log was created

## Log Levels

- **info**: General informational messages
- **warning**: Warning messages for potential issues
- **error**: Error messages for failures
- **debug**: Debug information for development
- **success**: Success messages for completed operations

## Table Structure

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| level | VARCHAR(20) | Log level (info, warning, error, debug, success) |
| message | TEXT | Log message |
| user_id | UUID | Optional user ID who triggered the log |
| metadata | JSONB | Optional additional data (method, path, IP, etc.) |
| created_at | TIMESTAMP | When the log was created |

## Best Practices

1. **Don't log sensitive data**: Avoid logging passwords, tokens, or personal information
2. **Use appropriate levels**: Use error for failures, warning for potential issues, info for normal operations
3. **Include context**: Use metadata to provide additional context (IP, method, path, etc.)
4. **Monitor regularly**: Check logs regularly in the admin panel to identify issues early
5. **Clean old logs**: Consider archiving or deleting logs older than a certain period

## Troubleshooting

### Logs not appearing in admin panel

1. Verify the `logs` table exists in Supabase
2. Check RLS policies are correctly set up
3. Verify the admin user has authenticated access
4. Check browser console for errors

### Logs not being written

1. Verify Supabase connection in backend
2. Check that `SUPABASE_SERVICE_ROLE_KEY` is set correctly
3. Check backend console for errors
4. Verify RLS policies allow inserts

### Performance issues

1. Ensure indexes are created on `created_at`, `level`, and `user_id`
2. Consider limiting the number of logs retrieved (currently 500)
3. Archive old logs periodically
4. Use log level filtering to reduce displayed logs

## Maintenance

### Archive Old Logs

```sql
-- Create archive table
CREATE TABLE logs_archive (LIKE logs INCLUDING ALL);

-- Move logs older than 90 days
INSERT INTO logs_archive 
SELECT * FROM logs 
WHERE created_at < NOW() - INTERVAL '90 days';

-- Delete archived logs
DELETE FROM logs 
WHERE created_at < NOW() - INTERVAL '90 days';
```

### Clean Up Logs

```sql
-- Delete logs older than 30 days
DELETE FROM logs 
WHERE created_at < NOW() - INTERVAL '30 days';
```

## Future Enhancements

- Log export functionality
- Log search and filtering
- Real-time log streaming
- Log aggregation and analytics
- Email alerts for critical errors

