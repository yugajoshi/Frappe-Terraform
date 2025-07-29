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

resource "aws_lb_target_group" "tg_home" {
  name        = "tg-home"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "vpc-0c7dfa3649ee39085"
  health_check {
    path = "/"
  }
  tags = {
    env = "dev"
  }
  
}
resource "aws_lb_target_group" "tg_cloth" {
  name        = "tg-cloth"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "vpc-0c7dfa3649ee39085"
  health_check {
    path = "/cloth"
  }
  tags = {
    env = "dev"
  }
}
resource "aws_lb_target_group" "tg_mobile" {
  name        = "tg-mobile"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "vpc-0c7dfa3649ee39085"
  health_check {
    path = "/mobile"
  }
  tags = {
    env = "dev"
  }
}
resource "aws_lb" "app_alb" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnets # Must be in 2 AZs minimum
}
resource "aws_lb_listener" "aws_lb_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_home.arn
  }
}

resource "aws_lb_listener_rule" "aws_lb_listener_rule_cloth" {
  listener_arn = aws_lb_listener.aws_lb_listener.arn
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_cloth.arn
  }

  condition {
    path_pattern {
      values = ["/cloth/*"]
    }
  }
  
}
resource "aws_lb_listener_rule" "aws_lb_listener_rule_mobile" {
  listener_arn = aws_lb_listener.aws_lb_listener.arn
  priority     = 102

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_mobile.arn
  }

  condition {
    path_pattern {
      values = ["/mobile/*"]
    }
  }
  
}
