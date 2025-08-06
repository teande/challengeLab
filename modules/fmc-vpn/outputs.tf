output "vpn_tunnels" {
  description = "VPN S2S tunnels"
  value = {
    aws1 = fmc_vpn_s2s.aws1_tunnel
    aws2 = fmc_vpn_s2s.aws2_tunnel
  }
}

output "ike_settings" {
  description = "IKE settings"
  value       = fmc_vpn_s2s_ike_settings.ike_settings
}

output "endpoints" {
  description = "VPN endpoints"
  value = {
    endpoints1 = fmc_vpn_s2s_endpoints.endpoints1
    endpoints2 = fmc_vpn_s2s_endpoints.endpoints2
    endpoints3 = fmc_vpn_s2s_endpoints.endpoints3
  }
}
