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

output "network_lb_elastic_ip" {
  description = "Value of Elastic IP address for network lb"
  value = "${aws_eip.nlb_eip.address}"
}