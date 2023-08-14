output "vpc_id" {
  description = "VPC Id"
  value = "${aws_vpc.vpc.id}"
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value = "${aws_subnet.public_subnet[*].id}"
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value = "${aws_subnet.private_subnet[*].id}"
}

output "network_lb_elastic_ip_id" {
  description = "Value of Elastic IP address for network lb"
  value = aws_eip.nlb_eip.id
}

output "jump_server_sg_id" {
  description = "Id for jump server security group"
  value = "${aws_security_group.jump-server-sg.id}"
}

output "alb_sg_id" {
  description = "Id for jump server security group"
  value = "${aws_security_group.alb-sg.id}"
}

output "web_app_sg_id" {
  description = "Id for jump server security group"
  value = "${aws_security_group.web-app-sg.id}"
}