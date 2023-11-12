
SELECT co.hadm_id
    , dr.starttime AS drug_starttime
    , dr.stoptime AS drug_stoptime
FROM aki_study.cohort co
INNER JOIN physionet-data.mimiciv_hosp.prescriptions dr
    ON co.hadm_id = dr.hadm_id
WHERE (
    -- generic names
    LOWER(drug) LIKE '%aspirin%' 
    OR LOWER(drug) LIKE '%ibuprofen%' 
    OR LOWER(drug) LIKE '%ketorolac%'
    -- brand names
    OR LOWER(drug) LIKE '%ecotrin%'
    OR LOWER(drug) LIKE '%motrin%'
    OR LOWER(drug) LIKE '%toradol%'
)
-- starts during the window, or starts before the window and ends after
AND (
    (dr.starttime >= co.aki_window_starttime AND dr.starttime <= co.aki_window_endtime)
    OR (dr.starttime <= co.aki_window_starttime AND dr.stoptime >= co.aki_window_starttime)
)