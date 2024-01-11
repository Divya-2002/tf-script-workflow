provider "aws" {
  region = "us-west-2"  
}

/////////////key-pair creation/////////////////
resource "tls_private_key" "mykey" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}


resource "aws_key_pair" "key1" {
  key_name   = "key3"
  public_key = tls_private_key.mykey.public_key_openssh

  provisioner "local-exec" { # Create "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.mykey.private_key_pem}' > ./key.pem"
  }
}

resource "local_file" "key_pair_save" {
  content  = tls_private_key.mykey.private_key_pem
  filename = "key.pem"

}

//////////////security-group/////////////

resource "aws_security_group" "my_security_group" {
  name        = "my_security_group"
  description = "Allow SSH and HTTP inbound traffic"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my_instance" {
  ami             = "ami-0944e91aed79c721c"  
  instance_type   = var.instance_type 
  key_name        = aws_key_pair.key1.key_name
  security_groups = [aws_security_group.my_security_group.name]

  tags = {
    Name = "MyEC2Instance"
  }
}
