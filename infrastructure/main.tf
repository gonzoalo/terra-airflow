# Deploying airflow with terraform 

# S3 for storing dags

# resource "aws_s3_bucket" "airflow" {
#     bucket        = "${var.porject}-dags"
#     force_destroy = true
# }

# resource "aws_s3_bucket_acl" "airflow" {
#     bucket  = aws_s3_bucket.airflow.id
#     acl     = "private"
#     key     = "/"
#     content = "application/x-directory"
# }

# Keys for ec2 instance

resource "tls_private_key" "airflow_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "airflow_key_pair" {
  key_name   = "${var.project}-key-pair"
  public_key = tls_private_key.airflow_key_pair.public_key_openssh
}

resource "local_file" "airflow_ssh_key" {
  filename = "${aws_key_pair.airflow_key_pair.key_name}.pem"
  content  = tls_private_key.airflow_key_pair.private_key_pem
}

# Security groups and vpc

resource "aws_security_group" "airflow_sg" {
    name = "${var.project}-airflow-sg"
    description = "Allow incoming connections"
    vpc_id = data.aws_vpc.main_vpc.id

    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow incoming web server connections"
    }

    ingress {
        from_port   = 5555
        to_port     = 5555
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow incoming connections for flower"
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow incoming SSH conections"
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# EC2 instance

resource "aws_instance" "airflow_instance" {
    ami                         = "ami-026b57f3c383c2eec"
    instance_type               = var.instance_type
    vpc_security_group_ids      = [aws_security_group.airflow_sg.id]
    associate_public_ip_address = "true"
    subnet_id                   = data.aws_subnet.public_a.id


    key_name = aws_key_pair.airflow_key_pair.key_name
    tags = {
        Name        = "${var.project}-airflow"
        Terraform   = "true"
        Environment = "test"
    }

    depends_on = [
      local_file.airflow_ssh_key
    ]

}