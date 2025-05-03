provider "aws" {
  region = "eu-central-1"
}

run "defaults" {

  command = plan

  assert {
    condition     = aws_s3_bucket.main.force_destroy == false
    error_message = "Defaults are not properly applied, force_destroy should be false"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.main.block_public_acls == true
    error_message = "Defaults are not properly applied, block_public_acls should be set to true"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.main.block_public_policy == true
    error_message = "Defaults are not properly applied, block_public_policy should be set to true"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.main.ignore_public_acls == true
    error_message = "Defaults are not properly applied, ignore_public_acls should be set to true"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.main.restrict_public_buckets == true
    error_message = "Defaults are not properly applied, restrict_public_buckets should be set to true"
  }
}
