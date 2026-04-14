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

  service_name_prefix = lower(replace("${var.project_stage}-${var.project_name}", " ", "-"))

  # Development Tools
  service_name__postresgl = "postgresql-db"
  service_plan__postresgl = "trial"
}


# Entitlements for PostgreSQL Trial
resource "btp_subaccount_entitlement" "postgresql" {
  subaccount_id = var.subaccount_id
  
  service_name  = local.service_name__postresgl
  plan_name     = local.service_plan__postresgl

  amount        = 1
}

#Cloud Foundry Service Instance for plan for PostgreSQL Trial
data "cloudfoundry_service_plan" "postgresql" {
  name                  = local.service_plan__postresgl
  service_offering_name = local.service_name__postresgl

  depends_on = [ btp_subaccount_entitlement.postgresql ]
}

# Managed service instance without parameters
resource "cloudfoundry_service_instance" "postgresql" {
  name         = "cf-db-postgresql"
  type         = "managed"
  space        = var.cf_space_id
  service_plan = data.cloudfoundry_service_plan.postgresql.id
  timeouts = {
    create = "45m"
    update = "30m"
    delete = "30m"
  }

  depends_on = [ data.cloudfoundry_service_plan.postgresql ]
}
