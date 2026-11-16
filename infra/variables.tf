# ============================================================================
# 变量定义
# ============================================================================

variable "source_region" {
  description = "源区域"
  type        = string
  default     = "cn-north-4"
}

variable "destination_region" {
  description = "目标区域"
  type        = string
  default     = "cn-north-4"
}

variable "project_name" {
  description = "项目名称"
  type        = string
  default     = "obs-replication"
}

variable "source_bucket_name" {
  description = "源 OBS 桶名称"
  type        = string
  default     = "source-replication-bucket"
}

variable "destination_bucket_name" {
  description = "目标 OBS 桶名称"
  type        = string
  default     = "destination-replication-bucket"
}

variable "replication_prefix" {
  description = "复制目标前缀"
  type        = string
  default     = "replicated/"
}

variable "target_domain_id" {
  description = "目标账户 Domain ID"
  type        = string
  default     = ""
}
