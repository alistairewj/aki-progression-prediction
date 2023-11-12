SELECT co.hadm_id
    , a.starttime AS antibiotic_starttime
    , a.stoptime AS antibiotic_stoptime
FROM aki_study.cohort co
INNER JOIN physionet-data.mimiciv_derived.antibiotic a
    ON co.hadm_id = a.hadm_id
    -- starts during the window, or starts before the window and ends after
    AND (
        (a.starttime >= co.aki_window_starttime AND a.starttime <= co.aki_window_endtime)
        OR (a.starttime <= co.aki_window_starttime AND a.stoptime >= co.aki_window_starttime)
    )