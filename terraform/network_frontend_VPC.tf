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

# Step 1: Create an Elastic IP for the NAT Gateway
resource "aws_eip" "frontend_nat" {
  domain = "vpc"
}

# Step 2: Create the NAT Gateway in one of the public subnets
resource "aws_nat_gateway" "frontend_nat" {
  allocation_id = aws_eip.frontend_nat.id
  subnet_id     = aws_subnet.frontend_public[0].id  # Place NAT Gateway in the first public subnet
}

# Step 3: Update the private route table to route traffic through the NAT Gateway
resource "aws_route" "frontend_private_nat" {
  route_table_id         = aws_route_table.frontend_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.frontend_nat.id
}
