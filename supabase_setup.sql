-- Create registrations table for DevTalks 2026
CREATE TABLE IF NOT EXISTS registrations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    registration_number TEXT NOT NULL,
    branch TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT NOT NULL,
    payment_id TEXT,
    payment_status TEXT DEFAULT 'pending',
    amount INTEGER DEFAULT 5100,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_registrations_email ON registrations(email);
CREATE INDEX IF NOT EXISTS idx_registrations_payment_status ON registrations(payment_status);
CREATE INDEX IF NOT EXISTS idx_registrations_created_at ON registrations(created_at DESC);

-- Enable Row Level Security
ALTER TABLE registrations ENABLE ROW LEVEL SECURITY;

-- Create policy to allow inserts from anyone (for registration)
CREATE POLICY "Allow public inserts" ON registrations
    FOR INSERT
    WITH CHECK (true);

-- Create policy to allow reads only for authenticated users (optional - for admin viewing)
CREATE POLICY "Allow authenticated reads" ON registrations
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- Optional: Create a view for admin dashboard (counts, statistics)
CREATE OR REPLACE VIEW registration_stats AS
SELECT 
    COUNT(*) as total_registrations,
    COUNT(CASE WHEN payment_status = 'success' THEN 1 END) as successful_payments,
    COUNT(CASE WHEN payment_status = 'failed' THEN 1 END) as failed_payments,
    SUM(CASE WHEN payment_status = 'success' THEN amount ELSE 0 END) as total_revenue
FROM registrations;
