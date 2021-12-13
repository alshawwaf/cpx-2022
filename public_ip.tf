#CP Gateway Public IP

resource "azurerm_public_ip" "cp-gw-public-ip" {
    name                         = "cp-gw-public-ip"
    location                     = azurerm_resource_group.smart1-cp-gw-rg.location
    resource_group_name          = azurerm_resource_group.smart1-cp-gw-rg.name
    allocation_method = "Static"
}

# Output the public ip of the gateway

output "CP_Gateway_Public_IP" {
    value = azurerm_public_ip.cp-gw-public-ip.ip_address
}