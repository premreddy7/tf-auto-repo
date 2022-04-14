variable "glue_job" {
  type = map(object({
    name              = string
    script_location   = string
    iam_role_name     = string
    iam_role_arn      = string
    managed_role_policy  = list(string)
    assume_role_policy_path = string
    python_version    = string
    glue_version      = string
    number_of_workers = string
    worker_type       = string
    })
  )
}

variable "env" {}
variable "bucket_name" {}
variable "create_bucket" {}

### Crawler Details ###
#variable "crawler_db_name" {}
#variable "jdbc_url" {}
#variable "jdbc_pass" {}
#variable "jdbc_user" {}
#variable "crawler_connection_name" {}
#variable "crawler_name" {}
#variable "crawler_role_arn" {}
#variable "jdbc_target_path" {}

### GLue Workflow ###
variable "glue_workflow_name" {}