provider "aws" {
  region = "us-east-1"
}

# CREATE CUSTOM VPC
resource "aws_vpc" "Hng11Projkt1-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

# CREATE CUSTOM SUBNET
resource "aws_subnet" "Hng11Projkt1-subnet-1" {
  vpc_id = aws_vpc.Hng11Projkt1-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}

# CREATE INTERNET GATEWAY
resource "aws_internet_gateway" "Hng11Projkt1-igw" {
  vpc_id = aws_vpc.Hng11Projkt1-vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

# CREATE ROUTE TABLE
resource "aws_route_table" "Hng11Projkt1-route-table" {
  vpc_id = aws_vpc.Hng11Projkt1-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Hng11Projkt1-igw.id
  }

  tags = {
    Name = "${var.env_prefix}-main-rtb"
  }
}

# ASSOCIATE ROUTE TABLE WITH SUBNET
resource "aws_route_table_association" "aws-rtb-subnet" {
  subnet_id      = aws_subnet.Hng11Projkt1-subnet-1.id
  route_table_id = aws_route_table.Hng11Projkt1-route-table.id
}

# CREATE SECURITY GROUP (FIREWALL)
resource "aws_security_group" "Hng11Projkt1-sg" {
  vpc_id = aws_vpc.Hng11Projkt1-vpc.id
  name   = "Hng11Projkt1-sg"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
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
    Name = "${var.env_prefix}-sg"
  }
}


 # PROVISION EC2 INSTANCE

data "aws_ami" "latest-ubuntu-noble-24-04-image" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20240423"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}


  output "aws_ami_id" {
    value = data.aws_ami.latest-ubuntu-noble-24-04-image.id
  }

  output "ec2_public_ip" {
    value = aws_instance.Hng11Projkt1-server.public_ip
  }


resource "aws_instance" "Hng11Projkt1-server" {
  ami = data.aws_ami.latest-ubuntu-noble-24-04-image.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.Hng11Projkt1-subnet-1.id
  vpc_security_group_ids = [aws_security_group.Hng11Projkt1-sg.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = "Hanny_Key"


    user_data = <<EOF
#cloud-config
package_update: true
packages:
  - apache2
  - git

runcmd:
  - [ systemctl, start, apache2 ]
  - [ systemctl, enable, apache2 ]
  - [ git, clone, https://github.com/IKUKU1010/Emmanuelwebpage.git, /var/www/Emmanuelwebpage ]
  - [ chmod, -R, 755, /var/www/Emmanuelwebpage ]
  - [ cp, /etc/apache2/sites-available/000-default.conf, /etc/apache2/sites-available/Emmanuelwebpage.conf ]
  - sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/Emmanuelwebpage|' /etc/apache2/sites-available/Emmanuelwebpage.conf
  - [ a2ensite, Emmanuelwebpage.conf ]
  - [ a2dissite, 000-default.conf ]
  - [ systemctl, reload, apache2 ]

EOF

  tags = {
    Name = "${var.env_prefix}-server"
  }
}
