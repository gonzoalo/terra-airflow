# Deploying airflow with terraform 

# S3 for storing dags

resource "aws_s3_bucket" "airflow" {
  bucket        = "${var.project}-dags"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "airflow" {
  bucket = aws_s3_bucket.airflow.id
  acl    = "private"
}

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
  name        = "${var.project}-airflow-sg"
  description = "Allow incoming connections"
  vpc_id      = data.aws_vpc.main_vpc.id

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
  ami           = "ami-026b57f3c383c2eec"
  instance_type = var.instance_type

  user_data = <<-EOF
    #!/bin/bash
    set -ex
    sudo yum update -y
    sudo yum install automake fuse fuse-devel gcc-c++ git libcurl-devel libxml2-devel make openssl-devel -y
    git clone https://github.com/s3fs-fuse/s3fs-fuse.git /opt/s3fs-fuse
    cd /opt/s3fs-fuse
    ./autogen.sh
    ./configure --prefix=/usr --with-openssl
    make
    sudo make install
    echo "${var.AWS_ACCESS_KEY}:${var.AWS_SECRET_ACCESS_KEY}" | sudo tee /etc/passwd-s3fs
    sudo chmod 640 /etc/passwd-s3fs
    mkdir /opt/airflow
    cd /opt/airflow
    mkdir -p ./dags ./logs ./plugins
    sudo s3fs ${aws_s3_bucket.airflow.bucket} -o use_cache=/tmp -o allow_other -o uid=1001 -o mp_umask=002 -o multireq_max=5 /opt/airflow/dags
    sudo amazon-linux-extras install docker -y
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    mkdir -p /usr/local/lib/docker/cli-plugins
    curl -SL https://github.com/docker/compose/releases/download/v2.4.1/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
    curl -LfO 'https://airflow.apache.org/docs/apache-airflow/2.2.5/docker-compose.yaml'
    sed -i "s/AIRFLOW__CORE__LOAD_EXAMPLES: 'true'/AIRFLOW__CORE__LOAD_EXAMPLES: 'false'/" docker-compose.yaml
    echo -e "AIRFLOW_UID=$(id -u)" > .env
    echo -e "_PIP_ADDITIONAL_REQUIREMENTS='boto3 pandas smart-open spotipy'" >> .env
    sudo docker compose up airflow-init
    sudo docker compose up -d
  EOF

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
    local_file.airflow_ssh_key,
    aws_s3_bucket.airflow
  ]

}