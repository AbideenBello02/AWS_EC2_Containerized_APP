terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.90.0"
    }

    null_resource = {
      source  = "hashicorp/null"
      version = "~> 3.2.0"
    }

  }
}

provider "aws" {
  region = "us-east-1"
}


# create a subnet
resource "aws_subnet" "node_app_subnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet_cidr_block[0]
  availability_zone       = var.az
  map_public_ip_on_launch = true

  tags = {
    Name = "NodeApp_Subnet"
  }
}

# create a security group
resource "aws_security_group" "node_app_sg" {
  name        = "node_app_sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# ec2 key pair
resource "aws_key_pair" "node_app_key" {
  key_name   = "node_app_key"
  public_key = file("./KEY/node_app_key.pub")
}

#EC2_instance
resource "aws_instance" "node_app_instance" {
  ami                    = var.ami
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.node_app_key.key_name
  vpc_security_group_ids = [aws_security_group.node_app_sg.id]
  subnet_id              = aws_subnet.node_app_subnet.id

  tags = {
    Name = "NodeApp_Instance"
  }

}

resource "null_resource" "docker_install" {
  depends_on = [aws_instance.node_app_instance]

  provisioner "remote-exec" {
    inline = [
        "sudo yum update -y",
        "sudo amazon-linux-extras install docker -y",
        "sudo yum install docker -y",
        "sudo service docker start",
    ]

    connection {
      type        = "ssh"
      host        = aws_instance.node_app_instance.public_ip
      user        = "ec2-user"
      private_key = file("./KEY/node_app_key")
    }
  }
  
}

