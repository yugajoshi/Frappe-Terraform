variable "db_identifier" {
    
  
}
variable "db_engine" {
  
}
variable "allocated_storage" {
  
}
variable "engine_version" {
  
}
variable "instance_class" {
  
}
variable "username" {
    default = "admin"
}
variable "db_password" {
  
}
variable "storage_type" {
  
}

variable "project" {
    default = "frappe"
  
}
variable "subnet_ids" {
  default = ["subnet-026ce912aff3e1142","subnet-0794c32eed0d60cbf"]
}
variable "vpc_id" {
  default = "vpc-0c7dfa3649ee39085"
}
