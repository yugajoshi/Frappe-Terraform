provider "aws" {
    region = "ap-south-1"
  
}

module "vpc" {
    source = "./terraform_module/vpc"
    vpc_cidr = "172.16.0.0/16"
    private_subnet_cidr = "172.16.0.0/24"
    public_subnet_cidr = "172.16.1.0/24"
  
}

module "public-instance" {
    source = "./terraform_module/ec2"
    project = "frappe"
    instance_type = "t2.medium"
    subnet_id = module.vpc.public_subnet
    vpc_id = module.vpc.vpc_id
  
}

module "private-instance" {
    source = "./terraform_module/ec2"
    project = "frappe"
    instance_type = "t2.medium"
    subnet_id = module.vpc.private_subnet
    vpc_id = module.vpc.vpc_id
  
}
