variable "environment" {
  description = "Deployment environment: dev, staging, or prod."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of dev, staging, prod."
  }
}

variable "aws_region" {
  description = "AWS region for deployment."
  type        = string
  default     = "ap-southeast-2"
}

variable "project_name" {
  description = "Project name prefix."
  type        = string
  default     = "ctoip-launch-engine"
}

variable "lambda_runtime" {
  description = "Lambda runtime."
  type        = string
  default     = "nodejs20.x"
}

variable "lambda_timeout_seconds" {
  description = "Lambda timeout."
  type        = number
  default     = 30
}

variable "lambda_memory_mb" {
  description = "Lambda memory."
  type        = number
  default     = 512
}

variable "log_retention_days" {
  description = "CloudWatch log retention days."
  type        = number
  default     = 30
}
