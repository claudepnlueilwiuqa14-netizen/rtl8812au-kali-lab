#!/usr/bin/env bash
# setup_reverselab.sh —— 在 ReverseLab (Ubuntu) 虚拟机里一键装好 Kali WiFi 实验环境
# 用法:  sudo bash setup_reverselab.sh
set -e
echo "[*] 更新软件源..."
sudo apt-get update -y

echo "[*] 安装 aircrack-ng 套件 + 抓包/破解工具..."
sudo apt-get install -y \
  aircrack-ng \
  hostapd \
  tcpdump \
  wireshark \
  hashcat \
  iw \
  iwconfig \
  macchanger \
  wireless-tools

echo "[*] 安装 RTL8812AU 驱动 (realtek-rtl88xxau-dkms)..."
# Kali/Ubuntu 新版本已带此 dkms 包；若源里没有则走 git 编译兜底
if apt-cache show realtek-rtl88xxau-dkms >/dev/null 2>&1; then
  sudo apt-get install -y realtek-rtl88xxau-dkms
else
  echo "[!] 源里没有 dkms 包，走 github 编译安装..."
  sudo apt-get install -y build-essential dkms git
  git clone https://github.com/aircrack-ng/rtl8812au.git /tmp/rtl8812au
  cd /tmp/rtl8812au
  sudo make dkms_install
fi

echo "[*] 载入驱动模块..."
sudo modprobe 88XXau || sudo modprobe rtl8812au || true

echo "[*] 准备字典 (rockyou)..."
if [ -f /usr/share/wordlists/rockyou.txt.gz ]; then
  sudo gunzip -kf /usr/share/wordlists/rockyou.txt.gz
fi

echo "[*] 验证 aircrack-ng 可用..."
which airodump-ng aircrack-ng airmon-ng

echo "[+] 完成。插上网卡后:  lsusb | grep 8812  然后  sudo airmon-ng start wlan0"
