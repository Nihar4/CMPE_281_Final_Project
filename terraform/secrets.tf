# Secrets Manager Configuration

# Mongo URI Secret
resource "aws_secretsmanager_secret" "mongo_uri" {
  name = "${var.project_name}/${var.environment}/mongo_uri"
  description = "MongoDB Connection URI"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-mongo-uri-secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "mongo_uri" {
  secret_id     = aws_secretsmanager_secret.mongo_uri.id
  secret_string = "mongodb+srv://Nihar123:Nihar123@cluster0.9srg0my.mongodb.net/MyProject?retryWrites=true"
}

# JWT Secret
resource "aws_secretsmanager_secret" "jwt_secret" {
  name = "${var.project_name}/${var.environment}/jwt_secret"
  description = "JWT Signing Secret"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-jwt-secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "jwt_secret" {
  secret_id     = aws_secretsmanager_secret.jwt_secret.id
  secret_string = "qwertyuiopasdfghjklzxcvbnmqwertyuioplkjhgfdsasdbnm"
}

# Cloudinary Secrets
resource "aws_secretsmanager_secret" "cloudinary" {
  name = "${var.project_name}/${var.environment}/cloudinary"
  description = "Cloudinary Credentials"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-cloudinary-secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "cloudinary" {
  secret_id = aws_secretsmanager_secret.cloudinary.id
  secret_string = jsonencode({
    CLOUDINARY_CLIENT_NAME   = "dummy_name"
    CLOUDINARY_CLIENT_API    = "dummy_api_key"
    CLOUDINARY_CLIENT_SECRET = "dummy_api_secret"
  })
}

# Razorpay Secrets
resource "aws_secretsmanager_secret" "razorpay" {
  name = "${var.project_name}/${var.environment}/razorpay"
  description = "Razorpay Credentials"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-razorpay-secret"
    }
  )
}

resource "aws_secretsmanager_secret_version" "razorpay" {
  secret_id = aws_secretsmanager_secret.razorpay.id
  secret_string = jsonencode({
    RAZORPAY_API_KEY    = "dummy_key"
    RAZORPAY_API_SECRET = "dummy_secret"
  })
}
