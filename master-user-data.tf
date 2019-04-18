data "template_file" "user_data_master" {
  template = "${file("scripts/master-user-data.tpl")}"

  vars {
    data_s3_bucket_name            = "${var.s3_bucket_name}"
  }
}
