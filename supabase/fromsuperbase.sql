-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.consultation_messages (
  message_id uuid NOT NULL DEFAULT uuid_generate_v4(),
  consultation_id uuid NOT NULL,
  sender_id uuid NOT NULL,
  sender_type text NOT NULL,
  message text NOT NULL,
  attachments jsonb,
  read boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT consultation_messages_pkey PRIMARY KEY (message_id),
  CONSTRAINT consultation_messages_consultation_id_fkey FOREIGN KEY (consultation_id) REFERENCES public.consultations(consultation_id)
);
CREATE TABLE public.consultations (
  consultation_id uuid NOT NULL DEFAULT uuid_generate_v4(),
  farmer_id uuid NOT NULL,
  vet_id uuid,
  title text NOT NULL,
  description text,
  status text NOT NULL DEFAULT 'PENDING'::text,
  urgency text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT consultations_pkey PRIMARY KEY (consultation_id),
  CONSTRAINT consultations_farmer_id_fkey FOREIGN KEY (farmer_id) REFERENCES public.farmers(farmer_id),
  CONSTRAINT consultations_vet_id_fkey FOREIGN KEY (vet_id) REFERENCES public.vets(vet_id)
);
CREATE TABLE public.disease_info (
  disease_id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  causes text,
  symptoms text,
  treatment text,
  prevention text,
  description text,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT disease_info_pkey PRIMARY KEY (disease_id)
);
CREATE TABLE public.farmers (
  farmer_id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL UNIQUE,
  full_name text NOT NULL,
  phone_number text,
  location text,
  farm_name text,
  farm_size text,
  bird_count integer,
  bird_type text,
  profile_image_url text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  farm_address text,
  CONSTRAINT farmers_pkey PRIMARY KEY (farmer_id),
  CONSTRAINT farmers_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.products (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  category text NOT NULL,
  brand text NOT NULL,
  buying_price numeric NOT NULL,
  selling_price numeric NOT NULL,
  quantity integer NOT NULL,
  description text,
  image_url text,
  date_added timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT products_pkey PRIMARY KEY (id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  role text NOT NULL DEFAULT 'customer'::text,
  email text,
  name text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.reminder (
  reminder_id uuid NOT NULL DEFAULT uuid_generate_v4(),
  vet_id uuid,
  farmer_id uuid,
  title text NOT NULL,
  message text NOT NULL,
  reminder_date timestamp without time zone NOT NULL,
  is_sent boolean DEFAULT false,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT reminder_pkey PRIMARY KEY (reminder_id)
);
CREATE TABLE public.sales (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  product_id uuid NOT NULL,
  product_name text NOT NULL,
  quantity integer NOT NULL,
  unit_price numeric NOT NULL,
  total_price numeric NOT NULL,
  customer_name text NOT NULL,
  customer_phone text NOT NULL,
  sale_date timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT sales_pkey PRIMARY KEY (id),
  CONSTRAINT sales_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.symptoms_reports (
  report_id uuid NOT NULL DEFAULT uuid_generate_v4(),
  farmer_id uuid NOT NULL,
  symptoms ARRAY NOT NULL,
  description text,
  bird_type text,
  bird_age text,
  bird_count integer,
  date_observed date NOT NULL,
  images jsonb,
  status text DEFAULT 'OPEN'::text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT symptoms_reports_pkey PRIMARY KEY (report_id),
  CONSTRAINT symptoms_reports_farmer_id_fkey FOREIGN KEY (farmer_id) REFERENCES public.farmers(farmer_id)
);
CREATE TABLE public.vets (
  vet_id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL UNIQUE,
  full_name text NOT NULL,
  phone_number text,
  qualification text,
  license_number text,
  specialization text,
  experience_years integer,
  available boolean DEFAULT true,
  profile_image_url text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT vets_pkey PRIMARY KEY (vet_id),
  CONSTRAINT vets_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);