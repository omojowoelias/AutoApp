
# Create Vpc
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "My_VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "My_IGW"
  }
}
# Create Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Public_Route_Table"
  }
}
# Create Route
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
  depends_on             = [aws_internet_gateway.my_igw]
}

# Associate Public Subnets with Route Table
resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_assoc" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_3_assoc" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Private_Route_Table"
  }
}
# Create Route for Private Subnets
# resource "aws_route" "private_route" {
#   route_table_id         = aws_route_table.private_route_table.id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.my_igw.id
#   depends_on             = [aws_internet_gateway.my_igw]
# }
# Create Route for NAT Gateway

resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id  # Route through NAT instead of IGW
}


  
# Associate private subnets with private route table
resource "aws_route_table_association" "private_subnet_1_assoc" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_assoc" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}
resource "aws_route_table_association" "private_subnet_3_assoc" {
  subnet_id      = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.private_route_table.id
}
# Create Security Group for Public Subnets          
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "Public_SG"
  tags = {
    Name = "Public_SG"
  }
}
# Create Security Group for Private Subnets
resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "Private_SG"
  tags = {
    Name = "Private_SG"
  }
}

# Create Subnet - 1
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = var.ax
  tags = {
    Name = "Public_Subnet_1"
  }
}


# Create Subnet - 2
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = var.ax
  tags = {
    Name = "Public_Subnet_2"
  }
}

# Create Subnet - 3
resource "aws_subnet" "public_subnet_3" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = var.ax
  tags = {
    Name = "Public_Subnet_3"
  }
}


# Create Private Subnet - 1
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = var.az
  tags = {
    Name = "private_subnet_1"
  }
}

# Create Private Subnet - 2
resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = var.az
  tags = {
    Name = "private_subnet_2"
  }
}

# Create Private Subnet - 3
resource "aws_subnet" "private_subnet_3" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = var.az
  tags = {
    Name = "private_subnet_3"
  }
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "NAT_EIP"
  }
}
# Create NAT Gateway for Public Subnets
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_1.id
  depends_on = [aws_internet_gateway.my_igw] # Ensure the IGW is created before the NAT Gateway
  tags = {
    Name = "NAT_Gateway"
  }
}