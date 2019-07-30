# Configure the AWS Provider
provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.region}"
}
  
resource "aws_instance" "web-server" {
    ami= "ami-e24b7d9d"
    instance_type= "t2.micro"

    tags = {
    Name= "Devops"
    }
}

variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "region" {
        default = "us-east-1"
}

