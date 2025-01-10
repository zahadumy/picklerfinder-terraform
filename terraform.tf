terraform {
  required_version = "~> 1.10.0"
  backend "s3" {
    bucket = "picklerfinder-terraform-state"
    region = "eu-central-1"
    key    = "development"
  }
}
