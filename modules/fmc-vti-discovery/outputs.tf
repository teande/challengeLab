output "vti_interfaces" {
  description = "Discovered VTI interfaces"
  value = {
    vti_1 = data.fmc_device_vti_interface.WAN_static_vti_1
    vti_2 = data.fmc_device_vti_interface.WAN_static_vti_2
    vti_3 = data.fmc_device_vti_interface.to_secure_access
    vti_4 = data.fmc_device_vti_interface.WAN_dynamic_vti_1
  }
}

output "netflow_group" {
  description = "Discovered NetFlowGrp interface group"
  value       = data.fmc_interface_group.NetFlowGrp
}

output "netflow_group_id" {
  description = "NetFlowGrp interface group ID"
  value       = data.fmc_interface_group.NetFlowGrp.id
}
