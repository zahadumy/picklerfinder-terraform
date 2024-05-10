output "backend_swagger" {
  value       = "http://${aws_alb.booking_alb.dns_name}/swagger-ui.html"
}
output "s3_url" {
  value       = "http://${aws_s3_bucket_website_configuration.config.website_endpoint}"
}
