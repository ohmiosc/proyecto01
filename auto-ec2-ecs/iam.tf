resource "aws_iam_role" "ecs-role" {
  name               = "${var.product}-${var.environment_prefix}-ec2-ecs-role"
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

resource "aws_iam_instance_profile" "ec2-ecs-profile" {
  name = "${var.product}-${var.environment_prefix}-ec2-ecs-profile"
  role = aws_iam_role.ecs-role.name
}

resource "aws_iam_role_policy_attachment" "ecs-attachment" {
  role       = aws_iam_role.ecs-role.name
  policy_arn = aws_iam_policy.ecs-policy.arn
}

resource "aws_iam_role_policy_attachment" "dev-resources-ssm-policy" {
  role       = aws_iam_role.ecs-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "ecs-policy" {
  name        = "${var.product}-${var.environment_prefix}-ec2-ecs-policy"
  description = "${var.product}-${var.environment_prefix}-ec2-ecs-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecs:CreateCluster",
                "ecs:DeregisterContainerInstance",
                "ecs:DiscoverPollEndpoint",
                "ecs:Poll",
                "ecs:RegisterContainerInstance",
                "ecs:StartTelemetrySession",
                "ecs:UpdateContainerInstancesState",
                "ecs:Submit*",
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups",
                "logs:CreateLogGroup",
                "logs:DescribeLogGroups",
                "cloudwatch:PutMetricData",
                "ec2:DescribeVolumes",
                "ec2:DescribeTags"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "sqs:*",
                "s3:*",
                "dynamodb:*",
                "ssm:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}