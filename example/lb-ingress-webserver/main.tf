variable "region" {}

provider "aws" {
  region = var.region
}

module "ingress-webserver" {
  source = "../../"

  ingress_name           = "webapp"
  tier                   = "production"
  lb_name                = "simple-load-balancer-production"
  ingress_port           = 3000
  create_lb_listener     = true

  rule_condition = [
    {
      field  = "path-pattern"
      values = ["/api"]
    }
  ]

  target_group = {
    port                 = 3000
    protocol             = "HTTP"
    deregistration_delay = 60
    target_type          = "ip"
    health_check = {
      enabled             = true
      path                = "/"
      protocol            = "HTTP"
      matcher             = 200
      interval            = 100 // In seconds
      timeout             = 60 // In seconds
      health_threshold    = 2  // In minutes min 2 max 10
      unhealthy_threshold = 2  // In minutes min 2 max 10
    }
  }
}
