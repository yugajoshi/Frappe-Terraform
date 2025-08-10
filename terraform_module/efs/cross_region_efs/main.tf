provider "aws" {
    region = "us-east-2"
}
provider "aws" {
    alias = "peer" 
    region = "ap-south-1"
}

resource "aws_vpc" "my-vpc" {
  provider = aws
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      Name = "my-vpc"
      env = "dev"
    }
  
}

resource "aws_subnet" "public-subnet" {
    cidr_block = "10.0.1.0/24"
    vpc_id = aws_vpc.my-vpc.id
    map_public_ip_on_launch =  true
    availability_zone = "us-east-2a"
    tags = {
      Name = "public-subnet"
      env = "dev"
    }
  
}

resource "aws_internet_gateway" "my-igw" {
    vpc_id = aws_vpc.my-vpc.id
    tags = {
      Name = "my-igw"
    }
  
}

resource "aws_default_route_table" "public-rt" {
    default_route_table_id = aws_vpc.my-vpc.default_route_table_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my-igw.id
    }
    
  
}

resource "aws_route" "vpc_peering_route" {
  route_table_id = aws_vpc.my-vpc.default_route_table_id
  destination_cidr_block = "172.32.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.my-peer.id
  depends_on = [ aws_vpc_peering_connection.my-peer,aws_vpc_peering_connection_accepter.my-peer-accepter ]
  
}

resource "aws_vpc_peering_connection" "my-peer" {
  vpc_id = aws_vpc.my-vpc.id
  peer_vpc_id = aws_vpc.my-vpc-1.id
  peer_region = "ap-south-1"
  auto_accept = false
  # accepter {
  #   allow_remote_vpc_dns_resolution = true
  # }
  # requester {
  #   allow_remote_vpc_dns_resolution = true
  # }
  
  tags = {
    Side = "Requester"
  }
  depends_on = [ aws_vpc.my-vpc, aws_vpc.my-vpc-1 ]
}

resource "aws_vpc_peering_connection_accepter" "my-peer-accepter" {
    provider = aws.peer
    # region = "ap-south-1"
    vpc_peering_connection_id = aws_vpc_peering_connection.my-peer.id
    auto_accept = true
    # accepter {
    #   allow_remote_vpc_dns_resolution = true
    # }
    tags = {
      Side = "Accepter"
    }
    depends_on = [ aws_vpc_peering_connection.my-peer ]
}



########################################
resource "aws_vpc" "my-vpc-1" {
    cidr_block = "172.32.0.0/16"
    provider = aws.peer
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      Name = "my-vpc"
      env = "dev"
    }
  
}

resource "aws_subnet" "public-subnet-1" {
    cidr_block = "172.32.1.0/24"
    provider = aws.peer
    vpc_id = aws_vpc.my-vpc-1.id
    map_public_ip_on_launch =  true
    availability_zone = "ap-south-1a"
    tags = {
      Name = "public-subnet"
      env = "dev"
    }
  
}

resource "aws_internet_gateway" "my-igw-1" {
    provider = aws.peer
    vpc_id = aws_vpc.my-vpc-1.id
    tags = {
      Name = "my-igw"
    }
  
}

resource "aws_default_route_table" "public-rt-1" {
    provider = aws.peer
    default_route_table_id = aws_vpc.my-vpc-1.default_route_table_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my-igw-1.id
    }
    
  
}


resource "aws_route" "vpc1_peering_route" {
  provider = aws.peer
  route_table_id = aws_vpc.my-vpc-1.default_route_table_id
  destination_cidr_block = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.my-peer.id
  depends_on = [ aws_vpc_peering_connection.my-peer,aws_vpc_peering_connection_accepter.my-peer-accepter ]
  
}

############################
resource "aws_efs_file_system" "my_efs" {
    creation_token = "my-efs"
    depends_on = [ aws_vpc.my-vpc ]
}

resource "aws_efs_mount_target" "efs_mount_target_a" {
    file_system_id = aws_efs_file_system.my_efs.id
    subnet_id = aws_subnet.public-subnet.id
    security_groups = [aws_security_group.nfs_sg.id]
    depends_on = [ aws_vpc.my-vpc, aws_efs_file_system.my_efs ]

}



resource "aws_security_group" "nfs_sg" {
    name = "nfs-sg"
    provider = aws
    vpc_id = aws_vpc.my-vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        description = "SSH Protocol"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 2049
        to_port = 2049
        protocol = "tcp"
        description = "NFS protocol"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      description = "HTTP"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      description = "HTTPS"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        description = "Allow All outbound"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}



resource "aws_instance" "my-ec2_a" {
    provider = aws
    ami = "ami-08221e706f343d7b7"
    key_name = "ohio"
    security_groups = [aws_security_group.nfs_sg.id]
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public-subnet.id

    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file("ohio.pem")
      host = self.public_ip
    }
    provisioner "remote-exec" {
        inline = [ "sudo yum install amazon-efs-utils -y",
         "sudo mkdir -p /mnt/efs",
         "sudo mount -t efs ${aws_efs_file_system.my_efs.id}:/ /mnt/efs"
          ]
      
    }
    depends_on = [ aws_efs_mount_target.efs_mount_target_a]
  
}


resource "aws_instance" "my-ec2_b" {
    provider = aws.peer
    ami = "ami-0144277607031eca2"
    key_name = "public_linux"
    security_groups = [aws_security_group.nfs_sg-1.id]
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public-subnet-1.id

    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file("public_linux.pem")
      host = self.public_ip
    }
    provisioner "remote-exec" {
        inline = [ "sudo yum install amazon-efs-utils -y",
         "sudo mkdir -p /mnt/efs",
         "sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_mount_target.efs_mount_target_a.ip_address}:/ /mnt/efs"
          ]
      
    }
    depends_on = [ aws_efs_mount_target.efs_mount_target_a]
  
}


resource "aws_security_group" "nfs_sg-1" {
    name = "nfs-sg"
    provider = aws.peer
    vpc_id = aws_vpc.my-vpc-1.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        description = "SSH Protocol"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 2049
        to_port = 2049
        protocol = "tcp"
        description = "NFS protocol"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      description = "HTTP"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      description = "HTTPS"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        description = "Allow All outbound"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}
