# Smart-1-Cloud with Terraform

Automatically deploy a gateway in Azure and connect it to Check Point Smart-1 Cloud


## Prerequisites
* Smart 1 Cloud Tenant in the [Check Point Infinity Portal](https://portal.checkpoint.com)
* Terraform
* Azure CLI
* requests library for the python script (pip install requests)

## Usage:

Clone the repository:

```hcl
git clone https://github.com/alshawwaf/Smart1-Cloud-GW-Terraform.git
```

Ensure that you have Azure CLI installed. Once installed run the following commands in Powershell.

This logs into the Azure Tenant:

```hcl
az login
```

Accept the licensing agreement (if you chose not to use the provided azurerm_marketplace_agreement):

```hcl
az vm image terms accept --urn checkpoint:check-point-cg-r81:sg-byol:latest
```

Edit the variables as required. Review terraform.tfvars.

```hcl
company                         = "NA-SE-Demo"                                      # use to derive the hostname
os_version                      = "R81"                                             # Gateway Version
gw-network-vnet-cidr            = "xxx.xxx.xxx.xxx/xx"                              # VNET range
gw-network-subnet-cidr          = "xxx.xxx.xxx.xxx/xx"                              # Internal Subnet
gw-network-internal-subnet-cidr = "xxx.xxx.xxx.xxx/xx"                              # External Subnet
gw-external-private-ip          = "xxx.xxx.xxx.xxx/xx"                              # External IP address
gw-internal-private-ip          = "xxx.xxx.xxx.xxx/xx"                              # Internal IP address

# Note that Azure reserves 5 IP addresses within each subnet. These are x.x.x.0-x.x.x.3 and the last address of the subnet. x.x.x.1-x.x.x.3 is reserved in each subnet for Azure services. https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-faq

environment                     = "Staging"                                         # Staging or Production           
username                        = "admin"                                           # Gaia user
password                        = "Vpn123vpn123!"                                   # Gaia password
sic_key                         = "Vpn123vpn123"                                    # SIC password
clientid                        = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"                
secretkey                       = "yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"          
mgmt_api_key                    = "zzzzzzzzzzzzzzzzzzzzzzzz"
# The ClientID and the secretKey are created using the Smart-1 Cloud portal.
```


Run the following commands in Terraform:

```hcl
terraform init
```

Apply the terraform plan:

```hcl
terraform apply
```

Finally, wait until Terraform has completed. Then wait an addtional 5-10 mins for the VM to complete bootstrapping.


## Smart1 Cloud Configuration Steps:

Once finished, you should see the gateway connected to Smart1 Cloud with SIC established.


## Removal:

To destroy, you need to run:

```hcl
terraform destroy
```

## Issues:


