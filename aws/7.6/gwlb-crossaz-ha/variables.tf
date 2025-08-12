//AWS Configuration
variable "access_key" {}
variable "secret_key" {}

variable "region" {
  default = "us-east-1"
}

// Availability zones for the region
variable "az1" {
  default = "us-east-1a"
}

variable "az2" {
  default = "us-east-1b"
}

// Existing VPC IDs
variable "security_vpc_id" {
  description = "Existing Security VPC ID where FortiGates will be deployed"
  type        = string
}

variable "customer_vpc_id" {
  description = "Existing Customer VPC ID where GWLB endpoints are located"
  type        = string
}

variable "customer_vpc_cidr" {
  description = "Customer VPC CIDR block for routing"
  type        = string
  default     = "20.1.0.0/16"
}

// Existing Subnet IDs
variable "public_subnet_az1_id" {
  description = "Existing public subnet ID in AZ1"
  type        = string
}

variable "private_subnet_az1_id" {
  description = "Existing private subnet ID in AZ1"
  type        = string
}

variable "private_subnet_az1_cidr" {
  description = "Private subnet CIDR in AZ1 for gateway calculation"
  type        = string
  default     = "10.1.1.0/24"
}

variable "hasync_subnet_az1_id" {
  description = "Existing HA sync subnet ID in AZ1"
  type        = string
}

variable "hamgmt_subnet_az1_id" {
  description = "Existing HA management subnet ID in AZ1"
  type        = string
}

variable "public_subnet_az2_id" {
  description = "Existing public subnet ID in AZ2"
  type        = string
}

variable "private_subnet_az2_id" {
  description = "Existing private subnet ID in AZ2"
  type        = string
}

variable "private_subnet_az2_cidr" {
  description = "Private subnet CIDR in AZ2 for gateway calculation"
  type        = string
  default     = "10.1.11.0/24"
}

variable "hasync_subnet_az2_id" {
  description = "Existing HA sync subnet ID in AZ2"
  type        = string
}

variable "hamgmt_subnet_az2_id" {
  description = "Existing HA management subnet ID in AZ2"
  type        = string
}

// Existing Security Group IDs
variable "public_security_group_id" {
  description = "Existing security group ID for public interfaces"
  type        = string
}

variable "private_security_group_id" {
  description = "Existing security group ID for private interfaces"
  type        = string
}

// Existing GWLB Endpoint IPs
variable "gwlb_endpoint_az1_ip" {
  description = "GWLB endpoint IP in AZ1"
  type        = string
}

variable "gwlb_endpoint_az2_ip" {
  description = "GWLB endpoint IP in AZ2"
  type        = string
}

// License Type to create FortiGate-VM
variable "license_type" {
  default = "payg"
}

// BYOL License format
variable "license_format" {
  default = "file"
}

// use s3 bucket for bootstrap
variable "bucket" {
  type    = bool
  default = false
}

// instance architect
variable "arch" {
  default = "x86"
}

// instance type needs to match the architect
variable "size" {
  default = "c5.xlarge"
}

// AMIs for FGTVM-7.6.1
variable "fgtami" {
  type = map(any)
  default = {
    us-east-1 = {
      arm = {
        payg = "ami-0fcc3c864914a6bbd"
        byol = "ami-015d206cf4d0248c0"
      },
      x86 = {
        payg = "ami-0337c73411330e400"
        byol = "ami-08af434d4f7a67d23"
      }
    },
    us-east-2 = {
      arm = {
        payg = "ami-0434460c7f4069fff"
        byol = "ami-0e88f00ba85e75d60"
      },
      x86 = {
        payg = "ami-02b90a51345912dfb"
        byol = "ami-00379d5a1deba1773"
      }
    },
    us-west-1 = {
      arm = {
        payg = "ami-0ebe64d481b6b1bcd"
        byol = "ami-0851e6495ad3a405d"
      },
      x86 = {
        payg = "ami-03399b9e23f7b7108"
        byol = "ami-0f2bd186b60ffdc2f"
      }
    },
    us-west-2 = {
      arm = {
        payg = "ami-00723df2b4dcd60a7"
        byol = "ami-0b744cfb916ded4dd"
      },
      x86 = {
        payg = "ami-087be46f183decec8"
        byol = "ami-061dc9e399349b5a5"
      }
    }
  }
}

//  Existing SSH Key on the AWS 
variable "keyname" {
  default = "<AWS SSH KEY>"
}

//  Admin HTTPS access port
variable "adminsport" {
  default = "443"
}

// FortiGate Active Instance IPs
variable "activeport1" {
  description = "Active FortiGate port1 IP (must be within public_subnet_az1 CIDR)"
  type        = string
}

variable "activeport2" {
  description = "Active FortiGate port2 IP (must be within private_subnet_az1 CIDR)"
  type        = string
}

variable "activeport3" {
  description = "Active FortiGate port3 IP - HA sync (must be within hasync_subnet_az1 CIDR)"
  type        = string
}

variable "activeport4" {
  description = "Active FortiGate port4 IP - HA mgmt (must be within hamgmt_subnet_az1 CIDR)"
  type        = string
}

// FortiGate Passive Instance IPs
variable "passiveport1" {
  description = "Passive FortiGate port1 IP (must be within public_subnet_az2 CIDR)"
  type        = string
}

variable "passiveport2" {
  description = "Passive FortiGate port2 IP (must be within private_subnet_az2 CIDR)"
  type        = string
}

variable "passiveport3" {
  description = "Passive FortiGate port3 IP - HA sync (must be within hasync_subnet_az2 CIDR)"
  type        = string
}

variable "passiveport4" {
  description = "Passive FortiGate port4 IP - HA mgmt (must be within hamgmt_subnet_az2 CIDR)"
  type        = string
}

// Gateway IPs (usually .1 of each subnet CIDR)
variable "activeport1_gateway" {
  description = "Gateway IP for active port1 (usually first IP of public_subnet_az1)"
  type        = string
}

variable "activeport2_gateway" {
  description = "Gateway IP for active port2 (usually first IP of private_subnet_az1)"
  type        = string
}

variable "activeport4_gateway" {
  description = "Gateway IP for active port4 (usually first IP of hamgmt_subnet_az1)"
  type        = string
}

variable "passiveport1_gateway" {
  description = "Gateway IP for passive port1 (usually first IP of public_subnet_az2)"
  type        = string
}

variable "passiveport2_gateway" {
  description = "Gateway IP for passive port2 (usually first IP of private_subnet_az2)"
  type        = string
}

variable "passiveport4_gateway" {
  description = "Gateway IP for passive port4 (usually first IP of hamgmt_subnet_az2)"
  type        = string
}

variable "bootstrap-active" {
  type    = string
  default = "config-active.conf"
}

variable "bootstrap-passive" {
  type    = string
  default = "config-passive.conf"
}

//license files for the two fgts
variable "licenses" {
  type    = list(string)
  default = ["license.lic", "license2.lic"]
}