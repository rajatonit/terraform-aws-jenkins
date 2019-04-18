resource "aws_sns_topic" "slave_updates" {
  name = "jenkins-slave-sns-${var.env}"
}


resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = "${aws_sns_topic.slave_updates.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.jenkins_slave_lambda.arn}"
}
