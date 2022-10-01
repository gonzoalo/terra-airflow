variable "project" {
  type        = string
  description = "Project Name"
  default     = "project1"
}
variable "AWS_ACCESS_KEY" {
  type        = string
  description = "Access key for AWS"
  sensitive   = true
}

variable "AWS_SECRET_ACCESS_KEY" {
  type        = string
  description = "Secret access key for AWS"
  sensitive   = true
}

variable "instance_type" {
  type    = string
  default = "t3.large"
}

variable "vpc_id" {
  type        = string
  description = "Main VPC id"
}

variable "public_subnet_a_id" {
  type        = string
  description = "Public subnet a id"
}