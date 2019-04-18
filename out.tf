output "jenkins_private_ip" {
  description = "jenkins_private_ip"
  value       = ["${aws_instance.jenkins_master.private_ip}"]
}

output "jenkins_private_fqdn" {
  description = "jenkins_private_fqdn"
  value       = ["${aws_route53_record.jenkins_master.fqdn}"]
}