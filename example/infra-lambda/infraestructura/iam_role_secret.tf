resource "aws_iam_policy" "policy-fn-vtex" {
  name        = "${var.product}-${var.environment_prefix}-policy"
  path        = "/"
  description = "Policy integracion Vtex - Lambda"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "arn:aws:secretsmanager:us-west-2:929226109038:secret:*"
        }
    ]
  })
}