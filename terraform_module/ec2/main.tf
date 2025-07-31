resource "aws_instance" "my-instance" {
    ami = var.image_id
    instance_type = var.instance_type
    subnet_id = var.subnet_id
    key_name = var.key_name
    vpc_security_group_ids = [aws_security_group.my-sg.id]
    tags = {
      Name = "${var.project}-public-ec2"
    }

  
}
resource "aws_security_group" "my-sg" {
    vpc_id = var.vpc_id
    description = "Enable 80 and 22"
    name = "vpc-sec-grp"
    ingress  {
        from_port = 22
        to_port = 22
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
        description = "SSH"
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP"
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
  
}
