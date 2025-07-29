provider "aws" {
    region = "ap-south-1"
  
}
resource "aws_launch_template" "my_template_home" {
    image_id = var.image_id #"ami-0f918f7e67a3323f0"
    name = "my-template-home"
    instance_type = var.instance_type #"t2.micro"
    key_name = var.key_name #"public_linux"
    vpc_security_group_ids = var.security_group_id
    user_data = base64encode(<<-EOF
        #!/bin/bash
        sudo -i
        apt update -y
        apt install apache2 -y
        systemctl start apache2
        systemctl enable apache2
        echo "Hello from Home Page" >/var/www/html/index.html
        mkdir /var/www/html/cloth
        echo "Hello from Cloth Page" >/var/www/html/cloth/index.html
        mkdir /var/www/html/mobile
        echo "Hello from Mobile Page" >/var/www/html/mobile/index.html
        EOF
    )

    tags = {
      env = "dev"
    }
  
}

resource "aws_autoscaling_group" "home_asg" {
    name = "home-asg"
    max_size = 3
    min_size = 1
    desired_capacity = 2
    launch_template {
      id = aws_launch_template.my_template_home.id
    }
    availability_zones = var.availability_zone
    target_group_arns   = [aws_lb_target_group.app_tg.arn]
    tag {
      key = "env"
      value = "dev"
      propagate_at_launch = true
    }
  
}

resource "aws_autoscaling_policy" "home_asp" {
    name = "home-asp"
    autoscaling_group_name = aws_autoscaling_group.home_asg.name
    policy_type = "TargetTrackingScaling"
    target_tracking_configuration {
      predefined_metric_specification {
        predefined_metric_type = "ASGAverageCPUUtilization"
      }
      target_value = 50
    }
}


resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP"
  vpc_id      = "vpc-0c7dfa3649ee39085"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "app_tg" {
  name        = "app-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "vpc-0c7dfa3649ee39085"
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}
resource "aws_lb" "app_alb" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = ["subnet-0019fb65b8b765997", "subnet-026ce912aff3e1142"] # Must be in 2 AZs minimum
}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
