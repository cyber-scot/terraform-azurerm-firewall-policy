
```hcl
resource "azurerm_firewall_policy" "firewall_policy" {
  name                              = var.name
  resource_group_name               = var.rg_name
  location                          = var.location
  tags                              = var.tags
  base_policy_id                    = var.base_policy_id
  private_ip_ranges                 = var.private_ip_ranges
  auto_learn_private_ranges_enabled = var.auto_learn_private_ranges_enabled
  sku                               = var.sku
  sql_redirect_allowed              = var.sql_redirect_allowed

  dynamic "dns" {
    for_each = var.dns != null ? var.dns : []
    content {
      proxy_enabled = dns.value.proxy_enabled
      servers       = toset(dns.value.servers)
    }
  }

  dynamic "insights" {
    for_each = var.insights != null ? var.insights : []
    content {
      default_log_analytics_workspace_id = insights.value.default_log_analytics_workspace_id
      enabled                            = try(insights.value.enabled, true)
      retention_in_days                  = insights.value.retention_in_days

      dynamic "log_analytics_workspace" {
        for_each = insights.value.log_analytics_workspace != null ? [insights.value.log_analytics_workspace] : []
        content {
          id                = log_analytics_workspace.value.id
          firewall_location = try(log_analytics_workspace.value.firewall_location, var.location)
        }
      }
    }
  }

  dynamic "threat_intelligence_allowlist" {
    for_each = var.threat_intelligence_allowlist != null ? var.threat_intelligence_allowlist : []
    content {
      fqdns        = threat_intelligence_allowlist.value.fqdns
      ip_addresses = threat_intelligence_allowlist.value.ip_addresses
    }
  }

  dynamic "tls_certificate" {
    for_each = var.tls_certificate != null ? var.tls_certificate : []
    content {
      key_vault_secret_id = tls_certificate.value.key_vault_secret_id
      name                = tls_certificate.value.name
    }
  }

  dynamic "intrusion_detection" {
    for_each = var.intrusion_detection != null ? var.intrusion_detection : []
    content {
      mode           = intrusion_detection.value.mode
      private_ranges = toset(intrusion_detection.value.private_ranges)

      dynamic "signature_overrides" {
        for_each = intrusion_detection.value.signature_overrides != null ? intrusion_detection.value.signature_overrides : []

        content {
          id    = signature_overrides.value.id
          state = signature_overrides.value.state
        }
      }

      dynamic "traffic_bypass" {
        for_each = intrusion_detection.value.traffic_bypass != null ? intrusion_detection.value.traffic_bypass : []
        content {
          name                  = traffic_bypass.value.name
          protocol              = traffic_bypass.value.protocol
          description           = traffic_bypass.value.description
          destination_addresses = traffic_bypass.value.destination_addresses
          destination_ip_groups = traffic_bypass.value.destination_ip_groups
          destination_ports     = traffic_bypass.value.destination_ports
          source_addresses      = traffic_bypass.value.source_addresses
          source_ip_groups      = traffic_bypass.value.source_ip_groups
        }
      }
    }
  }

  dynamic "explicit_proxy" {
    for_each = var.explict_proxy != null ? var.explict_proxy : []
    content {
      enabled         = explicit_proxy.value.enabled
      http_port       = explicit_proxy.value.http_port
      https_port      = explicit_proxy.value.https_port
      enable_pac_file = explicit_proxy.value.enable_pac_file
      pac_file_port   = explicit_proxy.value.pac_file_port
      pac_file        = explicit_proxy.value.pac_file_sas_url
    }
  }

  dynamic "identity" {
    for_each = var.identity_type == "UserAssigned" ? [var.identity_type] : []
    content {
      type         = var.identity_type
      identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : []
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "rule_collection_groups" {

  for_each           = { for k, v in var.rule_collection_groups : k => v if v.create_and_attach_rule_collection == true }
  name               = each.value.name
  firewall_policy_id = each.value.firewall_policy_id != null ? each.value.firewall_policy_id : azurerm_firewall_policy.firewall_policy.id
  priority           = each.value.priority



  dynamic "application_rule_collection" {
    for_each = each.value.application_rule_collection
    content {
      name     = application_rule_collection.value.name
      action   = application_rule_collection.value.action
      priority = application_rule_collection.value.priority


      dynamic "rule" {
        for_each = application_rule_collection.value.rule
        content {
          name                  = rule.value.name
          description           = rule.value.description
          source_addresses      = rule.value.source_addresses
          source_ip_groups      = rule.value.source_ip_groups
          destination_addresses = rule.value.destination_addresses
          destination_urls      = rule.value.destination_urls
          destination_fqdns     = rule.value.destination_fqdns
          destination_fqdn_tags = rule.value.destination_fqdn_tags
          terminate_tls         = rule.value.terminate_tls
          web_categories        = rule.value.web_categories

          dynamic "protocols" {
            for_each = rule.value.protocols
            content {
              type = protocols.value.type
              port = protocols.value.port
            }
          }
        }
      }
    }
  }

  dynamic "nat_rule_collection" {
    for_each = each.value.nat_rule_collection
    content {
      name     = nat_rule_collection.value.name
      action   = title(nat_rule_collection.value.action)
      priority = nat_rule_collection.value.priority

      dynamic "rule" {
        for_each = nat_rule_collection.value.rule
        content {
          name                = rule.value.name
          description         = rule.value.description
          protocols           = rule.value.protocols
          source_addresses    = rule.value.source_addresses
          source_ip_groups    = rule.value.source_ip_groups
          destination_address = rule.value.destination_address
          destination_ports   = rule.value.destination_ports
          translated_address  = rule.value.translated_address
          translated_fqdn     = rule.value.translated_fqdn
          translated_port     = rule.value.translated_port
        }
      }
    }
  }

  dynamic "network_rule_collection" {
    for_each = each.value.network_rule_collection
    content {
      name     = network_rule_collection.value.name
      action   = network_rule_collection.value.action
      priority = network_rule_collection.value.priority

      dynamic "rule" {
        for_each = network_rule_collection.value.rule
        content {
          name                  = rule.value.name
          description           = rule.value.description
          protocols             = rule.value.protocols
          source_addresses      = rule.value.source_addresses
          source_ip_groups      = rule.value.source_ip_groups
          destination_addresses = rule.value.destination_addresses
          destination_ports     = rule.value.destination_ports
          destination_ip_groups = rule.value.destination_ip_groups
          destination_fqdns     = rule.value.destination_fqdns
        }
      }
    }
  }
}
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_firewall_policy.firewall_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy) | resource |
| [azurerm_firewall_policy_rule_collection_group.rule_collection_groups](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy_rule_collection_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_learn_private_ranges_enabled"></a> [auto\_learn\_private\_ranges\_enabled](#input\_auto\_learn\_private\_ranges\_enabled) | Whether the auto learn feature is enabled on the firewall policy | `bool` | `false` | no |
| <a name="input_base_policy_id"></a> [base\_policy\_id](#input\_base\_policy\_id) | The base policy id if specified | `string` | `null` | no |
| <a name="input_dns"></a> [dns](#input\_dns) | The DNS block within the firewall policy | <pre>list(object({<br>    proxy_enabled = optional(bool, false)<br>    servers       = set(string)<br>  }))</pre> | `null` | no |
| <a name="input_explict_proxy"></a> [explict\_proxy](#input\_explict\_proxy) | The explict proxy block within the firewall policy | <pre>list(object({<br>    enabled          = optional(bool, true)<br>    http_port        = optional(number)<br>    https_port       = optional(number)<br>    enable_pac_file  = optional(bool)<br>    pac_file_port    = optional(number)<br>    pac_file_sas_url = optional(string)<br>  }))</pre> | `null` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Specifies a list of user managed identity ids to be assigned to the VM. | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | The Managed Service Identity Type of this Virtual Machine. | `string` | `""` | no |
| <a name="input_insights"></a> [insights](#input\_insights) | The insights block | <pre>list(object({<br>    enabled                            = optional(bool, true)<br>    default_log_analytics_workspace_id = optional(string)<br>    retention_in_days                  = optional(string)<br>    log_analytics_workspace = optional(list(object({<br>      id                = optional(string)<br>      firewall_location = optional(string)<br>    })))<br>  }))</pre> | `null` | no |
| <a name="input_intrusion_detection"></a> [intrusion\_detection](#input\_intrusion\_detection) | The instruction detection block | <pre>list(object({<br>    mode           = optional(string, "Alert")<br>    private_ranges = optional(set(string))<br>    signature_overrides = optional(list(object({<br>      id    = optional(string)<br>      state = optional(string)<br>    })))<br>    traffic_bypass = optional(list(object({<br>      name                  = optional(string)<br>      protocol              = optional(string)<br>      description           = optional(string)<br>      destination_addresses = optional(list(string))<br>      destination_ip_groups = optional(list(string))<br>      destination_ports     = optional(list(string))<br>      source_addresses      = optional(list(string))<br>      source_ip_groups      = optional(list(string))<br>    })))<br>  }))</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The location for the resources to be made in | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name for the resources | `string` | n/a | yes |
| <a name="input_private_ip_ranges"></a> [private\_ip\_ranges](#input\_private\_ip\_ranges) | A list of IP addresses for the private policy | `list(string)` | `null` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group the Azure firewall resides within | `string` | n/a | yes |
| <a name="input_rule_collection_groups"></a> [rule\_collection\_groups](#input\_rule\_collection\_groups) | The rule collection groups to be assigned to the firewall polices | <pre>list(object({<br>    create_and_attach_rule_collection = optional(bool, true)<br>    name                              = string<br>    firewall_policy_id                = optional(string, null)<br>    priority                          = number<br>    application_rule_collection = optional(list(object({<br>      name     = optional(string)<br>      action   = optional(string)<br>      priority = optional(number)<br>      rule = optional(list(object({<br>        name        = optional(string)<br>        description = optional(string)<br>        protocols = optional(list(object({<br>          type = optional(string)<br>          port = optional(string)<br>        })))<br>        source_addresses      = optional(list(string))<br>        source_ip_groups      = optional(list(string))<br>        destination_addresses = optional(list(string))<br>        destination_urls      = optional(list(string))<br>        destination_fqdns     = optional(list(string))<br>        destination_fqdn_tags = optional(list(string))<br>        terminate_tls         = optional(bool)<br>        web_categories        = optional(list(string))<br>      })))<br>    })))<br>    nat_rule_collection = optional(list(object({<br>      name     = optional(string)<br>      action   = optional(string)<br>      priority = optional(number)<br>      rule = optional(list(object({<br>        name                = optional(string)<br>        description         = optional(string)<br>        protocols           = optional(list(string))<br>        source_addresses    = optional(list(string))<br>        source_ip_groups    = optional(list(string))<br>        destination_address = optional(string)<br>        destination_ports   = optional(list(string))<br>        translated_address  = optional(string)<br>        translated_fqdn     = optional(string)<br>        translated_port     = optional(number)<br>      })))<br>    })))<br>    network_rule_collection = optional(list(object({<br>      name     = optional(string)<br>      action   = optional(string)<br>      priority = optional(number)<br>      rule = optional(list(object({<br>        name                  = optional(string)<br>        description           = optional(string)<br>        protocols             = optional(list(string))<br>        source_addresses      = optional(list(string))<br>        source_ip_groups      = optional(list(string))<br>        destination_addresses = optional(list(string))<br>        destination_ports     = optional(list(string))<br>        destination_fqdns     = optional(list(string))<br>        destination_ip_groups = optional(list(string))<br>      })))<br>    })))<br>  }))</pre> | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | The sku of the policy, should match firewall, defaults to standard | `string` | `"Standard"` | no |
| <a name="input_sql_redirect_allowed"></a> [sql\_redirect\_allowed](#input\_sql\_redirect\_allowed) | Whether SQL redirect is allowed in the policy | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags for the resources | `map(string)` | n/a | yes |
| <a name="input_threat_intelligence_allowlist"></a> [threat\_intelligence\_allowlist](#input\_threat\_intelligence\_allowlist) | The threat intelligence allowlist block within the firewall policy | <pre>list(object({<br>    fqdns        = optional(list(string))<br>    ip_addresses = optional(list(string))<br>  }))</pre> | `null` | no |
| <a name="input_tls_certificate"></a> [tls\_certificate](#input\_tls\_certificate) | The tls\_certificate block within the firewall policy | <pre>list(object({<br>    key_vault_secret_id = string<br>    name                = string<br>  }))</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firewall_policy_child_policies"></a> [firewall\_policy\_child\_policies](#output\_firewall\_policy\_child\_policies) | A list of references to child Firewall Policies of this Firewall Policy. |
| <a name="output_firewall_policy_firewalls"></a> [firewall\_policy\_firewalls](#output\_firewall\_policy\_firewalls) | A list of references to Azure Firewalls that this Firewall Policy is associated with. |
| <a name="output_firewall_policy_id"></a> [firewall\_policy\_id](#output\_firewall\_policy\_id) | The ID of the Firewall Policy. |
| <a name="output_firewall_policy_identity"></a> [firewall\_policy\_identity](#output\_firewall\_policy\_identity) | The identity block of the Firewall Policy. |
| <a name="output_firewall_policy_location"></a> [firewall\_policy\_location](#output\_firewall\_policy\_location) | The location of the Firewall Policy. |
| <a name="output_firewall_policy_name"></a> [firewall\_policy\_name](#output\_firewall\_policy\_name) | The name of the Firewall Policy. |
| <a name="output_firewall_policy_rule_collection_groups"></a> [firewall\_policy\_rule\_collection\_groups](#output\_firewall\_policy\_rule\_collection\_groups) | A list of references to Firewall Policy Rule Collection Groups that belong to this Firewall Policy. |
| <a name="output_firewall_policy_tags"></a> [firewall\_policy\_tags](#output\_firewall\_policy\_tags) | The tags of the Firewall Policy. |
| <a name="output_rule_collection_groups"></a> [rule\_collection\_groups](#output\_rule\_collection\_groups) | A map of the rule collection groups associated with the firewall policy. |
