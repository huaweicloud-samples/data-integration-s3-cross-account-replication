# 部署指导书

## 前置条件

1. 已注册华为云账号
2. 已获取 Access Key 和 Secret Key
3. 已安装 Terraform (>= 1.5)

## 步骤 1：配置凭据

```bash
export HW_ACCESS_KEY="your-access-key"
export HW_SECRET_KEY="your-secret-key"
export HW_REGION="cn-north-4"
export HW_TARGET_DOMAIN_ID="your-domain-id"
```

## 步骤 2：初始化 Terraform

```bash
cd infra
terraform init
```

## 步骤 3：预览资源

```bash
terraform plan
```

## 步骤 4：创建资源

```bash
terraform apply
```

## 验证部署

```bash
# 获取输出
terraform output

# 上传测试对象
# 在 OBS 控制台上传文件到源桶

# 验证复制
# 检查目标桶是否收到复制对象
```

## 资源清理

```bash
terraform destroy
```
