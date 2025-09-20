# GitHub Hosts文件更新脚本
# 按照GitHub访问问题解决方案文档执行

# 备份当前hosts文件
try {
    $backupPath = "C:\Windows\System32\drivers\etc\hosts.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item "C:\Windows\System32\drivers\etc\hosts" $backupPath -ErrorAction Stop
    Write-Host "Hosts文件已备份到: $backupPath" -ForegroundColor Green
}
catch {
    Write-Host "备份失败，可能需要管理员权限" -ForegroundColor Yellow
}

# 读取当前hosts文件内容
$hostsContent = Get-Content "C:\Windows\System32\drivers\etc\hosts"

# 移除所有GitHub相关的旧条目
$newContent = @()
$inGitHubSection = $false

foreach ($line in $hostsContent) {
    if ($line -match "# GitHub") {
        $inGitHubSection = $true
        continue
    }
    
    if ($inGitHubSection -and ($line -match "^#" -or $line.Trim() -eq "")) {
        $inGitHubSection = $false
    }
    
    if (-not $inGitHubSection -and -not ($line -match "(github\.com|github\.global\.ssl\.fastly\.net|assets-cdn\.github\.com)")) {
        $newContent += $line
    }
}

# 添加最新的GitHub IP地址映射（按照解决方案文档格式）
$githubEntries = @"
# GitHub Start
20.205.243.166 github.com
20.205.243.166 api.github.com
199.59.149.207 github.global.ssl.fastly.net
185.199.108.153 assets-cdn.github.com
# GitHub End
"@

$newContent += $githubEntries.Split("`n")

# 写入新的hosts文件
try {
    Set-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value $newContent -ErrorAction Stop
    Write-Host "Hosts文件已成功更新" -ForegroundColor Green
}
catch {
    Write-Host "写入失败，请以管理员身份运行此脚本" -ForegroundColor Red
    exit 1
}

# 刷新DNS缓存
ipconfig /flushdns
Write-Host "DNS缓存已刷新" -ForegroundColor Green

# 验证连接
Write-Host "验证GitHub连接..." -ForegroundColor Cyan
$testResult = Test-NetConnection -ComputerName github.com -Port 443
if ($testResult.TcpTestSucceeded) {
    Write-Host "✓ GitHub 443端口连接测试成功" -ForegroundColor Green
}
else {
    Write-Host "✗ GitHub 443端口连接测试失败" -ForegroundColor Red
}

try {
    $webResult = Invoke-WebRequest -Uri "https://github.com" -Method Head -ErrorAction Stop
    Write-Host "✓ GitHub HTTPS访问测试成功 (状态码: $($webResult.StatusCode))" -ForegroundColor Green
}
catch {
    Write-Host "✗ GitHub HTTPS访问测试失败: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n更新完成！请尝试在浏览器中访问 https://github.com" -ForegroundColor Cyan