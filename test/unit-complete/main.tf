module "test" {
  source = "../.."

  module_enabled = true

  # add all required arguments
  name   = "projects/test-project/policies/iam.disableServiceAccountKeyUpload"
  parent = "projects/test-project"

  # add all optional arguments that create additional resources
  spec = {
    rules = [
      {
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
      },
      {
        allow_all = true
      }
    ]
  }

  # add most/all other optional arguments

  # module_tags = {
  #   Environment = "unknown"
  # }

  module_depends_on = ["nothing"]
}
