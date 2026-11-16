# ============================================================================
# 华为云 Provider 配置
# ============================================================================

terraform {
  required_version = ">= 1.5"

  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = "~> 1.70"
    }
  }
}

# 源区域 Provider
provider "huaweicloud" {
  region = var.source_region
}

# 目标区域 Provider
provider "huaweicloud" {
  alias  = "destination"
  region = var.destination_region
}
