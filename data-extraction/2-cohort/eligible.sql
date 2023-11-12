-- This query defines the cohort used for the ALINE study.

-- Inclusion criteria:
--  Admitted to the emergency department
--  Age >= 16
--  AKI stage 1 at any time during the hospitalization
--    This is the start time of the observation of the patient.

-- Exclusion criteria:
--  None.

-- This query requires the following tables from the MIMIC code repository:
--  physionet-data.mimiciv_derived.kdigo_stages


-- get the *first* instance of AKI stage >= 1
with aki_stages as
(
  select kd.subject_id
  , kd.hadm_id
  , charttime
  , aki_stage_creat
  , creat
  , creat_low_past_7day
  , creat_low_past_48hr
  , ROW_NUMBER() OVER (PARTITION BY kd.hadm_id ORDER BY charttime) AS rn
  FROM `physionet-data.mimiciv_derived.kdigo_stages` kd
  INNER JOIN `physionet-data.mimiciv_hosp.admissions` adm
    ON kd.hadm_id = adm.hadm_id
  -- AKI stage creatinine is NULL when no creatinine is assessed
  -- since the table calculates AKI stage for both UO/cr
  WHERE aki_stage_creat IS NOT NULL
  AND aki_stage_creat >= 1
  -- since kdigo_stages allows for data up to 7 days before hospitalization, we limit to day 1
  AND kd.charttime >= DATETIME_SUB(adm.admittime, INTERVAL 24 HOUR)
)
SELECT 
    adm.subject_id, adm.hadm_id
    , adm.admittime, adm.dischtime

    -- time of a-line
    , a.charttime as starttime_aki
    , a.aki_stage_creat

    -- columns which help filter data
    , DATETIME_SUB(a.charttime, INTERVAL 24 HOUR) AS aki_window_starttime
    , a.charttime AS aki_window_endtime
    -- , a.creat
    -- , a.creat_low_past_7day
    -- , a.creat_low_past_48hr
    , CASE WHEN adm.edregtime IS NOT NULL THEN 0 ELSE 1 END AS exclude_not_ed
    , CASE WHEN a.aki_stage_creat = 1 THEN 0 ELSE 1 END AS exclude_not_aki_stage_1
  FROM `physionet-data.mimic_core.admissions` adm
  LEFT JOIN aki_stages a
    on adm.hadm_id = a.hadm_id
    AND a.rn = 1
;