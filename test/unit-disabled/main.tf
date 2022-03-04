# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# EMPTY FEATURES (DISABLED) UNIT TEST
# This module tests an empty set of features.
# The purpose is to verify no resources are created when the module is disabled.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

variable "spec" {

}

# DO NOT RENAME MODULE NAME
module "test" {
  source = "../.."

  module_enabled = false

  # add all required arguments
  name   = "projects/test-project/policies/iam.disableServiceAccountKeyUpload"
  parent = "projects/test-project"

  # add all optional arguments that create additional resources
  spec = {
    rules = {
      condition = {
        description = "A sample condition for the policy"
        expression  = "resource.matchLabels('labelKeys/123', 'labelValues/345')"
        location    = "sample-location.log"
        title       = "sample-condition"
      }

      values = {
        allowed_values = ["projects/allowed-project"]
        denied_values  = ["projects/denied-project"]
      }
    }

    rules = {
      allow_all = true
    }
  }
}

# outputs generate non-idempotent terraform plans so we disable them for now unless we need them.
# output "all" {
#   description = "All outputs of the module."
#   value       = module.test
# }
