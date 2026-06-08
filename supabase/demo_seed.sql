-- ============================================================================
-- demo_seed.sql — LLM(Claude)이 생성한 데모 시드 데이터
--
-- 목적: 과제 요건 [2] "나머지 Table들은 LLM을 활용해 데이터를 생성해서 사용"
--       + 보고서 [4] "각 Table별 실제 Tuple 갯수 표시 / 10개 Tuple 포함" 충족
--
-- 생성되는 데이터:
--   profiles          : 5개 행 (가상 사용자)
--   food_entries      : 약 150~200개 행 (7일 × 5명 × 평균 5끼)
--   exercise_entries  : 약 30~50개 행 (7일 × 5명 × 평균 1회)
--   daily_logs        : 약 35개 행 (트리거가 자동 합산)
--
-- 사용법: Supabase SQL Editor에서 통째로 Run.
-- 멱등성: ON CONFLICT 처리되어 있어 여러 번 실행해도 안전.
-- ============================================================================


-- ============================================================================
-- [1] FK 제약 해제 — auth.users 외부키를 일시 해제
-- 데모 시드는 실제 auth.users에 없는 가상 UUID를 사용하므로 FK가 막음.
-- 학술 제출 목적이라 데모 단계에서는 해제. 실제 운영 시 복원 가능.
-- ============================================================================
alter table public.profiles         drop constraint if exists profiles_id_fkey;
alter table public.daily_logs       drop constraint if exists daily_logs_user_id_fkey;
alter table public.food_entries     drop constraint if exists food_entries_user_id_fkey;
alter table public.exercise_entries drop constraint if exists exercise_entries_user_id_fkey;


-- ============================================================================
-- [2] 데모 사용자 5명 — LLM이 생성한 가상 프로필
-- 고정 UUID로 idempotent 보장
-- ============================================================================
insert into public.profiles
  (id, name, age, gender, height_cm, weight_kg, goal,
   daily_calorie_target, daily_protein_target, daily_carbs_target, daily_fat_target,
   has_kidney_disease, has_liver_disease, medications,
   last_weight_updated_at, created_at)
values
  ('11111111-1111-1111-1111-111111111111', '[DEMO] 김민지', 25, 'female', 165, 55, 'diet',
    1600, 60, 200, 50, false, false, ARRAY[]::text[],
    now(), now() - interval '30 days'),
  ('22222222-2222-2222-2222-222222222222', '[DEMO] 이준호', 32, 'male',   178, 78, 'muscle',
    2800, 140, 350, 80, false, false, ARRAY['프로바이오틱스'],
    now(), now() - interval '60 days'),
  ('33333333-3333-3333-3333-333333333333', '[DEMO] 박서연', 28, 'female', 168, 60, 'health',
    2000, 70, 250, 65, false, false, ARRAY['비타민D 보충제', '오메가3'],
    now(), now() - interval '15 days'),
  ('44444444-4444-4444-4444-444444444444', '[DEMO] 최도윤', 45, 'male',   175, 85, 'medical',
    2200, 85, 270, 70, true,  false, ARRAY['ACE억제제', '이뇨제'],
    now(), now() - interval '90 days'),
  ('55555555-5555-5555-5555-555555555555', '[DEMO] 정수아', 22, 'female', 160, 52, 'muscle',
    1900, 80, 230, 55, false, false, ARRAY['철분제'],
    now(), now() - interval '7 days')
on conflict (id) do update set
  name = excluded.name,
  age = excluded.age,
  goal = excluded.goal,
  medications = excluded.medications;


-- ============================================================================
-- [3] 기존 데모 데이터 정리 (재실행 시 중복 방지)
-- ============================================================================
delete from public.food_entries
  where user_id::text in (
    '11111111-1111-1111-1111-111111111111',
    '22222222-2222-2222-2222-222222222222',
    '33333333-3333-3333-3333-333333333333',
    '44444444-4444-4444-4444-444444444444',
    '55555555-5555-5555-5555-555555555555'
  );
delete from public.exercise_entries
  where user_id::text in (
    '11111111-1111-1111-1111-111111111111',
    '22222222-2222-2222-2222-222222222222',
    '33333333-3333-3333-3333-333333333333',
    '44444444-4444-4444-4444-444444444444',
    '55555555-5555-5555-5555-555555555555'
  );


