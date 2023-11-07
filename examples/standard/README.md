
```hcl
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

            nat_rule_collection = [
        {
          name     = "natRuleCollection1"
          action   = "Dnat"
          priority = 100
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
          priority = 200
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

      application_rule_collection = [
        {
          name     = "appRuleCollection1"
          action   = "Allow"
          priority = 300
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
              source_ip_groups      = []
              destination_addresses = []
              destination_urls      = [] # Premium only
              destination_fqdns     = []
              destination_fqdn_tags = ["AzureBackup"]
              terminate_tls         = false # Premium only
              web_categories        = [] # Replace with web categories if needed # Premium only
            }
          ]
        }
      ]
    }
  ]
}
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.77.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.1 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_firewall_policy"></a> [firewall\_policy](#module\_firewall\_policy) | cyber-scot/firewall-policy/azurerm | n/a |
| <a name="module_law"></a> [law](#module\_law) | cyber-scot/log-analytics-workspace/azurerm | n/a |
| <a name="module_rg"></a> [rg](#module\_rg) | cyber-scot/rg/azurerm | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [external_external.detect_os](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.generate_timestamp](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [http_http.client_ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_Regions"></a> [Regions](#input\_Regions) | Converts shorthand name to longhand name via lookup on map list | `map(string)` | <pre>{<br>  "eus": "East US",<br>  "euw": "West Europe",<br>  "uks": "UK South",<br>  "ukw": "UK West"<br>}</pre> | no |
| <a name="input_env"></a> [env](#input\_env) | The env variable, for example - prd for production. normally passed via TF\_VAR. | `string` | `"prd"` | no |
| <a name="input_loc"></a> [loc](#input\_loc) | The loc variable, for the shorthand location, e.g. uks for UK South.  Normally passed via TF\_VAR. | `string` | `"uks"` | no |
| <a name="input_short"></a> [short](#input\_short) | The shorthand name of to be used in the build, e.g. cscot for CyberScot.  Normally passed via TF\_VAR. | `string` | `"cscot"` | no |
| <a name="input_static_tags"></a> [static\_tags](#input\_static\_tags) | The tags variable | `map(string)` | <pre>{<br>  "Contact": "info@cyber.scot",<br>  "CostCentre": "671888",<br>  "ManagedBy": "Terraform"<br>}</pre> | no |

## Outputs

No outputs.
