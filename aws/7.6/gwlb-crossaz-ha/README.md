# FortiGate GWLB Cross-AZ HA Deployment

This Terraform configuration deploys FortiGate instances in High Availability (HA) mode across two Availability Zones, integrated with existing Gateway Load Balancer (GWLB) infrastructure.

## Architecture

- **Active-Passive HA**: FortiGate instances deployed in Active-Passive mode
- **Cross-AZ**: Active instance in AZ1, Passive instance in AZ2
- **GWLB Integration**: Uses existing GWLB endpoints for traffic inspection
- **Existing Infrastructure**: Leverages existing VPC, subnets, security groups, and GWLB

## Prerequisites

- Existing VPC with appropriate subnets in two AZs
- Existing GWLB and GWLB endpoints
- Existing security groups
- AWS CLI configured with appropriate permissions
- Terraform >= 0.12

## Required Infrastructure

This deployment requires the following existing components:

### Security VPC (where FortiGates are deployed)
- Public subnet (for FortiGate port1)
- Private subnet (for FortiGate port2) 
- HA Sync subnet (for FortiGate port3)
- HA Management subnet (for FortiGate port4)

### Customer VPC (where GWLB endpoints are located)
- GWLB endpoints in both AZs

### Security Groups
- Public security group (for port1 and port4)
- Private security group (for port2 and port3)

### GWLB Infrastructure
- Existing Gateway Load Balancer (in Security VPC)
- GWLB endpoints (in Customer VPC) - you'll need the IP addresses

## Configuration

1. Copy `terraform.tfvars.example` to `terraform.tfvars`
2. Update the variables with your specific values:

```hcl
// AWS Environment
access_key = "your-aws-access-key"
secret_key = "your-aws-secret-key"
region     = "us-east-1"

// Existing Infrastructure
security_vpc_id            = "vpc-xxxxxxxxx"  // Security VPC
customer_vpc_id            = "vpc-yyyyyyyyy"  // Customer VPC
public_subnet_az1_id       = "subnet-xxxxxxxxx"
private_subnet_az1_id      = "subnet-xxxxxxxxx"
hasync_subnet_az1_id       = "subnet-xxxxxxxxx"
hamgmt_subnet_az1_id       = "subnet-xxxxxxxxx"
public_subnet_az2_id       = "subnet-xxxxxxxxx"
private_subnet_az2_id      = "subnet-xxxxxxxxx"
hasync_subnet_az2_id       = "subnet-xxxxxxxxx"
hamgmt_subnet_az2_id       = "subnet-xxxxxxxxx"
public_security_group_id   = "sg-xxxxxxxxx"
private_security_group_id  = "sg-xxxxxxxxx"
gwlb_endpoint_az1_ip       = "10.1.1.100"
gwlb_endpoint_az2_ip       = "10.1.11.100"

// FortiGate Configuration
keyname      = "your-aws-key-pair"
license_type = "payg"  // or "byol"
```

## Deployment

1. Initialize Terraform:
```bash
terraform init
```

2. Plan the deployment:
```bash
terraform plan
```

3. Apply the configuration:
```bash
terraform apply
```

## FortiGate Configuration

The FortiGates are configured with:
- HA Active-Passive mode
- Unicast heartbeat over port3
- HA management over port4
- Static routes to GWLB endpoints
- Basic firewall policies for traffic inspection

## Network Interfaces

### Active FortiGate (AZ1)
- **port1**: Public interface (WAN)
- **port2**: Private interface (LAN) - connects to GWLB
- **port3**: HA Sync interface
- **port4**: HA Management interface

### Passive FortiGate (AZ2)
- **port1**: Public interface (WAN)
- **port2**: Private interface (LAN) - connects to GWLB
- **port3**: HA Sync interface
- **port4**: HA Management interface

## Outputs

The deployment provides the following outputs:
- FortiGate instance IDs
- Network interface IP addresses
- GWLB endpoint IP addresses

## License

For BYOL deployments, place your license files as:
- `license.lic` (Active FortiGate)
- `license2.lic` (Passive FortiGate)

## Support

This configuration is based on FortiGate 7.6.1 AMIs and supports both x86 and ARM architectures.

## Notes

- The passive FortiGate will only become active during failover scenarios
- HA synchronization occurs over the dedicated sync interface (port3)
- Management access is available through both the public interface (port1) and management interface (port4)
- GWLB endpoint IPs must be provided as variables since they are from existing infrastructure

## Finding GWLB Endpoint IPs

The GWLB endpoints are located in the Customer VPC. You can find their IPs using:

### AWS CLI:
```bash
# List GWLB endpoints in your customer VPC
aws ec2 describe-vpc-endpoints \
  --filters "Name=vpc-id,Values=vpc-customer-id" \
          "Name=vpc-endpoint-type,Values=GatewayLoadBalancer"

# Get network interfaces for a specific endpoint
aws ec2 describe-network-interfaces \
  --filters "Name=vpc-endpoint-id,Values=vpce-endpoint-id"
```

### AWS Console:
1. Go to VPC > Endpoints
2. Find your GWLB endpoints
3. Click on each endpoint to see the network interface details and private IPs