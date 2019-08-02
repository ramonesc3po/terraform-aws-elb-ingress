provider "aws" {
  region = "us-east-1"
}

locals {
  check_lb_name      = var.lb_name != "" ? 1 : 0
  check_lb_arn       = var.lb_arn == "" ? 1 : 0
  create_lb_listener = var.create_lb_listener != false ? 1 : 0
}