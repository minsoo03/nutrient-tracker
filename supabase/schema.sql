create extension if not exists pgcrypto;
create extension if not exists pg_trgm;

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

alter table public.daily_logs
  add column if not exists daily_medication_entries jsonb not null default '[]'::jsonb;

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

create table if not exists public.branded_foods (
  id text primary key,
  food_name text not null default '',
  maker_name text not null default '',
  item_report_no text not null default '',
  db_group_code text not null default '',
  db_group_name text not null default '',
  db_class_code text not null default '',
  db_class_name text not null default '',
  nutrition_basis_label text not null default '100g',
  serving_amount double precision,
  serving_unit text,
  package_amount double precision,
  package_unit text,
  calories_per_100 double precision not null default 0,
  carbs_g_per_100 double precision not null default 0,
  protein_g_per_100 double precision not null default 0,
  fat_g_per_100 double precision not null default 0,
  sugar_g_per_100 double precision not null default 0,
  fiber_g_per_100 double precision not null default 0,
  sodium_mg_per_100 double precision not null default 0,
  caffeine_mg_per_100 double precision not null default 0,
  alcohol_g_per_100 double precision not null default 0,
  source text not null default 'kr_mfds',
  raw_json jsonb,
  updated_at timestamptz not null default now()
);

-- LLM(Claude)이 생성한 약물 위험 카탈로그
-- 약물 카테고리별 간/신장 부담 가중치와 영양소 민감도 정보 (총 30개 행 시드)
create table if not exists public.medication_catalog (
  category text primary key,
  display_name text not null,
  description text not null default '',
  liver_weight numeric not null default 0,
  kidney_weight numeric not null default 0,
  sensitive_to_protein boolean not null default false,
  sensitive_to_alcohol boolean not null default false,
  sensitive_to_caffeine boolean not null default false,
  is_chronic boolean not null default true,
  warning_title text,
  warning_description text,
  warning_nutrient text,
  created_at timestamptz not null default now()
);

-- LLM(Claude)이 생성한 운동 카탈로그
-- MET 값과 카테고리/강도 정보 (총 30개 행 시드)
create table if not exists public.exercise_catalog (
  name text primary key,
  category text not null,
  met numeric not null,
  intensity text not null default 'medium',
  recommended_duration_min int not null default 30,
  description text not null default '',
  created_at timestamptz not null default now()
);

create index if not exists daily_logs_user_date_idx
  on public.daily_logs (user_id, date);

create index if not exists food_entries_user_date_logged_idx
  on public.food_entries (user_id, log_date, logged_at);

create index if not exists exercise_entries_user_date_logged_idx
  on public.exercise_entries (user_id, log_date, logged_at);

-- 한국어 부분검색을 위한 트라이그램 GIN 인덱스 (ilike '%query%' 성능 향상)
create index if not exists branded_foods_name_trgm_idx
  on public.branded_foods using gin (food_name gin_trgm_ops);

create index if not exists branded_foods_maker_trgm_idx
  on public.branded_foods using gin (maker_name gin_trgm_ops);

alter table public.profiles enable row level security;
alter table public.daily_logs enable row level security;
alter table public.food_entries enable row level security;
alter table public.exercise_entries enable row level security;
alter table public.branded_foods enable row level security;

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
drop policy if exists "branded_foods_select_all" on public.branded_foods;
drop policy if exists "branded_foods_insert_authenticated" on public.branded_foods;
drop policy if exists "branded_foods_update_authenticated" on public.branded_foods;

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

create policy "branded_foods_select_all"
  on public.branded_foods for select
  using (true);

-- 로그인된 사용자는 외부 API에서 받아온 식품 데이터를 공유 캐시(branded_foods)에 저장 가능
-- (id 충돌 시 upsert로 최신화)
create policy "branded_foods_insert_authenticated"
  on public.branded_foods for insert
  to authenticated
  with check (true);

create policy "branded_foods_update_authenticated"
  on public.branded_foods for update
  to authenticated
  using (true)
  with check (true);

