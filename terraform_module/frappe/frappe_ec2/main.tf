resource "aws_instance" "public-ec2" {
    tags = {
      Name = "${var.project}-public-ec2"
    }
    instance_type = var.instance_type
    ami = var.ami_id
    subnet_id = var.public_subnet_id
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.public-sg.id]
    key_name = var.public_instance_key

   
 }

 resource "aws_security_group" "public-sg" {
    vpc_id = var.vpc_id
    name = "${var.project}-public-sg"
    description = "Allow SSH, HTTP, HTTPs from anywhere"

    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
	protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
    }
    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
	protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "HTTPS"
        from_port = 443
        to_port = 443
	protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
   
 }
 resource "aws_instance" "private-ec2" {
    tags = {
      Name = "${var.project}-private"
    }
      instance_type = var.instance_type
      ami = var.ami_id
      subnet_id = var.private_subnet_id
      associate_public_ip_address = false
      vpc_security_group_ids = [aws_security_group.private_sg.id]
      key_name = var.private_instance_key
    
   
 }

 resource "aws_security_group" "private_sg" {
  name        = "${var.project}-private-sg"
  description = "Allow SSH from public SG, and HTTP/HTTPS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from public SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public-sg.id]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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
