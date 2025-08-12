// Public IP Addresses for Management Access
output "FortiGate-Active-Public-EIP" {
  value       = aws_eip.active_public_ip.public_ip
  description = "Active FortiGate public IP for management via port1"
}

output "FortiGate-Active-Mgmt-EIP" {
  value       = aws_eip.active_mgmt_ip.public_ip
  description = "Active FortiGate dedicated management IP via port4"
}

output "FortiGate-Passive-Public-EIP" {
  value       = aws_eip.passive_public_ip.public_ip
  description = "Passive FortiGate public IP for management via port1"
}

output "FortiGate-Passive-Mgmt-EIP" {
  value       = aws_eip.passive_mgmt_ip.public_ip
  description = "Passive FortiGate dedicated management IP via port4"
}

// Private IP Addresses
output "FortiGate-Active-Port1-PrivateIP" {
  value = aws_network_interface.eth0_active.private_ip
}

output "FortiGate-Active-Port2-PrivateIP" {
  value = aws_network_interface.eth1_active.private_ip
}

output "FortiGate-Active-HASyncIP" {
  value = aws_network_interface.eth2_active.private_ip
}

output "FortiGate-Active-HAMgmtIP" {
  value = aws_network_interface.eth3_active.private_ip
}

output "FortiGate-Passive-Port1-PrivateIP" {
  value = aws_network_interface.eth0_passive.private_ip
}

output "FortiGate-Passive-Port2-PrivateIP" {
  value = aws_network_interface.eth1_passive.private_ip
}

output "FortiGate-Passive-HASyncIP" {
  value = aws_network_interface.eth2_passive.private_ip
}

output "FortiGate-Passive-HAMgmtIP" {
  value = aws_network_interface.eth3_passive.private_ip
}

output "GWLB-Endpoint-AZ1-IP" {
  value = var.gwlb_endpoint_az1_ip
}

output "GWLB-Endpoint-AZ2-IP" {
  value = var.gwlb_endpoint_az2_ip
}

output "FortiGate-Active-Instance-ID" {
  value = aws_instance.fgtactive.id
}

output "FortiGate-Passive-Instance-ID" {
  value = aws_instance.fgtpassive.id
}