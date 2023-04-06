resource "aws_iam_role" "cw-canary-role" {
  name               = "${var.product}-${var.environment_prefix}-cw-canarys-role"
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

resource "aws_iam_instance_profile" "cw-canary-profile" {
  name = "${var.product}-${var.environment_prefix}-cw-canary-profile"
  role = aws_iam_role.cw-canary-role.name
}

resource "aws_iam_role_policy_attachment" "cw-attachment" {
  role       = aws_iam_role.cw-canary-role.name
  policy_arn = aws_iam_policy.canary-policy.arn
}


resource "aws_iam_policy" "canary-policy" {
  name        = "${var.product}-${var.environment_prefix}-cw-canaries-policy"
  description = "${var.product}-${var.environment_prefix}-cw-canaries-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "cloudwatch:PutMetricData",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "cloudwatch:namespace": "CloudWatchSynthetics"
                }
            }
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "logs:CreateLogStream",
                "s3:ListAllMyBuckets",
                "logs:CreateLogGroup",
                "logs:PutLogEvents",
                "s3:GetBucketLocation",
                "xray:PutTraceSegments"
            ],
      "Resource": "*"
    }
  ]
}
EOF
}