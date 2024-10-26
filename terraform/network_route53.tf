resource "aws_route53_zone" "main" {
  name = "mydomain.com"
}

# resource "aws_route53_record" "frontend" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "frontend.mydomain.com"
#   type    = "A"

#   alias {
#     name                   = aws_lb.public_app_lb.dns_name
#     zone_id                = aws_lb.public_app_lb.zone_id
#     evaluate_target_health = true
#   }
# }
# resource "aws_route53_record" "backend" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "backend.mydomain.com"
#   type    = "A"

#   alias {
#     name                   = aws_lb.private_app_lb.dns_name
#     zone_id                = aws_lb.private_app_lb.zone_id
#     evaluate_target_health = true
#   }
# }
