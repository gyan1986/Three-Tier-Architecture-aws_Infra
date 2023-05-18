# Creating a new VPC
resource "aws_vpc" "vpc01" {
  cidr_block = var.vpc_cidr
  tags = {
    name = "vpc01"
  }
}

#Public subnet and required resources
#################################################

resource "aws_internet_gateway" "intgw01" {
  vpc_id = aws_vpc.vpc01.id
  tags = {
    name = "intgw01"
  }
}
resource "aws_subnet" "public01" {
  vpc_id                  = aws_vpc.vpc01.id
  cidr_block              = var.public_subnet1
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  depends_on = [
    aws_internet_gateway.intgw01
  ]
  tags = {
    Name = "Public_Subnet01"
  }
}

resource "aws_subnet" "public02" {
  vpc_id                  = aws_vpc.vpc01.id
  cidr_block              = var.public_subnet2
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
  depends_on = [
    aws_internet_gateway.intgw01
  ]
  tags = {
    Name = "Public_Subnet02"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc01.id
  tags = {
    Name = "public_rtb"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.intgw01.id
}

resource "aws_route_table_association" "public01" {
  subnet_id      = aws_subnet.public01.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public02" {
  subnet_id      = aws_subnet.public02.id
  route_table_id = aws_route_table.public.id
}


#################################################

#Private subnet and required resources

resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = "nat_eip"
  }
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public01.id
  tags = {
    Name = "natgw"
  }
}

resource "aws_subnet" "private01" {
  vpc_id                  = aws_vpc.vpc01.id
  cidr_block              = var.private_subnet1
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false
  depends_on = [
    aws_nat_gateway.natgw
  ]
  tags = {
    Name = "Private_Subnet01"
  }
}

resource "aws_subnet" "private02" {
  vpc_id                  = aws_vpc.vpc01.id
  cidr_block              = var.private_subnet2
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = false
  depends_on = [
    aws_nat_gateway.natgw
  ]
  tags = {
    Name = "Private_Subnet02"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc01.id
  tags = {
    Name = "private_rtb"
  }
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw.id
}

resource "aws_route_table_association" "private01" {
  subnet_id      = aws_subnet.private01.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private02" {
  subnet_id      = aws_subnet.private02.id
  route_table_id = aws_route_table.private.id
}