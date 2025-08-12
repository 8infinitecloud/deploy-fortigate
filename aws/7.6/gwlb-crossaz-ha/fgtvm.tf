// FortiGate Active Instance (AZ1)

resource "aws_network_interface" "eth0_active" {
  description = "active-port1"
  subnet_id   = var.public_subnet_az1_id
}

resource "aws_network_interface" "eth1_active" {
  description       = "active-port2"
  subnet_id         = var.private_subnet_az1_id
  source_dest_check = false
}

resource "aws_network_interface" "eth2_active" {
  description       = "active-port3"
  subnet_id         = var.hasync_subnet_az1_id
  source_dest_check = false
}

resource "aws_network_interface" "eth3_active" {
  description = "active-port4"
  subnet_id   = var.hamgmt_subnet_az1_id
}

// FortiGate Passive Instance (AZ2)

resource "aws_network_interface" "eth0_passive" {
  description = "passive-port1"
  subnet_id   = var.public_subnet_az2_id
}

resource "aws_network_interface" "eth1_passive" {
  description       = "passive-port2"
  subnet_id         = var.private_subnet_az2_id
  source_dest_check = false
}

resource "aws_network_interface" "eth2_passive" {
  description       = "passive-port3"
  subnet_id         = var.hasync_subnet_az2_id
  source_dest_check = false
}

resource "aws_network_interface" "eth3_passive" {
  description = "passive-port4"
  subnet_id   = var.hamgmt_subnet_az2_id
}

// Security Group Attachments - Active
resource "aws_network_interface_sg_attachment" "active_public_attachment" {
  depends_on           = [aws_network_interface.eth0_active]
  security_group_id    = var.public_security_group_id
  network_interface_id = aws_network_interface.eth0_active.id
}

resource "aws_network_interface_sg_attachment" "active_private_attachment" {
  depends_on           = [aws_network_interface.eth1_active]
  security_group_id    = var.private_security_group_id
  network_interface_id = aws_network_interface.eth1_active.id
}

resource "aws_network_interface_sg_attachment" "active_hasync_attachment" {
  depends_on           = [aws_network_interface.eth2_active]
  security_group_id    = var.private_security_group_id
  network_interface_id = aws_network_interface.eth2_active.id
}

resource "aws_network_interface_sg_attachment" "active_hamgmt_attachment" {
  depends_on           = [aws_network_interface.eth3_active]
  security_group_id    = var.public_security_group_id
  network_interface_id = aws_network_interface.eth3_active.id
}

// Security Group Attachments - Passive
resource "aws_network_interface_sg_attachment" "passive_public_attachment" {
  depends_on           = [aws_network_interface.eth0_passive]
  security_group_id    = var.public_security_group_id
  network_interface_id = aws_network_interface.eth0_passive.id
}

resource "aws_network_interface_sg_attachment" "passive_private_attachment" {
  depends_on           = [aws_network_interface.eth1_passive]
  security_group_id    = var.private_security_group_id
  network_interface_id = aws_network_interface.eth1_passive.id
}

resource "aws_network_interface_sg_attachment" "passive_hasync_attachment" {
  depends_on           = [aws_network_interface.eth2_passive]
  security_group_id    = var.private_security_group_id
  network_interface_id = aws_network_interface.eth2_passive.id
}

resource "aws_network_interface_sg_attachment" "passive_hamgmt_attachment" {
  depends_on           = [aws_network_interface.eth3_passive]
  security_group_id    = var.public_security_group_id
  network_interface_id = aws_network_interface.eth3_passive.id
}

// GWLB endpoint IPs are provided as variables since GWLB infrastructure already exists

// Active FortiGate Configuration
data "template_file" "fgtconfig_active" {
  template = file("${var.bootstrap-fgtvm}")

  vars = {
    hostname_suffix = "Active"
    adminsport      = var.adminsport
    endpointip      = var.gwlb_endpoint_az1_ip
    endpointip2     = var.gwlb_endpoint_az2_ip
  }
}

data "template_cloudinit_config" "config_active" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "config"
    content_type = "text/x-shellscript"
    content      = data.template_file.fgtconfig_active.rendered
  }

  part {
    filename     = "license"
    content_type = "text/plain"
    content      = var.license_format == "token" ? "LICENSE-TOKEN:${chomp(file("${var.licenses[0]}"))} INTERVAL:4 COUNT:4" : "${file("${var.licenses[0]}")}"
  }
}

