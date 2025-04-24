terraform {
  backend "s3" {
    bucket   = "terraform-my-backet-state"
    key      = "workspaces/terraform.tfstate"
    region   = "eu-north-1"
    endpoint = "https://s3.eu-north-1.amazonaws.com"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}