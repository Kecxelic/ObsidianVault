# 简单的GitHub hosts更新脚本
# 严格按照GitHub访问问题解决方案文档执行

Write-Host "=== GitHub访问问题解决方案执行 ===" -ForegroundColor Cyan

# 步骤1：获取最新IP地址（使用Google DNS）
Write-Host "1. 查询最新GitHub IP地址..." -ForegroundColor Yellow

$githubIP = ""
$assetsIP = ""
$fastlyIP = ""

try {
    # 查询github.com
    $result = nslookup github.com 8.8.8.8 2>$null
    if ($result -match "Address:\s+([0-9.]+)") {
        $githubIP = $matches[1]
        Write-Host "   github.com: $githubIP" -ForegroundColor Green
    }
    
    # 查询assets-cdn.github.com
    $result = nslookup assets-cdn.github.com 8.8.8.8 2>$null
    if ($result -match "Address:\s+([0-9.]+)") {
        $assetsIP = $matches[1]
        Write-Host "   assets-cdn.github.com: $assetsIP" -ForegroundColor Green
    }
    
    # 查询github.global.ssl.fastly.net
    $result = nslookup github.global.ssl.fastly.net 8.8.8.8 2>$null
    if ($result -match "Address:\s+([0-9.]+)") {
        $fastlyIP = $matches[1]
        Write-Host "   github.global.ssl.fastly.net: $fastlyIP" -ForegroundColor Green
    }
}
catch {
    Write-Host "   DNS查询失败，使用备用IP地址" -ForegroundColor Yellow
    $githubIP = "20.205.243.166"
    $assetsIP = "185.199.108.153"
    $fastlyIP = "199.232.69.194"
}

# 步骤2：更新Hosts文件
Write-Host "2. 更新Hosts文件..." -ForegroundColor Yellow

$hostsPath = "C:\Windows\System32\drivers\etc\hosts"
$hostsContent = Get-Content $hostsPath

# 移除旧的GitHub相关条目
$newContent = @()
$skipNextLines = $false

foreach ($line in $hostsContent) {
    if ($line -match "# GitHub" -or $line -match "github") {
        $skipNextLines = $true
        continue
    }
    
    if ($skipNextLines -and ($line -match "^#" -or $line.Trim() -eq "")) {
        $skipNextLines = $false
    }
    
    if (-not $skipNextLines -and -not ($line -match "github")) {
        $newContent += $line
    }
}

# 添加新的GitHub条目
$newContent += ""
$newContent += "# GitHub Start"
$newContent += "$githubIP github.com"
$newContent += "$githubIP api.github.com"
$newContent += "$fastlyIP github.global.ssl.fastly.net"
$newContent += "$assetsIP assets-cdn.github.com"
$newContent += "# GitHub End"

# 写入文件
try {
    Set-Content -Path $hostsPath -Value $newContent -ErrorAction Stop
    Write-Host "   Hosts文件更新成功" -ForegroundColor Green
}
catch {
    Write-Host "   写入失败！请以管理员身份运行PowerShell" -ForegroundColor Red
    Write-Host "   右键点击PowerShell，选择'以管理员身份运行'" -ForegroundColor Red
    exit 1
}

# 步骤3：刷新DNS缓存
Write-Host "3. 刷新DNS缓存..." -ForegroundColor Yellow
ipconfig /flushdns
Write-Host "   DNS缓存已刷新" -ForegroundColor Green

# 步骤4：验证连接
Write-Host "4. 验证GitHub连接..." -ForegroundColor Yellow

# 测试443端口
$testResult = Test-NetConnection -ComputerName github.com -Port 443
if ($testResult.TcpTestSucceeded) {
    Write-Host "   ✓ 443端口连接测试成功" -ForegroundColor Green
}
else {
    Write-Host "   ✗ 443端口连接测试失败" -ForegroundColor Red
}

# 测试HTTPS访问
try {
    $webResult = Invoke-WebRequest -Uri "https://github.com" -Method Head -ErrorAction Stop
    Write-Host "   ✓ HTTPS访问测试成功 (状态码: $($webResult.StatusCode))" -ForegroundColor Green
}
catch {
    Write-Host "   ✗ HTTPS访问测试失败" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== 执行完成 ===" -ForegroundColor Cyan
Write-Host "请尝试在浏览器中访问: https://github.com" -ForegroundColor Cyan
Write-Host "如果仍有问题，请以管理员身份运行此脚本" -ForegroundColor Yellow