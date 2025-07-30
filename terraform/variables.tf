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
