data "aws_lb" "this" {
  count = local.check_lb_arn
  name  = var.lb_name
}

resource "aws_lb_listener" "this" {
  count             = local.create_lb_listener
  load_balancer_arn = var.lb_arn == "" ? var.lb_arn : data.aws_lb.this.*.arn[count.index]
  port              = var.listener_port
  protocol          = var.certificate_arn != null ? var.protocol : "HTTPS"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }
  }
}

data "aws_lb_listener" "this" {
  count             = 1
  load_balancer_arn = var.lb_arn == "" ? var.lb_arn : data.aws_lb.this.*.arn[count.index]
  port              = aws_lb_listener.this[count.index].port
}

resource "aws_lb_listener_rule" "this" {
  count        = 1
  listener_arn = data.aws_lb.this.*.arn[count.index]

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      host        = "https://arena.club"
    }
  }

  condition {
    field  = "path-pattern"
    values = ["/health"]
  }
}
