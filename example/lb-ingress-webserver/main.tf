variable "region" {}

provider "aws" {
  region = var.region
}

module "ingress-webserver" {
  source = "../../"

  lb_name            = "simple-load-balancer-production"
  create_lb_listener = true
}
