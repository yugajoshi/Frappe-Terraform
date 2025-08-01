resource "aws_db_instance" "rds-db" {
    identifier = var.db_identifier
  allocated_storage           = var.allocated_storage
  engine                      = var.db_engine
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  username                    = var.username
  password                    = var.db_password
  port = "3306"
  storage_type = var.storage_type
  publicly_accessible = false
  vpc_security_group_ids = [aws_security_group.rds-security_group.id]
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name
  skip_final_snapshot = true
  
  
  tags = {
    Name =  "${var.project}-frappe"
    env = "dev"
  }
}
resource "aws_db_subnet_group" "db_subnet" {
    name = "${var.project}-subnet-group"
    subnet_ids = var.subnet_ids
    tags = {
      Name = "${var.project}-frappe"
      env = "dev"
    }
  
}

resource "aws_security_group" "rds-security_group" {
    name = "terraform-db-sg"
    description = "Allow RDS Port"
    vpc_id = var.vpc_id
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow 3306 Port"
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow Outbound traffic"
    }
}
