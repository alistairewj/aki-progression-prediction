SELECT co.hadm_id
    , poe.ordertime AS transfusion_ordertime
    , order_subtype AS transfusion_type
FROM aki_study.cohort co
INNER JOIN physionet-data.mimiciv_hosp.poe poe
    ON co.hadm_id = poe.hadm_id
    AND poe.ordertime <= co.aki_window_endtime
WHERE order_type = 'Blood Bank'
-- exclude blood tests, which implicitly includes all other order types
AND (
    order_subtype != 'Blood tests'
)
-- order_subtype = 'Cryoprecipitate Product Order'
-- order_subtype = 'Derivative Order'
-- order_subtype = 'Frozen Plasma Product Order'
-- order_subtype = 'Platelet Product Order'
-- order_subtype = 'Red Cell Product Order'