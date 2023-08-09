variable "vpc_cidr_block" {
  description = "My VPC cidr block"
  type = string
  default = "192.168.0.0/16"
}

variable "public_subnets_cidr" {
  description = "CIDR blocks for public subnets"
  type = list(string)
  default = [ "192.168.1.0/24", "192.168.2.0/24" ]
}

variable "private_subnets_cidr" {
  description = "CIDR blocks for private subnets"
  type = list(string)
  default = [ "192.168.3.0/24", "192.168.4.0/24" ]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default = [ "eu-west-2a", "eu-west-2b" ]
}