resource "aws_lb_target_group" "tg-fn-bankinvoice" {
  name        = "${var.product}-${var.environment_prefix}-fn-bankinvoice-tg"
  target_type = "lambda"
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 10
    matcher             = "200-299"
    path                = "/v1/bankinvoice/health"
    timeout             = 5
    unhealthy_threshold = 2
  }
  tags = {
    ResourceType = "TargetGroup"
  }
}

resource "aws_lambda_permission" "permit-bankinvoice" {
  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_alias.pre-bankinvoice-alias.arn
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.tg-fn-bankinvoice.arn
}

resource "aws_lb_target_group_attachment" "attach-fn1" {
  target_group_arn = aws_lb_target_group.tg-fn-bankinvoice.arn
  target_id        = aws_lambda_alias.pre-bankinvoice-alias.arn
  depends_on       = [aws_lambda_permission.permit-bankinvoice]
}

resource "aws_lambda_alias" "pre-bankinvoice-alias" {
  name             = "pre"
  description      = "Alias pre bankinvoice"
  function_name    = aws_lambda_function.pre_bankinvoice.arn
  function_version = "$LATEST"
}

resource "aws_iam_role" "iam-for-bankinvoice" {
  name = "${var.environment_prefix}-iam_for_fn_bankinvoice"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "bankinvoice_exec_role_eni" {
  depends_on = ["aws_iam_policy.policy-fn-vtex"]
  role       = aws_iam_role.iam-for-bankinvoice.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
resource "aws_iam_role_policy_attachment" "bankinvoice_exec_role_secret" {
  depends_on = ["aws_iam_policy.policy-fn-vtex"]
  role       = aws_iam_role.iam-for-bankinvoice.name
  policy_arn = aws_iam_policy.policy-fn-vtex.arn
}

resource "aws_lambda_function" "pre_bankinvoice" {
  depends_on = ["aws_iam_role_policy_attachment.bankinvoice_exec_role_eni"]

  s3_bucket                      = "infraestructura.pre"
  s3_key                         = "build/lambda/pre/vtex-pre-fn-bankinvoice.zip"
  function_name                  = "${var.product}-${var.environment_prefix}-fn-bankinvoice"
  role                           = aws_iam_role.iam-for-bankinvoice.arn
  handler                        = "Api::Api.LambdaEntryPoint::FunctionHandlerAsync"
  reserved_concurrent_executions = -1
  runtime                        = "dotnet6"
  memory_size                    = "256"
  timeout                        = 10
  description = "Integracion vtex-pe - fn bankinvoice"

  #VPC Config
  vpc_config {
    subnet_ids         = data.aws_subnet_ids.tier_subnets.ids
    security_group_ids = ["${aws_security_group.sg-bankinvoice.id}"]
  }
  kms_key_arn = "arn:aws:kms:us-west-2:929226109038:key/12c0efa7-bb34-4a1f-a05d-95b475a2786c"

  environment {
    variables = {
      foo = "bar"
    }
  }
  tracing_config {
    mode = "Active"
  }
}
######SG########
resource "aws_security_group" "sg-bankinvoice" {
  name        = "${var.product}-${var.environment_prefix}-fn-bankinvoice-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description     = "${var.product}-${var.environment_prefix}-alb"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${module.alb.security_group_id}"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow egress traffic"
  }

  tags = {
    ResourceType = "bankinvoice-sg"
    Name         = "fn-bankinvoice-sg"
  }
}
##############
resource "aws_lb_listener_rule" "static-bankinvoice" {
  depends_on = [
    module.alb
  ]
  listener_arn = module.alb.https_alb_listener_arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-fn-bankinvoice.arn
  }

  condition {
    path_pattern {
      values = ["/v1/bankinvoice*"]
    }
  }

  condition {
    host_header {
      values = ["pre.vtex.pagoefectivolatam.com"]
    }
  }
}
