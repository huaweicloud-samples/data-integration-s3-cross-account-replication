# data-integration-s3-cross-account-replication / OBS 跨区域复制实践

[![License](https://img.shields.io/badge/License-MIT%20No%20Attribution-blue.svg)](LICENSE)
[![Huawei Cloud](https://img.shields.io/badge/Huawei%20Cloud-IAM%20Auth-red.svg)](https://support.huaweicloud.com/intl/en-us/)

> 华为云 OBS 跨区域复制最佳实践
> OBS Cross-Region Replication Best Practice

---

## 1. 简介 / Overview

**中文**：本实践提供 OBS 跨区域复制能力，用于实现数据容灾和跨区域数据同步。面向运维工程师和架构师，可作为参考架构或学习样例使用。

**English**: This practice provides OBS cross-region replication capability for data disaster recovery and cross-region data synchronization. Designed for operations engineers and architects as a reference architecture or learning example.

### 核心能力

- **跨区域复制**：源桶到目标桶的自动复制（OBS 原生能力）
- **版本控制**：支持对象版本管理
- **自定义前缀**：复制时可重写目标路径前缀（无需额外函数）
- **生命周期管理**：可选配置对象生命周期规则

---

## 2. 目录

- [1. 简介](#1-简介--overview-critical)
- [2. 目录](#2-目录)
- [3. 架构图](#3-架构图)
- [4. 方案亮点](#4-方案亮点)
- [5. 涉及云服务](#5-涉及云服务)
- [6. 前置条件](#6-前置条件-critical)
- [7. 快速开始](#7-快速开始-critical)
- [8. 分步部署](#8-分步部署)
- [9. 使用方法 / 验证](#9-使用方法--验证-critical)
- [10. 清理资源](#10-清理资源)
- [11. 详细说明](#11-详细说明)
- [12. 许可证](#12-许可证-critical)

---

## 3. 架构图

> 跨区域复制架构：源区域 OBS → 目标区域 OBS（OBS 原生能力）

```
+------------------------------------------------------------------+
|               源区域 (cn-north-4) / Source Region                |
|                                                                  |
|  +------------------------------------------------------------+  |
|  |                                                            |  |
|  |               源 OBS 桶 / Source OBS Bucket                |  |
|  |                                                            |  |
|  | versioning   : enabled                                     |  |
|  | replication  : replication-rule-1                          |  |
|  | key prefix   : replicated/                                 |  |
|  | agency       : obs-replication-agency                      |  |
|  |                                                            |  |
|  +------------------------------------------------------------+  |
+---------------------------------+--------------------------------+
                                  |
                                  |  OBS Cross-Region Replication
                                  |  destination object key prefix rewritten
                                  v
+---------------------------------+--------------------------------+
|            目标区域 (cn-east-3) / Destination Region             |
|                                                                  |
|  +------------------------------------------------------------+  |
|  |                                                            |  |
|  |            目标 OBS 桶 / Destination OBS Bucket            |  |
|  |                                                            |  |
|  | versioning   : enabled                                     |  |
|  | lifecycle    : 30 days -> Archive (optional)               |  |
|  |                                                            |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+

+------------------------------------------------------------------+
|                      IAM 委托 / IAM Agency                       |
|                                                                  |
|  name   : obs-replication-agency                                 |
|  roles  : OBS OperateAccess  (cn-north-4 + cn-east-3)            |
|  usage  : grants cross-region write access to the source         |
+------------------------------------------------------------------+
```

**组件说明**：
- **源 OBS 桶**：存储原始数据，配置复制规则（含目标前缀）
- **目标 OBS 桶**：接收复制的数据
- **IAM 委托**：跨区域授权
- **生命周期规则**（可选）：自动归档/清理

---

## 4. 方案亮点

- **自动复制**：配置后自动跨区域复制
- **高可用**：多版本支持，数据安全
- **事件驱动**：对象事件触发函数处理
- **灵活前缀**：支持目标路径自定义

---

## 5. 涉及云服务

| 服务 | 用途 | 备注 |
|---|---|---|
| OBS | 对象存储 | 源桶和目标桶（含复制规则） |
| IAM | 身份认证 | 跨区域委托 |

> **提示**：所有服务均可通过本仓库的 Terraform 一键创建。

---

## 6. 前置条件

| 项 | 要求 | 说明 |
|---|---|---|
| 华为云账号 | 已注册 | 需开通 OBS/IAM/FunctionGraph 权限 |
| AK/SK | 已获取 | 在「我的凭证」创建 |
| Terraform | >= 1.5 | IaC 工具 |

---

## 7. 快速开始

```bash
# 1. 克隆仓库
git clone https://github.com/huaweicloud-samples/data-integration-s3-cross-account-replication.git
cd data-integration-s3-cross-account-replication

# 2. 配置凭据
export HW_ACCESS_KEY="your-access-key"
export HW_SECRET_KEY="your-secret-key"

# 3. 初始化
cd infra
terraform init

# 4. 预览
terraform plan

# 5. 部署
terraform apply
```

---

## 8. 分步部署

### 8.1 创建源区域资源

1. 创建源区域 VPC
2. 创建源 OBS 桶（启用版本控制）
3. 配置复制规则
4. 创建 IAM 委托

### 8.2 创建目标区域资源

1. 创建目标区域 VPC
2. 创建目标 OBS 桶
3. 创建 IAM 委托

### 8.3 配置事件触发

1. 创建 FunctionGraph 函数
2. 配置 OBS 事件触发器

---

## 9. 使用方法 / 验证

### 9.1 上传对象到源桶

```bash
# 使用 OBS 控制台或 SDK 上传对象
# 对象将自动复制到目标桶
```

### 9.2 验证复制

```bash
# 检查目标桶是否收到复制对象
terraform output destination_bucket
```

### 9.3 验证事件触发

```bash
# 查看函数日志
huaweicloud fgs function logs <function-name>
```

---

## 10. 清理资源

```bash
terraform destroy
```

---

## 11. 详细说明

### 11.1 复制配置

OBS 跨区域复制规则：
- 目标桶：指定目标区域和桶名
- 复制模式：全量复制或增量复制
- 存储类型：标准存储或低频存储

### 11.2 IAM 委托

跨区域复制需要配置 IAM 委托，允许源区域访问目标区域资源。

---

## 12. 许可证

本项目采用 MIT No Attribution 许可证。详情请查看 [LICENSE](LICENSE)。

---

## 13. 依赖与致谢

### 主要依赖

| 依赖 | 版本 | 用途 |
|------|------|------|
| Terraform | >= 1.5 | IaC 编排 |
| huaweicloud provider | ~> 1.70 | 华为云资源 |

### 致谢

- 华为云官方文档
- Terraform 社区

---

## 14. FAQ / 故障排除

### Q1: 复制规则配置失败怎么办？

**A**: 请确保：
1. 源桶和目标桶都已启用版本控制
2. IAM 委托已正确配置
3. 目标区域与源区域不同

### Q2: 复制延迟过高怎么办？

**A**: OBS 跨区域复制通常有几分钟延迟，属于正常现象。

### Q3: 如何查看复制状态？

**A**: 在 OBS 控制台桶详情页，选择「数据管理」→「跨区域复制」查看状态。

### Q4: 费用如何计算？

**A**: OBS 跨区域复制会产生以下费用：
- 源桶存储费用
- 目标桶存储费用
- 跨区域流量费用

---

## 15. 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/xxx`)
3. 提交更改 (`git commit -m 'Add xxx'`)
4. 推送分支 (`git push origin feature/xxx`)
5. 创建 Pull Request

---

## 16. 维护者

- **维护团队**: 华为云解决方案架构团队
- **联系邮箱**: support@huaweicloud.com

---

## 17. 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0.0 | 2026-09-19 | 初始版本，支持跨区域复制 |

---

*本项目基于华为云最佳实践构建*
