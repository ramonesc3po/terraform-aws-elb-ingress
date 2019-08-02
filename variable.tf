###
# Load Balancer Listerner
###
variable "create_lb_listener" {
  type    = bool
  default = false
}

variable "lb_name" {
  type    = "string"
}

variable "lb_arn" {
  type    = "string"
  default = ""
}

variable "listener_port" {
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