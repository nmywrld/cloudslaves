# Create an S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "cloudslaves"  # Ensure this is unique
  acl    = "private"

  tags = {
    Name        = "My S3 Bucket"
    Environment = "Dev"
  }
}


# Create a security group for Aurora
resource "aws_security_group" "aurora_sg" {
  name        = "aurora-sg"
  description = "Security group for Aurora DB"
  vpc_id      = aws_vpc.backend.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # You can restrict this to your network range
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Aurora Cluster
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = "my-aurora-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.07.2"
  master_username         = var.db_username  # Pass DB user from Terraform variables
  master_password         = var.db_password  # Pass DB password from Terraform variables
  database_name           = var.db_name      # Name of the initial DB
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
  vpc_security_group_ids  = [aws_security_group.aurora_sg.id]  # Attach security group
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet.id

  # Enable access logging and encryption (optional)
  storage_encrypted       = true
  apply_immediately       = true
}

# Create DB instances for the Aurora Cluster
resource "aws_rds_cluster_instance" "aurora_instance" {
  count              = 2  # Create 2 instances for high availability
  identifier         = "aurora-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = "db.r5.large"  # You can adjust this based on your needs
  engine             = aws_rds_cluster.aurora_cluster.engine
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet.id
}

# Subnet group for Aurora
resource "aws_db_subnet_group" "aurora_subnet" {
  name       = "aurora-subnet-group"
  subnet_ids = aws_subnet.backend_private[*].id
}

# Outputs for DB details
output "aurora_db_host" {
  value = aws_rds_cluster.aurora_cluster.endpoint
}

output "aurora_db_user" {
  value = var.db_username
}

output "aurora_db_name" {
  value = var.db_name
}


# Variables for DB Credentials
variable "db_username" {
  description = "Database username"
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  default     = "my_secure_password123!"
}

variable "db_name" {
  description = "Initial database name"
  default     = "my_database"
}
# Create a security group for Aurora
resource "aws_security_group" "aurora_sg" {
  name        = "aurora-sg"
  description = "Security group for Aurora DB"
  vpc_id      = aws_vpc.backend.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # You can restrict this to your network range
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Aurora Cluster
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = "my-aurora-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.07.2"
  master_username         = var.db_username  # Pass DB user from Terraform variables
  master_password         = var.db_password  # Pass DB password from Terraform variables
  database_name           = var.db_name      # Name of the initial DB
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
  vpc_security_group_ids  = [aws_security_group.aurora_sg.id]  # Attach security group
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet.id

  # Enable access logging and encryption (optional)
  storage_encrypted       = true
  apply_immediately       = true
}

# Create DB instances for the Aurora Cluster
resource "aws_rds_cluster_instance" "aurora_instance" {
  count              = 2  # Create 2 instances for high availability
  identifier         = "aurora-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = "db.r5.large"  # You can adjust this based on your needs
  engine             = aws_rds_cluster.aurora_cluster.engine
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet.id
}

# Subnet group for Aurora
resource "aws_db_subnet_group" "aurora_subnet" {
  name       = "aurora-subnet-group"
  subnet_ids = aws_subnet.backend_private[*].id
}

# Outputs for DB details
output "aurora_db_host" {
  value = aws_rds_cluster.aurora_cluster.endpoint
}

output "aurora_db_user" {
  value = var.db_username
}

output "aurora_db_name" {
  value = var.db_name
}


# Variables for DB Credentials
variable "db_username" {
  description = "Database username"
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  default     = "my_secure_password123!"
}

variable "db_name" {
  description = "Initial database name"
  default     = "my_database"
}
