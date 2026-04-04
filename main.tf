provider "aws" {
  region = "eu-west-1"
}

# ==================== FRONTEND ====================
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "resume" {
  bucket = "angel-resume-${random_string.suffix.result}"
}

resource "aws_s3_bucket_website_configuration" "resume" {
  bucket = aws_s3_bucket.resume.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "resume" {
  bucket                  = aws_s3_bucket.resume.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "resume" {
  bucket = aws_s3_bucket.resume.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.resume.arn}/*"
    }]
  })
  depends_on = [aws_s3_bucket_public_access_block.resume]
}

# ← NUEVO: Terraform inyecta automáticamente la URL de la Lambda
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.resume.id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
  etag         = filemd5("index.html")
}
resource "aws_cloudfront_distribution" "resume" {
  origin {
    domain_name = aws_s3_bucket.resume.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.resume.id}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.resume.id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# ==================== BACKEND ====================
resource "aws_dynamodb_table" "visitors" {
  name         = "visitors"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "visitor_counter" {
  filename         = "lambda.zip"
  function_name    = "visitor_counter"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("lambda.zip")
}

resource "aws_lambda_function_url" "counter_url" {
  function_name      = aws_lambda_function.visitor_counter.function_name
  authorization_type = "NONE"

  cors {
    allow_origins     = ["*"]
    allow_methods     = ["GET"]
    allow_headers     = ["*"]
    expose_headers    = ["*"]
    allow_credentials = false
  }
}

# ← ESTE ERA EL FALLO FINAL (403 Forbidden)
resource "aws_lambda_permission" "allow_function_url" {
  statement_id           = "AllowPublicFunctionUrl"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.visitor_counter.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}

# ==================== STATE LOCK ====================
resource "random_string" "tfstate_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "angel-tfstate-${random_string.tfstate_suffix.result}"
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# ==================== GITHUB ACTIONS OIDC ====================
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:Angelito1210/cloud-resume-challenge:*"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "github_actions_minimal" {
  role = aws_iam_role.github_actions_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:*",
        "cloudfront:*",
        "lambda:*",
        "dynamodb:*",
        "iam:PassRole",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:AttachRolePolicy",
        "iam:PutRolePolicy",
        "iam:CreateOpenIDConnectProvider",
        "iam:DeleteOpenIDConnectProvider"
      ]
      Resource = "*"
    }]
  })
}
resource "aws_dynamodb_table_item" "initial_visitor_count" {
  table_name = aws_dynamodb_table.visitors.name
  hash_key   = "id"

  item = jsonencode({
    id    = { S = "total" }
    count = { N = "0" }
  })
}

# ==================== OUTPUTS ====================
output "website_url" {
  value = "https://${aws_cloudfront_distribution.resume.domain_name}"
}

output "api_url" {
  value = aws_lambda_function_url.counter_url.function_url
}
