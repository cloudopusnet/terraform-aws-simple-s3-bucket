output "bucket_name" {
  value       = aws_s3_bucket.main.bucket
  description = "S3 Bucket Name"
}

output "bucket_arn" {
  value       = aws_s3_bucket.main.arn
  description = "S3 Bucket ARN"
}
