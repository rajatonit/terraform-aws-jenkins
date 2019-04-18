resource "aws_security_group" "jenkins_master_sg" {
  name        = "jenkins_master_sg"
  description = "SG for jenkins master infra"
  vpc_id      = "${var.vpc_id}"

   ingress {
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = ["172.16.0.0/12","10.0.0.0/8"]
  }
  ingress {
    from_port         = 8080
    to_port           = 8080
    protocol          = "tcp"
    cidr_blocks       = ["172.16.0.0/12","10.0.0.0/8"]
  }

  ingress {
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["172.16.0.0/12","10.0.0.0/8"]
  }

  ingress {
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = ["172.16.0.0/12","10.0.0.0/8"]
  }

  egress {
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]

  } 
  
}

resource "aws_security_group" "jenkins_lambda_sg" {
  name        = "jenkins_lambda_sg"
  description = "SG for jenkins lambda infra"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port         = 8080
    to_port           = 8080
    protocol          = "tcp"
    cidr_blocks       = ["172.16.0.0/12","10.0.0.0/8"]
  }


  egress {
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]

  } 
  
}

resource "aws_security_group" "jenkins_slaves_sg" {
  name        = "jenkins_slaves_sg"
  description = "SG for jenkins slave infra"
  vpc_id      = "${var.vpc_id}"

   ingress {
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = ["172.16.0.0/12","10.0.0.0/8"]
  }

  egress {
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]

  } 
  
}