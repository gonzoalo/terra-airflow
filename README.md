# Testing terraform for airflow and AWS

This project is to test the use case for terraform with airflow in a AWS environment.

With this repo you can launch an airflow service for your team in AWS through terraform iac(infrastructure as code)

This project has an simple but powerful architecture that let see what can be done with terraform 


In this case we are going launch airflow in a ec2 with docker 
for that we are going to create our keys and security groups 
and also create a s3 bucket to put our dag files 

with this architecture anyone can create dags, drag them to the S3 bucket and see them in the webserver.


## Instructions

You need a vpc id and subnet id for the ec2 instance as input for the terraform process
Also the credentials of your aws account to set the dags folder location to an S3 bucket
Put this data on the `terraform.tfvars` file

```
cd infrastructre
terraform init 
terraform plan

# if everything is ok

terraform apply
```

After everything is runnig you can check your public ip and see how the magic of terraform is done.


## What else can be done?

- Terraform allows you to use S3 as a backend to host your tf states.
- Also terraform allows you to create users in the airflow instance for the people in your team. (you can connect with the slack provider and send the credentials in a slack message!!)
- Create a CI/CD pipeline for the dags in the repo to be automatically uploaded to the S3 bucket.



Enjoy!