-- ============================================================================
-- LLM 생성 카탈로그 테이블 RLS — 누구나 read, 쓰기 금지 (관리자가 일괄 시드)
-- ============================================================================
alter table public.medication_catalog enable row level security;
alter table public.exercise_catalog enable row level security;

drop policy if exists "medication_catalog_select_all" on public.medication_catalog;
drop policy if exists "exercise_catalog_select_all" on public.exercise_catalog;

create policy "medication_catalog_select_all"
  on public.medication_catalog for select using (true);
create policy "exercise_catalog_select_all"
  on public.exercise_catalog for select using (true);

-- ============================================================================
-- LLM 시드 데이터: medication_catalog (30개)
-- ============================================================================
insert into public.medication_catalog
  (category, display_name, description, liver_weight, kidney_weight,
   sensitive_to_protein, sensitive_to_alcohol, sensitive_to_caffeine, is_chronic,
   warning_title, warning_description, warning_nutrient)
values
  ('항응고제', '항응고제 (와파린 등)', '혈액 응고를 막아 혈전을 예방하는 약물',
    4, 0, false, true, false, true,
    '비타민K 주의', '와파린 복용 중 시금치·브로콜리 등 비타민K 식품 과다 섭취 주의', 'vitaminK'),
  ('이뇨제', '이뇨제', '수분과 나트륨 배출을 늘려 부종·고혈압을 완화',
    0, 8, false, false, true, true,
    '칼륨 보충 필요', '루프 이뇨제 복용 시 바나나·감자 등 칼륨 식품 섭취 권장', 'potassiumMg'),
  ('ACE억제제', 'ACE 억제제', '혈관 확장으로 고혈압을 조절',
    0, 6, false, false, false, true,
    '칼륨 과다 주의', '칼륨 보유 효과로 고칼륨혈증 위험', 'potassiumMg'),
  ('스타틴(고지혈증약)', '스타틴', '콜레스테롤 합성을 억제',
    6, 0, false, true, false, true,
    '자몽 주의', '자몽즙이 스타틴 대사를 방해해 부작용 증가 가능', 'fat'),
  ('MAO억제제(항우울제)', 'MAO 억제제', '단가아민 산화효소를 억제하는 항우울제',
    6, 0, false, true, true, true,
    '티라민 식품 주의', '치즈·청어·발효식품 등 티라민 섭취 금지', 'proteinG'),
  ('철분제', '철분 보충제', '철 결핍성 빈혈 예방·치료',
    2, 0, false, false, true, true,
    '칼슘·카페인 분리 복용', '복용 2시간 전후로 유제품·커피 피할 것', 'caffeineMg'),
  ('신장 투석', '신장 투석', '신부전 환자의 노폐물·수분 제거 치료',
    0, 18, true, false, false, true,
    '단백질·칼륨·인 엄격 제한', '단백질 0.6~0.8g/kg, 칼륨 2000mg, 인 800mg 이하', 'proteinG'),
  ('피부과약(이소트레티노인 등)', '피부과 레티노이드', '중증 여드름 치료용 비타민A 유도체',
    12, 2, true, true, false, true,
    '간 부담 주의', '음주·고지방·고용량 보충제와 함께 복용 시 간 부담 가중', 'alcoholG'),
  ('소염진통제(NSAIDs)', '소염진통제 (NSAIDs)', '염증·통증·발열을 완화',
    4, 10, true, true, false, false,
    '신장 부담 주의', '탈수·고단백·음주와 겹치면 신장 부담 가중', 'proteinG'),
  ('진통제', '일반 진통제', '아세트아미노펜 등 단기 통증 완화',
    4, 5, true, true, false, false, null, null, null),
  ('해열제', '해열제', '발열을 가라앉히는 약물',
    5, 2, false, true, false, false, null, null, null),
  ('감기약', '종합 감기약', '코·기침·콧물·열 등 감기 증상 완화',
    3, 2, false, true, false, false, null, null, null),
  ('항생제', '항생제', '세균 감염 치료',
    4, 3, false, false, false, false, null, null, null),
  ('알레르기약', '항히스타민제', '알레르기·비염·두드러기 완화',
    1, 0, false, false, true, false, null, null, null),
  -- ↓ 여기부터 LLM 추가 생성 (16개)
  ('당뇨약(메트포르민)', '메트포르민', '제2형 당뇨병의 1차 치료제',
    3, 4, false, true, false, true,
    '알코올 주의', '음주 시 젖산산증 위험 증가', 'alcoholG'),
  ('인슐린', '인슐린', '제1형·중증 제2형 당뇨에 사용',
    1, 1, false, true, false, true, null, null, null),
  ('베타차단제', '베타 차단제', '심박수·혈압을 낮춤',
    2, 3, false, true, true, true, null, null, null),
  ('칼슘채널차단제', '칼슘 채널 차단제', '혈관 평활근 이완으로 혈압 조절',
    2, 2, false, true, false, true,
    '자몽 주의', '자몽즙이 약효를 증가시켜 저혈압 위험', 'fat'),
  ('PPI(위산억제제)', '프로톤펌프 억제제', '위산 분비를 강하게 억제',
    3, 2, false, false, false, true, null, null, null),
  ('변비약', '완하제', '대장 운동을 자극하거나 수분 보유',
    1, 1, false, false, false, false, null, null, null),
  ('항암제', '경구 항암제', '암세포 증식을 억제',
    10, 8, true, true, false, true,
    '간·신장 부담 큼', '음주·자몽·고단백 보충제 동시 섭취 주의', 'alcoholG'),
  ('면역억제제', '면역 억제제', '장기이식·자가면역질환에 사용',
    8, 6, false, true, true, true,
    '자몽 주의', '자몽이 혈중농도를 크게 변화시킴', 'fat'),
  ('갑상선약(레보티록신)', '레보티록신', '갑상선 호르몬 보충',
    2, 1, false, false, true, true,
    '공복 복용', '커피·칼슘·철분 분리 복용 (30분 이상 간격)', 'caffeineMg'),
  ('골다공증약(비스포스포네이트)', '비스포스포네이트', '뼈 흡수를 억제',
    2, 3, false, false, true, true,
    '공복·물 충분히', '복용 후 30분 이상 눕지 말 것', 'caffeineMg'),
  ('SSRI(항우울제)', 'SSRI 항우울제', '세로토닌 재흡수 억제',
    4, 2, false, true, true, true, null, null, null),
  ('벤조다이아제핀', '벤조다이아제핀', '항불안·수면제',
    5, 2, false, true, true, true,
    '알코올 절대 금지', '호흡억제 위험', 'alcoholG'),
  ('수면제(졸피뎀)', '졸피뎀', '단기 불면증 치료',
    4, 1, false, true, true, false, null, null, null),
  ('항경련제', '항경련제', '간질·신경통 치료',
    6, 3, false, true, false, true, null, null, null),
  ('비타민D 보충제', '비타민 D3', '뼈 건강·면역 보조',
    0, 0, false, false, false, true, null, null, null),
  ('오메가3', '오메가-3 (EPA·DHA)', '심혈관 건강 보조',
    0, 0, false, false, false, true, null, null, null),
  ('프로바이오틱스', '유산균 보충제', '장내 미생물 균형',
    0, 0, false, false, false, true, null, null, null)
