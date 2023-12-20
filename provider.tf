# Installing AWS from
# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
#
# Setup the provider using documentation from
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.30.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}
