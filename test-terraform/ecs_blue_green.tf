# Definir o ECS Cluster
resource "aws_ecs_cluster" "aspnetapp_cluster" {
  name = "aspnetapp-cluster"
}

# Definir a IAM Role para execução da tarefa
resource "aws_iam_role" "ecs_execution_role" {
  name               = "ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_execution_assume_role_policy.json
}

# IAM Policy Document para ECS Execution Role
data "aws_iam_policy_document" "ecs_execution_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Anexar política de execução do ECS
resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_execution_role.name
}

# Definir a Task Definition para a aplicação ASP.NET Core
resource "aws_ecs_task_definition" "aspnetapp_task" {
  family                   = "aspnetapp-task"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  
  container_definitions = jsonencode([{
    name      = "aspnetapp-container"
    image     = "${aws_ecr_repository.aspnetapp.repository_url}:latest"
    essential = true
    portMappings = [
      {
        containerPort = 80
        hostPort      = 80
        protocol      = "tcp"
      }
    ]
  }])
}

# Definir o Service para Blue/Green Deployment no ECS
resource "aws_ecs_service" "aspnetapp_service" {
  name            = "aspnetapp-service"
  cluster         = aws_ecs_cluster.aspnetapp_cluster.id
  task_definition = aws_ecs_task_definition.aspnetapp_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_target_group.arn
    container_name   = "aspnetapp-container"
    container_port   = 80
  }

  network_configuration {
    subnets          = var.subnets
    security_groups = [aws_security_group.aspnetapp_sg.id]
    assign_public_ip = true
  }

  depends_on = [aws_lb_listener.http]
}

# Configuração do CodeDeploy para Blue/Green Deployment
resource "aws_codedeploy_app" "aspnetapp_codedeploy_app" {
  name = "aspnetapp-deployment"
}

resource "aws_codedeploy_deployment_group" "aspnetapp_codedeploy_deployment_group" {
  app_name              = aws_codedeploy_app.aspnetapp_codedeploy_app.name
  deployment_group_name = "aspnetapp-deployment-group"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  deployment_style {
    deployment_type = "BLUE_GREEN"
    blue_green_deployment_config {
      terminate_blue_instances_on_deployment_success {
        action = "TERMINATE"
        delay  = 0
      }
      deployment_ready_option {
        action_on_timeout = "STOP_DEPLOYMENT"
        wait_time_in_minutes = 10
      }
    }
  }

  blue_green_deployment_config {
    blue_target_group  = aws_lb_target_group.app_target_group.arn
    green_target_group = aws_lb_target_group.app_target_group.arn
    listener_arn       = aws_lb_listener.http.arn
  }
}

# Função do IAM para CodeDeploy
resource "aws_iam_role" "codedeploy_role" {
  name               = "codedeploy-execution-role"
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume_role_policy.json
}

data "aws_iam_policy_document" "codedeploy_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "codedeploy_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CodeDeployRole"
  role       = aws_iam_role.codedeploy_role.name
}
