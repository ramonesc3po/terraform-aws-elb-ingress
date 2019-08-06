data "aws_lb" "this" {
  count = 1
  name  = var.lb_arn == null ? var.lb_name : null
  arn   = var.lb_arn != null ? var.lb_arn : null
}

resource "aws_lb_listener" "this" {
  count             = local.create_lb_listener
  load_balancer_arn = data.aws_lb.this.*.arn[count.index]
  port              = var.ingress_port
  protocol          = var.certificate_arn == null ? var.protocol : "HTTPS"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response: ok"
      status_code  = "200"
    }
  }

  depends_on = [
    data.aws_lb.this
  ]
}

data "aws_lb_listener" "this" {
  count = 1

  load_balancer_arn = element(concat(data.aws_lb.this.*.arn, list("")), count.index)
  port              = var.ingress_port

  depends_on = [
    "data.aws_lb.this",
    "aws_lb_listener.this"
  ]
}

resource "aws_lb_listener_rule" "this" {
  count        = local.create_lb_ingress_rule
  listener_arn = element(concat(data.aws_lb_listener.this.*.arn, list("")), count.index)
  #  priority     = var.priority

  // Just add 1 action
  action {
    type  = "forward"
    order = 1

    target_group_arn = aws_lb_target_group.this[count.index].arn
  }

  // Add more then 1 condition
  dynamic "condition" {
    for_each = [for rule_condition in var.rule_condition : {
      field  = rule_condition.field
      values = rule_condition.values
    }]
    content {
      field  = condition.value.field
      values = condition.value.values
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    "aws_lb_target_group.this"
  ]
}

##
# Target Group
##
locals {
  target_group = {
    port                 = lookup(var.target_group, "port")
    protocol             = lookup(var.target_group, "protocol")
    deregistration_delay = lookup(var.target_group, "deregistration_delay")
    target_type          = lookup(var.target_group, "target_type")
    health_check = {
      enabled             = lookup(var.target_group.health_check, "enabled")
      path                = lookup(var.target_group.health_check, "path")
      protocol            = lookup(var.target_group.health_check, "protocol")
      matcher             = lookup(var.target_group.health_check, "matcher")
      interval            = lookup(var.target_group.health_check, "interval")
      timeout             = lookup(var.target_group.health_check, "timeout")
      healthy_threshold   = lookup(var.target_group.health_check, "health_threshold")
      unhealthy_threshold = lookup(var.target_group.health_check, "unhealthy_threshold")
    }
  }
}

resource "random_id" "this" {
  byte_length = 3

  keepers = {
    port = var.target_group.port
  }
}

resource "aws_lb_target_group" "this" {
  count = local.create_lb_ingress_rule

  name                 = "${var.ingress_name}-${var.tier}-${random_id.this.hex}"
  port                 = local.target_group.port
  protocol             = local.target_group.protocol
  deregistration_delay = local.target_group.deregistration_delay
  target_type          = local.target_group.target_type
  vpc_id               = data.aws_lb.this[count.index].vpc_id

  health_check {
    enabled             = local.target_group.health_check.enabled
    port                = "traffic-port"
    path                = local.target_group.health_check.path
    protocol            = local.target_group.health_check.protocol
    matcher             = local.target_group.health_check.matcher
    interval            = local.target_group.health_check.interval
    timeout             = local.target_group.health_check.timeout
    healthy_threshold   = local.target_group.health_check.healthy_threshold
    unhealthy_threshold = local.target_group.health_check.unhealthy_threshold
  }

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  depends_on = [
    data.aws_lb.this
  ]

  tags = merge({
    Name      = "${var.ingress_name}-${var.tier}.${random_id.this.hex}"
    Terraform = "true"
    Tier      = var.tier
  }, var.tags)
}
