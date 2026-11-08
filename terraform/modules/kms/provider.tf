provider "aws" {
  region = var.region
  profile = "default"
  shared_credentials_files = ["~/.aws/credentials"]
}
provider "aws" {
  alias = "secondary_region"
  region = var.secondary_region
  profile = "default"
}