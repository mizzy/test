data "github_repository_file" "test" {
  repository = "mizzy/test"
  branch     = "master"
  file       = ".gitignore"
}