-- ============================================================================
-- [4] food_entries 시드 — LLM 생성 30개 음식 템플릿 × 5명 × 7일
-- hashtext 기반 의사난수 분포로 사용자별 일일 4~6끼 정도 자동 선택
-- ============================================================================
with food_templates(food_name, amount_g, calories, carbs_g, protein_g, fat_g, sugar_g, fiber_g, sodium_mg, meal_type) as (
  values
    ('닭가슴살 샐러드', 200, 280, 12,  35,  8, 5,  4,  320, 'lunch'),
    ('현미밥 1공기',    200, 220, 47,   4,  1, 0,  2,    5, 'lunch'),
    ('연어구이',        150, 310,  0,  32, 18, 0,  0,  110, 'dinner'),
    ('그릭요거트',      150,  90,  8,  12,  2, 6,  0,   60, 'breakfast'),
    ('블루베리',         80,  45, 12, 0.5,0.3, 8,  2,    1, 'breakfast'),
    ('아메리카노',      350,   5,  0, 0.3,  0, 0,  0,    5, 'breakfast'),
    ('계란후라이 2개',  100, 196,  1,  14, 14, 0,  0,  168, 'breakfast'),
    ('통밀빵 2조각',     80, 196, 36,   8,  3, 4,  6,  332, 'breakfast'),
    ('바나나',          120, 105, 27,   1,0.4,14,  3,    1, 'snack'),
    ('두부김치',        250, 195,  8,  22,  9, 3,  4,  880, 'dinner'),
    ('된장찌개',        300, 145, 14,  11,  5, 3,  5, 1200, 'dinner'),
    ('미역국',          250,  70,  9,   6,  1, 1,  3,  620, 'dinner'),
    ('샤브샤브',        400, 380, 18,  35, 16, 4,  6, 1500, 'dinner'),
    ('새우볶음밥',      300, 480, 65,  18, 14, 3,  3,  820, 'lunch'),
    ('비빔밥',          350, 510, 70,  22, 13, 5,  7,  900, 'lunch'),
    ('김밥 1줄',        200, 320, 50,  12,  7, 3,  4,  680, 'lunch'),
    ('떡볶이',          250, 410, 70,   8, 10,18,  3, 1100, 'lunch'),
    ('피자 2조각',      240, 540, 60,  22, 22, 7,  3, 1240, 'dinner'),
    ('치킨 3조각',      300, 720, 18,  60, 45, 1,  0, 1500, 'dinner'),
    ('라면',            500, 480, 70,  11, 18, 4,  3, 1900, 'dinner'),
    ('초콜릿',           50, 270, 30,   4, 15,28,  3,   30, 'snack'),
    ('견과류 한 줌',     30, 180,  6,   6, 16, 1,  3,    5, 'snack'),
    ('아이스크림',      100, 220, 25,   4, 12,22,  0,   75, 'snack'),
    ('과일주스',        250, 120, 28,   1,0.3,25,  1,   10, 'snack'),
    ('녹차',            250,   2,  0,   0,  0, 0,  0,    2, 'snack'),
    ('우유 1잔',        200, 122, 10,   7,  5,10,  0,   95, 'snack'),
    ('두유',            200, 110,  9,   7,  4, 5,  1,   95, 'snack'),
    ('단백질쉐이크',    300, 165,  6,  25,  3, 3,  1,  110, 'snack'),
    ('샌드위치',        200, 320, 35,  18, 12, 4,  3,  720, 'lunch'),
    ('스파게티',        350, 580, 85,  20, 18, 8,  4,  850, 'lunch')
),
demo_users as (
  select id from public.profiles where id::text in (
    '11111111-1111-1111-1111-111111111111',
    '22222222-2222-2222-2222-222222222222',
    '33333333-3333-3333-3333-333333333333',
    '44444444-4444-4444-4444-444444444444',
    '55555555-5555-5555-5555-555555555555'
  )
)
insert into public.food_entries
  (user_id, log_date, food_id, food_name, amount_g,
   calories, carbs_g, protein_g, fat_g, sugar_g, fiber_g, sodium_mg,
   meal_type, logged_at)
