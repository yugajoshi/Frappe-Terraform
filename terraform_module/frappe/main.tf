provider "aws" {
    region = "ap-south-1"
  
}
module "frappe_vpc" {
    source = "./modules/frappe"
    vpc_cidr = var.vpc_cidr
    public_subnet_cidr = var.public_subnet_cidr
    private_subnet_cidr = var.private_subnet_cidr
    public_subnet_az = var.public_subnet_az
    private_subnet_az = var.private_subnet_az
    project = var.project
  
}
module "frappe_instances" {
    source = "./modules/frappe_ec2"
    project = var.project
    ami_id = var.ami_id
    instance_type = var.instance_type
    public_instance_key = var.public_instance_key
    private_instance_key = var.private_instance_key
    public_subnet_id = module.frappe_vpc.public_subnet
    private_subnet_id = module.frappe_vpc.private_subnet
    vpc_id = module.frappe_vpc.vpc_id
  
}
