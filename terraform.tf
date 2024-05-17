terraform {
  required_version = "~> 1.8.0"
  backend "s3" {
    bucket = "picklerfinder-terraform-state"
    region = "eu-central-1"
    key    = "development"
  }
}
