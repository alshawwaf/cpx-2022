resource "azurerm_route_table" "webapp_route_table" {
  name                = "webapp-routing-table"
  location            = azurerm_resource_group.smart1-cp-gw-rg.location
  resource_group_name = azurerm_resource_group.smart1-cp-gw-rg.name
}

resource "azurerm_route" "webapp_to_cp" {
  name                = "forwardalltocheckpoint"
  resource_group_name = azurerm_resource_group.smart1-cp-gw-rg.name
  route_table_name    = azurerm_route_table.webapp_route_table.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "virtualAppliance"
  next_hop_in_ip_address = var.gw-internal-private-ip
}

resource "azurerm_subnet_route_table_association" "webapp_subnet_route_table_association" {
    subnet_id      = azurerm_subnet.webapp_subnet.id
    route_table_id = azurerm_route_table.webapp_route_table.id
    depends_on = [
        azurerm_route.webapp_to_cp,
    ]
}