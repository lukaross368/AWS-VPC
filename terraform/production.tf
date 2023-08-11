module "networking" {
source = "./modules/networking"
}

/* Jump Server */
resource "aws_instance" "jump_server" {
  ami = "ami-0b594cc165f9cddaa"
  instance_type = "t2.micro"
  key_name = "mykeypair"

  subnet_id = module.networking.public_subnet_ids[0]
  vpc_security_group_ids = [ module.networking.jump_server_sg_id ]
  associate_public_ip_address = true

  tags = {
    "Name" : "Terraform-jump-server"
  }
}

/* Web Servers */
resource "aws_instance" "web-app" {
  ami = "ami-0b594cc165f9cddaa"
  instance_type = "t2.micro"
  key_name = "mykeypair"

  count = "${length(module.networking.private_subnet_ids)}"
  subnet_id = "${element(module.networking.private_subnet_ids, count.index)}"

  vpc_security_group_ids = [ module.networking.web_app_sg_id ]
  associate_public_ip_address = false

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
    Name = "Terraform-web-app-${count.index}"
  }
}

/* Application Load Balancer (ALB) */
resource "aws_lb" "application" {
  name = "terraform-alb"
  internal = false
  load_balancer_type = "application"
  subnets = module.networking.public_subnet_ids
  security_groups = [ module.networking.alb_sg_id ]
}

/* Target Group for ALB */
resource "aws_lb_target_group" "application" {
  name     = "terraform-alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.networking.vpc_id
}

/* Listeners for Application Load Balancer */
resource "aws_lb_listener" "application" {
  load_balancer_arn = aws_lb.application.arn
  depends_on = [ aws_lb_target_group.application ]
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.application.arn
  }
}

/* Attachment for ALB Target Group */
resource "aws_lb_target_group_attachment" "ec2_to_alb_target" {
  count = "${length(module.networking.private_subnet_ids)}"
  depends_on = [ aws_instance.web-app, aws_lb.application ]
  target_group_arn = aws_lb_target_group.application
  target_id = "${element(aws_instance.web-app.id, count.index)}" 
  port = 80
}


/* Network Load Balancer (NLB) */
resource "aws_lb" "network" {
  name = "terraform-nlb"
  internal = false
  load_balancer_type = "network"
  subnets = [ module.networking.public_subnet_ids[1] ]
  enable_cross_zone_load_balancing = true
}

/* Elastic IP Attachment for NLB */
resource "aws_lb_attachment" "network_eip_attachment" {
  depends_on = [ aws_lb.network ]
  lb_arn = aws_lb.network.arn
  elastic_ip = module.networking.network_lb_elastic_ip
}

/* Listeners for Network Load Balancer */
resource "aws_lb_listener" "network" {
  depends_on = [ aws_lb_target_group.nlb-target-group, aws_lb.network ]
  load_balancer_arn = aws_lb.network.arn
  port = "80"
  protocol = "TCP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.network.arn
  }
}

/* Create Target Group for NLB */
resource "aws_lb_target_group" "nlb-target-group" {
  name     = "terraform-nlb-target-group"
  port     = 80
  protocol = "TCP"
  vpc_id   = module.networking.vpc_id
}

/* Attachment for NLB Target Group */ 
resource "aws_lb_target_group_attachment" "alb_to_nlb" {
  depends_on = [ aws_lb_target_group.nlb-target-group, aws_lb.application, aws_lb.network ]
  target_group_arn = aws_lb_target_group.network.arn
  target_id = aws_lb.application.id
  port = 80
}

