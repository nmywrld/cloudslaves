resource "aws_wafv2_web_acl" "web_acl" {
  name        = "cloudslaves-web-acl"
  description = "Web ACL to monitor frontend and backend"
  scope       = "REGIONAL"
  default_action {
    allow {}
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "webACL"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "allow-k6-traffic"
    priority = 0

    action {
      allow {}
    }

    statement {
      byte_match_statement {
        search_string = "k6-test-header"
        field_to_match {
          single_header {
            name = "x-k6-test"
          }
        }
        text_transformation {
          priority = 0
          type     = "NONE"
        }
        positional_constraint = "EXACTLY"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "allowK6Traffic"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "rate-limit-rule-group"
    priority = 1

    override_action {
      none {}
    }

    statement {
      rule_group_reference_statement {
        arn = aws_wafv2_rule_group.rate_limit_rule_group.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rateLimitRuleGroup"
      sampled_requests_enabled   = true
    }
  }
}

resource "aws_wafv2_rule_group" "rate_limit_rule_group" {
  name        = "rate-limit-rule-group"
  description = "Rule group to limit requests from a single IP"
  scope       = "REGIONAL"
  capacity    = 100

  rule {
    name     = "rate-limit-rule"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rateLimitRule"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "rateLimitRuleGroup"
    sampled_requests_enabled   = true
  }
}

# Associate the WAF Web ACL with the frontend ALB
resource "aws_wafv2_web_acl_association" "frontend_association" {
  resource_arn = aws_lb.frontend_app_lb.arn
  web_acl_arn  = aws_wafv2_web_acl.web_acl.arn
}

# Associate the WAF Web ACL with the backend ALB
resource "aws_wafv2_web_acl_association" "backend_association" {
  resource_arn = aws_lb.backend_app_lb.arn
  web_acl_arn  = aws_wafv2_web_acl.web_acl.arn
}