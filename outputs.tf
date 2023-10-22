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
