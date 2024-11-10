
# Step 1: Create the IAM role for the Lambda function to assume
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"  # Lambda can assume this role
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}



# Step 2: Attach the basic execution policy to the Lambda role for logging
resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "lambda_policy_attachment"
  roles      = [aws_iam_role.lambda_execution_role.name]  # Attach to the Lambda execution role
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"  # Basic execution policy for logging
}

# Step 3: Attach the VPC access policy to the Lambda role
resource "aws_iam_policy_attachment" "lambda_vpc_policy_attachment" {
  name       = "lambda_vpc_policy_attachment"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}



# Step 4: Create the Lambda function
resource "aws_lambda_function" "another_lambda_tg" {
  function_name = "backend-lambda-function"  # Lambda function name
  handler       = "lambda_function.lambda_handler"  # The method in your code that Lambda calls
  runtime       = "python3.9"  # Specify runtime
  timeout       = 10  # Timeout in seconds
  filename      = "BackEnd.zip"  # Path to the zipped Lambda code
  role           = aws_iam_role.lambda_execution_role.arn  # IAM role to assume
  source_code_hash = filebase64sha256("BackEnd.zip")

  # VPC configuration for Lambda function
  vpc_config {
    subnet_ids         = aws_subnet.backend_public[*].id  # Use relevant subnets
    security_group_ids = [aws_security_group.backend_alb_sg.id]  # Use the relevant security group
  }
}

# # Step 5: Create a target group for the Lambda function (necessary for ALB)
# resource "aws_lb_target_group" "backend_lambda_tg" {
#   name     = "backend-lambda-tg"
#   target_type = "lambda"  # Ensure the target type is set to 'lambda'
#   port     = 80
#   protocol = "HTTP"
# }



# resource "aws_lb_target_group_attachment" "test" {
#   target_group_arn = aws_lb_target_group.backend_lambda_tg.arn
#   target_id        = aws_lambda_function.another_lambda_tg.arn  # Reference Lambda function ARN

# }
# Step 1: Create Lambda Permission to allow ALB to invoke Lambda
# resource "aws_lambda_permission" "allow_alb" {
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.another_lambda_tg.function_name
#   principal     = "elasticloadbalancing.amazonaws.com"
#   source_arn    = aws_lb.backend_app_lb.arn
# }
resource "aws_lambda_permission" "allow_alb" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.another_lambda_tg.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.backend_lambda_tg.arn  # Correct the source_arn to target group ARN
}



# Step 2: Attach the Lambda to the Target Group
resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.backend_lambda_tg.arn
  target_id        = aws_lambda_function.another_lambda_tg.arn  # Correct reference
  depends_on       = [aws_lambda_permission.allow_alb]
}




# Step 7: ALB listener for forwarding requests to the Lambda function
resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.backend_app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_lambda_tg.arn  # Forward to the Lambda target group
  }
  depends_on = [aws_lb.backend_app_lb, aws_lb_target_group.backend_lambda_tg]
}

# Step 8: IAM policy to allow Lambda to be invoked by the ALB (make sure it references the Lambda ARN)
resource "aws_iam_role_policy" "lambda_alb_invoke_policy" {
  name   = "lambda-alb-invoke-policy"
  role   = aws_iam_role.lambda_execution_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "lambda:InvokeFunction"
        Effect   = "Allow"
        Resource = aws_lambda_function.another_lambda_tg.arn  # This should reference the Lambda function ARN
      }
    ]
  })
}
