terraform {
  backend "gcs" {
    bucket = "backend-gcs-gfd"
    prefix = "checkpoint"
  }
}
