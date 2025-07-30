# VPC creation
resource "aws_vpc" "aspnetapp_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

# Internet Gateway creation
resource "aws_internet_gateway" "aspnetapp_igw" {
  vpc_id = aws_vpc.aspnetapp_vpc.id

  tags = {
    Name = var.vpc_name
  }
}

# Create the public subnet A - Availability Zone 1
resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.aspnetapp_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet_a_name
  }
}

# Create the public subnet B - Availability Zone 2
resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.aspnetapp_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}c"
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet_c_name
  }
}

# Create the route table for the public subnets
resource "aws_route_table" "aspnetapp_route_table" {
  vpc_id = aws_vpc.aspnetapp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aspnetapp_igw.id
  }

  tags = {
    Name = "aspnetapp-route-table"
  }
}

# Associate the route table with the public subnets
resource "aws_route_table_association" "subnet_a_association" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.aspnetapp_route_table.id
}

resource "aws_route_table_association" "subnet_b_association" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.aspnetapp_route_table.id
}

# Create a Security Group for the application
resource "aws_security_group" "aspnetapp_sg_alb" {
  name   = var.alb_sg_name
  vpc_id = aws_vpc.aspnetapp_vpc.id

  egress {
    description = "Allow HTTP outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow inbound HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.alb_sg_name
  }
}
