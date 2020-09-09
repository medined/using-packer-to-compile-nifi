resource "aws_iam_role" "worker" {
  name = "${var.vpc_name}-worker-role"
  path = "/"

  assume_role_policy = <<-EOF
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

resource "aws_iam_role_policy_attachment" "worker" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  ])
  role       = aws_iam_role.worker.id
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "worker" {
  name = "${var.vpc_name}-worker-instance-profile"
  role = aws_iam_role.worker.name
}
