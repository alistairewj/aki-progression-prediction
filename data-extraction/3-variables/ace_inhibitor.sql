SELECT co.hadm_id
    , dr.starttime AS drug_starttime
    , dr.stoptime AS drug_stoptime
FROM aki_study.cohort co
INNER JOIN physionet-data.mimiciv_hosp.prescriptions dr
    ON co.hadm_id = dr.hadm_id
WHERE (
    lower(drug) like '%benazepril%' OR lower(drug) like '%lotensin%'
    OR LOWER(drug) LIKE '%captopril%' OR LOWER(drug) LIKE '%capoten%'
    OR LOWER(drug) LIKE '%enalapril%' OR LOWER(drug) LIKE '%enalaprilat%' OR LOWER(drug) LIKE '%vasotec%'
    OR LOWER(drug) LIKE '%fosinopril%' OR LOWER(drug) LIKE '%monopril%'
    OR LOWER(drug) LIKE '%pisinopril%' OR LOWER(drug) LIKE '%zestril%' OR LOWER(drug) LIKE '%prinivil%'
    OR LOWER(drug) LIKE '%moexipril%' OR LOWER(drug) LIKE '%univasc%'
    OR LOWER(drug) LIKE '%perindopril%' OR LOWER(drug) LIKE '%aceon%'
    OR LOWER(drug) LIKE '%quinapril%' OR LOWER(drug) LIKE '%accupril%'
    OR LOWER(drug) LIKE '%ramipril%' OR LOWER(drug) LIKE '%altace%'
    OR LOWER(drug) LIKE '%trandolapril%' OR LOWER(drug) LIKE '%mavik%'
)
-- starts during the window, or starts before the window and ends after
AND (
    (dr.starttime >= co.aki_window_starttime AND dr.starttime <= co.aki_window_endtime)
    OR (dr.starttime <= co.aki_window_starttime AND dr.stoptime >= co.aki_window_starttime)
)