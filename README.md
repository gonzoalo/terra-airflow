# Testing terraform for airflow and AWS

This project is to test the use case for terraform with airflow in a AWS environment.

With this repo you can launch an airflow service for your team in AWS through terraform iac(infrastructure as code)

## Instructions

You need a vpc id and subnet id for the ec2 instance as input for the terraform process
Put your ids on the `terraform.tfvars` file

```
cd infrastructre
terraform init 
terraform plan

# if everything is ok

terraform apply
```


Enjoy!
