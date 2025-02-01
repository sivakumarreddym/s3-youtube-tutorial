resource "aws_route53_record" "expense" {
  count = length(var.instances)
  zone_id = var.zone_id
  name    = "${var.instances[count.index]}.${var.domain_name}" #interpolation
  type    = "A"
  ttl     = 1
  records = [aws_instance.expense[count.index].private_ip] #list type
  allow_overwrite = true
}

resource "aws_route53_record" "frontend" {
  zone_id = var.zone_id
  name    = "${var.domain_name}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.expense[2].public_ip] #list type
  allow_overwrite = true
}