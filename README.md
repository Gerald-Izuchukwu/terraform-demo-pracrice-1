# Terraform Demo Project

This repository contains a Terraform project that provisions a microservice application architecture on AWS. The architecture leverages Amazon EC2 instances, Amazon ECR for container storage, and auto-scaling with ELB for load balancing.

## Architecture Overview

The key components of the architecture include:

- **Amazon EC2 Instances**: Hosts for the microservice containers.
- **Amazon ECR (Elastic Container Registry)**: Repository for the container images.
- **Auto Scaling Group**: Manages the number of EC2 instances based on traffic.
- **Elastic Load Balancer (ELB)**: Distributes incoming traffic across the EC2 instances.

## Features

- **Infrastructure as Code**: Entire infrastructure is defined using Terraform.
- **Scalability**: Auto Scaling Group ensures the application scales in response to traffic.
- **High Availability**: ELB distributes traffic to ensure no single instance is overwhelmed.
- **Containerized Deployment**: Microservices are deployed as containers from ECR.

## Prerequisites

Before you begin, ensure you have the following:

- [Terraform installed](https://learn.hashicorp.com/terraform/getting-started/install.html)
- AWS CLI configured with appropriate permissions
- Docker installed and configured for building container images
- AWS account with necessary permissions

## Usage

<!-- 1. **Clone the Repository**

   ```sh
   git clone https://github.com/your-username/terraform-demo-practice-1.git
   cd terraform-demo-practice-1 -->
