# ----------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables must be set when using this module.
# ----------------------------------------------------------------------------------------------------------------------


variable "name" {
  type        = string
  description = <<-END
    (Required) Immutable. The resource name of the Policy. Must be one of the following forms, where constraint_name is the name of the constraint which this Policy configures: * projects/{project_number}/policies/{constraint_name} * folders/{folder_id}/policies/{constraint_name} * organizations/{organization_id}/policies/{constraint_name} For example, "projects/123/policies/compute.disableSerialPortAccess". Note: projects/{project_id}/policies/{constraint_name} is also an acceptable name for API requests, but responses will return the name using the equivalent project number.
  END
}

variable "parent" { # TODO: project_name?
  type        = string
  description = "(Required) The parent of the resource."
}


# ----------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults, but may be overridden.
# ----------------------------------------------------------------------------------------------------------------------

variable "spec" {
  type = any
  # type = object({
  #   etag = string
  #   inherit_from_parent = bool
  #   reset = bool
  #   rules = list(object({
  #     allow_all     = bool
  #     deny_all  = bool
  #     enforce   = bool
  #     values    = object({
  #       allowed_values = set(string)
  #       denied_values = set(string)
  #     })
  #     condition     = object({
  #       description = string
  #       expression  = string
  #       location    = string
  #       title       = string
  #     })
  #   }))
  # })
  description = "(Optional) Basic information about the Organization Policy."
  default     = {}
}

# ----------------------------------------------------------------------------------------------------------------------
# MODULE CONFIGURATION PARAMETERS
# These variables are used to configure the module.
# ----------------------------------------------------------------------------------------------------------------------

variable "module_enabled" {
  type        = bool
  description = "(Optional) Whether or not to create resources within the module."
  default     = true
}

# variable "module_tags" {
#   type        = map(string)
#   description = "(Optional) A map of tags that will be applied to all created resources that accept tags. Tags defined with 'module_tags' can be overwritten by resource-specific tags."
#   default     = {}
# }

# variable "module_timeouts" {
#   description = "(Optional) A map of timeout objects that is keyed by Terraform resource name defining timeouts for `create`, `update` and `delete` Terraform operations."
#   type        = any
#   default     = null
# }

variable "module_depends_on" {
  type        = any
  description = "(Optional) A list of external resources the module depends on."
  default     = []
}
