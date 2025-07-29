variable "instance_type" {
    default = "t2.micro"
}
variable "image_id" {
  default = "ami-0f918f7e67a3323f0"
}
variable "key_name" {
    default = "public_linux"
}
variable "security_group_id" {
    default = ["sg-0fc18f34fff5cd421"]
  
}
variable "availability_zone" {
    default = ["ap-south-1a"]
  
}
variable "vpc_id" {
    default = "vpc-0c7dfa3649ee39085"
  
}
variable "subnets" {
    default = ["subnet-0019fb65b8b765997", "subnet-026ce912aff3e1142"]
  
}
