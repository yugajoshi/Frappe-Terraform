
resource "aws_vpc" "my-vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    tags = {
        Name = "${project}-vpc"
    }
  
}
 resource "aws_subnet" "public-subnet" {
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = var.public_subnet_cidr
    availability_zone = var.public_subnet_az
    map_public_ip_on_launch = true
    tags = {
      Name = "${var.project}-frappe"
    }
   
 }
 resource "aws_subnet" "private-subnet" {
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = var.private_subnet_cidr
    availability_zone = var.private_subnet_az
    map_public_ip_on_launch = false
    tags = {
      Name = "${var.project}-frappe"
    }
   
 }
 resource "aws_internet_gateway" "my-igw" {
    vpc_id = aws_vpc.my-vpc.id
   
 }
 resource "aws_default_route_table" "public-rt-table" {
    default_route_table_id = aws_vpc.my-vpc.default_route_table_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my-igw.id
    }
    tags = {
      Name = "${var.project}-public"
    }
  
}

resource "aws_eip" "nat-ip" {
    domain = "vpc"
   
 }

 resource "aws_nat_gateway" "my-nat-gateway" {
    tags = {
      Name = "${var.project}-nat"
    }
    subnet_id = aws_subnet.public-subnet.id
    allocation_id = aws_eip.nat-ip.id
   
 }

 resource "aws_route_table" "private-rt-table" {
    vpc_id = aws_vpc.my-vpc.id
    route  {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.my-nat-gateway.id

    }
    tags = {
      Name = "${var.project}-private"
    }
   
 }

 resource "aws_route_table_association" "public-rt-association" {
    subnet_id = aws_subnet.public-subnet.id
    route_table_id = aws_route_table.public-rt-table.id
   
 }

 resource "aws_route_table_association" "private-rt-association" {
    subnet_id = aws_subnet.private-subnet.id
    route_table_id = aws_route_table.private-rt-table.id
   
 }



 resource "aws_instance" "public-ec2" {
    tags = {
      Name = "public-ec2"
    }
    instance_type = "t2.micro"
    ami = "ami-0f918f7e67a3323f0"
    subnet_id = aws_subnet.public-subnet.id
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.public-sg.id]
    key_name = "public_linux"

   
 }

 resource "aws_security_group" "public-sg" {
    vpc_id = aws_vpc.my-vpc.id
    name = "public-instance-sg"
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
      Name = "private-ec2"
    }
      instance_type = "t2.micro"
      ami = "ami-0f918f7e67a3323f0"
      subnet_id = aws_subnet.private-subnet.id
      associate_public_ip_address = false
      vpc_security_group_ids = [aws_security_group.private_sg.id]
      key_name = "public_linux"
    
   
 }

 resource "aws_security_group" "private_sg" {
  name        = "private-instance-sg"
  description = "Allow SSH from public SG, and HTTP/HTTPS"
  vpc_id      = aws_vpc.my-vpc.id

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


 
