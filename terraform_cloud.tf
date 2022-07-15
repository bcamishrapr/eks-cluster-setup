terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "my-organization"

    workspaces {
      prefix = "prasoon-wp"
    }
  }
}
