resource "aws_route53_zone" "hostedzone" {
  name = var.dns_record_domain_name
  force_destroy = true
  tags = {
    Environment = terraform.workspace
  }
}

resource "aws_route53_record" "hostedzone_elb" {
  zone_id = aws_route53_zone.hostedzone.zone_id
  name = var.dns_record_domain_name
  type = "A"
  alias {
    name = var.cf_distribution_domain_name
    zone_id = var.cf_distribution_hosted_zone_id
    evaluate_target_health = true
  }
}