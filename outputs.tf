output "booking_swagger" {
  value = "https://${aws_route53_record.pf-booking_route53_record.fqdn}/booking/swagger-ui.html"
}
output "ai-integration_swagger" {
  value = "https://${aws_route53_record.pf-booking_route53_record.fqdn}/ai-integration/swagger-ui.html"
}
