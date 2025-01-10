output "booking_swagger" {
  value = "https://${aws_route53_record.pf-booking_route53_record.fqdn}/swagger-ui.html"
}
output "ai-integration_swagger" {
  value = "https://${aws_route53_record.pf-ai-integration_route53_record.fqdn}/swagger-ui.html"
}