on conflict (category) do update set
  display_name = excluded.display_name,
  description = excluded.description,
  liver_weight = excluded.liver_weight,
  kidney_weight = excluded.kidney_weight,
  sensitive_to_protein = excluded.sensitive_to_protein,
  sensitive_to_alcohol = excluded.sensitive_to_alcohol,
  sensitive_to_caffeine = excluded.sensitive_to_caffeine,
  is_chronic = excluded.is_chronic,
  warning_title = excluded.warning_title,
  warning_description = excluded.warning_description,
  warning_nutrient = excluded.warning_nutrient;

-- ============================================================================
-- LLM 시드 데이터: exercise_catalog (31개)
-- ============================================================================
insert into public.exercise_catalog
  (name, category, met, intensity, recommended_duration_min, description)
values
  ('걷기', '유산소', 3.8, 'low', 40, '평지에서 가벼운 속도로 걷기'),
  ('빠르게 걷기', '유산소', 4.8, 'medium', 35, '시속 5.5~6.5km 속도의 파워워킹'),
  ('조깅', '유산소', 7.0, 'medium', 30, '편안하게 대화 가능한 정도의 달리기'),
  ('러닝', '유산소', 9.8, 'high', 30, '본격적인 달리기'),
  ('자전거', '유산소', 6.8, 'medium', 40, '평지 자전거 라이딩'),
  ('근력운동', '근력', 5.0, 'medium', 45, '웨이트 트레이닝 (중강도)'),
  ('수영', '수상', 6.0, 'medium', 30, '자유형·평영 등 일반 수영'),
  ('계단 오르기', '유산소', 8.8, 'high', 20, '계단 오르내리기'),
  ('요가/스트레칭', '유연성', 2.8, 'low', 40, '하타·빈야사 요가 등'),
  -- ↓ LLM 추가 생성 (22개)
  ('등산', '유산소', 7.3, 'medium', 90, '완만한 산길 등반'),
  ('필라테스', '코어', 3.8, 'low', 50, '코어 강화와 자세 교정'),
  ('테니스', '구기', 7.3, 'medium', 60, '단식 기준'),
  ('배드민턴', '구기', 5.5, 'medium', 45, '복식 기준'),
  ('탁구', '구기', 4.0, 'low', 45, '실내 라켓 스포츠'),
  ('농구', '구기', 8.0, 'high', 45, '하프코트~풀코트 경기'),
  ('축구', '구기', 9.0, 'high', 60, '필드 경기'),
  ('배구', '구기', 4.0, 'medium', 60, '실내 배구'),
  ('야구', '구기', 5.0, 'medium', 90, '경기 중 평균 활동량'),
  ('복싱', '격투', 9.5, 'high', 30, '샌드백 또는 미트 트레이닝'),
  ('태권도', '격투', 8.5, 'high', 50, '품새와 발차기 훈련'),
  ('줄넘기', '유산소', 11.0, 'high', 15, '쉬지 않고 빠른 속도로'),
  ('HIIT', '유산소', 9.0, 'high', 20, '고강도 인터벌 트레이닝'),
  ('크로스핏', '복합', 8.5, 'high', 45, '서킷 + 웨이트 + 유산소'),
  ('에어로빅', '유산소', 6.5, 'medium', 45, '음악에 맞춘 댄스성 운동'),
  ('줌바', '유산소', 7.5, 'medium', 50, '라틴 댄스 기반 유산소'),
  ('스피닝', '유산소', 8.5, 'high', 45, '실내 자전거 그룹운동'),
  ('클라이밍', '근력', 8.0, 'high', 60, '실내 볼더링·리드 클라이밍'),
  ('인라인스케이팅', '유산소', 7.5, 'medium', 45, '평지 인라인'),
  ('스키', '유산소', 7.0, 'high', 60, '활강 스키'),
  ('스노보드', '유산소', 5.3, 'medium', 60, '레저용 스노보드'),
  ('골프', '구기', 4.8, 'low', 240, '카트 없이 라운딩')
