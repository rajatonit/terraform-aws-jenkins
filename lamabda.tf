resource "aws_lambda_function" "jenkins_slave_lambda" {
  filename         = "lambda_function_payload.zip"
  function_name    = "jenkins-slave-sns-${var.env}"
  role             = "${var.jenkins_sns_lambda_arn}"
  handler          = "exports.test"
  source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  runtime          = "python2.7"
  vpc_config {
  subnet_ids = "${var.vpc_private_subnets}"
  security_group_ids = ["${aws_security_group.jenkins_lambda_sg.id}"]
  }
  timeout = 600
  environment {
    variables = {
      jenkinsUrl = "${aws_instance.jenkins_master.private_ip}",
      username       = "${var.jenkins_username}",
      password       = "${var.jenkins_password}"

    }
  }
}

resource "aws_lambda_permission" "with_sns" {
    statement_id = "AllowExecutionFromSNS"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.jenkins_slave_lambda.arn}"
    principal = "sns.amazonaws.com"
    source_arn = "${aws_sns_topic.slave_updates.arn}"
}
