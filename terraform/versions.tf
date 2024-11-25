terraform {
  required_version = "~> 1.7.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.36.0"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.3.3"
    }
  }

}