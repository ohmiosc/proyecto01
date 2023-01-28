resource "aws_iam_role" "nuget-server-role" {
  name               = "${var.product}-${var.environment_prefix}-windows-${var.service}-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "nuget-server-profile" {
  name = "${var.product}-${var.environment_prefix}-windows-${var.service}-profile"
  role = aws_iam_role.nuget-server-role.name
}

resource "aws_iam_role_policy_attachment" "nuget-attachment" {
  role       = aws_iam_role.nuget-server-role.name
  policy_arn = aws_iam_policy.nuget-policy.arn
}

resource "aws_iam_policy" "nuget-policy" {
  name        = "${var.product}-${var.environment_prefix}-windows-${var.service}-permit-s3"
  description = "${var.product}-${var.environment_prefix}-windows-${var.service}-permit s3"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}