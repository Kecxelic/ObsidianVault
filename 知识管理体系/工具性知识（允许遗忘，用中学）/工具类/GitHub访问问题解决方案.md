# GitHub访问问题解决方案

## 问题现象
- 网络连通性正常（ping github.com 成功）
- HTTPS端口443连接被拒绝
- 浏览器无法访问GitHub

## 诊断流程

### 1. 基础网络检查
```powershell
# 检查DNS解析
nslookup github.com

# 测试网络连通性  
ping github.com

# 测试443端口连通性
Test-NetConnection -ComputerName github.com -Port 443
```

### 2. 防火墙检查
```powershell
# 查看防火墙状态
netsh advfirewall show currentprofile
```

### 3. 代理设置检查
```powershell
# 检查系统代理设置
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable
```

### 4. 路由追踪
```powershell
# 追踪网络路由
tracert github.com
```

## 解决方案：修改Hosts文件

### 步骤1：获取最新IP地址
```powershell
# 使用Google DNS查询最新IP
nslookup github.com 8.8.8.8
nslookup assets-cdn.github.com 8.8.8.8  
nslookup github.global.ssl.fastly.net 8.8.8.8
```

### 步骤2：更新Hosts文件
以管理员身份运行PowerShell：

```powershell
# 添加GitHub域名IP映射
$hostsContent = @"
# GitHub Start
140.82.113.3 github.com
185.199.108.153 assets-cdn.github.com
199.232.69.194 github.global.ssl.fastly.net
# GitHub End
"@

Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value $hostsContent -Force
```

### 步骤3：刷新DNS缓存
```powershell
# 刷新DNS缓存
ipconfig /flushdns
```

### 步骤4：验证连接
```powershell
# 测试443端口连接
Test-NetConnection -ComputerName github.com -Port 443

# 测试HTTPS访问（PowerShell方式）
Invoke-WebRequest -Uri "https://github.com" -Method Head
```

## 备用方案

### 方案1：使用VPN
如果修改hosts后仍无法访问，建议使用VPN服务

### 方案2：定期更新IP
GitHub的IP地址可能会变化，建议定期检查并更新：
1. 访问 IPAddress.com 查询最新IP
2. 或使用 `nslookup github.com 8.8.8.8`
3. 更新hosts文件中的IP地址

## 常见问题排查

### 问题1：curl命令在PowerShell中报错
```powershell
# 错误：找不到驱动器。名为'https'的驱动器不存在
# 解决方案：使用PowerShell原生命令
Invoke-WebRequest -Uri "https://github.com" -Method Head
```

### 问题2：权限不足
- 修改hosts文件需要管理员权限
- 以管理员身份运行PowerShell或命令提示符

### 问题3：IP地址失效
- GitHub的IP地址可能会变化
- 定期检查并更新hosts文件

## 验证成功的标志
- `Test-NetConnection -ComputerName github.com -Port 443` 返回 `TcpTestSucceeded: True`
- `Invoke-WebRequest -Uri "https://github.com" -Method Head` 返回 `StatusCode: 200`
- 浏览器可以正常访问GitHub

## 注意事项
1. 修改hosts文件前建议备份原文件
2. 操作完成后务必刷新DNS缓存
3. 如果问题依旧，可能是本地网络环境限制，建议联系网络管理员

## 最后更新
2024年验证有效的IP地址：
- github.com: 140.82.113.3  
- assets-cdn.github.com: 185.199.108.153
- github.global.ssl.fastly.net: 199.232.69.194

> 注意：IP地址可能会变化，请以实际查询结果为准