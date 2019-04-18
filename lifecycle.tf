resource "aws_autoscaling_lifecycle_hook" "jenkins-slave-lifecycle" {
  name                   = "jenkins-slave-lifecycle-${var.env}"
  autoscaling_group_name = "${aws_autoscaling_group.jenkins_slaves.name}"
  default_result         = "CONTINUE"
  heartbeat_timeout      = 2000
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"

  notification_target_arn = "${aws_sns_topic.slave_updates.arn}"
  role_arn                = "${var.jenkins_lifecycle_arn}"
}