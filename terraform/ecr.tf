# AWS ECR respository creation
resource "aws_ecr_repository" "aspnetapp_repository" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"

  lifecycle {
    prevent_destroy = false
  }
}

# AWS ECR respository lifecycle
resource "aws_ecr_lifecycle_policy" "aspnetapp_lifecycle" {
  repository = aws_ecr_repository.aspnetapp_repository.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1,
      description  = "Expire images older than 5 days",
      selection = {
        tagStatus   = "untagged",
        countType   = "sinceImagePushed",
        countUnit   = "days",
        countNumber = 5
      },
      action = {
        type = "expire"
      }
    }]
  })
}
