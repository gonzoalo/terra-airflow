variable "project" {
  type          = string
  description   = "Project Name"
  default       = "project1"
}

variable "instance_type" {
  type          = string
  default       = "t2.micro"
}

variable "public_subnet_a_id" {
  type          = string
  description   = "Public subnet a id"
}

variable "vpc_id" {
  type          = string
  description   = "Main VPC id"
}