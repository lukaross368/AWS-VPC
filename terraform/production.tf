module "networking" {
source = "./modules/networking"
}

resource "aws_instance" "jump_server" {
  ami = "ami-0b594cc165f9cddaa"
  instance_type = "t2.micro"
  key_name = "mykeypair"

  subnet_id = module.networking.public_subnet_ids[0]
  vpc_security_group_ids = [ module.networking.jump_server_sg_id ]
  associate_public_ip_address = true

  user_data = <<-EOF
  #!/bin/bash

  sudo yum update -y 
  yes | sudo yum install docker
  sudo service docker start
  sudo usermod -a -G docker ec2-user
  sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  EOF

  tags = {
    "Name" : "Terraform-jump-server"
  }
}

