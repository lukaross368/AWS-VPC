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
resource "aws_subnet" "private_subnets" {
  vpc_id = "${aws_vpc.vpc.id}"
  count = "${length(var.private_subnets_cidr)}"
  cidr_block = "${element(var.private_subnets_cidr, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = false
  tags = {
    Name = "${element(var.availability_zones, count.index)}-private-subnet"
  }
}

/* Public Route Table */

/* Private Route Table */

/* Internet Gateway */
# resource "aws_internet_gateway" "ig" {
#   vpc_id = "${aws_vpc.vpc.id}"
#   tags = {
#     Name = "my-test-igw"
#   }
# }

/* Elastic IP for NAT */
# resource "aws_eip" "nat_eip" {
#   vpc        = true
#   depends_on = [aws_internet_gateway.ig]
# }

/* NAT Gatewat */
# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.nat_eip.id
#   subnet_id     = "${element(aws_subnet.public_subnet.*.id, 0)}"
#   depends_on    = [aws_internet_gateway.ig, aws_subnet.subnet-2a]
#   tags = {
#     Name        = "nat"
#   }
# }

/* Securtiy Groups */
