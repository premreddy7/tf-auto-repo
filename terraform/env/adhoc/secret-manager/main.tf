provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket = "tf-code-backend-state-bucket"
    region = "us-east-2"
    key    = "terraform-tfstate/adhoc/terraform.tfstate"
  }
}

module "secrets-manager-5" {

  source = "../../../modules/sercret-manager"
  secrets = {
    secret-plain = {
      description             = "My plain text secret"
      recovery_window_in_days = 7
      secret_string           = "plain_text_secret"
    },
    secret-key-value = {
      description = "This is a key/value secret"
      secret_key_value = {
        username = "user"
        password = "${random_password.password.result}"
      }
      tags = {
        app = "web"
      }
      recovery_window_in_days = 7
    },
  }

  tags = {
    Owner       = "DevOps team"
    Environment = "dev"
    Terraform   = true
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}
