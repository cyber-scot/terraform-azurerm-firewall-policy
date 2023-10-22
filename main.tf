
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
    for_each = var.dns != null ? [var.dns] : []
    content {
      proxy_enabled = dns.value.proxy_enabled
      servers       = toset(dns.value.servers)
    }
  }

  dynamic "insights" {
    for_each = var.insights != null ? [var.insights] : []
    content {
      default_log_analytics_workspace_id = insights.value.log_analytics_workspace_id
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
    for_each = var.threat_intelligence_allowlist != null ? [var.threat_intelligence_allowlist] : []
    content {
      fqdns        = threat_intelligence_allowlist.value.fqdns
      ip_addresses = threat_intelligence_allowlist.value.ip_addresses
    }
  }

  dynamic "tls_certificate" {
    for_each = var.tls_certificate != null ? [var.tls_certificate] : []
    content {
      key_vault_secret_id = tls_certificate.value.key_vault_secret_id
      name                = tls_certificate.value.name
    }
  }

  dynamic "intrusion_detection" {
    for_each = var.intrusion_detection != null ? [var.intrusion_detection] : []
    content {
      mode           = intrusion_detection.value.mode
      private_ranges = toset(intrusion_detection.value.private_ranges)

      dynamic "signature_overrides" {
        for_each = intrusion_detection.value.signature_overrides != null ? [intrusion_detection.value.signature_overrides] : []

        content {
          id    = signature_overrides.value.id
          state = signature_overrides.value.state
        }
      }

      dynamic "traffic_bypass" {
        for_each = intrusion_detection.value.traffic_bypass != null ? [intrusion_detection.value.traffic_bypass] : []
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
    for_each = var.explict_proxy != null ? [var.explict_proxy] : []
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
    for_each = length(var.identity_ids) == 0 && var.identity_type == "SystemAssigned" ? [var.identity_type] : []
    content {
      type = var.identity_type
    }
  }

  dynamic "identity" {
    for_each = var.identity_type == "UserAssigned" ? [var.identity_type] : []
    content {
      type         = var.identity_type
      identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : []
    }
  }

  dynamic "identity" {
    for_each = var.identity_type == "SystemAssigned, UserAssigned" ? [var.identity_type] : []
    content {
      type         = var.identity_type
      identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : []
    }
  }
}
