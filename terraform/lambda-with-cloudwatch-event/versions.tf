terraform {
  required_version = "~> 1.0"
  required_providers {
    google = {
      source  = "hashicorp/aws"
      version = "~> 5.42.0"
    }
  }
}
