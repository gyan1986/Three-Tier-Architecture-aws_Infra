resource "aws_launch_configuration" "web-lc" {
  name_prefix                = "web-lc-"
  image_id                   = "ami-0b08bfc6ff7069aff"
  instance_type              = "t2.micro"
    key_name                   = "terraform_key_pair"
  security_groups            = [aws_security_group.web_sg.id]
     user_data = templatefile("user_data.sh", {
    rds_endpoint = jsondecode(data.aws_secretsmanager_secret_version.rds.secret_string)["endpoint"]
    rds_password = jsondecode(data.aws_secretsmanager_secret_version.rds.secret_string)["password"]
  })
  lifecycle {
    create_before_destroy = true
  }
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "web-asg" {
  name                      = "web-asg"
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 2
  vpc_zone_identifier       = [aws_subnet.private01.id, aws_subnet.private02.id]
  launch_configuration      = aws_launch_configuration.web-lc.name
  target_group_arns         = [aws_lb_target_group.target-elb.arn]
  health_check_grace_period = 300
  termination_policies      = ["OldestInstance"]
  tag {
    key                 = "Name"
    value               = "Web_Server"
    propagate_at_launch = true
  }
  depends_on = [
    aws_db_instance.rds01
  ]
}

resource "aws_autoscaling_policy" "web-scaling" {
  name                   = "web-scaling"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.web-asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }
}


/*resource "aws_instance" "web" {
  count                       = 1
  ami                         = "ami-0b08bfc6ff7069aff"
  instance_type               = "t2.micro"
  key_name                   = "terraform_key_pair"
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  subnet_id                   = count.index == 0 ? aws_subnet.private01.id : aws_subnet.private02.id
  #associate_public_ip_address = true
  user_data = templatefile("user_data.sh", {
    rds_endpoint = jsondecode(data.aws_secretsmanager_secret_version.rds.secret_string)["endpoint"]
    rds_password = jsondecode(data.aws_secretsmanager_secret_version.rds.secret_string)["password"]
  })
  tags = {
    Name = "web_${count.index}"
  }

  depends_on = [
    aws_db_instance.rds01
  ]
}*/

resource "aws_instance" "jumpbox" {
  ami                         = "ami-0b08bfc6ff7069aff"
  instance_type               = "t2.small"
  key_name                   = "terraform_key_pair"
   vpc_security_group_ids      = [aws_security_group.web_sg_public.id]
  subnet_id                   = aws_subnet.public01.id
  associate_public_ip_address = true
  tags = {
    Name = "Jumpbox"
  }

  depends_on = [
    aws_db_instance.rds01
  ]
}
