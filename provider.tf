
terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = "~> 1.18.1"
    }
    cloudfoundry = {
      source  = "cloudfoundry/cloudfoundry"
      version = "1.12.0"
    }
  }

}

# Please checkout documentation on how best to authenticate against SAP BTP
# via the Terraform provider for SAP BTP
provider "btp" {
  globalaccount = var.globalaccount
  username      = var.username
  password      = var.password
}

provider "cloudfoundry" {
  api_url = "https://api.cf.us10-001.hana.ondemand.com"
  #api_url  = module.development.cf_api_url
  user     = var.username
  password = var.password
}


