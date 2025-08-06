terraform {
  required_providers {
    fmc = {
      source  = "CiscoDevNet/fmc"
      version = "2.0.0-rc4"
    }
  }
}

################################################################################################
# Physical Interfaces Data Sources
################################################################################################
data "fmc_device_physical_interface" "dc_phy_interfaces" {
  depends_on = [var.devices]
  count      = 7
  device_id  = var.devices[0].id
  name       = "GigabitEthernet0/${count.index}"
}

################################################################################################
# Loopback Interface Data Source
################################################################################################
data "fmc_device_loopback_interface" "loopback" {
  depends_on = [var.wait_for_onboarding, var.devices]
  device_id  = var.devices[0].id
  name       = "Loopback1"
}

################################################################################################
# DC Firewall Physical Interfaces
################################################################################################

# WAN Interface
resource "fmc_device_physical_interface" "dc_g0_0" {
  device_id                = var.devices[0].id
  name                     = "GigabitEthernet0/0"
  logical_name             = "WAN"
  description              = "PHY-Interface G0/0"
  mode                     = "NONE"
  enabled                  = true
  security_zone_id         = var.security_zones.WAN.id
  ipv4_static_address      = "198.18.8.2"
  ipv4_static_netmask      = "24"
  enable_sgt_propagate     = true
  ip_based_monitoring      = true
  ip_based_monitoring_type = "AUTO"

  depends_on = [
    var.devices,
    var.security_zones
  ]
}

# DMZ Interface
resource "fmc_device_physical_interface" "dc_g0_1" {
  device_id                = var.devices[0].id
  name                     = "GigabitEthernet0/1"
  logical_name             = "DMZ"
  description              = "PHY-Interface G0/1"
  mode                     = "NONE"
  enabled                  = true
  security_zone_id         = var.security_zones.DMZ.id
  ipv4_static_address      = "198.18.9.1"
  ipv4_static_netmask      = "24"
  enable_sgt_propagate     = true
  ip_based_monitoring      = true
  ip_based_monitoring_type = "AUTO"

  depends_on = [
    var.devices,
    var.security_zones
  ]
}

# Internet Interface
resource "fmc_device_physical_interface" "dc_g0_2" {
  device_id                = var.devices[0].id
  name                     = "GigabitEthernet0/2"
  logical_name             = "INTERNET"
  description              = "PHY-Interface G0/2"
  mode                     = "NONE"
  enabled                  = true
  security_zone_id         = var.security_zones.INTERNET.id
  ipv4_static_address      = "198.18.3.2"
  ipv4_static_netmask      = "24"
  enable_sgt_propagate     = false
  ip_based_monitoring      = true
  ip_based_monitoring_type = "AUTO"

  depends_on = [
    var.devices,
    var.security_zones
  ]
}

# Data Center Interface
resource "fmc_device_physical_interface" "dc_g0_3" {
  device_id                = var.devices[0].id
  name                     = "GigabitEthernet0/3"
  logical_name             = "DATA-CENTER"
  description              = "PHY-Interface G0/3"
  mode                     = "NONE"
  enabled                  = true
  security_zone_id         = var.security_zones.DATA_CENTER.id
  ipv4_static_address      = "198.18.5.1"
  ipv4_static_netmask      = "24"
  enable_sgt_propagate     = false
  ip_based_monitoring      = true
  ip_based_monitoring_type = "AUTO"

  depends_on = [
    var.devices,
    var.security_zones
  ]
}

# Attacker Interface
resource "fmc_device_physical_interface" "dc_g0_4" {
  device_id            = var.devices[0].id
  name                 = "GigabitEthernet0/4"
  logical_name         = "ATTACKER"
  description          = "ATTACKER"
  mode                 = "NONE"
  enabled              = true
  security_zone_id     = var.security_zones.ATTACKER.id
  ipv4_static_address  = "198.18.14.1"
  ipv4_static_netmask  = "24"
  enable_sgt_propagate = false
  ip_based_monitoring  = false

  depends_on = [
    var.devices,
    var.security_zones
  ]
}

# Transport Interface
resource "fmc_device_physical_interface" "dc_g0_5" {
  device_id            = var.devices[0].id
  name                 = "GigabitEthernet0/5"
  logical_name         = "Transport"
  description          = "Transport"
  mode                 = "NONE"
  enabled              = true
  security_zone_id     = var.security_zones.TRANSPORT.id
  ipv4_static_address  = "198.18.12.1"
  ipv4_static_netmask  = "24"
  enable_sgt_propagate = false
  ip_based_monitoring  = false

  depends_on = [
    var.devices,
    var.security_zones
  ]

  lifecycle {
    ignore_changes = [
      logical_name,
      description,
      mode,
      enabled,
      ipv4_static_address,
      ipv4_static_netmask,
      enable_sgt_propagate,
      ip_based_monitoring,
    ]
  }
}

