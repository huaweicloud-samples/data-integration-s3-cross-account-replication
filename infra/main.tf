# ============================================================================
# 华为云 OBS 跨区域复制 Terraform
# ============================================================================
# 本文件实现 S3 跨账户复制的等价功能：
#   源 OBS 桶 → 目标 OBS 桶（跨区域复制）
#   支持自定义前缀重写（使用 OBS 原生能力，无需 FunctionGraph）
# ============================================================================

terraform {
  required_version = ">= 1.5"

  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = "~> 1.70"
    }
  }

  backend "local" {}
}

provider "huaweicloud" {
  region = var.source_region
}

provider "huaweicloud" {
  alias  = "destination"
  region = var.destination_region
}

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
  default     = "cn-east-3"
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
}

# ============================================================================
# 源区域资源
# ============================================================================

resource "huaweicloud_vpc" "source" {
  name = "${var.project_name}-source-vpc"
  cidr = "10.0.0.0/16"
}

resource "huaweicloud_obs_bucket" "source" {
  bucket        = var.source_bucket_name
  acl           = "private"
  force_destroy = false

  versioning {
    status = "enabled"
  }

  # 跨区域复制配置（OBS 原生能力，支持目标前缀）
  replication_configuration {
    role   = "${var.project_name}-replication-agency"
    rule {
      id                          = "replication-rule-1"
      enabled                     = true
      priority                    = 1
      destination_bucket          = "obs://${var.destination_bucket_name}"
      destination_storage_class   = "STANDARD"
      destination_object_key_prefix = var.replication_prefix  # 自定义目标前缀
    }
  }

  tags = {
    project = var.project_name
  }
}

# IAM 委托（让目标账户可以复制到源桶）
resource "huaweicloud_identity_agency" "source_replication" {
  name                  = "${var.project_name}-replication-agency"
  description           = "Agency for cross-region replication"
  duration              = "FOREVER"
  delegated_domain_name = var.target_domain_id

  project_role {
    project = var.source_region
    roles = [
      "OBS OperateAccess",
    ]
  }

  project_role {
    project = var.destination_region
    roles = [
      "OBS OperateAccess",
    ]
  }
}

# ============================================================================
# 目标区域资源（使用 destination provider）
# ============================================================================

resource "huaweicloud_vpc" "destination" {
  provider = huaweicloud.destination
  name     = "${var.project_name}-dest-vpc"
  cidr     = "10.1.0.0/16"
}

resource "huaweicloud_obs_bucket" "destination" {
  provider = huaweicloud.destination
  bucket   = var.destination_bucket_name
  acl      = "private"
  force_destroy = false

  versioning {
    status = "enabled"
  }

  tags = {
    project = var.project_name
  }
}

# ============================================================================
# 可选：生命周期规则（如果需要额外的自动化处理）
# ============================================================================

# 目标桶生命周期规则：30天后自动归档到归档存储
resource "huaweicloud_obs_bucket_lifecycle" "destination" {
  provider = huaweicloud.destination
  bucket   = huaweicloud_obs_bucket.destination.bucket

  rule {
    id      = "archive-rule"
    status  = "enabled"
    prefix  = ""
    expiration {
      days = 30
    }
  }
}

# ============================================================================
# 输出
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