on conflict (name) do update set
  category = excluded.category,
  met = excluded.met,
  intensity = excluded.intensity,
  recommended_duration_min = excluded.recommended_duration_min,
  description = excluded.description;

-- ============================================================================
-- Trigger: food_entries / exercise_entries 변경 → daily_logs 자동 합산
-- (기존 클라이언트의 rebuildDailyLogTotals를 서버사이드로 대체)
-- ============================================================================
create or replace function public.fn_rebuild_daily_log()
returns trigger
language plpgsql
security definer
as $$
declare
  v_user_id uuid;
  v_log_date date;
  v_food record;
  v_exercise_kcal numeric;
begin
  if tg_op = 'DELETE' then
    v_user_id := old.user_id;
    v_log_date := old.log_date;
  else
    v_user_id := new.user_id;
    v_log_date := new.log_date;
  end if;

  select
    coalesce(sum(calories), 0)     as total_calories,
    coalesce(sum(carbs_g), 0)      as total_carbs_g,
    coalesce(sum(protein_g), 0)    as total_protein_g,
    coalesce(sum(fat_g), 0)        as total_fat_g,
    coalesce(sum(sugar_g), 0)      as total_sugar_g,
    coalesce(sum(fiber_g), 0)      as total_fiber_g,
    coalesce(sum(sodium_mg), 0)    as total_sodium_mg,
    coalesce(sum(caffeine_mg), 0)  as total_caffeine_mg,
    coalesce(sum(alcohol_g), 0)    as total_alcohol_g
  into v_food
  from public.food_entries
  where user_id = v_user_id and log_date = v_log_date;

  select coalesce(sum(burned_calories), 0) into v_exercise_kcal
  from public.exercise_entries
  where user_id = v_user_id and log_date = v_log_date;

  insert into public.daily_logs (
    user_id, date,
    total_calories, total_carbs_g, total_protein_g, total_fat_g,
    total_sugar_g, total_fiber_g, total_sodium_mg, total_caffeine_mg,
    total_alcohol_g, total_exercise_calories, updated_at
  ) values (
    v_user_id, v_log_date,
    v_food.total_calories, v_food.total_carbs_g, v_food.total_protein_g, v_food.total_fat_g,
    v_food.total_sugar_g, v_food.total_fiber_g, v_food.total_sodium_mg, v_food.total_caffeine_mg,
    v_food.total_alcohol_g, v_exercise_kcal, now()
  )
  on conflict (user_id, date) do update set
    total_calories = excluded.total_calories,
    total_carbs_g = excluded.total_carbs_g,
    total_protein_g = excluded.total_protein_g,
    total_fat_g = excluded.total_fat_g,
    total_sugar_g = excluded.total_sugar_g,
    total_fiber_g = excluded.total_fiber_g,
    total_sodium_mg = excluded.total_sodium_mg,
    total_caffeine_mg = excluded.total_caffeine_mg,
    total_alcohol_g = excluded.total_alcohol_g,
    total_exercise_calories = excluded.total_exercise_calories,
    updated_at = now();

  return null;
