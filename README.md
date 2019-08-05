# Terraform AWS Ingress Elastic Load Balancer

Developing

Example
---
```hcl
module "ingress-webserver" {
  source = "../../"

  ingress_name           = "webapp"
  tier                   = "production"
  lb_name                = "simple-load-balancer-production"
  ingress_port           = 80
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
  }
}
```

Author
---
Ramones C3po