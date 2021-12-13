# company name (Will be used as a prefix for management and gateways)
variable "company" {
  type        = string
  description = "Company Name"
}

# azure region
variable "location" {
  type        = string
  description = "Azure region where the resources will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  default     = "East US"
}

# Gateway VNET
variable "gw-network-vnet-cidr" {
  type        = string
  description = "Gateway VNET"
}

# Gateway Subnet
variable "gw-network-subnet-cidr" {
  type        = string
  description = "Gateway Subnet"
}

# Gateway External Private IP
variable "gw-external-private-ip" {
  type        = string
  description = "Gateway Subnet"
}

# Gateway INTERNAL Subnet
variable "gw-network-internal-subnet-cidr" {
  type        = string
  description = "Gateway Subnet"
}


# Gateway Intertal Private IP
variable "gw-internal-private-ip" {
  type        = string
  description = "Gateway Subnet"
}

#SIC Key
variable "sic_key" {
  type        = string
  description = "Sic Key"
}

# environment
variable "environment" {
  type        = string
  description = "Staging or Production"
}

# username
variable "username" {
  type        = string
  description = "Username"
}

# password
variable "password" {
  type        = string
  description = "Password"
}

# version of the gateway (R80.40 or R81..)
variable "os_version" {
  description = "GAIA OS version"
  type        = string
}

#Smart-1 Cloud API CLientID
variable "clientid" {
  type        = string
  description = "clientis"
}

#Smart-1Cloud API SecretKey
variable "secretkey" {
  type        = string
  description = "secretkey"
}

#Smart-1-cloud Mgmt Domain
variable "smart_1_mgmt_domain" {
  type        = string
  description = "mgmtdomain"
}

#Management API Key
variable "mgmt_api_key" {
  type        = string
  description = "mgmtapikey"
}

#Smart-1-cloud mgmt instance
variable "smart_1_cloud_instance" {
  type        = string
  description = "mgmtinstance"
}

#Smart-1-cloud API context
variable "smart_1_cloud_context" {
  type        = string
  description = "mgmtcontext"
}

# webapp subnet
variable "webapp-subnet-cidr" {
  type        = string
  description = "Webapp Subnet"
}
