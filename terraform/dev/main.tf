provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket = "tf-code-backend-state-bucket"
    key    = "terraform-tfstate/ens/dev/"
    region = "us-east-2"
  }
}

module "aws_glue_job" {
  source = "../modules/glue-job"
  env    = "dev"
  glue_job = {
    incorta_ops_da_mv_tbl_to_s3_glue_job = {
      name            = "incorta_ops_da_mv_tbl_to_s3_glue_job"
      script_location = "../scripts/incorta_to_s3.py"
      iam_role_name   = "test_role"
      iam_role_arn    = ""
      #iam_role_arn      = "arn:aws:iam::517446614341:role/first_glue_job_test"
      managed_role_policy     = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess", "arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole", "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"]
      assume_role_policy_path = "../iam_policy/assume_role_policy.json"
      python_version          = "3"
      glue_version            = "3.0"
      number_of_workers       = "10"
      worker_type             = "G.1X"

    },
    s3_to_redishift = {
      name                    = "s3_to_redishift"
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
      name                    = "update_flag_python"
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
      name                    = "stored_date_value"
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
      name                    = "archived_incorta_files"
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
      name                    = "output_from_redshift_to_s3_parquet"
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
  glue_workflow_name = "cfm-etl-workflow"
}
