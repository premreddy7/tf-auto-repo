region = "us-east-2"
env    = "dev"
glue_job = {
  incorta_ops_da_mv_tbl_to_s3_glue_job = {
    name                    = "incorta_ops_da_mv_tbl_to_s3_glue_job"
    script_location         = "../../scripts/incorta_to_s3.py"
    iam_role_name           = ""
    iam_role_arn            = "arn:aws:iam::517446614341:role/first_glue_job_test"
    managed_role_policy     = []
    assume_role_policy_path = "../iam_policy/assume_role_policy.json"
    python_version          = "3"
    glue_version            = "3.0"
    number_of_workers       = "10"
    worker_type             = "G.1X"

  },
  s3_to_redishift = {
    name                    = "s3_to_redishift"
    script_location         = "../../scripts/s3_to_redishift.py"
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
    name                    = "update_flag_python"
    script_location         = "../../scripts/update_flag_python.py"
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
    name                    = "stored_date_value"
    script_location         = "../../scripts/stored_date_value.py"
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
    name                    = "archived_incorta_files"
    script_location         = "../../scripts/archived_incorta_files.py"
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
    name                    = "output_from_redshift_to_s3_parquet"
    script_location         = "../../scripts/output_from_redshift_to_s3_parquet.py"
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

### Crawler Details ###
crawler_details = {
  incrota_crawler_OPS_DA_MV = {
    crawler_name            = "incrota_crawler_OPS_DA_MV"
    crawler_role_arn        = "arn:aws:iam::517446614341:role/first_glue_job_test"
    db_name                 = "ospr_redshift"
    jdbc_url                = "jdbc:postgresql://10.240.82.13:5438/inc_ebs"
    secret_id               = "db_creds"
    az                      = "us-east-2a"
    sec_group_id            = ["sg-0abdb3536666f63b7"]
    subnet_id               = "subnet-0f1ab85b3aeba21a8"
    crawler_connection_name = "incorta_postgresql_connection"
    jdbc_target_path        = "database-name/%"
    crawler_description     = ""
    connection_description  = ""
    db_description          = ""
  },

  OSPR_Redshift = {
    crawler_name            = "OSPR_Redshift"
    crawler_role_arn        = "arn:aws:iam::517446614341:role/first_glue_job_test"
    db_name                 = "ospr_redshift"
    jdbc_url                = "jdbc:postgresql://10.240.82.13:5438/inc_ebs"
    secret_id               = "db_creds"
    az                      = "us-east-2a"
    sec_group_id            = ["sg-0abdb3536666f63b7"]
    subnet_id               = "subnet-0f1ab85b3aeba21a8"
    crawler_connection_name = "incorta_postgresql_connection"
    jdbc_target_path        = "database-name/%"
    crawler_description     = ""
    connection_description  = ""
    db_description          = ""


  }

}
bucket_name   = "glue-job-workflow-bucket"
create_bucket = true

### Glue Workflow ###
glue_workflow_name = "cfm-etl-workflow"
cron_expression    = "cron(0 10 * * ? *)"

