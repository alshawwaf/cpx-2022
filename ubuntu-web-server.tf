# Create Network Card for linux VM
resource "azurerm_network_interface" "ubuntu-nic" {
  depends_on=[azurerm_resource_group.smart1-cp-gw-rg]

  name                = "ubuntu-nic"
  location            = azurerm_resource_group.smart1-cp-gw-rg.location
  resource_group_name = azurerm_resource_group.smart1-cp-gw-rg.name
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.webapp_subnet.id
    private_ip_address_allocation = "Dynamic"
 
  }

  tags = { 
    environment = var.environment
  }
}

# Create Linux VM with linux server
resource "azurerm_linux_virtual_machine" "ubuntu-vm" {
  depends_on=[azurerm_network_interface.ubuntu-nic]

  location              = azurerm_resource_group.smart1-cp-gw-rg.location
  resource_group_name   = azurerm_resource_group.smart1-cp-gw-rg.name
  name                  = "Ubuntu-web-server"
  network_interface_ids = [azurerm_network_interface.ubuntu-nic.id]
  size                  = "Standard_B1s"

  source_image_reference {

    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS" 
    version   = "latest"
  }


  os_disk {
    name                 = "ubuntu-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  computer_name  = "ubuntu-vm"
  admin_username = "tfadmin"
  admin_password = "Vpn123vpn123!"
  custom_data    = base64encode(data.template_file.ubuntu-cloud-init.rendered)

  disable_password_authentication = false

  tags = {
    environment = var.environment
  }
}

data "template_file" "ubuntu-cloud-init" {
  template = file("ubuntu-user-data.sh")
}