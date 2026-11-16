# 架构说明

## 概述

本实践实现了 OBS 跨区域复制功能，等价于 AWS S3 跨账户复制。

## 架构图

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

## 组件说明

### 源 OBS 桶
- 启用版本控制（跨区域复制的前提条件）
- 配置跨区域复制规则：指定目标桶、存储类别与目标对象 key 前缀
- 引用 IAM 委托完成跨区域写入授权

### 目标 OBS 桶
- 启用版本控制
- 接收源桶复制过来的对象，保持版本信息
- 可选：配置生命周期规则，到期自动转归档存储

### IAM 委托
- 授予源区域写入目标区域桶的权限
- 同时覆盖源区域与目标区域的项目角色（OBS OperateAccess）
- 委托名称由复制规则中的 `role` 字段引用

> 说明：目标对象 key 前缀由 OBS 复制规则原生支持（`destination_object_key_prefix`），
> 前、后缀改写无需额外的函数计算组件。
