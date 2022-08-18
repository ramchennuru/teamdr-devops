resource "aws_vpc" "teamdr-vpc" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "teamdr-vpc"
  }
}

resource "aws_subnet" "teamdr-public" {
  vpc_id     = aws_vpc.teamdr-vpc.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "teamdr-public"
  }
}

resource "aws_subnet" "teamdr-public2" {
  vpc_id     = aws_vpc.teamdr-vpc.id
  cidr_block = "10.10.3.0/24"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "teamdr-public2"
  }
}

resource "aws_subnet" "teamdr-private" {
  vpc_id     = aws_vpc.teamdr-vpc.id
  cidr_block = "10.10.2.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "teamdr-private"
  }
}

resource "aws_subnet" "teamdr-private2" {
  vpc_id     = aws_vpc.teamdr-vpc.id
  cidr_block = "10.10.4.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "teamdr-private2"
  }
}

resource "aws_internet_gateway" "teamdr-igw" {

    vpc_id = aws_vpc.teamdr-vpc.id

    tags = {
      Name = "teamdr-igw"
    }

}

resource "aws_eip" "teamdr-eip-natgatway" {
  vpc = true
  depends_on = [aws_internet_gateway.teamdr-igw]
  tags = {
    Name = "teamdr-eip-natgatway"
  }
}

resource "aws_nat_gateway" "teamdr-natgatway" {
  allocation_id = aws_eip.teamdr-eip-natgatway.id
  subnet_id     = aws_subnet.teamdr-public.id

  tags = {
    Name = "teamdr-natgatway"
  }
}

resource "aws_route_table" "teamdr-public-rt" {
  vpc_id = aws_vpc.teamdr-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.teamdr-igw.id
  }

  tags = {
    Name = "teamdr-public-rt"
  }
}

resource "aws_route_table_association" "teamdr-pub-rt-asso" {
  subnet_id      = aws_subnet.teamdr-public.id
  route_table_id = aws_route_table.teamdr-public-rt.id
}

resource "aws_route_table_association" "teamdr-pub-rt-asso2" {
  subnet_id      = aws_subnet.teamdr-public2.id
  route_table_id = aws_route_table.teamdr-public-rt.id
}

resource "aws_route_table" "teamdr-private-rt" {
  vpc_id = aws_vpc.teamdr-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.teamdr-natgatway.id
  }

  tags = {
    Name = "teamdr-private-rt"
  }
}

resource "aws_route_table_association" "teamdr-pri-rt-asso" {
  subnet_id      = aws_subnet.teamdr-private.id
  route_table_id = aws_route_table.teamdr-private-rt.id
}

resource "aws_route_table_association" "teamdr-pri-rt-asso2" {
  subnet_id      = aws_subnet.teamdr-private2.id
  route_table_id = aws_route_table.teamdr-private-rt.id
}

resource "aws_security_group" "teamdr-sg" {
  name   = "teamdr-sg"
  vpc_id = aws_vpc.teamdr-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "teamdr-sg"
  }
}


