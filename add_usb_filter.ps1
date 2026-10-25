# add_usb_filter.ps1 —— 宿主机 Windows 上给 ReverseLab 虚拟机配 RTL8812AU USB 直通
# 需要：VirtualBox + Extension Pack（支持 USB 3.0 直通）
# 以管理员 PowerShell 运行

$ErrorActionPreference = "Stop"
$VBOX = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$VM   = "ReverseLab"
$VID  = "0bda"   # Realtek
$PID  = "8812"   # RTL8812AU

# 1) 设 USB 控制器为 3.0 (xHCI)
& $VBOX modifyvm $VM --usb on
& $VBOX modifyvm $VM --usbxhci on
Write-Host "[+] USB 3.0 (xHCI) 已开启"

# 2) 加一条 USB 设备过滤器（插上 0bda:8812 自动进 VM）
$filters = & $VBOX showvminfo $VM --machinereadable | Select-String '^USBFilter'
$exists = $filters | Where-Object { $_ -match "0bda" -and $_ -match "8812" }
if (-not $exists) {
    & $VBOX usbfilter add 0 --target $VM --name "RTL8812AU-WiFi" --vendorid $VID --productid $PID
    Write-Host "[+] 已添加 USB 过滤器 0bda:8812 (插上自动直通进 VM)"
} else {
    Write-Host "[=] 过滤器已存在，跳过"
}

# 3) 提示 Extension Pack
$ext = & $VBOX list extpacks 2>$null
if ($ext -notmatch "Oracle VM VirtualBox Extension Pack") {
    Write-Warning "未检测到 Extension Pack！请先安装（否则 USB 3.0 直通不可用）。"
    Write-Host "下载: https://www.virtualbox.org/wiki/Downloads"
} else {
    Write-Host "[+] Extension Pack 已安装"
}

Write-Host "`n完成。启动 ReverseLab 后插上网卡，VM 里 lsusb 应能看到 Realtek 0bda:8812。"
