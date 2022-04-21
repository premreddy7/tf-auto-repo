variable "glue_job" {
  type = map(object({
    name                    = string
    script_location         = string
    iam_role_name           = string
    iam_role_arn            = string
    managed_role_policy     = list(string)
    assume_role_policy_path = string
    python_version          = string
    glue_version            = string
    number_of_workers       = string
    worker_type             = string
    })
  )
}

variable "env" {}
variable "bucket_name" {}
variable "create_bucket" {}

### Crawler Details ###
variable "crawler_details" {
  type = map(object({
    crawler_name            = string
    crawler_role_arn        = string
    db_name                 = string
    jdbc_url                = string
    jdbc_pass               = string
    jdbc_user               = string
    az                      = string
    sec_group_id            = list(string)
    subnet_id               = string
    crawler_connection_name = string
    jdbc_target_path        = string
    crawler_description     = string
    connection_description  = string
    db_description          = string

    })
  )
}

### GLue Workflow ###
variable "glue_workflow_name" {}
variable "cron_expression" {}