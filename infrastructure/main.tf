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

# EC2 instance