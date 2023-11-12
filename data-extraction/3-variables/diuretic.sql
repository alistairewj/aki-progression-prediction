SELECT co.hadm_id
    , dr.starttime AS drug_starttime
    , dr.stoptime AS drug_stoptime
FROM aki_study.cohort co
INNER JOIN physionet-data.mimiciv_hosp.prescriptions dr
    ON co.hadm_id = dr.hadm_id
WHERE (
    -- generic names
    lower(drug) like '%lasix%'
    OR lower(drug) like '%furosemide%'
    OR lower(drug) like '%bumex%'
    OR lower(drug) like '%bumetanide%'
)
-- starts during the window, or starts before the window and ends after
AND (
    (dr.starttime >= co.aki_window_starttime AND dr.starttime <= co.aki_window_endtime)
    OR (dr.starttime <= co.aki_window_starttime AND dr.stoptime >= co.aki_window_starttime)
)