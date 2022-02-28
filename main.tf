# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# THIS IS A UPPERCASE MAIN HEADLINE
# And it continues with some lowercase information about the module
# We might add more than one line for additional information
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

resource "google_org_policy_policy" "policy" {
  count = var.module_enabled ? 1 : 0

  depends_on = [var.module_depends_on]

  name   = var.name
  parent = var.parent

  dynamic "spec" {
    for_each = try([var.spec], [])

    content {
      dynamic "rules" {
        for_each = try(spec.value.rules, [])
        iterator = rule

        content {
          allow_all = rule.value.allow_all
          deny_all  = rule.value.deny_all
          enforce   = rule.value.enforce

          dynamic "condition" {
            for_each = try([rule.value.condition], [])

            content {
              description = condition.value.description
              expression  = condition.value.expression
              location    = condition.value.location
              title       = condition.value.title
            }
          }

          dynamic "values" {
            for_each = try(rule.value.values, [])
            iterator = spec_value

            content {
              allowed_values = try(spec_value.value.allowed_values, [])
              denied_values  = try(spec_value.value.denied_values, [])
            }
          }
        }
      }
    }
  }
}
