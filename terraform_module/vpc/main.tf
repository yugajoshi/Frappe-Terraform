resource "aws_vpc" "my-vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    tags = {
      Name = "${var.project}-vpc"
      env = var.env
    }
  
}

resource "aws_subnet" "public-subnet" {
    cidr_block = var.public_subnet_cidr
    vpc_id = aws_vpc.my-vpc.id
    map_public_ip_on_launch =  true
    tags = {
      Name = "${var.project}-public-subnet"
      env = var.env
    }
  
}

resource "aws_subnet" "private-subnet" {
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = var.private_subnet_cidr
    tags = {
      Name = "${var.project}-private-subnet"
      env = var.env
    }
}

resource "aws_internet_gateway" "my-igw" {
    vpc_id = aws_vpc.my-vpc.id
    tags = {
      Name = "${var.project}-igw"
    }
  
}
resource "aws_default_route_table" "public-rt" {
    default_route_table_id = aws_vpc.my-vpc.default_route_table_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my-igw.id
    }
  
}

resource "aws_eip" "nat-elastic-ip" {
    domain = "vpc"
  
}
resource "aws_nat_gateway" "my-nat" {
    subnet_id = aws_subnet.public-subnet.id
    allocation_id = aws_eip.nat-elastic-ip.id
  
}
resource "aws_route_table" "nat-route-table" {
    vpc_id = aws_vpc.my-vpc.id
    route  {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.my-nat.id
    }
    tags = {
      Name = "${var.project}-nat-rt"
    }
  
}

resource "aws_route_table_association" "nat-rt-association" {
    subnet_id = aws_subnet.private-subnet.id
    route_table_id = aws_route_table.nat-route-table.id
  
}
