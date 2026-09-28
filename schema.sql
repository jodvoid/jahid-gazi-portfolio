-- Jahid Gazi Portfolio — Supabase setup
create extension if not exists pgcrypto;

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null check (category in ('vector','raster','digital')),
  image_url text not null,
  storage_path text,
  featured boolean not null default false,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.admin_users enable row level security;
alter table public.projects enable row level security;

drop policy if exists "admins can read own admin row" on public.admin_users;
create policy "admins can read own admin row"
on public.admin_users for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "public can read projects" on public.projects;
create policy "public can read projects"
on public.projects for select
to anon, authenticated
using (true);

drop policy if exists "admins can insert projects" on public.projects;
create policy "admins can insert projects"
on public.projects for insert
to authenticated
with check ((select count(*) from public.admin_users a where a.user_id = auth.uid()) > 0);

drop policy if exists "admins can update projects" on public.projects;
create policy "admins can update projects"
on public.projects for update
to authenticated
using ((select count(*) from public.admin_users a where a.user_id = auth.uid()) > 0)
with check ((select count(*) from public.admin_users a where a.user_id = auth.uid()) > 0);

drop policy if exists "admins can delete projects" on public.projects;
create policy "admins can delete projects"
on public.projects for delete
to authenticated
using ((select count(*) from public.admin_users a where a.user_id = auth.uid()) > 0);

-- Public image bucket. RLS below controls who may upload/change files.
insert into storage.buckets (id, name, public)
values ('portfolio', 'portfolio', true)
on conflict (id) do update set public = true;

drop policy if exists "public can view portfolio images" on storage.objects;
create policy "public can view portfolio images"
on storage.objects for select
to anon, authenticated
using (bucket_id = 'portfolio');

drop policy if exists "admins can upload portfolio images" on storage.objects;
create policy "admins can upload portfolio images"
on storage.objects for insert
to authenticated
with check (bucket_id = 'portfolio' and (select count(*) from public.admin_users a where a.user_id = auth.uid()) > 0);

drop policy if exists "admins can update portfolio images" on storage.objects;
create policy "admins can update portfolio images"
on storage.objects for update
to authenticated
using (bucket_id = 'portfolio' and (select count(*) from public.admin_users a where a.user_id = auth.uid()) > 0)
with check (bucket_id = 'portfolio' and (select count(*) from public.admin_users a where a.user_id = auth.uid()) > 0);

drop policy if exists "admins can delete portfolio images" on storage.objects;
create policy "admins can delete portfolio images"
on storage.objects for delete
to authenticated
using (bucket_id = 'portfolio' and (select count(*) from public.admin_users a where a.user_id = auth.uid()) > 0);

-- After creating your account in Supabase Authentication, replace YOUR_AUTH_USER_UUID below
-- with your user UUID and run this once:
-- insert into public.admin_users (user_id) values ('YOUR_AUTH_USER_UUID')
-- on conflict (user_id) do nothing;

-- Existing portfolio seed. These keep your current local images and can be removed later
-- from the dashboard if you don't want them.
insert into public.projects (title, category, image_url, featured, sort_order) values ("Business Card Collection", "vector", "assets/page-04.jpg", false, 0);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Tri-fold Brochure", "vector", "assets/page-05.jpg", false, 1);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Tri-fold Brochure", "vector", "assets/page-06.jpg", false, 2);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Burger Tri-fold Brochure", "vector", "assets/page-07.jpg", false, 3);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Case Study / Agency Layout", "vector", "assets/page-08.jpg", false, 4);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Menu Card", "vector", "assets/page-09.jpg", false, 5);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Magazine Collection", "vector", "assets/page-10.jpg", true, 6);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Instagram Post", "vector", "assets/page-11.jpg", false, 7);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Danglar Collection", "vector", "assets/page-12.jpg", false, 8);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Book Covers", "vector", "assets/page-13.jpg", false, 9);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Packaging", "vector", "assets/page-14.jpg", true, 10);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Standee Collection", "vector", "assets/page-15.jpg", false, 11);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Illustration", "vector", "assets/page-16.jpg", false, 12);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Illustration", "vector", "assets/page-17.jpg", false, 13);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Business Card Collection", "raster", "assets/page-19.jpg", false, 14);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Brochure Collection", "raster", "assets/page-20.jpg", false, 15);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Menu Card Collection", "raster", "assets/page-21.jpg", false, 16);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Magazine Collection", "raster", "assets/page-22.jpg", false, 17);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Instagram Post", "raster", "assets/page-23.jpg", false, 18);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Brochure Collection", "raster", "assets/page-24.jpg", false, 19);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Car Service Brochure", "raster", "assets/page-25.jpg", false, 20);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Book Cover Collection", "raster", "assets/page-26.jpg", false, 21);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Standee Collection", "raster", "assets/page-27.jpg", false, 22);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Digital Painting Collection", "digital", "assets/page-28.jpg", true, 23);
insert into public.projects (title, category, image_url, featured, sort_order) values ("Digital Painting Collection", "digital", "assets/page-29.jpg", false, 24);
