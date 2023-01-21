resource "aws_globalaccelerator_accelerator" "ga" {
  name = "${var.product}-${var.environment_prefix}-global"

  ip_address_type = "IPV4"
  enabled         = true

  attributes {
    flow_logs_enabled   = true
    flow_logs_s3_bucket = module.s3_bucket_for_logs.s3_bucket_id
    flow_logs_s3_prefix = "logs/${var.product}/${var.environment_prefix}/global-accelerator"
  }
}

resource "aws_globalaccelerator_listener" "ga-listener" {
  accelerator_arn = aws_globalaccelerator_accelerator.ga.id
  client_affinity = "SOURCE_IP"
  protocol        = "TCP"

  port_range {
    from_port = 443
    to_port   = 443
  }
}

resource "aws_globalaccelerator_endpoint_group" "ga-endpoint" {
  depends_on = [
    module.alb
  ]
  listener_arn = aws_globalaccelerator_listener.ga-listener.id
  endpoint_group_region = var.region
  endpoint_configuration {
    endpoint_id = module.alb.alb_arn
    weight      = 100
    client_ip_preservation_enabled = true
  }
}