# RTL8812AU Kali 无线实战手册（已购 · 待到货）

> 写于：2026-10-25　状态：已下单付款，等快递。网卡到货前先把环境 100% 准备好，到货插上即用。
> 思路：**不买 B 启动盘也完全够用**——你机器里已有 VirtualBox 虚拟机 `ReverseLab`（Ubuntu 64位），
> 把网卡 USB 直通进去 + 装好驱动和 aircrack 套件，就是一台完整的 Kali 实验室。省下的 44 块留着。

---

## 一、已购商品信息卡（PDD 订单页实抓）

| 字段 | 内容 |
|---|---|
| 商品标题 | kali抓包网卡Linux **RTL8812AU**无线网卡双频5G免驱wifi可接收发射 |
| 型号（SKU） | **8812AU监听和注入**（双频 2.4G + 5G） |
| 店铺 | 花生WiFi |
| 芯片 | Realtek **RTL8812AU**（USB ID `0bda:8812`） |
| 能力 | 监听模式(monitor) + 注入(injection) + 可接收发射 —— 即 Kali 抓包/破解握手包所需 |
| 价格 | 券后 **¥59.9**（券前 ¥66.9，已自动领 7 元券 + 9 折），**免运费** |
| 销量 | 商品页已拼 302 件 / 该型号已拼 171 件 |
| goods_id | `900332942779` |
| 分享短链 | `https://mobile.yangkeduo.com/goods.html?ps=nL8qGhMtBz` |
| 收货 | 李 172****1072，山东省淄博市张店区纳奇路幸福家园多多驿站 |
| 不选的坑 | 「2.4高稳定监听和注入」= 单频 2.4G 款（¥36 基础款）——居民楼大家都在 5G，单频卡看不到 5G 网络，抓不到包，**已排除** |

> 为什么不是基础款：PDD 评价里有人写「不要贪小便宜买2.4g的，一般居民楼里用2.4的人不多，导致抓包也抓不到，主要还是用5g的人比较多」。双频 RTL8812AU 才是对的。

---

## 二、你的本机环境（已实测）

| 项 | 情况 |
|---|---|
| 系统 | Windows 10 专业工作站版 64位（THUNDEROBOT 911Pro / i7-10750H / RTX2070S） |
| 双系统 / WSL / Linux 分区 | **无** |
| 虚拟机 | VirtualBox「**ReverseLab**」= Ubuntu 64位（内存 4GB / 4 CPU，当前关机） |
| 其他 VM | 「1」= Windows 11（用不上） |
| 虚拟化 | Hyper-V 已启用；VMware Workstation 已装 |
| 已登录 Chrome | 拼多多网页版（`_pdd_chrome_profile_cdp` 存登录态，后续查物流直接复用） |

结论：用 **ReverseLab（Ubuntu VM）** 当实验主机，网卡走 **VirtualBox USB 直通** 进去。

---

## 三、开箱后一步步操作（到货照做）

### 第 1 步：启动 ReverseLab 并装工具
VM 里打开终端，一次性装齐（脚本见 `setup_reverselab.sh`，sudo 跑即可）：
```bash
sudo bash setup_reverselab.sh
```
会装：`aircrack-ng` `hostapd` `tcpdump` `wireshark` `hashcat` `iw` `macchanger`，
以及 RTL8812AU 驱动 `realtek-rtl88xxau-dkms`。

### 第 2 步：VirtualBox 配 USB 直通（宿主机 Windows 上做，已写好 `add_usb_filter.ps1`）
- ReverseLab 的 USB 控制器已设为 **USB 2.0 (EHCI)**——**无需 Extension Pack** 即可直通（RTL8812AU 跑 USB2 速度完全够用）。想上 USB 3.0 速度再装 Extension Pack（可选，非必需）。
- （早期方案配过 USB 3.0/xHCI，但 Extension Pack 官方 7.2.14 下载路径 404，故改 EHCI 一劳永逸。）
- 加一条 USB 设备过滤器：`Vendor ID 0bda` / `Product ID 8812`（RTL8812AU）。
  这样网卡一插，自动进 VM，不用手动选。
```powershell
# 宿主机 PowerShell（管理员）
.\add_usb_filter.ps1
```

### 第 3 步：插网卡，确认被 VM 认到
VM 里：
```bash
lsusb | grep -i 8812        # 应看到 Realtek 0bda:8812
iwconfig                    # 应出现 wlan0
```

### 第 4 步：开监听模式
```bash
sudo airmon-ng check kill   # 杀掉会抢网卡的服务
sudo airmon-ng start wlan0   # 生成 wlan0mon
iwconfig                    # 确认 wlan0mon 为 Monitor 模式
```

### 第 5 步：第一个实战——抓自己手机热点的握手包
```bash
sudo airodump-ng wlan0mon -w ~/cap/myap -c 6 --bssid XX:XX:XX:XX:XX:XX
# 另开终端对该热点做个 deauth，逼客户端重连，即可抓到 WPA 握手包
sudo aireplay-ng -0 2 -a XX:XX:XX:XX:XX:XX -c CC:CC:CC:CC:CC:CC wlan0mon
# 拿到握手包后跑字典
aircrack-ng ~/cap/myap-*.cap -w /usr/share/wordlists/rockyou.txt
```

---

## 四、排错速查

| 现象 | 原因/解法 |
|---|---|
| `airmon-ng start` 后没 wlan0mon | 驱动没加载：`sudo modprobe 88XXau`；或 dkms 没装好重装 `realtek-rtl88xxau-dkms` |
| VM 里 `lsusb` 看不到网卡 | USB 过滤器没配对 / 控制器不是 3.0 / 没装 Extension Pack |
| 监听模式一开就掉线 | `airmon-ng check kill` 没杀 NetworkManager；或hub 供电不足，换机箱后置 USB |
| 抓不到握手包 | 目标 AP 不在 5G 就切 `-c` 信道；确认 BSSID 正确；deauth 数量调大 |
| Windows 上 Hyper-V 和 VirtualBox 冲突 | 用 VirtualBox 6+ 的 Hyper-V 兼容后端，或关 Hyper-V 用裸 VirtualBox |

---

## 五、后续学习路线（按顺序）

1. **现在**：等网卡 → 跑通上面第 1–5 步，抓到自己热点握手包 = 第一课毕业。
2. **下一步**：弄个软路由 / 或开手机热点当靶场，练 `airodump-ng` 抓握、 `aircrack-ng` 跑字典。
3. **再往后**：想便携 Kali 再补 B 启动盘；想玩网络层搞软路由；猫池先别碰（重装备+法律红线）。
4. **不买清单**：B 启动盘（¥44，已有 VM 替代）、2.4G 单频基础款（坑）。

---

## 六、文件清单（本仓库）

- `RTL8812AU_Kali实战手册.md` —— 本文件
- `setup_reverselab.sh` —— VM 内一键装工具+驱动
- `add_usb_filter.ps1` —— 宿主机配 VirtualBox USB 直通
- `记忆/RTL8812AU_Kali实战记忆.md` —— 购入+环境+计划摘要（存进中枢记忆）
