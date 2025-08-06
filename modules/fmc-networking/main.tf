terraform {
  required_providers {
    fmc = {
      source  = "CiscoDevNet/fmc"
      version = "2.0.0-rc4"
    }
  }
}

################################################################################################
# Network objects Data objects
################################################################################################
data "fmc_network" "ipv4-private-10_0_0_0-8" {
  name = "IPv4-Private-10.0.0.0-8"
}

data "fmc_network" "any-ipv4" {
  name = "any-ipv4"
}

data "fmc_host" "ExtGW" {
  depends_on = [
    var.wait_for_onboarding,
    var.devices,
    var.physical_interfaces
  ]
  name = "ExtGW"
}

################################################################################################
# Network objects Resources
################################################################################################
resource "fmc_network" "Branch-EVPN-Overlay-Main" {
  depends_on  = [var.devices]
  name        = "Branch-EVPN-Overlay-Main"
  prefix      = "10.10.255.0/24"
  description = "Main branch EVPN overlay network"
}

resource "fmc_network" "Branch-EVPN-Underlay" {
  depends_on  = [var.devices]
  name        = "Branch-EVPN-Underlay"
  prefix      = "172.30.255.0/24"
  description = "Branch EVPN underlay network"
}

resource "fmc_network" "Coinforge1_net" {
  depends_on  = [var.devices]
  name        = "Coinforge1_net"
  prefix      = "10.104.255.0/24"
  description = "Coinforge1 network"
}

resource "fmc_host" "BRANCH-SITE-105-C8Kv" {
  depends_on = [data.fmc_host.ExtGW]
  name       = "BRANCH-SITE-105-C8Kv"
  ip         = "100.100.10.105"
}

resource "fmc_host" "HQ-SITE10-CEDGE8Kv" {
  depends_on = [data.fmc_host.ExtGW]
  name       = "HQ-SITE10-CEDGE8Kv"
  ip         = "100.100.10.10"
}

resource "fmc_host" "En-Cat8Kv" {
  depends_on = [data.fmc_host.ExtGW]
  name       = "En-Cat8Kv"
  ip         = "198.18.8.1"
}

resource "fmc_host" "AWS1" {
  depends_on = [data.fmc_host.ExtGW]
  name       = "169.254.6.1_AWS1"
  ip         = "169.254.6.1"
}

resource "fmc_host" "AWS2" {
  depends_on = [data.fmc_host.ExtGW]
  name       = "169.254.6.5_AWS2"
  ip         = "169.254.6.5"
}

################################################################################################
# DC Firewall Static Routes
################################################################################################

# Static route to Internet
resource "fmc_device_ipv4_static_route" "route_to_internet" {
  device_id              = var.devices[0].id
  interface_logical_name = "INTERNET"
  interface_id           = var.physical_interfaces[2].id
  destination_networks = [{
    id = data.fmc_network.any-ipv4.id
  }]
  gateway_host_object_id = data.fmc_host.ExtGW.id

  depends_on = [
    var.devices,
    var.physical_interfaces,
    data.fmc_host.ExtGW
  ]
}

resource "fmc_device_ipv4_static_route" "route_to_aws1" {
  device_id              = var.devices[0].id
  interface_logical_name = "WAN_static_vti_1"
  interface_id           = var.vti_interfaces.vti_1.id
  destination_networks = [
    {
      id = data.fmc_network.ipv4-private-10_0_0_0-8.id
    }
  ]
  gateway_host_object_id = fmc_host.AWS1.id
  metric_value           = 1

  depends_on = [
    var.devices,
    var.vti_interfaces,
    fmc_host.AWS1
  ]
}

resource "fmc_device_ipv4_static_route" "route_to_aws2" {
  device_id              = var.devices[0].id
  interface_logical_name = "WAN_static_vti_2"
  interface_id           = var.vti_interfaces.vti_2.id
  destination_networks = [
    {
      id = data.fmc_network.ipv4-private-10_0_0_0-8.id
    }
  ]
  metric_value           = 2
  gateway_host_object_id = fmc_host.AWS2.id

  depends_on = [
    var.devices,
    var.vti_interfaces,
    fmc_host.AWS2
  ]
}

resource "fmc_device_ipv4_static_route" "dc_branch_evpn_route" {
  device_id              = var.devices[0].id
  interface_logical_name = "WAN"
  interface_id           = var.physical_interfaces[0].id
  destination_networks = [{
    id = fmc_network.Branch-EVPN-Overlay-Main.id
    }, {
    id = fmc_network.Branch-EVPN-Underlay.id
  }]
  gateway_host_literal = "198.18.8.1"
  metric_value         = 1

  depends_on = [
    var.devices,
    var.physical_interfaces,
    fmc_network.Branch-EVPN-Overlay-Main,
    fmc_network.Branch-EVPN-Underlay
  ]
}

resource "fmc_device_ipv4_static_route" "dc_branch_c8kv_route" {
  device_id              = var.devices[0].id
  interface_logical_name = "WAN"
  interface_id           = var.physical_interfaces[0].id
  destination_networks = [
    {
      id = fmc_host.BRANCH-SITE-105-C8Kv.id
    }
  ]
  gateway_host_literal = "198.18.8.1"
  metric_value         = 1

  depends_on = [
    var.devices,
    var.physical_interfaces,
    fmc_host.BRANCH-SITE-105-C8Kv
  ]
}

resource "fmc_device_ipv4_static_route" "dc_hq_c8kv_route" {
  device_id              = var.devices[0].id
  interface_logical_name = "WAN"
  interface_id           = var.physical_interfaces[0].id
  destination_networks = [
    {
      id = fmc_host.HQ-SITE10-CEDGE8Kv.id
    }
  ]
  gateway_host_literal = "198.18.8.1"
  metric_value         = 1

  depends_on = [
    var.devices,
    var.physical_interfaces,
    fmc_host.HQ-SITE10-CEDGE8Kv
  ]
}

resource "fmc_device_ipv4_static_route" "dc_en_cat8kv_route" {
  device_id              = var.devices[0].id
  interface_logical_name = "WAN"
  interface_id           = var.physical_interfaces[0].id
  destination_networks = [
    {
      id = fmc_network.Coinforge1_net.id
    }
  ]
  gateway_host_object_id = fmc_host.En-Cat8Kv.id

  depends_on = [
    var.devices,
    var.physical_interfaces,
    fmc_network.Coinforge1_net,
    fmc_host.En-Cat8Kv
  ]
}
