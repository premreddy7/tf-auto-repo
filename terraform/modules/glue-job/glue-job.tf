resource "aws_s3_bucket" "bucket" {
  count  = var.create_bucket == true ? 1 : 0
  bucket = var.bucket_name #"glue-job-bucket"
}

resource "aws_s3_object" "object" {
  for_each = var.glue_job
  bucket   = aws_s3_bucket.bucket[0].id
  key      = "${var.env}/${basename(each.value.script_location)}"
  source   = each.value.script_location
  #etag     = filemd5("${basename(each.value.script_location)}")
}

resource "aws_glue_job" "glue_job" {
  for_each = var.glue_job
  name     = each.value.name
  role_arn = each.value.iam_role_name != "" ? aws_iam_role.glue_role[each.key].arn : each.value.iam_role_arn

  command {
    script_location = "s3://${aws_s3_bucket.bucket[0].id}/${var.env}/${basename(each.value.script_location)}"
    python_version  = each.value.python_version
  }
  glue_version      = each.value.glue_version
  number_of_workers = each.value.number_of_workers
  worker_type       = each.value.worker_type
}


resource "aws_iam_role" "glue_role" {
  for_each           = { for k in compact([for k, v in var.glue_job : v.iam_role_arn == "" ? k : ""]) : k => var.glue_job[k] }
  name               = each.value.iam_role_name
  assume_role_policy = "${file(each.value.assume_role_policy_path)}" 
  managed_policy_arns = each.value.managed_role_policy
}

#resource "aws_iam_policy" "iam_policy" {
#for_each           = { for k in compact([for k, v in var.glue_job : v.iam_role_arn == "" ? k : ""]) : k => var.glue_job[k] }
#  name = "${each.value.iam_role_name}-policy"
#  policy = "${file(each.value.role_policy_path)}"
#}

#resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
#  name = var.crawler_db_name
#}

### AWS Glue Crawler ###

#resource "aws_glue_connection" "jdbc_conn" {
#  connection_properties = {
#    JDBC_CONNECTION_URL = var.jdbc_url
#    PASSWORD            = var.jdbc_pass
#    USERNAME            = var.jdbc_user
#  }
#  name = var.crawler_connection_name
#}
#
#resource "aws_glue_crawler" "crawler" {
#  database_name = aws_glue_catalog_database.aws_glue_catalog_database.name
#  name          = var.crawler_name
#  role          = var.crawler_role_arn
#
#  jdbc_target {
#    connection_name = aws_glue_connection.jdbc_conn.name
#    path            = var.jdbc_target_path
#  }
#}

### Glue Workflow ###
resource "aws_glue_workflow" "wf" {
  name = var.glue_workflow_name
}

resource "aws_glue_trigger" "int_trigger" {
  name          = "start_workflow"
  workflow_name = aws_glue_workflow.wf.name
  type          = "ON_DEMAND"

  actions {
    job_name = var.glue_job.incorta_ops_da_mv_tbl_to_s3_glue_job.name
  }
}

resource "aws_glue_trigger" "s3_to_redishift" {
  name          = "trigger_s3toredshift_job"
  workflow_name = aws_glue_workflow.wf.name
  type          = "CONDITIONAL"

  actions {
    job_name = var.glue_job.s3_to_redishift.name
  }

  predicate {
    conditions {
      job_name = var.glue_job.incorta_ops_da_mv_tbl_to_s3_glue_job.name
      state    = "SUCCEEDED"
    }
  }
}

resource "aws_glue_trigger" "updateflag_storedate" {
  name          = "trigger_updateflag_store_date_job"
  workflow_name = aws_glue_workflow.wf.name
  type          = "CONDITIONAL"

  actions {
    job_name = var.glue_job.update_flag_python.name
  }

  actions {
    job_name = var.glue_job.stored_date_value.name
  }

  predicate {
    conditions {
      job_name = var.glue_job.s3_to_redishift.name
      state    = "SUCCEEDED"
    }
  }
}


resource "aws_glue_trigger" "archived_redshifttos3" {
  name          = "trigger_archived_redshifttos3_job"
  workflow_name = aws_glue_workflow.wf.name
  type          = "CONDITIONAL"

  actions {
    job_name = var.glue_job.archived_incorta_files.name
  }

  actions {
    job_name = var.glue_job.output_from_redshift_to_s3_parquet.name
  }

  predicate {
    conditions {
      job_name = var.glue_job.update_flag_python.name
      state    = "SUCCEEDED"
    }
    conditions {
      job_name = var.glue_job.stored_date_value.name
      state    = "SUCCEEDED"
    }
  }
}