data "github_user" "current" {
  username = ""
}

data "github_repository" "test" {
  full_name = "mizzy/test"
}

resource "github_repository_environment" "example" {
  environment  = "example"
  repository   = data.github_repository.test.name

  reviewers {
    users = [data.github_user.current.id]
  }

  deployment_branch_policy {
    protected_branches          = true
    custom_branch_policies = false
  }
}
