resource "aws_iam_role" "aspnetapp_codedeploy" {
  name = "codedeploy-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "codedeploy.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Criar a aplicação CodeDeploy
resource "aws_codedeploy_app" "aspnetapp_codedeploy_app" {
  compute_platform = "ECS"
  name             = "aspnetapp-deployment"
}

# Criar o grupo de implantação CodeDeploy (Blue/Green Deployment)
resource "aws_codedeploy_deployment_group" "aspnetapp_codedeploy_deployment_group" {
  app_name               = aws_codedeploy_app.aspnetapp_codedeploy_app.name
  deployment_group_name  = "aspnetapp-deployment-group"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn       = aws_iam_role.aspnetapp_codedeploy.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  deployment_style {
    deployment_type   = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }

    deployment_ready_option {
      action_on_timeout    = "STOP_DEPLOYMENT"
      wait_time_in_minutes = 10
    }

  }
  ecs_service {
    cluster_name = aws_ecs_cluster.aspnetapp_ecs_cluster.name
    service_name = aws_ecs_service.aspnetapp_ecs_service.name
  }
  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.aspnetapp_lb_listiner.arn]
      }

      target_group {
        name = aws_lb_target_group.blue_aspnetapp_target.arn
      }

      target_group {
        name = aws_lb_target_group.green_aspnetapp_target.arn
      }
    }
  }
  # Relacionamento do ECS Service com CodeDeploy
  depends_on = [aws_ecs_service.aspnetapp_ecs_service]
}
