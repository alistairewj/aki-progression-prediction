-- SOFA at AKIN1 diagnosis
-- APACHES at AKIN1 diagnosis
SELECT co.hadm_id
    , s.sofa_24hours AS sofa_score
FROM aki_study.cohort co
INNER JOIN physionet-data.mimiciv_hosp.transfers t
    ON co.hadm_id = t.hadm_id
INNER JOIN physionet-data.mimiciv_derived.sofa s
    ON t.transfer_id = s.stay_id
    -- sofa is charted hourly, so join to the last avail softa
    AND s.endtime = DATETIME_TRUNC(co.aki_window_endtime, HOUR)
;
