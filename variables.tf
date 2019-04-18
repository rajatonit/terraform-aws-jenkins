variable "aws_region" {}

variable "shared_credentials_file" {}

variable "key_name" {}

variable "dns_zone_name" {}

variable "jenkins_username" {}

variable "jenkins_password" {}

variable "jenkins_credentials_id" {}

variable "vpc_id" {}

variable "vpc_private_subnets" {
        type = "list"
}

variable "vpc_public_subnets" {
        type = "list"
}

variable "s3_bucket_name" {}

variable "jenkins_master_instance_type" {}

variable "min_jenkins_slaves" {}

variable "max_jenkins_slaves" {}

variable "jenkins_slave_instance_type" {}

variable "env" {}

variable "jenkins_iam_master" {}

variable "jenkins_iam_slave" {}

variable "jenkins_lifecycle_arn" {}

variable "jenkins_route53_name" {}
