variable "bucket_name" {
  description = "S3 Bucket name"
  type        = string
  nullable    = true
  default     = null
}

variable "versioning_enabled" {
  description = "Enable Bucket Versioning (true/false)"
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Upon Deletion Force Destroy is applied"
  type        = bool
  default     = false
}

variable "vpc_flow_log_policies" {
  description = "Add VPC Flow Log pre-defined bucket policies"
  type        = bool
  default     = false
}

variable "custom_bucket_policy_document" {
  description = "Bucket Policy JSON document"
  type        = string
  nullable    = true
  default     = null
}
