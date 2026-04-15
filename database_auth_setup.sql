-- 1. Create the `profiles` table to store roles and user data
CREATE TABLE public.profiles (
  id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL,
  role text NOT NULL DEFAULT 'user'::text,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  CONSTRAINT profiles_pkey PRIMARY KEY (id)
);

-- 2. Enable RLS on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Profiles: Anyone can read profiles (needed so the app can see if you are admin)
CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles FOR SELECT USING (true);

-- Admins can update roles
CREATE POLICY "Admins can update roles" ON public.profiles FOR UPDATE USING (
  exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
);

-- normal users cannot update profiles, since role changes should be protected.

-- 3. Create a Function and Trigger to auto-create a profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, role)
  VALUES (new.id, new.email, 'user');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger the function every time a user is created
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 4. Farmacias RLS (Replace the current permissive ones with these):
-- First clear old policies on farmacias using the dashboard or run DROP POLICY 
-- DROP POLICY IF EXISTS "Permitir insertar" ON public.farmacias;

ALTER TABLE public.farmacias ENABLE ROW LEVEL SECURITY;

-- SELECT is free for all
CREATE POLICY "Farmacias viewable by everyone" ON public.farmacias FOR SELECT USING (true);

-- INSERT only if role = admin
CREATE POLICY "Admins can insert farmacia" ON public.farmacias FOR INSERT WITH CHECK (
  exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
);

-- UPDATE only if role = admin
CREATE POLICY "Admins can update farmacia" ON public.farmacias FOR UPDATE USING (
  exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
);

-- DELETE only if role = admin
CREATE POLICY "Admins can delete farmacia" ON public.farmacias FOR DELETE USING (
  exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
);
