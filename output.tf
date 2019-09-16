output "target_group_name" {
  value = element(concat(aws_lb_target_group.this.*.name, list("")), 0)
}