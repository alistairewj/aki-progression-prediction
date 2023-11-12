SELECT co.hadm_id
    , dr.starttime AS drug_starttime
    , dr.stoptime AS drug_stoptime
FROM aki_study.cohort co
INNER JOIN physionet-data.mimiciv_hosp.prescriptions dr
    ON co.hadm_id = dr.hadm_id
WHERE (
    lower(drug) like '%benicar%' OR lower(drug) like '%olmesartan%'
    OR LOWER(drug) LIKE '%diovan%' OR LOWER(drug) LIKE '%valsartan%'
    OR LOWER(drug) LIKE '%cozaar%' OR LOWER(drug) LIKE '%losartan%'
    OR LOWER(drug) LIKE '%edarbi%' OR LOWER(drug) LIKE '%azilsartan medoxomil%'
    OR LOWER(drug) LIKE '%micardis%' OR LOWER(drug) LIKE '%telmisartan%'
    OR LOWER(drug) LIKE '%avapro%' OR LOWER(drug) LIKE '%irbesartan%'
    OR LOWER(drug) LIKE '%atacand%' OR LOWER(drug) LIKE '%candesartan%'
    OR LOWER(drug) LIKE '%teveten%' OR LOWER(drug) LIKE '%eprosartan%'
    OR LOWER(drug) LIKE '%prexxartan%' OR LOWER(drug) LIKE '%valsartan%'
)
-- starts during the window, or starts before the window and ends after
AND (
    (dr.starttime >= co.aki_window_starttime AND dr.starttime <= co.aki_window_endtime)
    OR (dr.starttime <= co.aki_window_starttime AND dr.stoptime >= co.aki_window_starttime)
)