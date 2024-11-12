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
  }])
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

# ECS Service configuration
resource "aws_ecs_service" "frontend_service" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.frontend_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # Network configuration
  network_configuration {
    subnets          = [for subnet in aws_subnet.frontend_public : subnet.id]  # Loop through and get all public subnet IDs
    assign_public_ip = true
    security_groups  = [aws_security_group.frontend_alb_sg.id]  # Reference the security group for ALB
  }

  # Load Balancer configuration
  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_ecs_tg.arn
    container_name   = "frontend"
    container_port   = 80
  }

  # Explicitly define dependencies to ensure all resources are created before ECS Service
  depends_on = [
    aws_security_group.frontend_alb_sg,   # Security group dependency
    aws_lb_target_group.frontend_ecs_tg,  # Target group dependency
    aws_lb_listener.frontend_public_http  # Load balancer listener dependency
  ]
}
