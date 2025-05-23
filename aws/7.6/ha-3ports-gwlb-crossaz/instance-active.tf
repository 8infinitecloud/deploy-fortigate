// FGTVM active instance

resource "aws_network_interface" "eth0" {
  description = "active-port1"
  subnet_id   = aws_subnet.publicsubnetaz1.id
  private_ips = [var.activeport1]
}

resource "aws_network_interface" "eth1" {
  description       = "active-port2"
  subnet_id         = aws_subnet.privatesubnetaz1.id
  private_ips       = [var.activeport2]
  source_dest_check = false
}


resource "aws_network_interface" "eth2" {
  description       = "active-port3"
  subnet_id         = aws_subnet.hasyncmgmtsubnetaz1.id
  private_ips       = [var.activeport3]
  source_dest_check = false
}


resource "aws_network_interface_sg_attachment" "publicattachment" {
  depends_on           = [aws_network_interface.eth0]
  security_group_id    = aws_security_group.public_allow.id
  network_interface_id = aws_network_interface.eth0.id
}


resource "aws_network_interface_sg_attachment" "internalattachment" {
  depends_on           = [aws_network_interface.eth1]
  security_group_id    = aws_security_group.allow_all.id
  network_interface_id = aws_network_interface.eth1.id
}

resource "aws_network_interface_sg_attachment" "hasyncmgmtattachment" {
  depends_on           = [aws_network_interface.eth2]
  security_group_id    = aws_security_group.allow_all.id
  network_interface_id = aws_network_interface.eth2.id
}


resource "aws_instance" "fgtactive" {
  //it will use region, architect, and license type to decide which ami to use for deployment
  ami               = "ami-0482366d385444bde" #var.fgtami[var.region][var.arch][var.license_type]
  instance_type     = var.size
  availability_zone = var.az1
  key_name          = var.keyname
  user_data = templatefile("${var.bootstrap-active}", {
    type            = "${var.license_type}"
    license_file    = var.licenses[0]
    format          = "${var.license_format}"
    port1_ip        = "${var.activeport1}"
    port1_mask      = "${var.activeport1mask}"
    port2_ip        = "${var.activeport2}"
    port2_mask      = "${var.activeport2mask}"
    port3_ip        = "${var.activeport3}"
    port3_mask      = "${var.activeport3mask}"
    passive_peerip  = "${var.passiveport3}"
    mgmt_gateway_ip = "${var.activeport3gateway}"
    defaultgwy      = "${var.activeport1gateway}"
    privategwy      = "${var.activeport2gateway}"
    vpc_ip          = cidrhost(var.vpccidr, 0)
    vpc_mask        = cidrnetmask(var.vpccidr)
    adminsport      = "${var.adminsport}"
  })
  iam_instance_profile = var.iam

  root_block_device {
    volume_type = "gp2"
    volume_size = "2"
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "30"
    volume_type = "gp2"
  }

  network_interface {
    network_interface_id = aws_network_interface.eth0.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.eth1.id
    device_index         = 1
  }

  network_interface {
    network_interface_id = aws_network_interface.eth2.id
    device_index         = 2
  }

  tags = {
    Name = "FortiGateVM Active"
  }
}
