data "aws_subnet" "public_a" {
    id = var.public_subnet_a_id
}

data "aws_vpc" "main_vpc" {
    id = var.vpc_id
}