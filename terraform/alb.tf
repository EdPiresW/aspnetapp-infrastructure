# ALB Creation
resource "aws_lb" "aspnetapp_lb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.aspnetapp_sg_alb.id]
  subnets            = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]

  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true

  tags = {
    Name = var.alb_name
  }
}

# ALB Blue Target Group 
resource "aws_lb_target_group" "blue_aspnetapp_target" {
  name        = var.blue_target_group_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.aspnetapp_vpc.id
  target_type = "ip"

  health_check {
    path     = "/"
    port     = 80
    protocol = "HTTP"
  }
}

# ALB Green Target Group 
resource "aws_lb_target_group" "green_aspnetapp_target" {
  name        = var.green_target_group_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.aspnetapp_vpc.id
  target_type = "ip"

  health_check {
    path     = "/"
    port     = 80
    protocol = "HTTP"
  }
}

# ALB Listener 
resource "aws_lb_listener" "aspnetapp_lb_listiner" {
  load_balancer_arn = aws_lb.aspnetapp_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue_aspnetapp_target.arn
  }

  lifecycle {
    ignore_changes = [default_action]
  }
  depends_on = [aws_lb.aspnetapp_lb]
}

# ALB test Listener
resource "aws_lb_listener" "test_listener" {
  load_balancer_arn = aws_lb.aspnetapp_lb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green_aspnetapp_target.arn
  }

  lifecycle {
    ignore_changes = [default_action]
  }
}