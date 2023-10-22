module "rg" {
  source = "cyber-scot/rg/azurerm"

  name     = "rg-${var.short}-${var.loc}-${var.env}-01"
  location = local.location
  tags     = local.tags
}


module "law" {
  source = "cyber-scot/log-analytics-workspace/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  create_new_workspace       = true
  name                       = "law-${var.short}-${var.loc}-${var.env}-01"
  sku                        = "PerNode"
  retention_in_days          = "30"
  daily_quota_gb             = "0.5"
  internet_ingestion_enabled = false
  internet_query_enabled     = false
}

module "firewall_policy" {
  source = "../../"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  name          = "fwpol-${var.short}-${var.loc}-${var.env}-01"
  identity_type = "SystemAssigned"

  dns = [
    {
      proxy_enabled = false
      servers       = ["8.8.8.8", "8.8.4.4"]
    }
  ]

  intrusion_detection = [
    {
      mode           = "Alert"
      private_ranges = ["10.0.0.0/16"]
    }
  ]

  insights = [
    {

      retention_in_days = "30"
    }
  ]

  explict_proxy = [
    {
      enabled    = true
      http_port  = 80
      https_port = 443
    }
  ]

  threat_intelligence_allowlist = [
    {
      fqdns        = ["example.com"]
      ip_addresses = ["203.0.113.0"]
    }
  ]

  tls_certificate = [
    {
      key_vault_secret_id = "https://myvault.vault.azure.net/secrets/mysecret/abc123"
      name                = "my-tls-certificate"
    }
  ]
}
