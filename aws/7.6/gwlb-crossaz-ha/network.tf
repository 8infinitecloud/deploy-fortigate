// Route Tables for Security VPC (where FortiGates are)
resource "aws_route_table" "security_private_rt_az1" {
  vpc_id = var.security_vpc_id
  tags = {
    Name = "security-private-rt-az1"
  }
}

resource "aws_route_table" "security_private_rt_az2" {
  vpc_id = var.security_vpc_id
  tags = {
    Name = "security-private-rt-az2"
  }
}

// Routes in Security VPC - Private subnets point to FortiGate ENIs
resource "aws_route" "security_private_route_az1" {
  depends_on             = [aws_instance.fgtactive]
  route_table_id         = aws_route_table.security_private_rt_az1.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.eth1_active.id
}

resource "aws_route" "security_private_route_az2" {
  depends_on             = [aws_instance.fgtpassive]
  route_table_id         = aws_route_table.security_private_rt_az2.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.eth1_passive.id
}

// Route Table Associations for Security VPC
resource "aws_route_table_association" "security_private_associate_az1" {
  subnet_id      = var.private_subnet_az1_id
  route_table_id = aws_route_table.security_private_rt_az1.id
}

resource "aws_route_table_association" "security_private_associate_az2" {
  subnet_id      = var.private_subnet_az2_id
  route_table_id = aws_route_table.security_private_rt_az2.id
}

// Route Tables for Customer VPC (where GWLB endpoints are)
resource "aws_route_table" "customer_private_rt_az1" {
  vpc_id = var.customer_vpc_id
  tags = {
    Name = "customer-private-rt-az1"
  }
}

resource "aws_route_table" "customer_private_rt_az2" {
  vpc_id = var.customer_vpc_id
  tags = {
    Name = "customer-private-rt-az2"
  }
}

// Routes in Customer VPC - Private subnets point to GWLB endpoints
resource "aws_route" "customer_private_route_az1" {
  route_table_id         = aws_route_table.customer_private_rt_az1.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = var.gwlb_endpoint_az1_id
}

resource "aws_route" "customer_private_route_az2" {
  route_table_id         = aws_route_table.customer_private_rt_az2.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = var.gwlb_endpoint_az2_id
}

// Note: You need to manually associate these route tables to your customer VPC subnets
// or provide the subnet IDs as variables if you want Terraform to manage the associations