provider "aws" {
  region = "ap-south-2"
  profile= "prashanth"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/20"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "my_vpc"
  }
}

resource "aws_subnet" "subnet_one" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.0.0/21"
  availability_zone = "ap-south-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet_one"
  }
}

resource "aws_subnet" "subnet_two" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.8.0/21"
  availability_zone = "ap-south-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet_two"
  }
}

resource "aws_internet_gateway" "my_gateway" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my_gateway"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_gateway.id
  }

  tags = {
    Name = "my_route_table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_one.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_security_group" "my_sg" {
  name        = "my_sg"
  description = "Allow SSH and custom port"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my_sg"
  }
}
resource "aws_security_group" "my_sg2" {
  name        = "my_sg2"
  description = "Allow SSH and custom port"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my_sg2"
  }
}


resource "aws_instance" "my_instance" {
  ami           = "ami-05b5693ff73bc6f84" # This is an example AMI ID, replace with a current t3.micro compatible AMI in ap-south-1
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.subnet_one.id
  security_groups = [aws_security_group.my_sg.id]
    user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install software-properties-common -y
              sudo add-apt-repository --yes --update ppa:ansible/ansible
              sudo apt install ansible -y
              EOF

  tags = {
    Name = "DevServer"
  }
}

resource "aws_instance" "my_instance2" {
  ami           = "ami-05b5693ff73bc6f84" # This is an example AMI ID, replace with a current t3.micro compatible AMI in ap-south-1
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.subnet_one.id
  security_groups = [aws_security_group.my_sg.id]
  user_data = <<-EOF
              #!/bin/bash
              sleep 2
              sudo apt update
              sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
              echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
              sudo apt-get update
              sudo apt-get install fontconfig openjdk-17-jre -y
              sudo apt-get install jenkins -y
              EOF
  tags = {
    Name = "Jenkins"
  }
}
resource "aws_instance" "my_instance3" {
  ami           = "ami-05b5693ff73bc6f84" # This is an example AMI ID, replace with a current t3.micro compatible AMI in ap-south-1
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.subnet_one.id
  security_groups = [aws_security_group.my_sg2.id]
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y docker.io
              EOF
  tags = {
    Name = "nexusServer"
  }
}