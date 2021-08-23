# Create repository 


This terraform code is for creating infrastucture AWS ALB + ASG
Task description is in the file TASK-README.md


## Getting Started

These instructions will get you a copy of the project and help you to run it on your local machine.

### Prerequisites

Before running the project you need to rename file variables.tf.example to variables.tf.
In variables.tf, you have to define variables:

```
variable "region" {
  default = "..."
}

variable "key-pair" {
  default = "..."
}

variable "route53zoneid" {
  default = "..."
}
``` 


### Installing 

```
git clone git@github.com:AlexandrVovk/devops-test.git

mv variables.tf.example variables.tf

cd devops-test

terraform init

```

### Deployment

```
terraform plan

terraform apply
```

## Authors

* **Alexandr Vovk** [GitHub](https://github.com/AlexandrVovk/)
