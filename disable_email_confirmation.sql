-- Disable Email Confirmation Requirement
-- Run this in your Supabase SQL Editor to disable email confirmation

-- Update auth configuration to disable email confirmation
-- Note: This affects the auth.config table which might not be directly accessible
-- The preferred method is through the Supabase Dashboard

-- However, we can check current email confirmation settings
SELECT 
    name,
    value
FROM auth.config 
WHERE name IN ('DISABLE_SIGNUP', 'EMAIL_CONFIRM', 'SMTP_HOST');

-- Alternative: Create a function to bypass email confirmation for specific users
-- This allows immediate login without email confirmation

CREATE OR REPLACE FUNCTION public.confirm_user_email(user_email TEXT)
RETURNS TEXT AS $$
DECLARE
    user_id UUID;
BEGIN
    -- Find user by email
    SELECT id INTO user_id
    FROM auth.users
    WHERE email = user_email
    LIMIT 1;
    
    IF user_id IS NULL THEN
        RETURN 'Error: User with email ' || user_email || ' not found';
    END IF;
    
    -- Update user to mark email as confirmed
    UPDATE auth.users 
    SET 
        email_confirmed_at = NOW(),
        updated_at = NOW()
    WHERE id = user_id;
    
    RETURN 'Success: Email confirmed for user ' || user_email;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.confirm_user_email(TEXT) TO authenticated;

-- Usage example (run after creating a user):
-- SELECT public.confirm_user_email('vcxasdax@gmail.com');

-- Test the function
DO $$
BEGIN
    RAISE NOTICE '✅ Email Confirmation Bypass Function Created!';
    RAISE NOTICE '';
    RAISE NOTICE '📋 Options to disable email confirmation:';
    RAISE NOTICE '   • Option 1 (Recommended): Disable in Supabase Dashboard';
    RAISE NOTICE '   • Option 2: Use confirm_user_email function for specific users';
    RAISE NOTICE '';
    RAISE NOTICE '🔧 Dashboard Steps:';
    RAISE NOTICE '   1. Go to Authentication → Settings';
    RAISE NOTICE '   2. Turn OFF "Enable email confirmations"';
    RAISE NOTICE '   3. Save changes';
    RAISE NOTICE '';
    RAISE NOTICE '🧪 Function Usage:';
    RAISE NOTICE '   SELECT public.confirm_user_email(''user@example.com'');';
END
$$;