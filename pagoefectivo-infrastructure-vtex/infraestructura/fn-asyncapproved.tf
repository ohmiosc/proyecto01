resource "aws_lb_target_group" "tg-fn-asyncapproved" {
  name        = "${var.product}-${var.environment_prefix}-fn-asyncapproved-tg"
  target_type = "lambda"
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 10
    matcher             = "200-299"
    path                = "/v1/asyncapproved/health"
    timeout             = 5
    unhealthy_threshold = 2
  }
  tags = {
    ResourceType = "TargetGroup"
  }
}

resource "aws_lambda_permission" "permit-asyncapproved" {
  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_alias.pre-asyncapproved-alias.arn
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.tg-fn-asyncapproved.arn
}

resource "aws_lb_target_group_attachment" "attach-fn2" {
  target_group_arn = aws_lb_target_group.tg-fn-asyncapproved.arn
  target_id        = aws_lambda_alias.pre-asyncapproved-alias.arn
  depends_on       = [aws_lambda_permission.permit-asyncapproved]
}

resource "aws_lambda_alias" "pre-asyncapproved-alias" {
  name             = "pre"
  description      = "Alias pre asyncapproved"
  function_name    = aws_lambda_function.pre_asyncapproved.arn
  function_version = "$LATEST"
}

resource "aws_iam_role" "iam_for_asyncapproved" {
  name = "${var.environment_prefix}-iam_for_fn_asyncapproved"

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

resource "aws_iam_role_policy_attachment" "asyncapproved_exec_role_eni" {
  depends_on = ["aws_iam_policy.policy-fn-vtex"]
  role       = aws_iam_role.iam_for_asyncapproved.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
resource "aws_iam_role_policy_attachment" "asyncapproved_exec_role_secret" {
  depends_on = ["aws_iam_policy.policy-fn-vtex"]
  role       = aws_iam_role.iam_for_asyncapproved.name
  policy_arn = aws_iam_policy.policy-fn-vtex.arn
}

resource "aws_lambda_function" "pre_asyncapproved" {
  depends_on = ["aws_iam_role_policy_attachment.asyncapproved_exec_role_eni"]

  s3_bucket                      = "infraestructura.pre"
  s3_key                         = "build/lambda/pre/vtex-pre-fn-asyncapproved.zip"
  function_name                  = "${var.product}-${var.environment_prefix}-fn-asyncapproved"
  role                           = aws_iam_role.iam_for_asyncapproved.arn
  handler                        = "Api::Api.LambdaEntryPoint::FunctionHandlerAsync"
  reserved_concurrent_executions = -1
  runtime                        = "dotnet6"
  memory_size                    = "256"
  timeout = 10
  description = "Integracion vtex-pe - fn asyncapproved"
  #VPC Config
  vpc_config {
    subnet_ids         = data.aws_subnet_ids.tier_subnets.ids
    security_group_ids = ["${aws_security_group.sg-asyncapproved.id}"]
  }
  #environment {
  #  variables = {
  #    foo = "bar"
  #  }
  #}
  tracing_config {
    mode = "Active"
  }
}
######SG########
resource "aws_security_group" "sg-asyncapproved" {
  name        = "${var.product}-${var.environment_prefix}-fn-asyncapproved-sg"
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
    ResourceType = "asyncapproved-sg"
    Name         = "fn-asyncapproved-sg"
  }
}
##############
resource "aws_lb_listener_rule" "static-asyncapproved" {
  depends_on = [
    module.alb
  ]
  listener_arn = module.alb.https_alb_listener_arn
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-fn-asyncapproved.arn
  }

  condition {
    path_pattern {
      values = ["/v1/asyncapproved*"]
    }
  }

  condition {
    host_header {
      values = ["pre.vtex.pagoefectivolatam.com"]
    }
  }
}
