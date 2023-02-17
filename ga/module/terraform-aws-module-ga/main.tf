resource "aws_globalaccelerator_accelerator" "ga-default" {
  name            = var.name
  ip_address_type = var.ip_address_type
  enabled         = var.enabled

  attributes {
      flow_logs_enabled   = var.flow_logs_enabled
      flow_logs_s3_bucket = var.flow_logs_s3_bucket
      flow_logs_s3_prefix = var.flow_logs_s3_prefix
    }
}

resource "aws_globalaccelerator_listener" "ga-listener-https" {

  accelerator_arn = aws_globalaccelerator_accelerator.ga-default.id
  client_affinity = "SOURCE_IP"
  protocol        = "TCP"

  port_range {
    from_port = 443
    to_port   = 443
  }
}

resource "aws_globalaccelerator_endpoint_group" "ga-endpoint-https" {
  listener_arn = aws_globalaccelerator_listener.ga-listener-https.id
  endpoint_group_region = var.region
  health_check_path = "/test"
  
  endpoint_configuration {
    #endpoint_id = var.lb_arn
    endpoint_id = data.aws_lb.alb.arn
    weight      = 100
    client_ip_preservation_enabled = true
  }
}





