data "aws_availability_zones" "available" {
  state = "available"
}

############
# Create VPC
############
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = merge({
    Name = "vpc"
  }, var.tags)
}

#######################
# Create public subnets
#######################
resource "aws_subnet" "public-subnet-primary" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = merge({
    Name = "public-subnet-primary"
  }, var.tags)
}

resource "aws_subnet" "public-subnet-secondary" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = merge({
    Name = "public-subnet-secondary"
  }, var.tags)
}

########################
# Create private subnets
########################
resource "aws_subnet" "private-subnet-primary" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = merge({
    Name = "private-subnet-primary"
  }, var.tags)
}

resource "aws_subnet" "private-subnet-secondary" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = merge({
    Name = "private-subnet-secondary"
  }, var.tags)
}

#########################
# Create internet gateway
#########################
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({
    Name = "internet-gateway"
  }, var.tags)
}

###########################
# Create public route table
###########################
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  tags = merge({
    Name = "public-rt"
  }, var.tags)
}

//resource "aws_route_table" "main-rt" {
//  vpc_id = aws_vpc.vpc.id
//  tags = merge({
//    Name = "main-rt"
//  }, var.tags)
//}

#################################################
# Associate public route table and public subnets
#################################################
resource "aws_route_table_association" "rt-public-subnet-primary" {
  subnet_id      = aws_subnet.public-subnet-primary.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "rt-public-subnet-secondary" {
  subnet_id      = aws_subnet.public-subnet-secondary.id
  route_table_id = aws_route_table.public-rt.id
}

############
# Create EIP
############
resource "aws_eip" "eip" {
  vpc = true

  tags = merge({
    Name = "eip"
  }, var.tags)
}

####################
# Create NAT Gateway
####################
//resource "aws_nat_gateway" "nat-gateway" {
//  subnet_id     = aws_subnet.public-subnet-primary.id
//  allocation_id = aws_eip.eip.id
//
//  tags = merge({
//    Name = "nat-gateway"
//  }, var.tags)
//
//  depends_on = [aws_internet_gateway.internet-gateway]
//}

#############################
# Modify the main route table
#############################
//resource "aws_route" "nat-route" {
//  route_table_id         = aws_vpc.vpc.main_route_table_id
//  destination_cidr_block = "0.0.0.0/0"
//  nat_gateway_id         = aws_nat_gateway.nat-gateway.id
//}

################################################
# Associate main route table and private subnets
################################################
resource "aws_route_table_association" "rt-private-subnet-primary" {
  subnet_id      = aws_subnet.private-subnet-primary.id
  route_table_id = aws_vpc.vpc.main_route_table_id
}

resource "aws_route_table_association" "rt-private-subnet-secondary" {
  subnet_id      = aws_subnet.private-subnet-secondary.id
  route_table_id = aws_vpc.vpc.main_route_table_id
}