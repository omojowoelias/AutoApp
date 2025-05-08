
# Create Vpc
resource "aws_vpc" "my_vpc" {
  cidr_block         = "10.0.0.0/16"
  instance_tenancy   = "default"
  enable_dns_support = "true"
  #enable_dns_hostnames = "true"
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
  nat_gateway_id         = aws_nat_gateway.nat.id # Route through NAT instead of IGW
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
  depends_on    = [aws_internet_gateway.my_igw] # Ensure the IGW is created before the NAT Gateway
  tags = {
    Name = "NAT_Gateway"
  }
}
# Create securiry group for the application load balancer
# terraform aws create security group
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "ALB_SG"
  description = "Allow HTTP and HTTPS traffic"
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  # Add tags to the security group
  tags = {
    Name = "ALB_SG"
  }
}
# Create Application Load Balancer  
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id, aws_subnet.public_subnet_3.id]
  enable_deletion_protection = false
  enable_http2 = true
  idle_timeout {
    timeout_seconds = 60
  }
  tags = {
    Name = "My_ALB"
  }
}
# # Create Target Group for ALB
resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold  = 2
    unhealthy_threshold = 2
    matcher {
      http_code = "200,302"
    }
  }
  tags = {
    Name = "My_Target_Group"
  }
}
# # Create Listener for ALB
# resource "aws_lb_listener" "my_listener" {
#   load_balancer_arn = aws_lb.my_alb.arn
#   port              = 80
#   protocol          = "HTTP"
#   default_action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.my_target_group.arn
#   }
#   tags = {
#     Name = "My_Listener"
#   }
# }
# Create security group for bastion host
resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "Bastion_SG"
  description = "Allow SSH traffic from specific IP"
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # Replace with your IP address
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  # Add tags to the security group
  tags = {
    Name = "Bastion_SG"
  }
}
# Create Bastion Host
resource "aws_instance" "bastion" {
  ami           = "ami-0c55b159cbfafe1f0" # Replace with the latest Amazon Linux 2 AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_1.id
  key_name      = "your-key-pair-name" # Replace with your key pair name
  security_groups = [aws_security_group.bastion_sg.name]
  tags = {
    Name = "Bastion_Host"
  }
}
# Create Security Group for the webserver
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "Web_SG"
  description = "Allow HTTP and HTTPS traffic from ALB"
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.alb_sg.id]
    }
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        security_groups = [aws_security_group.alb_sg.id]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    # Add tags to the security group
    tags = {
      Name = "Web_SG"
    }
}
# Create EC2 Instance for Web Server
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0" # Replace with the latest Amazon Linux 2 AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet_1.id
  key_name      = "your-key-pair-name" # Replace with your key pair name
  security_groups = [aws_security_group.web_sg.name]
  tags = {
    Name = "Web_Server"
  }
}
# # Create RDS Instance
# resource "aws_db_instance" "my_rds" {
#   identifier         = "my-rds-instance"
#   engine             = "mysql"
#   engine_version     = "8.0"
#   instance_class     = "db.t2.micro"
#   allocated_storage   = 20
#   storage_type       = "gp2"
#   db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name
#   vpc_security_group_ids = [aws_security_group.private_sg.id]
#   username           = "admin"
#   password           = "yourpassword" # Replace with a secure password
#   skip_final_snapshot = true
#   tags = {
#     Name = "My_RDS_Instance"
#   }
# }
# Create Security Group for RDS
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "RDS_SG"
  description = "Allow MySQL traffic from Web Server"
    ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        security_groups = [aws_security_group.web_sg.id]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    # Add tags to the security group
    tags = {
      Name = "RDS_SG"
    }
}