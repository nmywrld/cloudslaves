# # Create a VPC for Aurora (or use your existing VPC)
# resource "aws_vpc" "aurora_vpc" {
#   cidr_block = "10.0.0.0/16"  # Define a CIDR block for your VPC
# }

# # Create subnets in the VPC
# resource "aws_subnet" "aurora_subnet" {
#   count                   = 2  # Create two subnets across two availability zones
#   vpc_id                  = aws_vpc.aurora_vpc.id
#   cidr_block              = "10.0.${count.index}.0/24"
#   availability_zone       = element(data.aws_availability_zones.available.names, count.index)
#   map_public_ip_on_launch = false  # Aurora subnets are typically private
# }

# # Create security group for Aurora DB
# resource "aws_security_group" "aurora_sg" {
#   name        = "aurora-sg"
#   description = "Allow MySQL/Aurora access"
#   vpc_id      = aws_vpc.aurora_vpc.id

#   # Allow MySQL/Aurora traffic (port 3306)
#   ingress {
#     from_port   = 3306
#     to_port     = 3306
#     protocol    = "tcp"
#     cidr_blocks = ["10.0.0.0/16"]  # Allow from VPC CIDR range
#   }

#   # Allow all outbound traffic
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# # Create Aurora (MySQL-compatible) DB cluster
# resource "aws_rds_cluster" "aurora_cluster" {
#   cluster_identifier      = "aurora-cluster"
#   engine                  = "aurora-mysql"
#   master_username         = "your-db-user"
#   master_password         = "your-db-password"
#   backup_retention_period = 5
#   preferred_backup_window = "07:00-09:00"
#   skip_final_snapshot     = true
#   vpc_security_group_ids  = [aws_security_group.aurora_sg.id]
#   db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
# }

# # Create Aurora (MySQL-compatible) DB instance in the cluster
# resource "aws_rds_cluster_instance" "aurora_instance" {
#   count               = 2  # Deploy two instances in the cluster
#   identifier          = "aurora-instance-${count.index}"
#   cluster_identifier  = aws_rds_cluster.aurora_cluster.id
#   instance_class      = "db.r5.large"  # Adjust instance class as per your needs
#   engine              = aws_rds_cluster.aurora_cluster.engine
#   publicly_accessible = false
#   db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name
# }

# # Create DB subnet group for Aurora
# resource "aws_db_subnet_group" "aurora_subnet_group" {
#   name       = "aurora-subnet-group"
#   subnet_ids = aws_subnet.aurora_subnet[*].id

#   tags = {
#     Name = "aurora-subnet-group"
#   }
# }
