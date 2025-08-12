output "FortiGate-Active-PublicIP" {
  value = aws_network_interface.eth0_active.private_ip
}

output "FortiGate-Active-PrivateIP" {
  value = aws_network_interface.eth1_active.private_ip
}

output "FortiGate-Active-HASyncIP" {
  value = aws_network_interface.eth2_active.private_ip
}

output "FortiGate-Active-HAMgmtIP" {
  value = aws_network_interface.eth3_active.private_ip
}

output "FortiGate-Passive-PublicIP" {
  value = aws_network_interface.eth0_passive.private_ip
}

output "FortiGate-Passive-PrivateIP" {
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