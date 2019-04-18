data "aws_ami" "jenkins-master" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["Jenkins-master-*"]
  }
}

data "aws_ami" "jenkins-slave" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["Jenkins-slave-*"]
  }
}