resource "aws_instance" "jenkins_master" {
  ami                    = "${data.aws_ami.jenkins-master.id}"
  instance_type          = "${var.jenkins_master_instance_type}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.jenkins_master_sg.id}"]
  subnet_id              = "${element(var.vpc_private_subnets, 0)}"
  user_data              = "${data.template_file.user_data_master.rendered}"
  iam_instance_profile = "${var.jenkins_iam_master}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 50
    delete_on_termination = true
  }

  tags {
    Name   = "jenkins_master"
    Author = ""
    Tool   = "Terraform"
  }
}
