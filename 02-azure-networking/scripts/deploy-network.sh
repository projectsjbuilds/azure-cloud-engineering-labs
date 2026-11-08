
#!/usr/bin/env bash
set -euo pipefail

# Azure Cloud Engineering — Networking Lab
# Requires Azure CLI and an existing RG-CLOUD-LAB.

RG="RG-CLOUD-LAB"
VNET="VNET-LAB"
WEB_SUBNET="SNET-WEB"
APP_SUBNET="SNET-APP"
WEB_NSG="NSG-WEB-LAB"
APP_NSG="NSG-APP-LAB"

LOCATION=$(az group show \
  --name "$RG" --query location -o tsv)

# Create VNet only if missing
if ! az network vnet show -g "$RG" -n "$VNET" \
  >/dev/null 2>&1; then
  az network vnet create \
    -g "$RG" -n "$VNET" \
    --location "$LOCATION" \
    --address-prefixes 10.0.0.0/16 \
    --tags Project=CloudEngineering Environment=Lab
fi

# Ensure intended VNet address space
PREFIX=$(az network vnet show -g "$RG" -n "$VNET" \
  --query "addressSpace.addressPrefixes[0]" -o tsv)

if [[ "$PREFIX" != "10.0.0.0/16" ]]; then
  echo "Unexpected VNet address space: $PREFIX"
  exit 1
fi

# Create subnets if absent
for entry in \
  "$WEB_SUBNET:10.0.1.0/24" \
  "$APP_SUBNET:10.0.2.0/24"; do

  NAME="${entry%%:*}"
  CIDR="${entry#*:}"

  if ! az network vnet subnet show \
    -g "$RG" --vnet-name "$VNET" \
    -n "$NAME" >/dev/null 2>&1; then

    az network vnet subnet create \
      -g "$RG" --vnet-name "$VNET" \
      -n "$NAME" --address-prefixes "$CIDR"
  fi
done

# Create NSGs
for NSG in "$WEB_NSG" "$APP_NSG"; do
  if ! az network nsg show \
    -g "$RG" -n "$NSG" >/dev/null 2>&1; then

    az network nsg create \
      -g "$RG" -n "$NSG" \
      --location "$LOCATION" \
      --tags Project=CloudEngineering Environment=Lab
  fi
done

# Web HTTPS rule
az network nsg rule create \
  -g "$RG" --nsg-name "$WEB_NSG" \
  -n ALLOW-HTTPS \
  --priority 100 --direction Inbound \
  --access Allow --protocol Tcp \
  --source-address-prefixes Internet \
  --source-port-ranges '*' \
  --destination-address-prefixes 10.0.1.0/24 \
  --destination-port-ranges 443

# Web to application rule
az network nsg rule create \
  -g "$RG" --nsg-name "$APP_NSG" \
  -n ALLOW-WEB-TO-APP \
  --priority 100 --direction Inbound \
  --access Allow --protocol Tcp \
  --source-address-prefixes 10.0.1.0/24 \
  --source-port-ranges '*' \
  --destination-address-prefixes 10.0.2.0/24 \
  --destination-port-ranges 8080

# Deny other inbound VNet traffic to app subnet
az network nsg rule create \
  -g "$RG" --nsg-name "$APP_NSG" \
  -n DENY-OTHER-VNET-INBOUND \
  --priority 200 --direction Inbound \
  --access Deny --protocol '*' \
  --source-address-prefixes VirtualNetwork \
  --source-port-ranges '*' \
  --destination-address-prefixes 10.0.2.0/24 \
  --destination-port-ranges '*'

# Associate NSGs with subnets
az network vnet subnet update \
  -g "$RG" --vnet-name "$VNET" \
  -n "$WEB_SUBNET" \
  --network-security-group "$WEB_NSG"

az network vnet subnet update \
  -g "$RG" --vnet-name "$VNET" \
  -n "$APP_SUBNET" \
  --network-security-group "$APP_NSG"

echo "Azure networking deployment completed."

# Verify deployed subnet associations
az network vnet subnet list \
  -g "$RG" --vnet-name "$VNET" \
  --query "[].{Name:name,Address:addressPrefix,NSG:networkSecurityGroup.id}" \
  -o table
