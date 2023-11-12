-- This query extracts the age and sex of a patient on admission to the hospital.

-- The columns of the table patients: anchor_age, anchor_year, anchor_year_group
-- provide information regarding the actual patient year for the patient
-- admission, and the patient's age at that time.

SELECT
    ad.hadm_id
    -- calculate the age as anchor_age (60) plus difference between
    -- admit year and the anchor year.
    -- the noqa retains the extra long line so the 
    -- convert to postgres bash script works
    , pa.anchor_age + DATETIME_DIFF(ad.admittime, DATETIME(pa.anchor_year, 1, 1, 0, 0, 0), YEAR) AS age -- noqa: L016
    , pa.gender
FROM aki_study.cohort co
INNER JOIN `physionet-data.mimiciv_hosp.admissions` ad
    ON co.hadm_id = ad.hadm_id
INNER JOIN `physionet-data.mimiciv_hosp.patients` pa
    ON ad.subject_id = pa.subject_id
;