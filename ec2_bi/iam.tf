resource "aws_iam_role" "bi-role" {
  name               = "${var.product}-${var.environment_prefix}-bi-ec2-role"
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

resource "aws_iam_instance_profile" "bi-profile" {
  name = "${var.product}-${var.environment_prefix}-bi-ec2-profile"
  role = aws_iam_role.bi-role.name
}

resource "aws_iam_role_policy_attachment" "bi-attachment" {
  role       = aws_iam_role.bi-role.name
  policy_arn = aws_iam_policy.bi-policy.arn
}

resource "aws_iam_role_policy_attachment" "prod-resources-ssm-policy" {
  role       = aws_iam_role.bi-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "bi-policy" {
  name        = "${var.product}-${var.environment_prefix}-bi-ec2-policy"
  description = "${var.product}-${var.environment_prefix}-bi-ec2-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "logs:*",
          "ssm:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}