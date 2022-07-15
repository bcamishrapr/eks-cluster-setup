terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "proficloud"

    workspaces {
      prefix = "proficloud-infra-"
    }
  }
}