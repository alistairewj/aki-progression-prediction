SELECT co.hadm_id
    , p.ordertime AS imaging_ordertime
    , p.order_subtype AS imaging_type
FROM aki_study.cohort co
INNER JOIN physionet-data.mimiciv_hosp.poe p
    ON co.hadm_id = p.hadm_id
    AND p.ordertime >= co.aki_window_starttime
    AND p.ordertime <= co.aki_window_endtime
-- include imaging orders
WHERE order_type = 'Radiology'