// Passive FortiGate Configuration
data "template_file" "fgtconfig_passive" {
  template = file("${var.bootstrap-fgtvm}")

  vars = {
    hostname_suffix = "Passive"
    adminsport      = var.adminsport
    endpointip      = var.gwlb_endpoint_az1_ip
    endpointip2     = var.gwlb_endpoint_az2_ip
  }
}

data "template_cloudinit_config" "config_passive" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "config"
    content_type = "text/x-shellscript"
    content      = data.template_file.fgtconfig_passive.rendered
  }

  part {
    filename     = "license"
    content_type = "text/plain"
    content      = var.license_format == "token" ? "LICENSE-TOKEN:${chomp(file("${var.licenses[1]}"))} INTERVAL:4 COUNT:4" : "${file("${var.licenses[1]}")}"
  }
}

// Active FortiGate Instance
resource "aws_instance" "fgtactive" {
  ami               = var.fgtami[var.region][var.arch][var.license_type]
  instance_type     = var.size
  availability_zone = var.az1
  key_name          = var.keyname

  user_data = var.bucket ? (var.license_format == "file" ? "${jsonencode({ bucket = aws_s3_bucket.s3_bucket[0].id,
    region                        = var.region,
    license                       = var.licenses[0],
    config                        = "${var.bootstrap-fgtvm}"
    })}" : "${jsonencode({ bucket = aws_s3_bucket.s3_bucket[0].id,
    region                        = var.region,
    license-token                 = file("${var.licenses[0]}"),
    config                        = "${var.bootstrap-fgtvm}"
  })}") : "${data.template_cloudinit_config.config_active.rendered}"

  iam_instance_profile = var.bucket ? aws_iam_instance_profile.fortigate[0].id : aws_iam_instance_profile.fortigateha.id

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
    network_interface_id = aws_network_interface.eth0_active.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.eth1_active.id
    device_index         = 1
  }

  network_interface {
    network_interface_id = aws_network_interface.eth2_active.id
    device_index         = 2
  }

  network_interface {
    network_interface_id = aws_network_interface.eth3_active.id
    device_index         = 3
  }

  tags = {
    Name = "FortiGateVM-Active-AZ1"
  }
}

// Elastic IPs for public access
resource "aws_eip" "active_public_ip" {
  depends_on        = [aws_instance.fgtactive]
  domain            = "vpc"
  network_interface = aws_network_interface.eth0_active.id
  
  tags = {
    Name = "FortiGate-Active-PublicIP"
  }
}

resource "aws_eip" "active_mgmt_ip" {
  depends_on        = [aws_instance.fgtactive]
  domain            = "vpc"
  network_interface = aws_network_interface.eth3_active.id
  
  tags = {
    Name = "FortiGate-Active-MgmtIP"
  }
}

// Passive FortiGate Instance
resource "aws_instance" "fgtpassive" {
  depends_on        = [aws_instance.fgtactive]
  ami               = var.fgtami[var.region][var.arch][var.license_type]
  instance_type     = var.size
  availability_zone = var.az2
  key_name          = var.keyname

  user_data = var.bucket ? (var.license_format == "file" ? "${jsonencode({ bucket = aws_s3_bucket.s3_bucket[0].id,
    region                        = var.region,
    license                       = var.licenses[1],
    config                        = "${var.bootstrap-fgtvm}"
    })}" : "${jsonencode({ bucket = aws_s3_bucket.s3_bucket[0].id,
    region                        = var.region,
    license-token                 = file("${var.licenses[1]}"),
    config                        = "${var.bootstrap-fgtvm}"
  })}") : "${data.template_cloudinit_config.config_passive.rendered}"

  iam_instance_profile = var.bucket ? aws_iam_instance_profile.fortigate[0].id : aws_iam_instance_profile.fortigateha.id

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
    network_interface_id = aws_network_interface.eth0_passive.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.eth1_passive.id
    device_index         = 1
  }

  network_interface {
    network_interface_id = aws_network_interface.eth2_passive.id
    device_index         = 2
  }

  network_interface {
    network_interface_id = aws_network_interface.eth3_passive.id
    device_index         = 3
  }

  tags = {
    Name = "FortiGateVM-Passive-AZ2"
  }
}

resource "aws_eip" "passive_public_ip" {
  depends_on        = [aws_instance.fgtpassive]
  domain            = "vpc"
  network_interface = aws_network_interface.eth0_passive.id
  
  tags = {
    Name = "FortiGate-Passive-PublicIP"
  }
}

resource "aws_eip" "passive_mgmt_ip" {
  depends_on        = [aws_instance.fgtpassive]
  domain            = "vpc"
  network_interface = aws_network_interface.eth3_passive.id
  
  tags = {
    Name = "FortiGate-Passive-MgmtIP"
  }
}