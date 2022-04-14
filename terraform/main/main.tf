provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "tf-code-backend-state-bucket"
  }
}

module "aws_glue_job" {
  source   = "../modules/glue-job"
  env      = var.env
  glue_job = var.glue_job

  bucket_name   = var.bucket_name
  create_bucket = var.create_bucket

  ### Glue Workflow ###
  glue_workflow_name = var.glue_workflow_name
  cron_expression    = var.cron_expression
}
