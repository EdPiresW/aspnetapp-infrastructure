variable "aws_region" {
  default = "us-west-1"
  type    = string
}

variable "ecr_repo_name" {
  description = "Name or ECR repository"
  type        = string
  default     = "ed-cicd-project"
}

variable "alb_name" {
  description = "Name or ALB"
  type        = string
  default     = "aspnetapp-lb"
}
variable "blue_target_group_name" {
  description = "Name of the blue target group"
  type        = string
  default     = "aspnetapp-target-group-blue"
}

variable "green_target_group_name" {
  description = "Name of the green target group"
  type        = string
  default     = "aspnetapp-target-group-green"
}

variable "codedeploy_service_role_name" {
  description = "Name of the IAM role used by AWS CodeDeploy"
  type        = string
  default     = "aspnetapp-codedeploy-service-role"
}

variable "codedeploy_app_name" {
  description = "Name of the AWS CodeDeploy application"
  type        = string
  default     = "aspnetapp-deployment"
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
  default     = "aspnetapp_ecs_service"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "aspnetapp-vpc"
}

variable "subnet_a_name" {
  description = "Name of the public subnet A"
  type        = string
  default     = "aspnetapp-subnet-a"
}

variable "subnet_c_name" {
  description = "Name of the public subnet C"
  type        = string
  default     = "aspnetapp-subnet-c"
}

variable "alb_sg_name" {
  description = "Name of the Security Group used by the ALB"
  type        = string
  default     = "aspnetapp_sg_alb"
}
