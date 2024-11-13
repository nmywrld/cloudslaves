resource "aws_ecs_cluster" "frontend_cluster" {
  name = "joelene-frontend-public"
}

resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "frontend-task"
  network_mode             = "awsvpc"  # Required for Fargate
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"     # Adjust as per requirements
  memory                   = "512"     # Adjust as per requirements
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  # container_definitions = jsonencode([{
  #   name      = "frontend"
  #   image     = "nmywrld/cloudslaves-frontend"
  #   essential = true
  #   portMappings = [
  #     {
  #       containerPort = 80
  #       protocol      = "tcp"
  #     }
  #   ]
  # }])

  container_definitions = jsonencode([{
    name      = "frontend"
    image     = "nmywrld/cloudslaves-frontend"
    essential = true
    portMappings = [
      {
        containerPort = 80
        protocol      = "tcp"
      }
    ]
    environment = [
      {
        name  = "BACKEND_URL"
        value = "http://${aws_lb.backend_app_lb.dns_name}"
      }
      // Add other environment variables here
    ]
  }])

  depends_on = [ aws_lb.backend_app_lb ]
}

# IAM role for ECS task execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions   = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
# Security group for ECS service
resource "aws_security_group" "ecs_service_sg" {
  name        = "ecs-service-sg"
  description = "Security group for ECS service"
  vpc_id      = aws_vpc.frontend.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.frontend_alb_sg.id]  # Allow traffic only from ALB security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Update ECS Service configuration to use the new security group
resource "aws_ecs_service" "frontend_service" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.frontend_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # Network configuration
  network_configuration {
    subnets          = [for subnet in aws_subnet.frontend_private : subnet.id]  # Loop through and get all public subnet IDs
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_service_sg.id]  # Reference the new security group for ECS
  }

  # Load Balancer configuration
  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_ecs_tg.arn
    container_name   = "frontend"
    container_port   = 80
  }

  # Explicitly define dependencies to ensure all resources are created before ECS Service
  depends_on = [
    aws_security_group.ecs_service_sg,    # New security group dependency
    aws_lb_target_group.frontend_ecs_tg,  # Target group dependency
    aws_lb_listener.frontend_public_http  # Load balancer listener dependency
  ]
}



# CloudWatch Metric for ECS Service CPU Utilization
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "ecs-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "20"
  alarm_description   = "This metric monitors ECS service CPU utilization"
  dimensions = {
    ClusterName  = aws_ecs_cluster.frontend_cluster.name
    ServiceName  = aws_ecs_service.frontend_service.name
  }
}

# ECS Service Autoscaling
resource "aws_appautoscaling_target" "frontend_scaling_target" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.frontend_cluster.name}/${aws_ecs_service.frontend_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "frontend_scaling_policy" {
  name               = "frontend-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.frontend_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.frontend_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.frontend_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 50.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}