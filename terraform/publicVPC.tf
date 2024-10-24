resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Create public subnets in 2 availability zones
resource "aws_subnet" "public" {
  count = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)  # Split subnets
  availability_zone = element(data.aws_availability_zones.available.names, count.index)  # Spread across AZs
  map_public_ip_on_launch = true
}

# Create private subnets in 2 availability zones
resource "aws_subnet" "private" {
  count = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 2)  # Different range for private subnets
  availability_zone = element(data.aws_availability_zones.available.names, count.index)  # Spread across AZs
}

# Create Internet Gateway for public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Create a public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create a private route table (no internet access)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Data source to get available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}
