output "firewall_policy_child_policies" {
  description = "A list of references to child Firewall Policies of this Firewall Policy."
  value       = azurerm_firewall_policy.firewall_policy.child_policies
}

output "firewall_policy_firewalls" {
  description = "A list of references to Azure Firewalls that this Firewall Policy is associated with."
  value       = azurerm_firewall_policy.firewall_policy.firewalls
}

output "firewall_policy_id" {
  description = "The ID of the Firewall Policy."
  value       = azurerm_firewall_policy.firewall_policy.id
}

output "firewall_policy_identity" {
  description = "The identity block of the Firewall Policy."
  value       = azurerm_firewall_policy.firewall_policy.identity
}

output "firewall_policy_location" {
  description = "The location of the Firewall Policy."
  value       = azurerm_firewall_policy.firewall_policy.location
}

output "firewall_policy_name" {
  description = "The name of the Firewall Policy."
  value       = azurerm_firewall_policy.firewall_policy.name
}

output "firewall_policy_rule_collection_groups" {
  description = "A list of references to Firewall Policy Rule Collection Groups that belong to this Firewall Policy."
  value       = azurerm_firewall_policy.firewall_policy.rule_collection_groups
}

output "firewall_policy_tags" {
  description = "The tags of the Firewall Policy."
  value       = azurerm_firewall_policy.firewall_policy.tags
}

output "rule_collection_groups" {
  description = "A map of the rule collection groups associated with the firewall policy."
  value = { for k, v in azurerm_firewall_policy_rule_collection_group.rule_collection_groups : k => {
    name     = v.name
    priority = v.priority

    application_rule_collections = v.application_rule_collection != null ? [for arc in v.application_rule_collection : {
      name     = arc.name
      action   = arc.action
      priority = arc.priority
      rules = arc.rule != null ? [for r in arc.rule : {
        name                  = r.name
        description           = r.description
        source_addresses      = r.source_addresses
        source_ip_groups      = r.source_ip_groups
        destination_addresses = r.destination_addresses
        destination_urls      = r.destination_urls
        destination_fqdns     = r.destination_fqdns
        destination_fqdn_tags = r.destination_fqdn_tags
        terminate_tls         = r.terminate_tls
        web_categories        = r.web_categories
        protocols = r.protocols != null ? [for p in r.protocols : {
          type = p.type
          port = p.port
        }] : []
      }] : []
    }] : []

    nat_rule_collections = v.nat_rule_collection != null ? [for nrc in v.nat_rule_collection : {
      name     = nrc.name
      action   = nrc.action
      priority = nrc.priority
      rules = nrc.rule != null ? [for r in nrc.rule : {
        name                = r.name
        description         = r.description
        protocols           = r.protocols
        source_addresses    = r.source_addresses
        source_ip_groups    = r.source_ip_groups
        destination_address = r.destination_address
        destination_ports   = r.destination_ports
        translated_address  = r.translated_address
        translated_fqdn     = r.translated_fqdn
        translated_port     = r.translated_port
      }] : []
    }] : []

    network_rule_collections = v.network_rule_collection != null ? [for nwc in v.network_rule_collection : {
      name     = nwc.name
      action   = nwc.action
      priority = nwc.priority
      rules = nwc.rule != null ? [for r in nwc.rule : {
        name                  = r.name
        description           = r.description
        protocols             = r.protocols
        source_addresses      = r.source_addresses
        source_ip_groups      = r.source_ip_groups
        destination_addresses = r.destination_addresses
        destination_ports     = r.destination_ports
        destination_ip_groups = r.destination_ip_groups
        destination_fqdns     = r.destination_fqdns
      }] : []
    }] : []
    }
  }
}
