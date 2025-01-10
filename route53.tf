resource "aws_route53_record" "pf-booking_route53_record" {
  # hosted zone is created manually, not managed by terraform
  zone_id = "Z09307423JT3353HGJCHW"
  name    = "pf-booking"
  type    = "A"
  alias {
    name                   = "dualstack.${aws_alb.booking_alb.dns_name}"
    zone_id                = "Z215JYRZR1TBD5"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "pf-ai-integration_route53_record" {
  # hosted zone is created manually, not managed by terraform
  zone_id = "Z09307423JT3353HGJCHW"
  name    = "pf-ai-integration"
  type    = "A"
  alias {
    name                   = "dualstack.${aws_alb.ai-integration_alb.dns_name}"
    zone_id                = "Z215JYRZR1TBD5"
    evaluate_target_health = true
  }
}
