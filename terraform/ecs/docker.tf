terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.72.1"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.17.0"
    }
  }
}

# Configure the Docker provider for Windows (using the named pipe)
provider "docker" {
  host = "npipe:////./pipe/docker_engine"  # Correct for Docker Desktop on Windows
}

# Build the Docker image
resource "docker_image" "frontend_image" {
  name = "cme-app:latest"  # Name for the Docker image

  build {
    path = "../../UI"  # Path to the directory where your Dockerfile is located
  }
}

# Push the image to Docker Hub (or any other registry)
resource "docker_registry_image" "frontend_registry_image" {
  name = "zotero309/cme-app:latest"  # Replace with your DockerHub username and repository

  # Use the name of the built Docker image as the source for the image to push
  depends_on = [docker_image.frontend_image]
}

# Local resource to read the access key and secret key from json
locals {
  aws_credentials = jsondecode(file("./credentials.json"))
}

# AWS provider configuration
provider "aws" {
  region     = "us-east-1"
  access_key = local.aws_credentials.access_key
  secret_key = local.aws_credentials.secret_key
}
