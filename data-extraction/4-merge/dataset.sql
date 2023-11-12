WITH agg AS
(
    -- aggregate some tables to the existence of a row 1 or 0
    SELECT co.hadm_id
    -- transfusions
    , MAX(CASE WHEN transfusion_ordertime IS NOT NULL THEN 1 ELSE 0 END) AS transfusion
    -- contrast
    , MAX(CASE WHEN with_contrast = 1 THEN 1 ELSE 0 END) AS contrast
    -- medications
    , MAX(CASE WHEN ace.hadm_id IS NOT NULL THEN 1 ELSE 0 END) AS ace_inhibitor
    , MAX(CASE WHEN arb.hadm_id IS NOT NULL THEN 1 ELSE 0 END) AS arb
    , MAX(CASE WHEN di.hadm_id IS NOT NULL THEN 1 ELSE 0 END) AS diuretic
    , MAX(CASE WHEN nsaid.hadm_id IS NOT NULL THEN 1 ELSE 0 END) AS nsaid
    , MAX(CASE WHEN v.hadm_id IS NOT NULL THEN 1 ELSE 0 END) AS vasopressor
    FROM aki_study.cohort co
    LEFT JOIN aki_study.transfusion tr
        ON co.hadm_id = tr.hadm_id
    LEFT JOIN aki_study.contrast ct
        ON co.hadm_id = tr.hadm_id
    -- medications
    LEFT JOIN aki_study.ace_inhibitor ace
        ON co.hadm_id = ace.hadm_id
    LEFT JOIN aki_study.arb arb
        ON co.hadm_id = arb.hadm_id
    LEFT JOIN aki_study.diuretic di
        ON co.hadm_id = di.hadm_id
    LEFT JOIN aki_study.nsaid nsaid
        ON co.hadm_id = nsaid.hadm_id
    LEFT JOIN aki_study.vasopressor v
        ON co.hadm_id = v.hadm_id
    GROUP BY 1
)
SELECT co.hadm_id
    -- cohort derived variables
    , co.admittime
    , co.dischtime
    , co.starttime_aki
    , co.aki_stage_creat
    , co.aki_window_starttime
    , co.aki_window_endtime

    -- outcome
    -- TODO: add outcome

    -- demographics
    , dem.age
    , dem.gender

    , agg.transfusion
    , agg.contrast
    , agg.ace_inhibitor
    , agg.arb
    , agg.diuretic
    , agg.nsaid
    , agg.vasopressor

    -- labs
    , lab.crp_aki
    , lab.albumin_aki
    , lab.wbc_aki
    , lab.hemoglobin_aki
    , lab.sodium_aki

    , lab.hemoglobin_adm
    , lab.sodium_adm

    -- vital signs
    , vs.heartrate_ed
    , vs.sbp_ed
    , vs.dbp_ed

FROM aki_study.cohort co
LEFT JOIN agg
    ON co.hadm_id = agg.hadm_id
LEFT JOIN aki_study.demographics dem
    ON co.hadm_id = dem.hadm_id
LEFT JOIN aki_study.lab lab
    ON co.hadm_id = lab.hadm_id
LEFT JOIN aki_study.vitalsign vs
    ON co.hadm_id = vs.hadm_id
;