# Application Network Interface
resource "fmc_device_physical_interface" "dc_g0_6" {
  device_id                = var.devices[0].id
  name                     = "GigabitEthernet0/6"
  logical_name             = "APP"
  description              = "Application Network"
  mode                     = "NONE"
  enabled                  = true
  security_zone_id         = var.security_zones.APPS.id
  ipv4_static_address      = "198.18.11.1"
  ipv4_static_netmask      = "24"
  enable_sgt_propagate     = false
  ip_based_monitoring      = true
  ip_based_monitoring_type = "AUTO"

  depends_on = [
    var.devices,
    var.security_zones
  ]
}

################################################################################################
# DC Firewall VTI Interfaces
################################################################################################

# VTI Interface Resources (these will be imported via the deploy script)
resource "fmc_device_vti_interface" "WAN_static_vti_1" {
  device_id                         = var.devices[0].id
  tunnel_type                       = "STATIC"
  logical_name                      = "WAN_static_vti_1"
  enabled                           = true
  description                       = "WAN Static VTI 1"
  security_zone_id                  = var.security_zones.DCtoMCD.id
  priority                          = 0
  tunnel_id                         = 1
  tunnel_source_interface_id        = fmc_device_physical_interface.dc_g0_2.id
  tunnel_source_interface_name      = "GigabitEthernet0/2"
  tunnel_mode                       = "ipv4"
  ipv4_address                      = "169.254.6.2"
  ipv4_netmask                      = "30"
  ip_based_monitoring               = false
  http_based_application_monitoring = true

  depends_on = [
    var.devices,
    var.security_zones,
    fmc_device_physical_interface.dc_g0_2
  ]
}

resource "fmc_device_vti_interface" "WAN_static_vti_2" {
  device_id                         = var.devices[0].id
  tunnel_type                       = "STATIC"
  logical_name                      = "WAN_static_vti_2"
  enabled                           = true
  description                       = "WAN Static VTI 2"
  security_zone_id                  = var.security_zones.DCtoMCD.id
  priority                          = 0
  tunnel_id                         = 2
  tunnel_source_interface_id        = fmc_device_physical_interface.dc_g0_2.id
  tunnel_source_interface_name      = "GigabitEthernet0/2"
  tunnel_mode                       = "ipv4"
  ipv4_address                      = "169.254.6.6"
  ipv4_netmask                      = "30"
  ip_based_monitoring               = false
  http_based_application_monitoring = true

  depends_on = [
    var.devices,
    var.security_zones,
    fmc_device_physical_interface.dc_g0_2
  ]
}

resource "fmc_device_vti_interface" "ToSecureAccess" {
  device_id                         = var.devices[0].id
  tunnel_type                       = "STATIC"
  logical_name                      = "ToSecureAccess"
  enabled                           = true
  description                       = "To Secure Access"
  security_zone_id                  = var.security_zones.SecureAccess.id
  priority                          = 0
  tunnel_id                         = 3
  tunnel_source_interface_id        = fmc_device_physical_interface.dc_g0_2.id
  tunnel_source_interface_name      = "GigabitEthernet0/2"
  tunnel_mode                       = "ipv4"
  ipv4_address                      = "169.254.0.10"
  ipv4_netmask                      = "30"
  ip_based_monitoring               = false
  http_based_application_monitoring = true

  depends_on = [
    var.devices,
    var.security_zones,
    fmc_device_physical_interface.dc_g0_2
  ]
}

resource "fmc_device_vti_interface" "WAN_dynamic_vti_1" {
  device_id                    = var.devices[0].id
  tunnel_type                  = "DYNAMIC"
  logical_name                 = "WAN_dynamic_vti_1"
  enabled                      = true
  description                  = "WAN Dynamic VTI 1"
  security_zone_id             = var.security_zones.TUNNEL_ZONE.id
  tunnel_id                    = 1
  tunnel_mode                  = "ipv4"
  tunnel_source_interface_id   = fmc_device_physical_interface.dc_g0_5.id
  tunnel_source_interface_name = "GigabitEthernet0/5"
  borrow_ip_interface_id       = data.fmc_device_loopback_interface.loopback.id
  borrow_ip_interface_name     = data.fmc_device_loopback_interface.loopback.name

  depends_on = [
    var.devices,
    var.security_zones,
    fmc_device_physical_interface.dc_g0_5,
    data.fmc_device_loopback_interface.loopback
  ]
}
