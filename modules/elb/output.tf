output "dns_name"{
  value = aws_lb.alb.dns_name
}

output "zone_id"{
  value = aws_lb.alb.zone_id
}

output "sg_alb_id"{
  value = aws_security_group.sg_alb.id
}

output "alb_target_group_arn"{
  value = aws_lb_target_group.alb_target_group.arn
}