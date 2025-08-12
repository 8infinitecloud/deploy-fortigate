#!/bin/bash

# Script to help find available IP addresses in your subnets
# Usage: ./find-available-ips.sh <subnet-id>

if [ $# -eq 0 ]; then
    echo "Usage: $0 <subnet-id>"
    echo "Example: $0 subnet-12345678"
    exit 1
fi

SUBNET_ID=$1

echo "Checking available IPs in subnet: $SUBNET_ID"
echo "================================================"

# Get subnet CIDR
SUBNET_CIDR=$(aws ec2 describe-subnets --subnet-ids $SUBNET_ID --query 'Subnets[0].CidrBlock' --output text)
echo "Subnet CIDR: $SUBNET_CIDR"

# Get used IPs in the subnet
echo -e "\nUsed IP addresses in this subnet:"
aws ec2 describe-network-interfaces \
    --filters "Name=subnet-id,Values=$SUBNET_ID" \
    --query 'NetworkInterfaces[*].PrivateIpAddress' \
    --output table

echo -e "\nSuggested available IPs (verify before using):"
# Extract network part and suggest some IPs
NETWORK=$(echo $SUBNET_CIDR | cut -d'/' -f1 | cut -d'.' -f1-3)
echo "${NETWORK}.10"
echo "${NETWORK}.11" 
echo "${NETWORK}.12"
echo "${NETWORK}.20"
echo "${NETWORK}.21"
echo "${NETWORK}.22"

echo -e "\nNote: Always verify these IPs are actually available before using them!"
echo "Gateway IP is typically: ${NETWORK}.1"