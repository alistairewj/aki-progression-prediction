-- get vital sign from their presentation in the ED

-- Ideally, we would get:
--  Systolic blood pressure variation: daily maximum minus minimun at AKIN1 Diagnosis
--  Heart rate variation: same as above
--  Hypotension at diagnosis of AKIN1, reducing fist hospitalized  blood pressure <20 mmHg systolic; <10 mmHg diastolic;
--  Mean BP <65 mmHg at AKIN1 diagnosis
--  Heart rate at AKIN1 diagnosis

WITH vitalsign AS
(
    SELECT co.hadm_id
        -- treat admit time as the time of triage
        , ed.intime AS charttime
        -- triage
        , t.heartrate
        -- , t.resprate
        -- , t.o2sat
        , t.sbp
        , t.dbp
    FROM aki_study.cohort co
    INNER JOIN physionet-data.mimiciv_ed.edstays ed
        ON co.hadm_id = ed.hadm_id
    INNER JOIN physionet-data.mimiciv_ed.triage t
        ON ed.stay_id = t.stay_id
    WHERE ed.intime <= co.aki_window_endtime
    UNION ALL
    SELECT co.hadm_id
        -- treat admit time as the time of triage
        , v.charttime
        -- vital sign
        , v.heartrate
        -- , v.resprate
        -- , v.o2sat
        , v.sbp
        , v.dbp
    FROM aki_study.cohort co
    INNER JOIN physionet-data.mimiciv_ed.edstays ed
        ON co.hadm_id = ed.hadm_id
    INNER JOIN physionet-data.mimiciv_ed.vitalsign v
        ON ed.stay_id = v.stay_id
        AND v.charttime <= co.aki_window_endtime
)
, v2 AS
(
    SELECT hadm_id
        , LAST_VALUE(heartrate IGNORE NULLS) OVER w AS heartrate
        , LAST_VALUE(sbp IGNORE NULLS) OVER w AS sbp
        , LAST_VALUE(dbp IGNORE NULLS) OVER w AS dbp
    FROM vitalsign v
    WINDOW w AS (
        PARTITION BY hadm_id
        ORDER BY charttime
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    )
)
SELECT hadm_id
    , ANY_VALUE(heartrate)  AS heartrate_ed
    , ANY_VALUE(sbp)  AS sbp_ed
    , ANY_VALUE(dbp)  AS dbp_ed
FROM v2
GROUP BY hadm_id
;