end;
$$;

drop trigger if exists trg_food_entries_rebuild_log on public.food_entries;
drop trigger if exists trg_exercise_entries_rebuild_log on public.exercise_entries;

create trigger trg_food_entries_rebuild_log
after insert or update or delete on public.food_entries
for each row execute function public.fn_rebuild_daily_log();

create trigger trg_exercise_entries_rebuild_log
after insert or update or delete on public.exercise_entries
for each row execute function public.fn_rebuild_daily_log();

-- ============================================================================
-- View: 주간 영양 요약 (대시보드·보고서용)
-- ============================================================================
create or replace view public.v_weekly_nutrition_summary as
select
  user_id,
  date_trunc('week', date)::date as week_start,
  round(avg(total_calories)::numeric, 1)    as avg_daily_calories,
  round(avg(total_protein_g)::numeric, 1)   as avg_daily_protein_g,
  round(avg(total_carbs_g)::numeric, 1)     as avg_daily_carbs_g,
  round(avg(total_fat_g)::numeric, 1)       as avg_daily_fat_g,
  round(avg(total_sodium_mg)::numeric, 1)   as avg_daily_sodium_mg,
  round(avg(total_caffeine_mg)::numeric, 1) as avg_daily_caffeine_mg,
  round(avg(total_alcohol_g)::numeric, 1)   as avg_daily_alcohol_g,
  count(*) as logged_days
from public.daily_logs
group by user_id, date_trunc('week', date);
