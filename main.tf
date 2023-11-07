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