select
  u.id,
  (current_date - (d || ' days')::interval)::date,
  'demo_' || substring(md5(f.food_name), 1, 12),
  f.food_name,
  f.amount_g,
  f.calories, f.carbs_g, f.protein_g, f.fat_g, f.sugar_g, f.fiber_g, f.sodium_mg,
  f.meal_type,
  (current_date - (d || ' days')::interval)::timestamptz
    + case f.meal_type
        when 'breakfast' then interval '8 hours'
        when 'lunch'     then interval '13 hours'
        when 'dinner'    then interval '19 hours'
        else                  interval '15 hours'
      end
from demo_users u
cross join generate_series(0, 6) as d
cross join food_templates f
where
  -- 사용자/날짜/음식 해시로 약 1/6 확률 → 사용자당 일평균 약 5끼 선택
  (hashtext(u.id::text || f.food_name || d::text) & 2147483647) % 6 = 0;


-- ============================================================================
-- [5] exercise_entries 시드 — LLM 생성 20개 운동 템플릿
-- ============================================================================
with exercise_templates(exercise_name, duration_min, burned_kcal) as (
  values
    ('걷기',             45,  180),
    ('빠르게 걷기',      30,  144),
    ('조깅',             30,  210),
    ('러닝',             25,  245),
    ('자전거',           40,  272),
    ('근력운동',         60,  300),
    ('수영',             30,  180),
    ('요가/스트레칭',    50,  140),
    ('필라테스',         50,  190),
    ('테니스',           60,  438),
    ('배드민턴',         45,  248),
    ('농구',             45,  360),
    ('등산',             90,  660),
    ('줄넘기',           15,  165),
    ('HIIT',             20,  180),
    ('크로스핏',         45,  380),
    ('에어로빅',         45,  290),
    ('줌바',             50,  375),
    ('클라이밍',         60,  480),
    ('골프',            240, 1150)
),
demo_users as (
  select id from public.profiles where id::text in (
    '11111111-1111-1111-1111-111111111111',
    '22222222-2222-2222-2222-222222222222',
    '33333333-3333-3333-3333-333333333333',
    '44444444-4444-4444-4444-444444444444',
    '55555555-5555-5555-5555-555555555555'
  )
)
insert into public.exercise_entries
  (user_id, log_date, exercise_name, duration_minutes, burned_calories, logged_at)
select
  u.id,
  (current_date - (d || ' days')::interval)::date,
  e.exercise_name,
  e.duration_min,
  e.burned_kcal,
  (current_date - (d || ' days')::interval)::timestamptz + interval '18 hours'
from demo_users u
cross join generate_series(0, 6) as d
cross join exercise_templates e
where
  -- 약 1/15 확률 → 사용자당 일평균 1.3개 운동 선택
  (hashtext(u.id::text || e.exercise_name || d::text) & 2147483647) % 15 = 0;


-- ============================================================================
-- [6] daily_logs 는 별도 INSERT 불필요
-- 위의 food_entries / exercise_entries INSERT가 트리거를 발동시켜
-- fn_rebuild_daily_log() 가 자동으로 daily_logs를 채워줌
-- → 트리거 가산점 시연 + 데이터 정합성 자동 보장
-- ============================================================================


-- ============================================================================
-- [7] 시드 결과 검증 — 각 테이블 tuple 갯수 확인
-- ============================================================================
select 'profiles'         as table_name, count(*) as tuple_count from public.profiles
union all
select 'daily_logs',         count(*) from public.daily_logs
union all
select 'food_entries',       count(*) from public.food_entries
union all
select 'exercise_entries',   count(*) from public.exercise_entries
union all
select 'branded_foods',      count(*) from public.branded_foods
union all
select 'medication_catalog', count(*) from public.medication_catalog
union all
select 'exercise_catalog',   count(*) from public.exercise_catalog
order by table_name;


-- ============================================================================
-- (참고) FK 복원이 필요한 경우 — 아래 주석 해제 후 실행
-- ============================================================================
-- alter table public.profiles add constraint profiles_id_fkey
--   foreign key (id) references auth.users(id) on delete cascade;
-- alter table public.daily_logs add constraint daily_logs_user_id_fkey
--   foreign key (user_id) references auth.users(id) on delete cascade;
-- alter table public.food_entries add constraint food_entries_user_id_fkey
--   foreign key (user_id) references auth.users(id) on delete cascade;
-- alter table public.exercise_entries add constraint exercise_entries_user_id_fkey
--   foreign key (user_id) references auth.users(id) on delete cascade;
