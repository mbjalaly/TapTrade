-- Create logs table for system logging
CREATE TABLE IF NOT EXISTS logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  level VARCHAR(20) DEFAULT 'info' NOT NULL,
  message TEXT NOT NULL,
  user_id UUID, -- Store user_id without foreign key constraint to avoid FK issues
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_logs_created_at ON logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_logs_level ON logs(level);
CREATE INDEX IF NOT EXISTS idx_logs_user_id ON logs(user_id);

-- Enable RLS (Row Level Security)
ALTER TABLE logs ENABLE ROW LEVEL SECURITY;

-- Policy: Allow authenticated users to insert logs
CREATE POLICY "Allow authenticated insert" ON logs 
  FOR INSERT 
  TO authenticated 
  WITH CHECK (true);

-- Policy: Allow service role to insert logs (for backend)
CREATE POLICY "Allow service role insert" ON logs 
  FOR INSERT 
  TO service_role 
  WITH CHECK (true);

-- Policy: Allow authenticated users to read logs (for admin panel)
CREATE POLICY "Allow authenticated read" ON logs 
  FOR SELECT 
  TO authenticated 
  USING (true);

-- Policy: Allow service role to read all logs
CREATE POLICY "Allow service role read" ON logs 
  FOR SELECT 
  TO service_role 
  USING (true);

-- Add comment
COMMENT ON TABLE logs IS 'System logs table for tracking application events and errors';
COMMENT ON COLUMN logs.level IS 'Log level: info, warning, error, debug, success';
COMMENT ON COLUMN logs.metadata IS 'Additional metadata as JSON object';

