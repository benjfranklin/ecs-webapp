
output "Application_Endpoint_URL" {
  value = "https://${module.alb.accelerator_dns_name}"
}