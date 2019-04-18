provider "aws" {
  version = "~> 1.18"
  region = "${var.aws_region}"
  shared_credentials_file = "~/.aws/credentials"
}