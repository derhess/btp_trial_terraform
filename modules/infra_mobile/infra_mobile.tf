terraform {
  required_providers {
    cloudfoundry = {
      source  = "cloudfoundry/cloudfoundry"
    }
    btp = {
      source = "SAP/btp"
    }
  }
}


# ------------------------------------------------------------------------------------------------------
# Setup Variables
# ------------------------------------------------------------------------------------------------------
locals {
    service_name__mobile_services = "mobile-services"
    service_plan__mobile_services = "lite"
}
# ------------------------------------------------------------------------------------------------------
# Mobile Services (CROSS-PLATFORM Service) depends on Cloud Foundry Runtime 
# ------------------------------------------------------------------------------------------------------

# Requirements for Mobile Services
# - XSUAA Service Instance for API Access (planname = apiaccess)

# Entitle
resource "btp_subaccount_entitlement" "mobile_services" {
  subaccount_id = var.subaccount_id

  service_name  = local.service_name__mobile_services
  plan_name     = local.service_plan__mobile_services
  #amount        = var.service_plan__mobile_services == "free" ? 1 : null
  amount        = 1
}
# Subscribe

data "cloudfoundry_service_plan" "mobile_services" {
  service_offering_name = local.service_name__mobile_services
  name                  = local.service_plan__mobile_services

  depends_on = [ btp_subaccount_entitlement.mobile_services ]
}


# Instance creation
resource "cloudfoundry_service_instance" "mobile_services" {
  
  name         = local.service_name__mobile_services
  service_plan = data.cloudfoundry_service_plan.mobile_services.id
  
  space        = var.cf_space_id

  type         = "managed"
  
  timeouts = {
    create = "30m"
    delete = "30m"
    update = "30m"
  }

  depends_on = [ data.cloudfoundry_service_plan.mobile_services ]
}