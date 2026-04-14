create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null default '',
  age integer not null default 0,
  gender text not null default 'other',
  height_cm double precision not null default 0,
  weight_kg double precision not null default 0,
  goal text not null default 'health',
  daily_calorie_target integer not null default 2000,
  daily_protein_target integer not null default 60,
  daily_carbs_target integer not null default 250,
  daily_fat_target integer not null default 65,
  daily_sodium_target integer not null default 2300,
  has_kidney_disease boolean not null default false,
  has_liver_disease boolean not null default false,
  medications text[] not null default '{}',
  last_weight_updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table if not exists public.daily_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  date date not null,
  total_calories double precision not null default 0,
  total_carbs_g double precision not null default 0,
  total_protein_g double precision not null default 0,
  total_fat_g double precision not null default 0,
  total_sugar_g double precision not null default 0,
  total_fiber_g double precision not null default 0,
  total_sodium_mg double precision not null default 0,
  total_caffeine_mg double precision not null default 0,
  total_alcohol_g double precision not null default 0,
  total_exercise_calories double precision not null default 0,
  total_water_ml double precision not null default 0,
  daily_medications text[] not null default '{}',
  updated_at timestamptz not null default now(),
  unique (user_id, date)
);

create table if not exists public.food_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  log_date date not null,
  food_id text not null default '',
  food_name text not null default '',
  amount_g double precision not null default 0,
  amount_value double precision not null default 0,
  amount_unit text not null default 'g',
  entry_type text not null default 'food',
  calories double precision not null default 0,
  carbs_g double precision not null default 0,
  protein_g double precision not null default 0,
  fat_g double precision not null default 0,
  sugar_g double precision not null default 0,
  fiber_g double precision not null default 0,
  sodium_mg double precision not null default 0,
  caffeine_mg double precision not null default 0,
  alcohol_g double precision not null default 0,
  logged_at timestamptz not null default now(),
  meal_type text not null default 'snack'
);

create table if not exists public.exercise_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  log_date date not null,
  exercise_name text not null default '',
  duration_minutes double precision not null default 0,
  burned_calories double precision not null default 0,
  logged_at timestamptz not null default now()
);

create index if not exists daily_logs_user_date_idx
  on public.daily_logs (user_id, date);

create index if not exists food_entries_user_date_logged_idx
  on public.food_entries (user_id, log_date, logged_at);

create index if not exists exercise_entries_user_date_logged_idx
  on public.exercise_entries (user_id, log_date, logged_at);

alter table public.profiles enable row level security;
alter table public.daily_logs enable row level security;
alter table public.food_entries enable row level security;
alter table public.exercise_entries enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
drop policy if exists "profiles_insert_own" on public.profiles;
drop policy if exists "profiles_update_own" on public.profiles;
drop policy if exists "daily_logs_select_own" on public.daily_logs;
drop policy if exists "daily_logs_insert_own" on public.daily_logs;
drop policy if exists "daily_logs_update_own" on public.daily_logs;
drop policy if exists "daily_logs_delete_own" on public.daily_logs;
drop policy if exists "food_entries_select_own" on public.food_entries;
drop policy if exists "food_entries_insert_own" on public.food_entries;
drop policy if exists "food_entries_delete_own" on public.food_entries;
drop policy if exists "exercise_entries_select_own" on public.exercise_entries;
drop policy if exists "exercise_entries_insert_own" on public.exercise_entries;
drop policy if exists "exercise_entries_delete_own" on public.exercise_entries;

create policy "profiles_select_own"
  on public.profiles for select
  using (auth.uid() = id);

create policy "profiles_insert_own"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "profiles_update_own"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "daily_logs_select_own"
  on public.daily_logs for select
  using (auth.uid() = user_id);

create policy "daily_logs_insert_own"
  on public.daily_logs for insert
  with check (auth.uid() = user_id);

create policy "daily_logs_update_own"
  on public.daily_logs for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "daily_logs_delete_own"
  on public.daily_logs for delete
  using (auth.uid() = user_id);

create policy "food_entries_select_own"
  on public.food_entries for select
  using (auth.uid() = user_id);

create policy "food_entries_insert_own"
  on public.food_entries for insert
  with check (auth.uid() = user_id);

create policy "food_entries_delete_own"
  on public.food_entries for delete
  using (auth.uid() = user_id);

create policy "exercise_entries_select_own"
  on public.exercise_entries for select
  using (auth.uid() = user_id);

create policy "exercise_entries_insert_own"
  on public.exercise_entries for insert
  with check (auth.uid() = user_id);

create policy "exercise_entries_delete_own"
  on public.exercise_entries for delete
  using (auth.uid() = user_id);
