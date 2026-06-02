-- ============================================================================
-- 보고서용 SQL 쿼리 모음
-- (각 기능과 연계되는 Query + Trigger/View/Rollup 활용 예시)
--
-- 사용법: Supabase SQL Editor에 복붙해서 Run.
--   - 일부는 로그인된 사용자가 있어야 결과가 나옵니다.
--   - 또는 :user_id 자리에 특정 uuid를 직접 넣어서 실행하셔도 됩니다.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- [Q1] 오늘의 영양소 현황 조회 (홈 화면 기능)
-- ----------------------------------------------------------------------------
select
  date,
  total_calories,
  total_carbs_g,
  total_protein_g,
  total_fat_g,
  total_sodium_mg,
  total_caffeine_mg,
  total_alcohol_g,
  total_exercise_calories
from public.daily_logs
where user_id = auth.uid()
  and date = current_date;


-- ----------------------------------------------------------------------------
-- [Q2] 음식 검색 (자동완성 — 트라이그램 GIN 인덱스 사용)
-- ----------------------------------------------------------------------------
select id, food_name, maker_name, calories_per_100, protein_g_per_100
from public.branded_foods
where food_name ilike '%' || '햄버거' || '%'
order by length(food_name)
limit 20;


-- ----------------------------------------------------------------------------
-- [Q3] 약물 카탈로그에서 위험도 높은 약물 조회 (보고서: LLM 시드 활용)
-- ----------------------------------------------------------------------------
select category, display_name, liver_weight, kidney_weight, warning_title
from public.medication_catalog
where liver_weight + kidney_weight >= 10
order by liver_weight + kidney_weight desc;


-- ----------------------------------------------------------------------------
-- [Q4] 운동 카탈로그에서 카테고리별 평균 MET 조회 (보고서: LLM 시드 활용)
-- ----------------------------------------------------------------------------
select
  category,
  count(*) as exercise_count,
  round(avg(met)::numeric, 2) as avg_met,
  round(min(met)::numeric, 2) as min_met,
  round(max(met)::numeric, 2) as max_met
from public.exercise_catalog
group by category
order by avg_met desc;


-- ----------------------------------------------------------------------------
-- [Q5] View 활용 — 주간 영양 요약 조회
-- ----------------------------------------------------------------------------
select *
from public.v_weekly_nutrition_summary
where user_id = auth.uid()
order by week_start desc
limit 12;


-- ----------------------------------------------------------------------------
-- [Q6] Rollup OLAP — 월 / 주 / 일 다단 집계 (소계와 총계 동시 산출)
--      가산점 요구사항: "Query에 Rollup 사용 OLAP 포함"
-- ----------------------------------------------------------------------------
select
  date_trunc('month', date)::date as month,
  date_trunc('week',  date)::date as week,
  date                            as day,
  round(sum(total_calories)::numeric, 1) as sum_calories,
  round(sum(total_protein_g)::numeric, 1) as sum_protein_g,
  round(sum(total_exercise_calories)::numeric, 1) as sum_exercise_kcal
from public.daily_logs
where user_id = auth.uid()
  and date >= current_date - interval '90 days'
group by rollup (
  date_trunc('month', date),
  date_trunc('week',  date),
  date
)
order by month nulls last, week nulls last, day nulls last;


-- ----------------------------------------------------------------------------
-- [Q7] Trigger 동작 검증 — 음식 추가 후 daily_logs가 자동 갱신되는지 확인
--      Trigger 가산점 시연용
-- ----------------------------------------------------------------------------
-- step 1: 추가 전 daily_logs 확인
select date, total_calories, total_protein_g, updated_at
from public.daily_logs
where user_id = auth.uid() and date = current_date;

-- step 2: 음식 1건 직접 INSERT (Trigger가 자동으로 daily_logs를 갱신함)
insert into public.food_entries (
  user_id, log_date, food_id, food_name,
  amount_g, calories, carbs_g, protein_g, fat_g
) values (
  auth.uid(), current_date, 'demo_chicken_breast', '닭가슴살(데모)',
  150, 247, 0, 46.5, 5.4
);

-- step 3: 추가 후 daily_logs 재확인 — total_calories, total_protein_g가 자동 증가
select date, total_calories, total_protein_g, updated_at
from public.daily_logs
where user_id = auth.uid() and date = current_date;


-- ----------------------------------------------------------------------------
-- [Q8] 사용자의 약물 위험 점수 계산 (profiles.medications join medication_catalog)
-- ----------------------------------------------------------------------------
select
  p.id                                            as user_id,
  unnest(p.medications)                           as medication_category,
  m.display_name,
  m.liver_weight,
  m.kidney_weight
from public.profiles p
join public.medication_catalog m
  on m.category = any(p.medications)
where p.id = auth.uid();


-- ----------------------------------------------------------------------------
-- [Q9] 운동별 권장 시간 대비 사용자가 실제로 한 운동 시간 비교
-- ----------------------------------------------------------------------------
select
  e.exercise_name,
  c.recommended_duration_min,
  round(avg(e.duration_minutes)::numeric, 1) as avg_done_minutes,
  count(*) as session_count
from public.exercise_entries e
left join public.exercise_catalog c on c.name = e.exercise_name
where e.user_id = auth.uid()
  and e.log_date >= current_date - interval '30 days'
group by e.exercise_name, c.recommended_duration_min
order by session_count desc;
