-- Extract relevant comorbidities:
-- Heart failure previous diagnosis
-- Diabetes previous diagnosis
-- HTN as previous diagnosis
-- Cirrhosis previous diagnosis
-- Previous stroke (ictus, isquemic stroke) as previous  diagnposis
-- Peripheral vasculopathy / Amputation (to identify vasculopathy) ) as previous  diagnposis
SELECT 
co.hadm_id
-- , myocardial_infarct
, congestive_heart_failure
, GREATEST(COALESCE(diabetes_without_cc, 0), COALESCE(diabetes_with_cc, 0)) as diabetes
-- HTN?
-- cirrhosis
, mild_liver_disease
, severe_liver_disease
-- previous stroke?
, peripheral_vascular_disease
, renal_disease
FROM aki_study.cohort co
INNER JOIN physionet-data.mimiciv_derived.charlson ch
    ON co.hadm_id = ch.hadm_id