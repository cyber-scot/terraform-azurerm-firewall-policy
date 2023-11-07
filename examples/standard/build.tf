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
  sku                        = "PerGB2018"
  retention_in_days          = "30"
  daily_quota_gb             = "0.5"
  internet_ingestion_enabled = false
  internet_query_enabled     = false
}

module "firewall_policy" {
  source = "cyber-scot/firewall-policy/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  name = "fwpol-${var.short}-${var.loc}-${var.env}-01"

  dns = [
    {
      proxy_enabled = false
      servers       = ["8.8.8.8", "8.8.4.4"]
    }
  ]

  insights = [
    {
      default_log_analytics_workspace_id = module.law.law_id
      retention_in_days                  = "30"
    }
  ]

  explict_proxy = [
    {
      enabled    = true
      http_port  = 8080
      https_port = 8443
    }
  ]

  threat_intelligence_allowlist = [
    {
      fqdns        = ["example.com"]
      ip_addresses = ["203.0.113.0"]
    }
  ]

  rule_collection_groups = [
    {
      name               = "exampleRuleCollectionGroup"
      firewall_policy_id = null # Replace with a specific firewall policy ID if needed
      priority           = 100

      application_rule_collection = [
        {
          name     = "appRuleCollection1"
          action   = "Allow"
          priority = 100
          rule = [
            {
              name        = "appRule1"
              description = "Example application rule"
              protocols = [
                {
                  type = "Http"
                  port = "80"
                },
                {
                  type = "Https"
                  port = "443"
                }
              ]
              source_addresses      = ["10.0.0.0/24"]
              source_ip_groups      = [] # Replace with source IP group references if available
              destination_addresses = [] # Replace with destination addresses if needed
              destination_urls      = ["www.example.com"]
              destination_fqdns     = [] # Replace with FQDNs if needed
              destination_fqdn_tags = [] # Replace with FQDN tags if needed
              terminate_tls         = false
              web_categories        = [] # Replace with web categories if needed
            }
          ]
        }
      ]

      nat_rule_collection = [
        {
          name     = "natRuleCollection1"
          action   = "Dnat"
          priority = 200
          rule = [
            {
              name                = "natRule1"
              description         = "Example NAT rule"
              protocols           = ["TCP"]
              source_addresses    = ["10.0.1.0/24"]
              source_ip_groups    = [] # Replace with source IP group references if available
              destination_address = "192.0.2.1"
              destination_ports   = ["8080"]
              translated_address  = "10.0.2.1"
              translated_fqdn     = null
              translated_port     = "80"
            }
          ]
        }
      ]

      network_rule_collection = [
        {
          name     = "networkRuleCollection1"
          action   = "Allow"
          priority = 300
          rule = [
            {
              name                  = "networkRule1"
              description           = "Example network rule"
              protocols             = ["TCP", "UDP"]
              source_addresses      = ["10.0.3.0/24"]
              source_ip_groups      = [] # Replace with source IP group references if available
              destination_addresses = ["192.0.2.2"]
              destination_ports     = ["1000", "2000"]
              destination_ip_groups = [] # Replace with destination IP group references if available
              destination_fqdns     = [] # Replace with FQDNs if needed
            }
          ]
        }
      ]
    }
  ]
}
