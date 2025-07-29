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
        EOF
    )

    tags = {
      env = "dev"
    }
  
}

resource "aws_launch_template" "my_template_cloth" {
    image_id = var.image_id #"ami-0f918f7e67a3323f0"
    name = "my-template-cloth"
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
        mkdir /var/www/html/cloth
        echo "Hello from Cloth Page" >/var/www/html/cloth/index.html
        EOF
    )

    tags = {
      env = "dev"
    }
  
}

resource "aws_launch_template" "my_template_mobile" {
    image_id = var.image_id #"ami-0f918f7e67a3323f0"
    name = "my-template-mobile"
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
    target_group_arns   = [aws_lb_target_group.tg_home.arn]
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

resource "aws_autoscaling_group" "cloth_asg" {
    name = "cloth-asg"
    max_size = 3
    min_size = 1
    desired_capacity = 2
    launch_template {
      id = aws_launch_template.my_template_cloth.id

    }
    availability_zones = var.availability_zone
    target_group_arns   = [aws_lb_target_group.tg_cloth.arn]
    tag {
      key = "env"
      value = "dev"
      propagate_at_launch = true
    }
}

resource "aws_autoscaling_policy" "cloth_asp" {
    name = "cloth-asp"
    autoscaling_group_name = aws_autoscaling_group.cloth_asg.name
    policy_type = "TargetTrackingScaling"
    target_tracking_configuration {
      predefined_metric_specification {
        predefined_metric_type = "ASGAverageCPUUtilization"
      }
      target_value = 50
    }
  
}

resource "aws_autoscaling_group" "mobile_asg" {
    name = "mobile-asg"
    max_size = 3
    min_size = 1
    desired_capacity = 2
    launch_template {
      id = aws_launch_template.my_template_mobile.id
    }
    availability_zones = var.availability_zone
    target_group_arns   = [aws_lb_target_group.tg_mobile.arn]
    tag {
      key = "env"
      value = "dev"
      propagate_at_launch = true
    }
}

resource "aws_autoscaling_policy" "mobile_asp" {
    name = "mobile-asp"
    autoscaling_group_name = aws_autoscaling_group.mobile_asg.name
    policy_type = "TargetTrackingScaling"
    target_tracking_configuration {
      predefined_metric_specification {
        predefined_metric_type = "ASGAverageCPUUtilization"
      }
      target_value = 50
    }
  
}


