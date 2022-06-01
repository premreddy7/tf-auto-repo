##### S3 bucket configuration configuration details begin #####

resource "aws_s3_bucket" "coin" {
  for_each = var.s3_details
  bucket   = each.value.name
  tags     = each.value.tags
}

resource "aws_s3_bucket_versioning" "default" {
  for_each = var.s3_details
  bucket   = aws_s3_bucket.coin[each.key].bucket
  versioning_configuration {
    status = each.value.versioning == true ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  for_each = var.s3_details
  bucket   = aws_s3_bucket.coin[each.key].bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.ospr_s3_key[each.key].arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_kms_key" "ospr_s3_key" {
  for_each    = var.s3_details
  description = "KMS key for s3"
  tags        = each.value.tags
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_kms_alias" "ospr_s3_key" {
  for_each      = var.s3_details
  name          = each.value.kms_key_name
  target_key_id = aws_kms_key.ospr_s3_key[each.key].key_id
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_s3_bucket_public_access_block" "coin-s3Public" {
  for_each                = var.s3_details
  bucket                  = aws_s3_bucket.coin[each.key].id
  block_public_acls       = each.value.block_public_acls
  block_public_policy     = each.value.block_public_policy
  restrict_public_buckets = each.value.restrict_public_buckets
  ignore_public_acls      = each.value.ignore_public_acls
}

##### S3 bucket configuration details end #####