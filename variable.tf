##
# Global
##
variable "ingress_name" {
  type = string
}

variable "create_lb_ingress_rule" {
  type    = bool
  default = true
}

variable "tier" {
  description = "Type environment. Example: production, staging or integration"
  type        = string
}

variable "tags" {
  description = "Extra tags."
  type        = "map"
  default     = {}
}

###
# Load Balancer Listerner
###
variable "create_lb_listener" {
  type    = bool
  default = false
}

variable "lb_name" {
  type = "string"
}

variable "lb_arn" {
  type    = "string"
  default = null
}

variable "ingress_port" {
  type    = number
  default = 80
}

variable "certificate_arn" {
  type    = "string"
  default = null
}

variable "protocol" {
  description = "Valid values are TCP, TLS, UDP, TCP_UDP, HTTP and HTTPS. Defaults to HTTP."
  type        = "string"
  default     = "HTTP"
}


##
# Listener Rule
##
#variable "priority" {
#  type = number
#}

variable "rule_condition" {
  type = list(object({
    field  = string
    values = list(string)
  }))

  default = [
    {
      field  = "path-pattern"
      values = ["/"]
    }
  ]
}


##
# Target Group
##
variable "target_group" {
  type = object({
    port                 = number
    protocol             = string
    deregistration_delay = number
    target_type          = string
  })

  default = {
    port                 = null
    protocol             = "HTTP" // HTTP HTTPS TCP UDP
    deregistration_delay = 60
    target_type          = "ip" // ip or instance
  }
}