terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.72.1"
    }
  }

//  backend "remote" {
//    hostname     = "app.terraform.io"
//    organization = "cloudslaves"

//    workspaces {
//      name = "cloudslaves"
//    }
//  }
}

// local resource  to read the access key and secret key from json
locals {
  aws_credentials = jsondecode(file("./credentials.json"))
}


provider "aws" {
  region     = "ap-southeast-1"
  access_key = local.aws_credentials.access_key
  secret_key = local.aws_credentials.secret_key

}