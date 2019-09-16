output "target_group_name" {
  value = element(concat(aws_lb_target_group.this.*.name, list("")), 0)
}

output "target_group_arn" {
  value = element(concat(aws_lb_target_group.this.*.arn, list("")), 0)
}
