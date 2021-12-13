# Create CP GW network VNET
resource "azurerm_virtual_network" "cp-gw-network-vnet" {
  name                = "${var.company}-cp-gw-vnet"
  address_space       = [var.gw-network-vnet-cidr]
  resource_group_name = azurerm_resource_group.smart1-cp-gw-rg.name
  location            = azurerm_resource_group.smart1-cp-gw-rg.location
  tags = {
    application = var.company
    environment = var.environment
  }
}

# Create CP GW subnet for Network
resource "azurerm_subnet" "cp-gw-subnet" {
  name                 = "${var.company}-cp-gw-subnet"
  address_prefixes     = [var.gw-network-subnet-cidr]
  virtual_network_name = azurerm_virtual_network.cp-gw-network-vnet.name
  resource_group_name  = azurerm_resource_group.smart1-cp-gw-rg.name
}

# Create CP GW INTERAL subnet for Network
resource "azurerm_subnet" "cp-gw-internal-subnet" {
  name                 = "${var.company}-cp-gw-internal-subnet"
  address_prefixes     = [var.gw-network-internal-subnet-cidr]
  virtual_network_name = azurerm_virtual_network.cp-gw-network-vnet.name
  resource_group_name  = azurerm_resource_group.smart1-cp-gw-rg.name
}

# create an internal subnet for the web server
resource "azurerm_subnet" "webapp_subnet" {
  name                 = "${var.company}-webapp-subnet"
  address_prefixes     = [var.webapp-subnet-cidr]
  virtual_network_name = azurerm_virtual_network.cp-gw-network-vnet.name
  resource_group_name  = azurerm_resource_group.smart1-cp-gw-rg.name
}