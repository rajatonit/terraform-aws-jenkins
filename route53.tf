data "aws_route53_zone" "selected" {
  name = "${var.dns_zone_name}"
  private_zone = true
}

resource "aws_alb" "alb" {  
  name            = "jenkins-alb-${var.env}"  
  subnets         = ["${var.vpc_private_subnets[0]}", "${var.vpc_private_subnets[1]}"]
  internal = true
  security_groups  = ["${aws_security_group.jenkins_master_sg.id}"]
}

resource "aws_alb_target_group" "alb_target_group" {  
  name     = "jenkins-albTargetGroup-${var.env}" 
  port     = "80"  
  protocol = "HTTP"  
  vpc_id   = "${var.vpc_id}"   

  stickiness {    
    type            = "lb_cookie"    
    cookie_duration = 1800    
  }   
  health_check {    
    healthy_threshold   = 3    
    unhealthy_threshold = 10    
    timeout             = 5    
    interval            = 10    
    path                = "/"    
    port                = "8080"  
  }
}

resource "aws_alb_listener" "alb_listener_80" {  
  load_balancer_arn = "${aws_alb.alb.arn}"  
  port              = "80"  
  protocol          = "HTTP"
  
  default_action {    
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
    type             = "forward"  
  }
}
resource "aws_alb_listener" "alb_listener_8080" {  
  load_balancer_arn = "${aws_alb.alb.arn}"  
  port              = "8080"  
  protocol          = "HTTP"
  
  default_action {    
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
    type             = "forward"  
  }
}

resource "aws_alb_listener_rule" "listener_rule" {
  depends_on   = ["aws_alb_target_group.alb_target_group"]  
  listener_arn = "${aws_alb_listener.alb_listener_80.arn}"  
  action {    
    type             = "forward"    
    target_group_arn = "${aws_alb_target_group.alb_target_group.id}"  
  }   
  condition {    
    field  = "path-pattern"    
    values = ["/*"]  
  }
}


#Instance Attachment
resource "aws_alb_target_group_attachment" "svc_physical_external" {
  target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
  target_id        = "${aws_instance.jenkins_master.id}"  
  port             = 8080
}


resource "aws_route53_record" "jenkins_master" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${var.jenkins_route53_name}"
  type    = "A"
  
  alias {
    name                   = "${aws_alb.alb.dns_name}"
    zone_id                = "${aws_alb.alb.zone_id}"
    evaluate_target_health = true
  }
}