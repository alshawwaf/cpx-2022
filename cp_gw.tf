#Variable Processing
# Setup the userdata that will be used for the instance. The token variable is used to connect to Smart-1 Cloud

resource "null_resource" "smart-1-cloud" {
  triggers = {
    gwname    = "${var.company}-cp-gw"
    clientid  = "${var.clientid}"
    secretkey = "${var.secretkey}"
  }
  provisioner "local-exec" {
    command = "python smart-1-Cloud-API.py register -i ${var.clientid} -k ${var.secretkey}  -n ${var.company}-cp-gw > registration_token.txt"
    when    = create
  }
  provisioner "local-exec" {
    command = "python smart-1-Cloud-API.py delete -i ${self.triggers.clientid} -k ${self.triggers.secretkey}  -n ${self.triggers.gwname} > registration_token.txt"
    when    = destroy
  }
}

data "local_file" "registrationtoken" {
  depends_on = [null_resource.smart-1-cloud]
  filename   = "registration_token.txt"
}

data "template_file" "userdata_setup" {
  template = file("userdata_setup.template")

  vars = {
    sic_key = "${var.sic_key}"
    company = "${var.company}"
    token   = "${data.local_file.registrationtoken.content}"
  }
}

# Establish SIC for the deployed gateway

resource "null_resource" "smart-1-cloud-establish-sic" {
  triggers = {
    gateway                = "${var.company}-cp-gw"
    mgmt_api_key           = "${var.mgmt_api_key}"
    smart_1_cloud_instance = "${var.smart_1_cloud_instance}"
    smart_1_cloud_context  = "${var.smart_1_cloud_context}"
    # smart_1_mgmt_domain    = "${var.smart_1_mgmt_domain}"
    os_version             = "${var.os_version}"

  }
  provisioner "local-exec" {
    command = "python smart-1-Cloud-Mgmt-API.py -g ${var.company}-cp-gw -k ${var.mgmt_api_key} -i ${var.smart_1_cloud_instance} -c ${var.smart_1_cloud_context} -s ${var.sic_key} -v ${var.os_version}"
    when    = create
  }

  depends_on = [azurerm_virtual_machine.cp-gw]
}

#CP GW NICS
resource "azurerm_network_interface" "cp-gw-external" {
  name                 = "cp-gw-external"
  location             = azurerm_resource_group.smart1-cp-gw-rg.location
  resource_group_name  = azurerm_resource_group.smart1-cp-gw-rg.name
  enable_ip_forwarding = "true"
  ip_configuration {

    name                          = "cp-gw-public-ip-config"
    subnet_id                     = azurerm_subnet.cp-gw-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.gw-external-private-ip
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.cp-gw-public-ip.id
  }
}

resource "azurerm_network_interface" "cp-gw-internal" {
  name                 = "cp-gw-internal"
  location             = azurerm_resource_group.smart1-cp-gw-rg.location
  resource_group_name  = azurerm_resource_group.smart1-cp-gw-rg.name
  enable_ip_forwarding = "true"
  ip_configuration {
    name                          = "cp-gw-internal-config"
    subnet_id                     = azurerm_subnet.cp-gw-internal-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.gw-internal-private-ip
  }
}

#Associate Security Group with Internface

resource "azurerm_network_interface_security_group_association" "cp-gw-nsg-int" {
  network_interface_id      = azurerm_network_interface.cp-gw-external.id
  network_security_group_id = azurerm_network_security_group.cp-gw-nsg.id
}
resource "azurerm_network_interface_security_group_association" "cp-gw-nsg-int2" {
  network_interface_id      = azurerm_network_interface.cp-gw-internal.id
  network_security_group_id = azurerm_network_security_group.cp-gw-nsg.id
}


#CP GW Virtual Machine
resource "azurerm_virtual_machine" "cp-gw" {
  name                         = "${var.company}-cp-gw"
  location                     = azurerm_resource_group.smart1-cp-gw-rg.location
  resource_group_name          = azurerm_resource_group.smart1-cp-gw-rg.name
  network_interface_ids        = [azurerm_network_interface.cp-gw-external.id, azurerm_network_interface.cp-gw-internal.id]
  primary_network_interface_id = azurerm_network_interface.cp-gw-external.id
  vm_size                      = "Standard_D4s_v3"

  depends_on = [
    azurerm_network_interface_security_group_association.cp-gw-nsg-int,
    azurerm_network_interface_security_group_association.cp-gw-nsg-int2
  ]


  storage_os_disk {
    name              = "cp-gw-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "checkpoint"
    offer     = "check-point-cg-${var.os_version}"
    sku       = "sg-byol"
    version   = "latest"
  }

  plan {
    name      = "sg-byol"
    publisher = "checkpoint"
    product   = "check-point-cg-${var.os_version}"
  }

  os_profile {
    computer_name  = "${var.company}-cp-gw"
    admin_username = "azureuser"
    admin_password = var.password
    custom_data    = data.template_file.userdata_setup.rendered

  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = azurerm_storage_account.cp-gw-storage-account.primary_blob_endpoint
  }

}

