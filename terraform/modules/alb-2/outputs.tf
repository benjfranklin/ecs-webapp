/* output "listener_https_arn" {
  description = "The ARN of the HTTPS ALB Listener that can be used to add rules"
  value       = module.alb.https_listener_arns
}

output "listener_http_arn" {
  description = "The ARN of the HTTP ALB Listener that can be used to add rules"
  value       = module.alb.http_tcp_listener_arns
}
*/

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.app.arn
}

output "accelerator_dns_name" {
  description = "The DNS name of the accelerator"
  value       = aws_globalaccelerator_accelerator.alb.dns_name
}