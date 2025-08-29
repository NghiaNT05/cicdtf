# create vpc
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "my-vpc"
  }
}
data "aws_availability_zones" "available" {
  state = "available"
}

# internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
  tags= {
    Name = "main-igw"
  }
}
# Allocate Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "nat-eip"
  }
}
#public subnet
resource "aws_subnet" "public" {
  count =3
  vpc_id = aws_vpc.myvpc.id
  cidr_block = cidrsubnet("10.0.0.0/16",8,count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public subnet -${count.index + 1}"
  }
}
# Private Subnets (3 AZs)
resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}
#NAT for public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public[0].id
  tags = {
    Name = "main - NAT"
  }
  depends_on = [ aws_internet_gateway.igw ]
}
#route table
resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.myvpc.id
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "internet public route table"
  }
}
resource "aws_route_table_association" "public_assoc" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.rtb.id
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "private_assoc" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Sg for bastion
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # (test)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}
# SG for Web Tier
resource "aws_security_group" "web_sg" {
    name = "web-sg"
    description = "allow http and https from internet"
    vpc_id = aws_vpc.myvpc.id
    ingress{
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }
    ingress  {
        description = "HTPPS"
        from_port = "443"
        to_port = "443"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        }
        tags = {
            Name = "web-sg"
        }  
}
#Sg for app tier
resource "aws_security_group" "app-tier-sg" {
  name = "app_sg"
  description = "allow traffic form web"
  vpc_id = aws_vpc.myvpc.id
  ingress {
    description = "from web"
    from_port = 3200
    to_port = 3200
    protocol = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
   ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]  # Chỉ cho phép từ Bastion
  }
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "app-sg"
  }
}
# SG cho DB Tier
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow traffic from app tier"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description     = "From app tier"
    from_port       = 3306       # port MySQL, thay đổi nếu DB khác
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app-tier-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}
resource "aws_db_subnet_group" "main" {
  name = "my-db-subnet-group"
  subnet_ids = [
    aws_subnet.private[0].id,
    aws_subnet.private[1].id,
    aws_subnet.private[2].id
  ]
  tags = {
    Name = "DB subnet group"
  }
}
#sg bastion
