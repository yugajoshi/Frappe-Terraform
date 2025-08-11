variable "main_region" {
  default = "us-east-2"
}
variable "peer_region" {
    default = "ap-south-1"
}
variable "main_vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "project" {
  default = "frappe"
}
variable "env" {
  default = "dev"
}
variable "main_vpc_subnet_cidr" {
  default = "10.0.1.0/24"
}
variable "main_vpc_subnet_az" {
    default = "us-east-a"
}
variable "peer_vpc_cidr" {
  default = "172.32.0.0/16"
}
variable "peer_vpc_subnet_cidr" {
  default = "172.32.1.0/24"
}
variable "peer_vpc_subnet_az" {
  default = "ap-south-1a"
}
variable "main_vpc_instance_ami" {
  default = "ami-08221e706f343d7b7"
}
variable "main_vpc_instance_key" {
  default = "ohio"
}
variable "main_vpc_instance_type" {
  default = "t2.micro"
}
variable "peer_vpc_instance_ami" {
  default = "ami-0144277607031eca2"
}
variable "peer_vpc_instance_key" {
  default = "public_linux"
}
variable "peer_vpc_instance_type" {
  default = "t2.micro"
}
