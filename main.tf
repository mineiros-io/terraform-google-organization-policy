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
    for_each = var.spec != null ? [var.spec] : []

    content {
      dynamic "rules" {
        for_each = try(spec.value.rules, [])
        iterator = rule

        content {
          allow_all = try(rule.value.allow_all, null)
          deny_all  = try(rule.value.deny_all, null)
          enforce   = try(rule.value.enforce, null)

          dynamic "condition" {
            for_each = try([rule.value.condition], [])

            content {
              description = try(condition.value.description, null)
              expression  = try(condition.value.expression, null)
              location    = try(condition.value.location, null)
              title       = try(condition.value.title, null)
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
