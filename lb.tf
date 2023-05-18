resource "aws_lb" "alb" {
  name               = "ALB01"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public01.id, aws_subnet.public02.id]
}

resource "aws_lb_target_group" "target-elb" {
  name     = "ALB-TG01"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc01.id

  health_check {
    path = "/wp-admin/setup-config.php"
  }
}

/*resource "aws_lb_target_group_attachment" "attachment" {
  count            = 1
  target_group_arn = aws_lb_target_group.target-elb.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
  depends_on = [
    aws_instance.web,
  ]
}*/

resource "aws_lb_listener" "external-elb" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-elb.arn
  }
}