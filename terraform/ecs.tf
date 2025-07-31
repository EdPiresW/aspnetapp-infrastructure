# ECS cluster criation
resource "aws_ecs_cluster" "aspnetapp_ecs_cluster" {
  name = "aspnetapp-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# ECS taks definition
resource "aws_ecs_task_definition" "aspnetapp_task_definition" {
  family                   = "aspnetapp-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "aspnetapp-container"
      image     = "${aws_ecr_repository.aspnetapp_repository.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
    }
  ])
}

# ECS Service 
resource "aws_ecs_service" "aspnetapp_ecs_service" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.aspnetapp_ecs_cluster.name
  task_definition = aws_ecs_task_definition.aspnetapp_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets         = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
    security_groups = [aws_security_group.aspnetapp_sg_alb.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue_aspnetapp_target.arn
    container_name   = var.ecs_service_name
    container_port   = 8080
  }
  lifecycle {
    ignore_changes = [
      load_balancer
    ]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
