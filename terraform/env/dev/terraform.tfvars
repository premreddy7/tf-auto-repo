region = "us-east-2"
env    = "dev"
glue_job = {
  incorta_ops_da_mv_tbl_to_s3_glue_job = {
    name            = "incorta_ops_da_mv_tbl_to_s3_glue_job_dev"
    script_location = "../scripts/incorta_to_s3.py"
    iam_role_name   = ""
    iam_role_arn      = "arn:aws:iam::517446614341:role/first_glue_job_test"
    managed_role_policy = []
    assume_role_policy_path = "../iam_policy/assume_role_policy.json"
    python_version          = "3"
    glue_version            = "3.0"
    number_of_workers       = "10"
    worker_type             = "G.1X"

  },
  s3_to_redishift = {
    name                    = "s3_to_redishift_dev"
    script_location         = "../scripts/s3_to_redishift.py"
    iam_role_name           = ""
    iam_role_arn            = "arn:aws:iam::517446614341:role/first_glue_job_test"
    managed_role_policy     = []
    assume_role_policy_path = ""
    python_version          = "3"
    glue_version            = "3.0"
    number_of_workers       = "10"
    worker_type             = "G.1X"
  },

  update_flag_python = {
    name                    = "update_flag_python_dev"
    script_location         = "../scripts/update_flag_python.py"
    iam_role_name           = ""
    iam_role_arn            = "arn:aws:iam::517446614341:role/first_glue_job_test"
    managed_role_policy     = []
    assume_role_policy_path = ""
    python_version          = "3"
    glue_version            = "3.0"
    number_of_workers       = "10"
    worker_type             = "G.1X"
  },

  stored_date_value = {
    name                    = "stored_date_value_dev"
    script_location         = "../scripts/stored_date_value.py"
    iam_role_name           = ""
    iam_role_arn            = "arn:aws:iam::517446614341:role/first_glue_job_test"
    managed_role_policy     = []
    assume_role_policy_path = ""
    python_version          = "3"
    glue_version            = "3.0"
    number_of_workers       = "10"
    worker_type             = "G.1X"
  },

  archived_incorta_files = {
    name                    = "archived_incorta_files_dev"
    script_location         = "../scripts/archived_incorta_files.py"
    iam_role_name           = ""
    iam_role_arn            = "arn:aws:iam::517446614341:role/first_glue_job_test"
    managed_role_policy     = []
    assume_role_policy_path = ""
    python_version          = "3"
    glue_version            = "3.0"
    number_of_workers       = "10"
    worker_type             = "G.1X"
  },

  output_from_redshift_to_s3_parquet = {
    name                    = "output_from_redshift_to_s3_parquet_dev"
    script_location         = "../scripts/output_from_redshift_to_s3_parquet.py"
    iam_role_name           = ""
    iam_role_arn            = "arn:aws:iam::517446614341:role/first_glue_job_test"
    managed_role_policy     = []
    assume_role_policy_path = ""
    python_version          = "3"
    glue_version            = "3.0"
    number_of_workers       = "10"
    worker_type             = "G.1X"
  }
}

bucket_name   = "glue-job-workflow-bucket"
create_bucket = true

### Glue Workflow ###
glue_workflow_name = "cfm-etl-workflow_dev"
cron_expression    = "cron(0 10 * * ? *)"

