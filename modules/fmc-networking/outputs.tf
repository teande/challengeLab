output "networks" {
  description = "Created networks"
  value = {
    branch_evpn_overlay = fmc_network.Branch-EVPN-Overlay-Main
    branch_evpn_underlay = fmc_network.Branch-EVPN-Underlay
  }
}

output "hosts" {
  description = "Created hosts"
  value = {
    aws1 = fmc_host.AWS1
    aws2 = fmc_host.AWS2
    branch_c8kv = fmc_host.BRANCH-SITE-105-C8Kv
    hq_c8kv = fmc_host.HQ-SITE10-CEDGE8Kv
    en_cat8kv = fmc_host.En-Cat8Kv
  }
}

output "static_routes" {
  description = "Created static routes"
  value = {
    internet = fmc_device_ipv4_static_route.route_to_internet
    aws1 = fmc_device_ipv4_static_route.route_to_aws1
    aws2 = fmc_device_ipv4_static_route.route_to_aws2
    branch_evpn = fmc_device_ipv4_static_route.dc_branch_evpn_route
    branch_c8kv = fmc_device_ipv4_static_route.dc_branch_c8kv_route
    hq_c8kv = fmc_device_ipv4_static_route.dc_hq_c8kv_route
  }
}
