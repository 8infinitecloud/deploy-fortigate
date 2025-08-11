resource "aws_iam_role" "fortigateha" {
  name = "fortigateha"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "fortigateha" {
  name        = "fortigateha"
  path        = "/"
  description = "Policies for the FortiGate HA instances"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:AssociateAddress",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses",
          "ec2:ReplaceRoute"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "fortigateha" {
  name       = "fortigateha"
  roles      = [aws_iam_role.fortigateha.name]
  policy_arn = aws_iam_policy.fortigateha.arn
}

resource "aws_iam_instance_profile" "fortigateha" {
  name = "fortigateha"
  role = aws_iam_role.fortigateha.name
}

// S3 bucket IAM role (optional, for bootstrap)
resource "aws_iam_role" "fortigate" {
  count = var.bucket ? 1 : 0
  name  = "fortigate"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "fortigate" {
  count       = var.bucket ? 1 : 0
  name        = "fortigate"
  path        = "/"
  description = "Policies for the FortiGate instances"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.s3_bucket[0].arn}/*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "fortigate" {
  count      = var.bucket ? 1 : 0
  name       = "fortigate"
  roles      = [aws_iam_role.fortigate[0].name]
  policy_arn = aws_iam_policy.fortigate[0].arn
}

resource "aws_iam_instance_profile" "fortigate" {
  count = var.bucket ? 1 : 0
  name  = "fortigate"
  role  = aws_iam_role.fortigate[0].name
}

// S3 bucket for bootstrap (optional)
resource "aws_s3_bucket" "s3_bucket" {
  count  = var.bucket ? 1 : 0
  bucket = "fortigate-bootstrap-${random_string.random_name_post.result}"
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  count  = var.bucket ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_encryption" {
  count  = var.bucket ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "random_string" "random_name_post" {
  length  = 5
  special = false
  upper   = false
}