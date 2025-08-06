terraform {
  required_providers {
    fmc = {
      source  = "CiscoDevNet/fmc"
      version = "2.0.0-rc4"
    }
  }
}

################################################################################################
# Multi Cloud Defense (MCD) Policy Configuration
################################################################################################

# Data source for intrusion policy "Balanced Security and Connectivity"
data "fmc_intrusion_policy" "balanced_security_connectivity" {
  name = "Balanced Security and Connectivity"
}

# Create security zone "ciscomcd-vni" 
resource "fmc_security_zone" "ciscomcd_vni" {
  name           = "ciscomcd-vni"
  interface_type = "ROUTED"
}

# Create MCD Access Control Policy
resource "fmc_access_control_policy" "mcd_policy" {
  name           = "MCDFTD-Policy"
  default_action = "BLOCK"
  description    = "Multi Cloud Defense FTD Access Control Policy"
  rules = [
    {
      action = "ALLOW"
      name   = "Allow MCD Traffic"
      source_zones = [{
        id   = fmc_security_zone.ciscomcd_vni.id
        type = "SecurityZone"
      }]

      log_begin           = true
      log_end             = true
      send_events_to_fmc  = true
      send_syslog         = true
      syslog_severity     = "ALERT"
      intrusion_policy_id = data.fmc_intrusion_policy.balanced_security_connectivity.id
    }
  ]
}

# network object for MCD Task
resource "fmc_host" "developmentservercom" {
  name        = "developmentserver.com"
  ip          = "66.96.146.102"
  description = "Development Server network segment"
}
