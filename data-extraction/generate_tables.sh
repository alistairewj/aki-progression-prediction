# set your cloud project
#   gcloud config set project lcp-internal

# first, generate the eligible individuals, and then the cohort
bq query --max_rows=2 --use_legacy_sql=False --replace --destination_table=aki_study.eligible < 2-cohort/eligible.sql
bq query --max_rows=2 --use_legacy_sql=False --replace --destination_table=aki_study.cohort < 2-cohort/cohort.sql


# generate the variables
bq query --max_rows=2 --use_legacy_sql=False --replace --destination_table=aki_study.ace_inhibitor < 3-variables/ace_inhibitor.sql
bq query --max_rows=2 --use_legacy_sql=False --replace --destination_table=aki_study.antibiotic < 3-variables/antibiotic.sql
bq query --max_rows=2 --use_legacy_sql=False --replace --destination_table=aki_study.arb < 3-variables/arb.sql
bq query --max_rows=2 --use_legacy_sql=False --replace --destination_table=aki_study.comorbidity < 3-variables/comorbidity.sql
bq query --max_rows=2 --use_legacy_sql=False --replace --destination_table=aki_study.contrast < 3-variables/contrast.sql
bq query --max_rows=2 --use_legacy_sql=False --replace --destination_table=aki_study.demographics < 3-variables/demographics.sql
bq query --max_rows=2 --use_legacy_sql=False --replace --destination_table=aki_study.diuretic < 3-variables/diuretic.sql
bq query --max_rows=2 --use_legacy_sql=False --replace --destination_table=aki_study.imaging_order < 3-variables/imaging_order.sql
bq query --max_rows=2 --use_legacy_sql=False --replace --destination_table=aki_study.lab < 3-variables/lab.sql
bq query --max_rows=2 --use_legacy_sql=False --replace --destination_table=aki_study.nsaid < 3-variables/nsaid.sql
bq query --max_rows=2 --use_legacy_sql=False --replace --destination_table=aki_study.outcome < 3-variables/outcome.sql
bq query --max_rows=2 --use_legacy_sql=False --replace --destination_table=aki_study.sofa < 3-variables/sofa.sql
bq query --max_rows=2 --use_legacy_sql=False --replace --destination_table=aki_study.transfusion < 3-variables/transfusion.sql
bq query --max_rows=2 --use_legacy_sql=False --replace --destination_table=aki_study.vasopressor < 3-variables/vasopressor.sql
bq query --max_rows=2 --use_legacy_sql=False --replace --destination_table=aki_study.vitalsign < 3-variables/vitalsign.sql


# merge together the data into a single dataframe
bq query --max_rows=2 --use_legacy_sql=False --replace --destination_table=aki_study.vitalsign < 4-merge/dataset.sql