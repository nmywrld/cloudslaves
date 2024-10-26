resource "aws_vpc" "backend" {
  cidr_block = "10.11.0.0/20"
}

# Create public subnets in 2 availability zones
resource "aws_subnet" "backend_public" {
  count = 2
  vpc_id            = aws_vpc.backend.id
  cidr_block        = cidrsubnet(aws_vpc.backend.cidr_block, 8, count.index)  # Split subnets
  availability_zone = element(data.aws_availability_zones.available.names, count.index)  # Spread across AZs
  map_public_ip_on_launch = true
}

# Create private subnets in 2 availability zones
resource "aws_subnet" "backend_private" {
  count = 2
  vpc_id            = aws_vpc.backend.id
  cidr_block        = cidrsubnet(aws_vpc.backend.cidr_block, 8, count.index + 2)  # Different range for private subnets
  availability_zone = element(data.aws_availability_zones.available.names, count.index)  # Spread across AZs
}

# Create Internet Gateway for public subnets
resource "aws_internet_gateway" "backend_igw" {
  vpc_id = aws_vpc.backend.id
}

# Create a public route table
resource "aws_route_table" "backend_public" {
  vpc_id = aws_vpc.backend.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.backend_igw.id
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "backend_public" {
  count          = 2
  subnet_id      = aws_subnet.backend_public[count.index].id
  route_table_id = aws_route_table.backend_public.id
}

# Create a private route table (no internet access)
resource "aws_route_table" "backend_private" {
  vpc_id = aws_vpc.backend.id
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "backend_private" {
  count          = 2
  subnet_id      = aws_subnet.backend_private[count.index].id
  route_table_id = aws_route_table.backend_private.id
}