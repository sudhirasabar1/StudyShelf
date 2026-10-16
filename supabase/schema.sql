-- StudyShelf starter schema for Supabase Postgres.
-- Review/test in a development project before production use.

create extension if not exists pgcrypto;

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.resources (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 3 and 180),
  slug text unique not null,
  description text not null check (char_length(description) between 5 and 3000),
  category text not null,
  level text not null default 'Beginner' check (level in ('Beginner','Intermediate','Exam Prep')),
  storage_path text,
  external_url text,
  file_size_bytes bigint check (file_size_bytes is null or file_size_bytes >= 0),
  page_count integer check (page_count is null or page_count > 0),
  published boolean not null default false,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint resource_has_file check (storage_path is not null or external_url is not null)
);

create index if not exists resources_published_created_idx
  on public.resources (published, created_at desc);
create index if not exists resources_category_idx
  on public.resources (category);

create or replace function public.is_studyshelf_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.admin_users au
    where au.user_id = (select auth.uid())
  );
$$;

revoke all on function public.is_studyshelf_admin() from public;
grant execute on function public.is_studyshelf_admin() to anon, authenticated;

alter table public.resources enable row level security;
alter table public.admin_users enable row level security;

-- Public visitors can read published resources only.
drop policy if exists "Published resources are readable" on public.resources;
create policy "Published resources are readable"
  on public.resources for select
  to anon, authenticated
  using (published = true or public.is_studyshelf_admin());

-- Only explicitly allow-listed admins can add/update/delete metadata.
drop policy if exists "Admins can insert resources" on public.resources;
create policy "Admins can insert resources"
  on public.resources for insert
  to authenticated
  with check (public.is_studyshelf_admin() and created_by = (select auth.uid()));

drop policy if exists "Admins can update resources" on public.resources;
create policy "Admins can update resources"
  on public.resources for update
  to authenticated
  using (public.is_studyshelf_admin())
  with check (public.is_studyshelf_admin());

drop policy if exists "Admins can delete resources" on public.resources;
create policy "Admins can delete resources"
  on public.resources for delete
  to authenticated
  using (public.is_studyshelf_admin());

-- Admin identities must be provisioned by a trusted project owner in SQL editor.
-- Do not create a public client policy that lets users self-promote to admin.
-- Example after creating the admin account in Supabase Auth:
-- insert into public.admin_users (user_id) values ('ADMIN-AUTH-USER-UUID');

-- Storage bucket setup is intentionally separate. Create a PRIVATE bucket named `pdfs`
-- in the Supabase Dashboard. Add Storage policies that check public.is_studyshelf_admin()
-- for insert/update/delete. For downloads from a private bucket, issue short-lived signed URLs
-- only after validating the caller and resource record. Do not expose the service-role key.
