# ----------------------------------------------------------------------------------------------------------------------
# OUTPUT CALCULATED VARIABLES (prefer full objects)
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# OUTPUT ALL RESOURCES AS FULL OBJECTS
# ----------------------------------------------------------------------------------------------------------------------

output "policy" {
  description = "All outputs of the created 'google_org_policy_policy' resource."
  value       = one(resource.google_org_policy_policy.policy)
}

# ----------------------------------------------------------------------------------------------------------------------
# OUTPUT MODULE CONFIGURATION
# ----------------------------------------------------------------------------------------------------------------------

output "module_enabled" {
  description = "Whether or not the module is enabled."
  value       = var.module_enabled
}

# output "module_tags" {
#   description = "A map of tags that will be applied to all created resources that accept tags."
#   value       = var.module_tags
# }
