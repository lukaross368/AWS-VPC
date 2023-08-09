/* VPC */
resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "VPC-Terraform"
  }
}

/* Public subnets */
resource "aws_subnet" "public_subnet" {
  vpc_id = "${aws_vpc.vpc.id}"
  count = "${length(var.public_subnets_cidr)}"
  cidr_block = "${element(var.public_subnets_cidr, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = true
  tags = {
    Name = "${element(var.availability_zones, count.index)}-public-subnet"
  }
}

/* Private Subnets */
resource "aws_subnet" "private_subnet" {
  vpc_id = "${aws_vpc.vpc.id}"
  count = "${length(var.private_subnets_cidr)}"
  cidr_block = "${element(var.private_subnets_cidr, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = false
  tags = {
    Name = "${element(var.availability_zones, count.index)}-private-subnet"
  }
}

/* Internet Gateway */
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "terraform-igw"
  }
}

/* Elastic IP for NAT Gateway */
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.ig]
}

/* NAT Gateway */
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = "${element(aws_subnet.public_subnet.*.id, 0)}"
  depends_on = [aws_internet_gateway.ig]
  tags = {
    Name = "terraform-nat-gateway"
  }
}

/* Public Route Table */
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "terraform-public-route-table"
  }
}

/* Private Route Table */
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "terraform-private-route-table"
  }
}

/* Route Outgoing Traffic from Public Subnet to the Internet Gateway */
resource "aws_route" "public_internet_gateway" {
  route_table_id = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.ig.id}"
}

/* Route Outgoing Traffic from Priavte Subnet to the NAT Gateway  */
resource "aws_route" "private_nat_gateway" {
  route_table_id = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.nat.id}"
}

/* Public Route table associations */
resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnets_cidr)}"
  subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

/* Private Route table associations */
resource "aws_route_table_association" "private" {
  count = "${length(var.private_subnets_cidr)}"
  subnet_id = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

/* Securtiy Groups */

/* default sg */
resource "aws_security_group" "default" {
  name = "default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id = "${aws_vpc.vpc.id}"
  depends_on = [aws_vpc.vpc]
  
  ingress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    self = true
  }
  
  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    self = true
  }
}

/* web-app-sg */

/* jump-server-sg */

/* alb-sg */

