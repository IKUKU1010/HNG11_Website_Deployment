# HNG11 INTERNSHIP 2024 STAGE 1 PROJECT

Task: Static Website Deployment

### STEP 1: We get all our login credentials from AWS like the access key and secret key as well as the EC2-instance login key-pair. Then we setup our project environment


### STEP 2: We now write the terraform codes as follows on the terraform files ctreated for this project as shown :


```bash
terraform.tfvars


vpc_cidr_block      = "10.0.0.0/16"
subnet_cidr_block   = "10.0.10.0/24"
avail_zone          = "us-east-1a"
env_prefix          = "Ikuku-Web"
my_ip               = "192.168.35.0/24"
instance_type       = "t2.micro"

```


```bash
webServer.tf

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


```


```bash
variables.tf


variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "avail_zone" {
  description = "Availability zone for the subnet"
  type        = string
}

variable "env_prefix" {
  description = "Environment prefix for naming resources"
  type        = string
}

variable "my_ip" {
  description = "Your IP address to allow SSH access"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
}

```

### STEP 3: We now do AWS configure to connect our terminal to AWS CLI. when this is achieved we do terraform init to initialise terraform on our working directory

![Terraform init after AWS configured successfully](./Md%20images/step%203.png)




### STEP 4: Terraform validate and Terraform Apply


![Terraform validate and Terraform Apply](./Md%20images/stage%204.png)



### STEP 5: We run terraform apply to build the web infastructure


![terraform apply](./Md%20images/stage%205.png)



### STEP 6: Our webserver has been deployed with success and terraform has shown us the public ip of the webserver as an output as shown, we will now copy the ip address.

![terraform apply ran successfully](./Md%20images/stage%206.png)



### STEP 7: We login to our AWS console and confirm that our ec2-instance has been launched. The ec2 instance is an ubuntu server configured with apache web server to host my static website files. My webserver has been launched as shown below;

![ec2-webserver has been launched](./Md%20images/stage%207.png)



### STEP 8: We now open a web browser and paste the server address like this http://3.90.239.232:80 on the browser. the webserver hosts the website on port 80. Viola !!! My website is up and running smoothly as shown below;


![Static web site is live](./Md%20images/stage%208.png)





# CONGRATULATIONS !!!!!!

Name: Emmanuel Nnamdi Cosmas | HNG11 Username : @IKUKU1010-HNG11P | Email: engr.nnamdiemmanuel@gmail.com
