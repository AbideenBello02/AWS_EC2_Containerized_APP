variable "vpc_id" {
  description = "vpc id"
  type        = string
  default     = "vpc-074b43b6d9bdd916b"
}

variable "port" {
  description = "to and from port"
  type        = number
  default     = 2049
}

variable "subnet_cidr_block" {
  description = "subnet_cidr_block"
  type        = list(string)
  default     = ["172.31.1.0/24"]
}

variable "az" {
  description = "availability zone"
  type        = string
  default     = "us-east-1a"
}

variable "ami" {
  description = "ami id"
  type        = string
  default     = "ami-0e449927258d45bc4" 

}
