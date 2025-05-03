provider "aws" {
  region = "eu-central-1"
}

run "customs" {

  command = plan

  variables {
    bucket_name           = "test-test-test"
    force_destroy         = true
    versioning_enabled    = true
    vpc_flow_log_policies = true
  }

  assert {
    condition     = aws_s3_bucket.main.force_destroy == true
    error_message = "force_destroy should be true"
  }

  assert {
    condition     = aws_s3_bucket_versioning.main.versioning_configuration[0].status == "Enabled"
    error_message = "force_destroy should be true"
  }
}
