resource "aws_iam_role" "sql-server-role" {
  name               = "${var.product}-${var.environment_prefix}-bd-ec2-role"
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

resource "aws_iam_instance_profile" "sql-server-profile" {
  name = "${var.product}-${var.environment_prefix}-bd-ec2-profile"
  role = aws_iam_role.sql-server-role.name
}

resource "aws_iam_role_policy_attachment" "sql-attachment" {
  role       = aws_iam_role.sql-server-role.name
  policy_arn = aws_iam_policy.sqlserver-policy.arn
}

resource "aws_iam_role_policy_attachment" "dev-resources-ssm-policy" {
  role       = aws_iam_role.sql-server-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "sqlserver-policy" {
  name        = "${var.product}-${var.environment_prefix}-bd-ec2-policy"
  description = "${var.product}-${var.environment_prefix}-bd-ec2-policy"

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
          "codedeploy:*",
          "ssm:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}