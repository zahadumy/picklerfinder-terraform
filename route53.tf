resource "aws_route53_record" "pf-booking_route53_record" {
  # hosted zone is created manually, not managed by terraform
  zone_id = "Z09307423JT3353HGJCHW"
  name    = "pf-api"
  type    = "A"
  alias {
    name                   = "dualstack.${aws_alb.alb.dns_name}"
    zone_id                = "Z215JYRZR1TBD5"
    evaluate_target_health = true
  }
}
