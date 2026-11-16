# data-integration-s3-cross-account-replication / OBS Cross-Region Replication

[![License](https://img.shields.io/badge/License-MIT%20No%20Attribution-blue.svg)](LICENSE)
[![Huawei Cloud](https://img.shields.io/badge/Huawei%20Cloud-IAM%20Auth-red.svg)](https://support.huaweicloud.com/intl/en-us/)

> Huawei Cloud OBS Cross-Region Replication Best Practice

---

## 1. Overview

This practice provides OBS cross-region replication capability for data disaster recovery and cross-region data synchronization. Designed for operations engineers and architects as a reference architecture or learning example.

### Core Capabilities

- **Cross-Region Replication**: Automatic replication from source bucket to destination bucket (OBS native)
- **Versioning**: Object version management support
- **Custom Prefix**: Rewrite destination path prefix during replication (no function needed)
- **Lifecycle Management**: Optional object lifecycle rules

---

## 2. Table of Contents

- [1. Overview](#1-overview-critical)
- [2. Table of Contents](#2-table-of-contents)
- [3. Architecture Diagram](#3-architecture-diagram)
- [4. Highlights](#4-highlights)
- [5. Cloud Services Used](#5-cloud-services-used)
- [6. Prerequisites](#6-prerequisites-critical)
- [7. Quick Start](#7-quick-start-critical)
- [8. Step-by-Step Deployment](#8-step-by-step-deployment)
- [9. Usage / Verification](#9-usage--verification-critical)
- [10. Cleanup](#10-cleanup)
- [11. Detailed Explanation](#11-detailed-explanation)
- [12. License](#12-license-critical)

---

## 3. Architecture Diagram

> Cross-region replication: Source OBS → Destination OBS

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

---

## 4. Highlights

- **Automatic Replication**: Automatic cross-region replication after configuration
- **High Availability**: Versioning support, data security
- **Event-Driven**: Object events trigger function processing
- **Flexible Prefix**: Custom destination path support

---

## 5. Cloud Services Used

| Service | Purpose | Notes |
|---|---|---|
| OBS | Object Storage | Source and destination buckets |
| IAM | Identity & Access | Cross-region agency |
| FunctionGraph | Serverless | Event processing |

---

## 6. Prerequisites

| Item | Requirement | Description |
|---|---|---|
| Huawei Cloud Account | Registered | Requires OBS/IAM/FunctionGraph permissions |
| AK/SK | Obtained | Create in "My Credentials" |
| Terraform | >= 1.5 | IaC tool |

---

## 7. Quick Start

```bash
# 1. Clone repository
git clone https://github.com/huaweicloud-samples/data-integration-s3-cross-account-replication.git
cd data-integration-s3-cross-account-replication

# 2. Configure credentials
export HW_ACCESS_KEY="your-access-key"
export HW_SECRET_KEY="your-secret-key"

# 3. Initialize
cd infra
terraform init

# 4. Preview
terraform plan

# 5. Deploy
terraform apply
```

---

## 8. Step-by-Step Deployment

### 8.1 Create Source Region Resources

1. Create source region VPC
2. Create source OBS bucket (enable versioning)
3. Configure replication rules
4. Create IAM agency

### 8.2 Create Destination Region Resources

1. Create destination region VPC
2. Create destination OBS bucket
3. Create IAM agency

### 8.3 Configure Event Trigger

1. Create FunctionGraph function
2. Configure OBS event trigger

---

## 9. Usage / Verification

### 9.1 Upload Object to Source Bucket

```bash
# Use OBS console or SDK to upload objects
# Objects will automatically replicate to destination bucket
```

### 9.2 Verify Replication

```bash
# Check if destination bucket received replicated objects
terraform output destination_bucket
```

### 9.3 Verify Event Trigger

```bash
# View function logs
huaweicloud fgs function logs <function-name>
```

---

## 10. Cleanup

```bash
terraform destroy
```

---

## 11. Detailed Explanation

### 11.1 Replication Configuration

OBS cross-region replication rules:
- Destination bucket: Specify destination region and bucket name
- Replication mode: Full or incremental
- Storage class: Standard or IA

### 11.2 IAM Agency

Cross-region replication requires IAM agency configuration to allow source region to access destination region resources.

---

## 12. License

This project uses MIT No Attribution license. See [LICENSE](LICENSE) for details.

---

## 13. Dependencies & Acknowledgments

### Main Dependencies

| Dependency | Version | Purpose |
|------------|---------|---------|
| Terraform | >= 1.5 | IaC orchestration |
| huaweicloud provider | ~> 1.70 | Huawei Cloud resources |

### Acknowledgments

- Huawei Cloud Official Documentation
- Terraform Community

---

## 14. FAQ / Troubleshooting

### Q1: Replication rule configuration fails. What should I do?

**A**: Please ensure:
1. Both source and destination buckets have versioning enabled
2. IAM agency is properly configured
3. Destination region is different from source region

### Q2: Replication latency is too high. What should I do?

**A**: OBS cross-region replication typically has a few minutes delay, which is normal.

### Q3: How to check replication status?

**A**: In OBS console, go to bucket details → Data Management → Cross-Region Replication.

### Q4: How is billing calculated?

**A**: OBS cross-region replication incurs:
- Source bucket storage fees
- Destination bucket storage fees
- Cross-region traffic fees

---

## 15. Contributing Guide

Contributions are welcome!

1. Fork this repository
2. Create feature branch (`git checkout -b feature/xxx`)
3. Commit changes (`git commit -m 'Add xxx'`)
4. Push branch (`git push origin feature/xxx`)
5. Create Pull Request

---

## 16. Maintainers

- **Team**: Huawei Cloud Solution Architecture Team
- **Email**: support@huaweicloud.com

---

## 17. Version History

| Version | Date | Description |
|---------|------|-------------|
| v1.0.0 | 2026-09-19 | Initial release, supports cross-region replication |

---

*Built with Huawei Cloud Best Practices*
