# # Create the IAM role for the Lambda function to assume
# resource "aws_iam_role" "lambda_execution_role" {
#   name               = "lambda_execution_role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action    = "sts:AssumeRole"  # Allow Lambda to assume this role
#         Principal = {
#           Service = "lambda.amazonaws.com"  # Specify the Lambda service
#         }
#         Effect    = "Allow"  # Allow this action
#         Sid       = ""
#       },
#     ]
#   })
# }

# # Create a policy for accessing S3 and Aurora
# resource "aws_iam_policy" "lambda_policy" {
#   name        = "lambda_policy"
#   description = "Policy for Lambda to access S3 and Aurora"
  
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject",
#           "s3:ListBucket"
#         ]
#         Resource = [
#           "arn:aws:s3:::your-s3-bucket-name",           # Specify your S3 bucket
#           "arn:aws:s3:::your-s3-bucket-name/*"          # Allow actions on objects within the bucket
#         ]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "rds:DescribeDBInstances",
#           "rds:Connect"  # Required for connecting to Aurora DB
#         ]
#         Resource = "arn:aws:rds:your-region:your-account-id:db:your-db-instance-name"  # Specify your Aurora DB instance
#       }
#     ]
#   })
# }

# # Attach the policy to the IAM role
# resource "aws_iam_role_policy_attachment" "attach_lambda_policy" {
#   policy_arn = aws_iam_policy.lambda_policy.arn
#   role       = aws_iam_role.lambda_execution_role.name
# }

# # Attach the basic execution policy to the Lambda role for logging
# resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
#   name       = "lambda_policy_attachment"
#   roles      = [aws_iam_role.lambda_execution_role.name]  # Attach to the Lambda execution role
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"  # Basic execution policy for logging
# }

# # Define the Lambda function resource
# resource "aws_lambda_function" "backend_lambda" {
#   function_name = "backend-lambda-function"  # Name of the Lambda function
#   handler       = "lambda_function.lambda_handler"  # The method in your code that Lambda calls
#   runtime       = "python3.9"  # Specify the runtime environment

#   filename      = "path/to/your/lambda.zip"  # Path to the zipped Lambda code
#   role          = aws_iam_role.lambda_execution_role.arn  # IAM role to assume

#   # Optional: Define environment variables
#   environment {
#     variables = {
#       S3_BUCKET_NAME = aws_s3_bucket.my_bucket.bucket
#       DB_ARN         = aws_rds_cluster.aurora_cluster.arn
#       DB_USER        = var.db_username
#       DB_PASSWORD    = var.db_password
#     }
#   }

#   # Optional: Specify VPC configuration if Lambda needs to access resources in a VPC
#   vpc_config {
#     subnet_ids         = aws_subnet.aurora_subnet[*].id  # Use the Aurora subnets
#     security_group_ids = [aws_security_group.aurora_sg.id]  # Use the Aurora security group
#   }
# }

# # Define the target group for the Lambda function
# resource "aws_lb_target_group" "backend_lambda_tg" {
#   name        = "lambda-tg"  # Name of the target group
#   target_type = "lambda"  # Specify that this target group will use Lambda functions
#   vpc_id      = aws_vpc.backend.id  # VPC ID for the target group
# }



# Create the IAM role for the Lambda function to assume
resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"  # Allow Lambda to assume this role
        Principal = {
          Service = "lambda.amazonaws.com"  # Specify the Lambda service
        }
        Effect    = "Allow"  # Allow this action
        Sid       = ""
      },
    ]
  })
}

# Attach the basic execution policy to the Lambda role for logging
resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "lambda_policy_attachment"
  roles      = [aws_iam_role.lambda_execution_role.name]  # Attach to the Lambda execution role
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"  # Basic execution policy for logging
}
# Attach the VPC access policy to the Lambda role
resource "aws_iam_policy_attachment" "lambda_vpc_policy_attachment" {
  name       = "lambda_vpc_policy_attachment"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Define the Lambda function resource
resource "aws_lambda_function" "backend_lambda" {
  function_name = "backend-lambda-function"  # Name of the Lambda function
  handler       = "lambda_function.lambda_handler"  # The method in your code that Lambda calls
  runtime       = "python3.9"  # Specify the runtime environment

  filename      = "../BackEnd.zip"  # Path to the zipped Lambda code
  role          = aws_iam_role.lambda_execution_role.arn  # IAM role to assume

  # # Optional: Define environment variables if needed
  # environment {
  #   variables = {
  #     # Add any necessary environment variables
  #   }
  # }


  # Optional: Specify VPC configuration if Lambda needs to access resources in a VPC
  vpc_config {
    subnet_ids         = aws_subnet.backend_public[*].id  # Use relevant subnets
    security_group_ids = [aws_security_group.backend_alb_sg.id]  # Use the relevant security group
  }
}

output "lambda_function_name" {
  value = aws_lambda_function.backend_lambda.function_name
}

# # Define the target group for the Lambda function
# resource "aws_lb_target_group" "another_lambda_tg" {
#   name        = "lambda-tg"  # Name of the target group
#   target_type = "lambda"  # Specify that this target group will use Lambda functions
#   vpc_id      = aws_vpc.backend.id  # VPC ID for the target group
# }
