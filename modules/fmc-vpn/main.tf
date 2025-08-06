terraform {
  required_providers {
    fmc = {
      source  = "CiscoDevNet/fmc"
      version = "2.0.0-rc4"
    }
  }
}

################################################################################################
# VPN Site-to-Site Tunnels
################################################################################################

# AWS1 VPN Site-to-Site Tunnel
resource "fmc_vpn_s2s" "aws1_tunnel" {
  name             = "AWS_Tunnel_1"
  route_based      = true
  network_topology = "POINT_TO_POINT"
  ikev1            = false
  ikev2            = true
}

# AWS2 VPN Site-to-Site Tunnel
resource "fmc_vpn_s2s" "aws2_tunnel" {
  name             = "AWS_Tunnel_2"
  route_based      = true
  network_topology = "POINT_TO_POINT"
  ikev1            = false
  ikev2            = true
}

# Secure Access VPN to ISE Tunnel
resource "fmc_vpn_s2s" "secure_access_tunnel" {
  name             = "SecureAccessToISE"
  route_based      = true
  network_topology = "POINT_TO_POINT"
  ikev1            = false
  ikev2            = true
}

################################################################################################
# IKEv2 Settings for VPN Tunnels
################################################################################################

# IKEv2 Settings for both AWS tunnels
resource "fmc_vpn_s2s_ike_settings" "ike_settings" {
  count                                  = 2
  vpn_s2s_id                             = count.index == 0 ? fmc_vpn_s2s.aws1_tunnel.id : fmc_vpn_s2s.aws2_tunnel.id
  ikev2_authentication_type              = "MANUAL_PRE_SHARED_KEY"
  ikev2_manual_pre_shared_key            = "Cisco@123"
  ikev2_enforce_hex_based_pre_shared_key = false

  depends_on = [
    fmc_vpn_s2s.aws1_tunnel,
    fmc_vpn_s2s.aws2_tunnel
  ]
}

# IKE Settings for Secure Access tunnel
resource "fmc_vpn_s2s_ike_settings" "ike_settings_secure_access" {
  vpn_s2s_id                             = fmc_vpn_s2s.secure_access_tunnel.id
  ikev2_authentication_type              = "MANUAL_PRE_SHARED_KEY"
  ikev2_manual_pre_shared_key            = "Cisco@123"
  ikev2_enforce_hex_based_pre_shared_key = false

  depends_on = [
    fmc_vpn_s2s.secure_access_tunnel
  ]
}

################################################################################################
# VPN S2S Endpoints
################################################################################################

# Endpoints for AWS1 tunnel
resource "fmc_vpn_s2s_endpoints" "endpoints1" {
  vpn_s2s_id = fmc_vpn_s2s.aws1_tunnel.id

  items = {
    # Node A - Internal FTD device
    internal_node = {
      peer_type                   = "PEER"
      extranet_device             = false
      device_id                   = var.devices[0].id
      interface_id                = var.vti_interfaces.vti_1.id
      connection_type             = "BIDIRECTIONAL"
      allow_incoming_ikev2_routes = true
    }

    # Node B - Extranet AWS device
    AWS_Node_1 = {
      peer_type                   = "PEER"
      extranet_device             = true
      extranet_dynamic_ip         = false
      extranet_ip_address         = "203.0.113.10"
      connection_type             = "BIDIRECTIONAL"
      allow_incoming_ikev2_routes = true
    }
  }

  depends_on = [
    fmc_vpn_s2s.aws1_tunnel,
    fmc_vpn_s2s.aws2_tunnel,
    fmc_vpn_s2s_ike_settings.ike_settings,
    var.devices,
    var.vti_interfaces
  ]
}

# Endpoints for AWS2 tunnel
resource "fmc_vpn_s2s_endpoints" "endpoints2" {
  vpn_s2s_id = fmc_vpn_s2s.aws2_tunnel.id

  items = {
    # Node A - Internal FTD device
    internal_node = {
      peer_type                   = "PEER"
      extranet_device             = false
      device_id                   = var.devices[0].id
      interface_id                = var.vti_interfaces.vti_2.id
      connection_type             = "BIDIRECTIONAL"
      allow_incoming_ikev2_routes = true
    }

    # Node B - Extranet AWS device
    AWS_Node_2 = {
      peer_type                   = "PEER"
      extranet_device             = true
      extranet_dynamic_ip         = false
      extranet_ip_address         = "203.0.113.20"
      connection_type             = "BIDIRECTIONAL"
      allow_incoming_ikev2_routes = true
    }
  }

  depends_on = [
    fmc_vpn_s2s.aws1_tunnel,
    fmc_vpn_s2s.aws2_tunnel,
    fmc_vpn_s2s_ike_settings.ike_settings,
    var.devices,
    var.vti_interfaces
  ]
}

# Endpoints for Secure Access tunnel
resource "fmc_vpn_s2s_endpoints" "endpoints3" {
  vpn_s2s_id = fmc_vpn_s2s.secure_access_tunnel.id

  items = {
    # Node A - Internal FTD device
    internal_node = {
      peer_type                   = "PEER"
      extranet_device             = false
      device_id                   = var.devices[0].id
      interface_id                = var.vti_interfaces.vti_3.id
      connection_type             = "BIDIRECTIONAL"
      allow_incoming_ikev2_routes = true
      local_identity_type         = "EMAILID"
      local_identity_string       = "me@cisco.com"
    }

    # Node B - Extranet device
    Extranet = {
      peer_type                   = "PEER"
      extranet_device             = true
      extranet_dynamic_ip         = false
      extranet_ip_address         = "1.1.1.1"
      connection_type             = "BIDIRECTIONAL"
      allow_incoming_ikev2_routes = true
    }
  }

  depends_on = [
    fmc_vpn_s2s.secure_access_tunnel,
    fmc_vpn_s2s_ike_settings.ike_settings_secure_access,
    var.devices,
    var.vti_interfaces
  ]
}
