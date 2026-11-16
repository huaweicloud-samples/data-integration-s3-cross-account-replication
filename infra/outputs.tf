# ============================================================================
# 输出定义
# ============================================================================

output "source_bucket" {
  description = "源 OBS 桶名称"
  value       = huaweicloud_obs_bucket.source.bucket
}

output "destination_bucket" {
  description = "目标 OBS 桶名称"
  value       = huaweicloud_obs_bucket.destination.bucket
}

output "source_region" {
  description = "源区域"
  value       = var.source_region
}

output "destination_region" {
  description = "目标区域"
  value       = var.destination_region
}

output "replication_prefix" {
  description = "复制目标前缀"
  value       = var.replication_prefix
}

output "iam_agency_name" {
  description = "IAM 委托名称"
  value       = huaweicloud_identity_agency.source_replication.name
}
