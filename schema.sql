-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.tickets (
  id text NOT NULL,
  judul text NOT NULL,
  deskripsi text NOT NULL,
  status text NOT NULL DEFAULT 'open'::text CHECK (status = ANY (ARRAY['open'::text, 'assigned'::text, 'on_progress'::text, 'resolved'::text, 'closed'::text])),
  prioritas text NOT NULL CHECK (prioritas = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text])),
  kategori text NOT NULL,
  created_at timestamp without time zone DEFAULT now(),
  lampiran_url text,
  pembuat_id uuid,
  assigned_to uuid,
  CONSTRAINT tickets_pkey PRIMARY KEY (id),
  CONSTRAINT tickets_pembuat_id_fkey FOREIGN KEY (pembuat_id) REFERENCES public.profiles(id),
  CONSTRAINT tickets_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.profiles(id)
);
CREATE TABLE public.komentar (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  ticket_id text NOT NULL,
  isi text NOT NULL,
  waktu timestamp without time zone DEFAULT now(),
  user_id uuid,
  CONSTRAINT komentar_pkey PRIMARY KEY (id),
  CONSTRAINT komentar_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT komentar_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id)
);
CREATE TABLE public.notifikasi (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  judul text NOT NULL,
  pesan text NOT NULL,
  tipe text NOT NULL CHECK (tipe = ANY (ARRAY['info'::text, 'success'::text, 'warning'::text])),
  waktu timestamp without time zone DEFAULT now(),
  sudah_dibaca boolean DEFAULT false,
  user_id uuid,
  CONSTRAINT notifikasi_pkey PRIMARY KEY (id),
  CONSTRAINT notifikasi_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.riwayat_tiket (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  ticket_id text NOT NULL,
  aksi text NOT NULL,
  keterangan text NOT NULL,
  waktu timestamp without time zone DEFAULT now(),
  CONSTRAINT riwayat_tiket_pkey PRIMARY KEY (id),
  CONSTRAINT riwayat_tiket_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  nama text NOT NULL,
  email text NOT NULL,
  role text NOT NULL CHECK (role = ANY (ARRAY['Admin'::text, 'Helpdesk'::text, 'User'::text])),
  created_at timestamp with time zone DEFAULT now(),
  is_active boolean NOT NULL DEFAULT true,
  avatar_url text,
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);