locals {
  create_lb_listener     = var.create_lb_listener != false ? 1 : 0
  create_lb_ingress_rule = var.create_lb_ingress_rule != false ? 1 : 0
}
