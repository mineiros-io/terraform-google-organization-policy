module "test" {
  source = "../.."

  name   = "projects/test-project/policies/iam.disableServiceAccountKeyUpload"
  parent = "projects/test-project"
}
