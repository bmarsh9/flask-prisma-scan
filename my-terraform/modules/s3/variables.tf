variable "buckets" {
  type        = list(string)
  description = "List of bucket names"
}

variable "expiration_days" {
  default     = 0
  description = "If set, will expire objects older than X days"
}

variable "sse" {
  default     = false
  description = "Map containing server-side encryption configuration"
}

variable "versioning" {
  default     = false
  description = "Map containing versioning configuration"
}
