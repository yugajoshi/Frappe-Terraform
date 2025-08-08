provider "aws" {
    region = "us-east-2"
  
}
resource "aws_efs_file_system" "my_efs" {
    creation_token = "my-efs"
  
}
resource "aws_efs_mount_target" "efs_mount_target_a" {
    file_system_id = aws_efs_file_system.my_efs.id
    subnet_id = "subnet-084b469669dbc4ae9"
    security_groups = ["sg-0925e2b52280d9d93"]

}
resource "aws_efs_mount_target" "efs_mount_target_b" {
    file_system_id = aws_efs_file_system.my_efs.id
    subnet_id = "subnet-09b5f106b09903aea"
    security_groups = ["sg-0925e2b52280d9d93"]

}

resource "aws_instance" "my-ec2_a" {
    ami = "ami-08221e706f343d7b7"
    key_name = "ohio"
    security_groups = ["sg-0925e2b52280d9d93"]
    instance_type = "t2.micro"
    subnet_id = "subnet-084b469669dbc4ae9"

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
    ami = "ami-08221e706f343d7b7"
    key_name = "ohio"
    security_groups = ["sg-0925e2b52280d9d93"]
    instance_type = "t2.micro"
    subnet_id = "subnet-09b5f106b09903aea"

    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file("ohio.pem")
      host = self.public_ip
    }
    provisioner "remote-exec" {
        inline = [ "sudo yum install amazon-efs-utils -y",
         "sudo mkdir -p /mnt/efs",
         "sudo mount -t efs -o tls ${aws_efs_file_system.my_efs.id}:/ /mnt/efs"
          ]
      
    }
    depends_on = [ aws_efs_mount_target.efs_mount_target_b]
  
}
