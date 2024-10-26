resource "aws_vpc" "frontend" {
  cidr_block = "10.10.0.0/20"
}

# Create public subnets in 2 availability zones
resource "aws_subnet" "frontend_public" {
  count = 2
  vpc_id            = aws_vpc.frontend.id
  cidr_block        = cidrsubnet(aws_vpc.frontend.cidr_block, 8, count.index)  # Split subnets
  availability_zone = element(data.aws_availability_zones.available.names, count.index)  # Spread across AZs
  map_public_ip_on_launch = true
}

# Create private subnets in 2 availability zones
resource "aws_subnet" "frontend_private" {
  count = 2
  vpc_id            = aws_vpc.frontend.id
  cidr_block        = cidrsubnet(aws_vpc.frontend.cidr_block, 8, count.index + 2)  # Different range for private subnets
  availability_zone = element(data.aws_availability_zones.available.names, count.index)  # Spread across AZs
}

# Create Internet Gateway for public subnets
resource "aws_internet_gateway" "frontend_igw" {
  vpc_id = aws_vpc.frontend.id
}

# Create a public route table
resource "aws_route_table" "frontend_public" {
  vpc_id = aws_vpc.frontend.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.frontend_igw.id
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "frontend_public" {
  count          = 2
  subnet_id      = aws_subnet.frontend_public[count.index].id
  route_table_id = aws_route_table.frontend_public.id
}

# Create a private route table (no internet access)
resource "aws_route_table" "frontend_private" {
  vpc_id = aws_vpc.frontend.id
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "frontend_private" {
  count          = 2
  subnet_id      = aws_subnet.frontend_private[count.index].id
  route_table_id = aws_route_table.frontend_private.id
}
