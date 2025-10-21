# ===========================
# VPC
# ===========================
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ===========================
# Internet Gateway
# ===========================
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
  }
}

# ===========================
# Elastic IP for NAT Gateway
# ===========================
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat-eip"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.this]
}

# ===========================
# NAT Gateway (Single for cost saving)
# ===========================
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id  # Place in first public subnet

  tags = {
    Name        = "${var.project_name}-${var.environment}-natgw"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.this]
}

# ===========================
# Public Subnets
# ===========================
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.project_name}-${var.environment}-public-${var.azs[count.index]}"
    Environment              = var.environment
    Tier                     = "Public"
    "kubernetes.io/role/elb" = "1"  # For EKS ALB/NLB
  }
}

# ===========================
# Private Subnets
# ===========================
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name                              = "${var.project_name}-${var.environment}-private-${var.azs[count.index]}"
    Environment                       = var.environment
    Tier                              = "Private"
    "kubernetes.io/role/internal-elb" = "1"  # For EKS internal ALB
  }
}

# ===========================
# Route Tables (Only 2!)
# ===========================

# 1. Default Route Table as Public Route Table
resource "aws_default_route_table" "public" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Environment = var.environment
    Type        = "Public"
  }
}

# 2. Private Route Table (Only one for all private subnets)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-rt"
    Environment = var.environment
    Type        = "Private"
  }
}

# ===========================
# Route Table Associations
# ===========================

# Associate public subnets with default (public) route table
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_default_route_table.public.id
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}