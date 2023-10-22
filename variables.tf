variable "auto_learn_private_ranges_enabled" {
  type        = bool
  description = "Whether the auto learn feature is enabled on the firewall policy"
  default     = false
}

variable "base_policy_id" {
  type        = string
  description = "The base policy id if specified"
  default     = null
}

variable "dns" {
  description = "The DNS block within the firewall policy"
  type = list(object({
    proxy_enabled = optional(bool, false)
    servers       = set(string)
  }))
  default = null
}

variable "explict_proxy" {
  description = "The explict proxy block within the firewall policy"
  type = list(object({
    enabled          = optional(bool, true)
    http_port        = optional(number)
    https_port       = optional(number)
    enable_pac_file  = optional(bool)
    pac_file_port    = optional(number)
    pac_file_sas_url = optional(string)
  }))
  default = null
}

variable "identity_ids" {
  description = "Specifies a list of user managed identity ids to be assigned to the VM."
  type        = list(string)
  default     = []
}

variable "identity_type" {
  description = "The Managed Service Identity Type of this Virtual Machine."
  type        = string
  default     = ""
}

variable "insights" {
  description = "The insights block"
  type = list(object({
    enabled                            = optional(bool, true)
    default_log_analytics_workspace_id = optional(string)
    retention_in_days                  = optional(string)
    log_analytics_workspace = optional(list(object({
      id                = optional(string)
      firewall_location = optional(string)
    })))
  }))
  default = null
}

variable "intrusion_detection" {
  description = "The instruction detection block"
  type = list(object({
    mode           = optional(string, "Alert")
    private_ranges = optional(set(string))
    signature_overrides = optional(list(object({
      id    = optional(string)
      state = optional(string)
    })))
    traffic_bypass = optional(list(object({
      name                  = optional(string)
      protocol              = optional(string)
      description           = optional(string)
      destination_addresses = optional(list(string))
      destination_ip_groups = optional(list(string))
      destination_ports     = optional(list(string))
      source_addresses      = optional(list(string))
      source_ip_groups      = optional(list(string))
    })))
  }))
  default = null
}

variable "location" {
  type        = string
  description = "The location for the resources to be made in"
}

variable "name" {
  type        = string
  description = "The name for the resources"
}

variable "private_ip_ranges" {
  type        = list(string)
  description = "A list of IP addresses for the private policy"
  default     = null
}

variable "rg_name" {
  type        = string
  description = "The name of the resource group the Azure firewall resides within"
}

variable "sku" {
  type        = string
  description = "The sku of the policy, should match firewall, defaults to standard"
  default     = "Standard"
}

variable "sql_redirect_allowed" {
  type        = bool
  description = "Whether SQL redirect is allowed in the policy"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "The tags for the resources"
}

variable "threat_intelligence_allowlist" {
  description = "The threat intelligence allowlist block within the firewall policy"
  type = list(object({
    fqdns        = optional(list(string))
    ip_addresses = optional(list(string))
  }))
  default = null
}

variable "tls_certificate" {
  description = "The tls_certificate block within the firewall policy"
  type = list(object({
    key_vault_secret_id = string
    name                = string
  }))
  default = null
}
