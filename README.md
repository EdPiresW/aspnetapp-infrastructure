# aspnetapp-infrastructure  
*Terraform-based AWS Blue/Green deployment for ASP.NET Core on ECS Fargate*

## 🚀 Overview  
This project automates provisioning of infrastructure and CI/CD pipelines on AWS using Terraform, enabling zero‑downtime **blue/green deployments** of an ASP.NET Core application running in ECS Fargate, leveraging ALB, ECR, CodeDeploy, CloudWatch alarms, and GitHub Actions.

## 🧩 Architecture  
- **VPC setup** with 2 public subnets, internet gateway, security group  
- **ECR repository** for storing container images with lifecycle policy  
- **ECS cluster & service** running in Fargate  
- **Application Load Balancer (ALB)** with blue/green target groups and listeners on ports 80 and 8080  
- **CodeDeploy application & Deployment Group** configured for blue/green deployments and rollback  
- **CloudWatch alarms** for unhealthy targets and CodeDeploy deployment success/failure  
- **GitHub Actions workflows** for Terraform validation (`terraform.yaml`), linting (`terraform-lint.yaml`) and deployment (`build-deploy.yaml`)

## 🗂 Directory Structure  
```text
.
├── terraform/                  # Terraform configuration files
├── build-deploy.yaml           # Workflow: build, push and trigger CodeDeploy
├── terraform.yaml              # Workflow: terraform init, validate, plan
├── terraform-lint.yaml         # Workflow: tflint for Terraform code quality
└── Dockerfile                  # Base image & runtime for ASP.NET app
