-- Extract labs measured up to 12 hours before the AKI stage 1 dx

-- CRP
-- Albumin
-- Leukocyte (WBC)
-- Hemoglobin
-- Sodium

-- Also extract the following labs at admission to the hospital:
--  Sodium
--  hemoglobin

with labs_merged as
(
    -- blood gas data
    SELECT co.hadm_id
        , aki_window_starttime, aki_window_endtime
        , bg.charttime
        , NULL AS crp
        , NULL AS albumin
        , NULL AS wbc
        , bg.hemoglobin as hemoglobin
        , bg.sodium as sodium
    FROM aki_study.cohort co
    INNER JOIN physionet-data.mimiciv_hosp.admissions adm
        ON co.hadm_id = adm.hadm_id
    INNER JOIN physionet-data.mimiciv_derived.bg bg
        on co.hadm_id = bg.hadm_id
        AND bg.charttime <= co.aki_window_endtime
        AND bg.charttime >= LEAST(co.aki_window_starttime, DATETIME_SUB(adm.admittime, INTERVAL 12 HOUR))
    WHERE bg.hemoglobin IS NOT NULL OR bg.sodium IS NOT NULL
    UNION ALL
    -- chemistry data
    SELECT co.hadm_id
        , aki_window_starttime, aki_window_endtime
        , ch.charttime
        , NULL AS crp
        , ch.albumin AS albumin
        , NULL AS wbc
        , NULL as hemoglobin
        , ch.sodium as sodium
    FROM aki_study.cohort co
    INNER JOIN physionet-data.mimiciv_hosp.admissions adm
        ON co.hadm_id = adm.hadm_id
    INNER JOIN physionet-data.mimiciv_derived.chemistry ch
        on co.hadm_id = ch.hadm_id
        AND ch.charttime <= co.aki_window_endtime
        AND ch.charttime >= LEAST(co.aki_window_starttime, DATETIME_SUB(adm.admittime, INTERVAL 12 HOUR))
    WHERE ch.albumin IS NOT NULL OR ch.sodium IS NOT NULL
    UNION ALL
    -- complete blood count data
    SELECT co.hadm_id
        , aki_window_starttime, aki_window_endtime
        , cbc.charttime
        , NULL AS crp
        , NULL AS albumin
        , cbc.wbc AS wbc
        , cbc.hemoglobin as hemoglobin
        , NULL as sodium
    FROM aki_study.cohort co
    INNER JOIN physionet-data.mimiciv_hosp.admissions adm
        ON co.hadm_id = adm.hadm_id
    INNER JOIN physionet-data.mimiciv_derived.complete_blood_count cbc
        on co.hadm_id = cbc.hadm_id
        AND cbc.charttime <= co.aki_window_endtime
        AND cbc.charttime >= LEAST(co.aki_window_starttime, DATETIME_SUB(adm.admittime, INTERVAL 12 HOUR))
    WHERE cbc.wbc IS NOT NULL OR cbc.hemoglobin IS NOT NULL
    UNION ALL
    -- inflammation data
    SELECT co.hadm_id
        , aki_window_starttime, aki_window_endtime
        , inf.charttime
        , inf.crp AS crp
        , NULL AS albumin
        , NULL AS wbc
        , NULL AS hemoglobin
        , NULL AS sodium
    FROM aki_study.cohort co
    INNER JOIN physionet-data.mimiciv_hosp.admissions adm
        ON co.hadm_id = adm.hadm_id
    INNER JOIN physionet-data.mimiciv_derived.inflammation inf
        on co.hadm_id = inf.hadm_id
        AND inf.charttime <= co.aki_window_endtime
        AND inf.charttime >= LEAST(co.aki_window_starttime, DATETIME_SUB(adm.admittime, INTERVAL 12 HOUR))
    WHERE inf.crp IS NOT NULL
)
, labs_at_aki AS
(
    SELECT hadm_id
        , MAX(crp) AS crp
        , MAX(albumin) AS albumin
        , MAX(wbc) AS wbc
        , MAX(hemoglobin) as hemoglobin
        , MAX(sodium) as sodium
    FROM labs_merged
    WHERE charttime <= aki_window_endtime
    AND charttime >= aki_window_starttime
    GROUP BY 1
)
, labs_at_admission AS
(
    SELECT lab.hadm_id
        -- , MAX(crp) AS crp
        -- , MAX(albumin) AS albumin
        -- , MAX(wbc) AS wbc
        , MAX(hemoglobin) as hemoglobin
        , MAX(sodium) as sodium
    FROM labs_merged lab
    INNER JOIN physionet-data.mimiciv_hosp.admissions adm
        ON lab.hadm_id = adm.hadm_id
    -- admission labs defined as [-12, 12] hours around admission
    -- *unless* AKI starts earlier than 12 hours, in which case, no later than AKI
    WHERE charttime <= LEAST(aki_window_endtime, DATETIME_ADD(adm.admittime, INTERVAL 12 HOUR))
    AND charttime >= DATETIME_SUB(adm.admittime, INTERVAL 12 HOUR)
    GROUP BY 1
)
-- select all the data
SELECT co.hadm_id
, lab_aki.crp AS crp_aki
, lab_aki.albumin AS albumin_aki
, lab_aki.wbc AS wbc_aki
, lab_aki.hemoglobin AS hemoglobin_aki
, lab_aki.sodium AS sodium_aki
-- , lab_adm.crp AS crp_adm
-- , lab_adm.albumin AS albumin_adm
-- , lab_adm.wbc AS wbc_adm
, lab_adm.hemoglobin AS hemoglobin_adm
, lab_adm.sodium AS sodium_adm
FROM aki_study.cohort co
LEFT JOIN labs_at_aki lab_aki
    ON co.hadm_id = lab_aki.hadm_id
LEFT JOIN labs_at_admission lab_adm
    ON co.hadm_id = lab_adm.hadm_id
;