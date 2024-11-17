
# CloudWatch Metric for ECS Service CPU Utilization
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "ecs-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "This metric monitors ECS service CPU utilization"
  dimensions = {
    ClusterName  = aws_ecs_cluster.frontend_cluster.name
    ServiceName  = aws_ecs_service.frontend_service.name
  }
}

# front end VPC monitoring
resource "aws_cloudwatch_metric_alarm" "frontend_vpc_network_in" {
  alarm_name          = "frontend_vpc-network-in-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Sum"
  threshold           = 1000000000  # Adjust threshold as needed (in bytes)
  alarm_description   = "This metric monitors the incoming network traffic for the VPC"
  dimensions = {
    VpcId = aws_vpc.frontend.id
  }
}

resource "aws_cloudwatch_metric_alarm" "frontend_vpc_network_out" {
  alarm_name          = "frontend_vpc-network-out-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "NetworkOut"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Sum"
  threshold           = 1000000000  # Adjust threshold as needed (in bytes)
  alarm_description   = "This metric monitors the outgoing network traffic for the VPC"
  dimensions = {
    VpcId = aws_vpc.frontend.id
  }
}

# back end VPC monitoring
resource "aws_cloudwatch_metric_alarm" "backend_vpc_network_in" {
  alarm_name          = "backend-vpc-network-in-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Sum"
  threshold           = 1000000000  # Adjust threshold as needed (in bytes)
  alarm_description   = "This metric monitors the incoming network traffic for the VPC"
  dimensions = {
    VpcId = aws_vpc.backend.id
  }
}

resource "aws_cloudwatch_metric_alarm" "backend_vpc_network_out" {
  alarm_name          = "backend-vpc-network-out-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "NetworkOut"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Sum"
  threshold           = 1000000000  # Adjust threshold as needed (in bytes)
  alarm_description   = "This metric monitors the outgoing network traffic for the VPC"
  dimensions = {
    VpcId = aws_vpc.backend.id
  }
}

resource "aws_cloudwatch_metric_alarm" "nat_gateway_active_connections" {
  alarm_name          = "nat-gateway-active-connections-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ActiveConnectionCount"
  namespace           = "AWS/NATGateway"
  period              = 60
  statistic           = "Sum"
  threshold           = 1000  # Adjust threshold as needed
  alarm_description   = "This metric monitors the active connections for the NAT Gateway"
  dimensions = {
    NatGatewayId = aws_nat_gateway.frontend_nat.id
  }
}

resource "aws_cloudwatch_metric_alarm" "nat_gateway_bytes_out_to_destination" {
  alarm_name          = "nat-gateway-bytes-out-to-destination-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "BytesOutToDestination"
  namespace           = "AWS/NATGateway"
  period              = 60
  statistic           = "Sum"
  threshold           = 1000000000  # Adjust threshold as needed (in bytes)
  alarm_description   = "This metric monitors the bytes out to destination for the NAT Gateway"
  dimensions = {
    NatGatewayId = aws_nat_gateway.frontend_nat.id
  }
}

# CloudWatch Metric for frontend ELB
resource "aws_cloudwatch_metric_alarm" "elb_healthy_host_count" {
  alarm_name          = "elb-healthy-host-count-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ELB"
  period              = 60
  statistic           = "Average"
  threshold           = 1  # Adjust threshold as needed
  alarm_description   = "This metric monitors the healthy host count for the ELB"
  dimensions = {
    LoadBalancerName = aws_lb.frontend_app_lb.name
  }
}

resource "aws_cloudwatch_metric_alarm" "elb_latency" {
  alarm_name          = "elb-latency-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Latency"
  namespace           = "AWS/ELB"
  period              = 60
  statistic           = "Average"
  threshold           = 1  # Adjust threshold as needed (in seconds)
  alarm_description   = "This metric monitors the latency for the ELB"
  dimensions = {
    LoadBalancerName = aws_lb.frontend_app_lb.name
  }
}

# CloudWatch Metric for backend ELB
resource "aws_cloudwatch_metric_alarm" "backend_elb_healthy_host_count" {
  alarm_name          = "backend-elb-healthy-host-count-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ELB"
  period              = 60
  statistic           = "Average"
  threshold           = 1  # Adjust threshold as needed
  alarm_description   = "This metric monitors the healthy host count for the ELB"
  dimensions = {
    LoadBalancerName = aws_lb.backend_app_lb.name
  }
}

resource "aws_cloudwatch_metric_alarm" "backend_elb_latency" {
  alarm_name          = "backend-elb-latency-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Latency"
  namespace           = "AWS/ELB"
  period              = 60
  statistic           = "Average"
  threshold           = 1  # Adjust threshold as needed (in seconds)
  alarm_description   = "This metric monitors the latency for the ELB"
  dimensions = {
    LoadBalancerName = aws_lb.backend_app_lb.name
  }
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name = "/aws/vpc/flowlogs/${aws_vpc.frontend.id}"
}

resource "aws_flow_log" "vpc_flow_log" {
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  iam_role_arn   = aws_iam_role.flow_logs_role.arn
  vpc_id         = aws_vpc.frontend.id
  traffic_type   = "ALL"
}

resource "aws_iam_role" "flow_logs_role" {
  name = "flow-logs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "flow_logs_policy" {
  name = "flow-logs-policy"
  role = aws_iam_role.flow_logs_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}