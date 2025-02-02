# KMS KEY
# ENCRYPTE THE DISK KMS

resource "aws_s3_bucket" "s3_terraform_state" {
  bucket = "s3bucket-internship-jakub-12932"

  tags = {
    Name        = "TerraformStateBucket"
    Environment = "production"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.s3_terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

module "kms" {
  source = "../kms" # Path to the folder containing the KMS module
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.s3_terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = module.kms.kms_key
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_dynamodb_table" "dynamo_terraform_locks" {
  name         = "terraform-locks-internship-jakub"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "TerraformStateLocks"
    Environment = "production"
  }
}
