# Alarme para instâncias unhealthy no Target Group Green
resource "aws_cloudwatch_metric_alarm" "aspnetapp_unhealthy_alarm" {
  alarm_name          = "AspnetappUnhealthyAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "AspnetappUnHealthyCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "Triggers when there are unhealthy instances in the green target group"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TargetGroup  = aws_lb_target_group.green_aspnetapp_target.arn_suffix
    LoadBalancer = aws_lb.aspnetapp_lb.arn_suffix
  }
}

# Alarm for CodeDeploy deployment failure
resource "aws_cloudwatch_metric_alarm" "aspnetapp_deployment_failure_alarm" {
  alarm_name          = "AspnetappCodeDeployDeploymentFailures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DeploymentFailure"
  namespace           = "AWS/CodeDeploy"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Triggers if a deployment fails in CodeDeploy"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DeploymentGroupName = aws_codedeploy_deployment_group.aspnetapp_codedeploy_deployment_group.deployment_group_name
    ApplicationName     = aws_codedeploy_app.aspnetapp_codedeploy_app.name
  }
}

# Alarm for CodeDeploy deployment success
resource "aws_cloudwatch_metric_alarm" "aspnetapp_deployment_success_alarm" {
  alarm_name          = "AspnetappCodeDeployDeploymentSuccess"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "DeploymentSuccess"
  namespace           = "AWS/CodeDeploy"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggers if at least one successful deployment occurred in the last 5 minutes"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DeploymentGroupName = aws_codedeploy_deployment_group.aspnetapp_codedeploy_deployment_group.deployment_group_name
    ApplicationName     = aws_codedeploy_app.aspnetapp_codedeploy_app.name
  }
}
