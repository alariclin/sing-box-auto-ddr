# 📦 Aio-box

- **[📖 中文说明](#-中文说明) | [🌐 English Description](#-english-description)**
- **致谢:** 感谢开源社区中优秀的网络路由与加密项目（如 Xray-core、Sing-box、Hysteria 等）提供的底层技术启发与支持。本项目为独立的学习与自动化运维工具。
- Credits: Thanks to the excellent network routing and encryption projects in the open-source community, including Xray-core, sing-box, Hysteria, and related projects, for providing the underlying technical inspiration and support. This project is an independent learning and automated operations tool.

[![Version](https://img.shields.io/badge/Version-2026.05.04-success.svg?style=flat-square)]()
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg?style=flat-square)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/alariclin/aio-box?style=flat-square&color=yellow)](https://github.com/alariclin/aio-box/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/alariclin/aio-box?style=flat-square&color=orange)](https://github.com/alariclin/aio-box/network/members)

---

<a name="-中文说明"></a>

## 📖 中文说明

**Aio-box** 是一款面向 Linux 服务器的自动化网络加密隧道部署与运维脚本。当前版本围绕 **Xray-core、sing-box、官方 Hysteria 2** 三类核心构建，提供 VLESS-Reality、VLESS-XHTTP-Reality、Shadowsocks-2022、Hysteria 2、系统调优、流量管控、白名单、防御探针、SNI 优选、Cloudflare WARP、Swap 划拨与中英文界面切换。

> ⚠️ 合规与免责声明：本项目定位为网络架构测试、网络安全研究与个人隐私保护的自动化部署工具。
> 1. 法律合规性：严禁利用本项目提供的脚本及技术手段从事任何违反所在国家或地区法律法规的活动。用户在使用本工具时，必须确保其行为符合当地电信管理、网络安全及互联网信息服务的相关规定。
> 2. 责任界定：本项目仅供授权环境下的技术交流、协议研究与合规的隐私安全加固使用。因用户违反法律法规、不当操作或滥用工具而产生的任何直接或间接法律责任、安全风险，均由使用者本人承担，项目开发者不承担任何连带责任。
> 3. 技术属性：本项目所涉及的加密协议与路由技术，旨在提升数据传输的安全性与私密性。严禁将本工具用于任何形式的非法攻击、非法跨境接入或其他危害网络基础设施安全的目的。
> 4. 最终解释权：下载、复制或运行本脚本即视为您已完全阅读、理解并同意本声明的所有条款。

---

### 📑 目录

1. [✨ 核心特性](#-features-cn)
2. [🏗️ 架构与协议组合](#-arch-cn)
3. [🚀 快速部署](#-deploy-cn)
4. [🛠️ 运维与管理](#-ops-cn)
5. [📋 菜单功能说明](#-menu-cn)
6. [🧩 参数与协议建议](#-params-cn)
7. [💻 系统要求](#-system-requirements)
8. [📄 许可证](#-license)

<a name="-features-cn"></a>

### ✨ 核心特性

| 模块 | 当前能力 |
| :--- | :--- |
| 自动化部署 | 一键部署 Xray、sing-box、官方 Hysteria 2；支持 Systemd / OpenRC。 |
| 双架构 | Xray + 官方 Hysteria 2 双核混编；sing-box 单核聚合。 |
| 协议组合 | VLESS-Vision-Reality、VLESS-XHTTP-Reality、Shadowsocks-2022、Hysteria 2。 |
| SNI策略 | 443 端口默认 `www.apple.com`；非 443 端口默认 `www.microsoft.com`；非 443 使用 Apple/iCloud 类 SNI 时提示风险并允许重设。 |
| XHTTP优化 | Xray XHTTP 默认导出 `mode=stream-one`；Clash/Mihomo 示例固定 `alpn: h2`、`smux: false`、`encryption: ""`。 |
| SS-2022 | 默认端口改为 `2053`；Xray 使用 `tcp,udp`；sing-box 不强制 network 字段，默认 TCP/UDP 双栈监听。 |
| HY2 | 官方 Hysteria 2 支持 ACME 域名证书、自签证书 + 指纹锁定、端口跳跃、masquerade 伪装站点。 |
| 语言切换 | 首次运行选择中文/英文；支持菜单 `20` 切换；支持 `--lang zh` / `--lang en`；配置持久化到 `/etc/ddr/.lang`。 |
| 启动加速 | 公网 IP 缓存至 `/etc/ddr/.public_ip.cache`，默认 TTL 600 秒；部署前强制刷新。 |
| 参数导出 | 输出 URI、QR、Clash/Mihomo YAML、sing-box 出站示例、v2rayN / v2rayNG XHTTP JSON。 |
| 工具箱 | bench.sh、Check.Place、100 域名本地 SNI 优选、Cloudflare WARP 管理、2G Swap 划拨。 |
| 运维防护 | BBR/FQ、KeepAlive、Fail2Ban、logrotate、健康探针、Geo 数据定时更新、vnStat 月流量熔断、SS-2022 白名单。 |
| 静态自测 | 支持 `--self-test`，检查输入校验、Xray/sing-box JSON 生成、SS-2022 2053、SNI 分离等关键逻辑。 |

---

<a name="-arch-cn"></a>

### 🏗️ 架构与协议组合

| 菜单 | 模式 | 默认端口 | 核心用途 |
| :--- | :--- | :--- | :--- |
| 1 | Xray VLESS-Vision-Reality | TCP 443 | 长期主力通道；443 默认 SNI 为 `www.apple.com`。 |
| 2 | Xray VLESS-XHTTP-Reality | TCP 8443 | 桌面高吞吐备用；非 443 默认 SNI 为 `www.microsoft.com`；推荐 Mihomo v1.19.24+。 |
| 3 | Xray Shadowsocks-2022 | TCP/UDP 2053 | 回程/落地入站；适合公共前置或机场前置后接入，建议配合白名单。 |
| 4 | 官方 Hysteria 2 | UDP 443 | UDP/QUIC/H3 加速；适合移动网络、丢包链路、端口跳跃场景。 |
| 5 | Xray + 官方 Hysteria 2 四合一 | Vision TCP 443 + XHTTP TCP 8443 + HY2 UDP 443 + SS-2022 TCP/UDP 2053 | 当前推荐的综合模式，兼顾隐蔽、速度、移动链路与链式回程。 |
| 6 | sing-box VLESS-Vision-Reality | TCP 443 | 低内存单进程 Vision 部署。 |
| 7 | sing-box Shadowsocks-2022 | TCP/UDP 2053 | 低内存 SS-2022 回程部署。 |
| 8 | sing-box VLESS + SS-2022 | TCP 443 + TCP/UDP 2053 | Vision 主路径 + SS-2022 回程路径。 |
| 9 | sing-box Hysteria 2 | UDP 443 | sing-box 承载 HY2。 |
| 10 | sing-box 三合一 | Vision + HY2 + SS-2022 | 低内存聚合模式；按设计不包含 XHTTP。 |

| 架构维度 | Xray-Hybrid | sing-box |
| :--- | :--- | :--- |
| 核心引擎 | Xray-core + 官方 Hysteria 2 | 纯 sing-box 核心 |
| 协议分配 | Xray 承载 TCP；官方 HY2 承载 UDP | 单进程承载 Vision / HY2 / SS-2022 |
| 资源占用 | 中等 | 低 |
| 推荐场景 | 追求 XHTTP、Vision、官方 HY2 的完整能力 | 小内存 VPS、轻量化统一管理 |

---

<a name="-deploy-cn"></a>

### 🚀 快速部署

**全球通道：**

```bash
curl -fsSL https://raw.githubusercontent.com/alariclin/aio-box/main/install.sh > aio.sh && sudo bash aio.sh
```

**镜像通道：**

```bash
curl -fsSL https://ghp.ci/https://raw.githubusercontent.com/alariclin/aio-box/main/install.sh > aio.sh && sudo bash aio.sh
```

**启动指定语言：**

```bash
sudo bash aio.sh --lang zh
sudo bash aio.sh --lang en
```

**静态自测：**

```bash
sudo bash aio.sh --self-test
```

安装后离线唤醒：

```bash
sb
```

---

<a name="-ops-cn"></a>

### 🛠️ 运维与管理

| 指令 | 作用 |
| :--- | :--- |
| `sb` | 打开 Aio-box 主菜单。 |
| `bash aio.sh --lang zh` | 使用中文界面启动，并保存语言设置。 |
| `bash aio.sh --lang en` | 使用英文界面启动，并保存语言设置。 |
| `bash aio.sh --self-test` | 运行无副作用静态自测。 |
| `bash aio.sh --help` | 显示命令行帮助。 |

---

<a name="-menu-cn"></a>

### 📋 菜单功能说明

| 菜单 | 名称 | 功能说明 | 常用设置 |
| :--- | :--- | :--- | :--- |
| 1 | Xray VLESS-Vision-Reality | 部署 TCP REALITY + Vision。适合作为长期主力。 | 端口 `443`；SNI 默认 `www.apple.com`；指纹 `chrome`；可开启 TCP KeepAlive。 |
| 2 | Xray VLESS-XHTTP-Reality | 部署 XHTTP over REALITY。适合桌面高速链路。 | 端口 `8443`；SNI 默认 `www.microsoft.com`；客户端推荐 Mihomo v1.19.24+；使用 `stream-one + h2 + smux:false`。 |
| 3 | Xray Shadowsocks-2022 | 部署 SS-2022 回程/落地节点。 | 默认 `2053/TCP+UDP`；推荐配合菜单 19 做前置机白名单。 |
| 4 | 官方 Hysteria 2 | 部署官方 HY2。 | 有域名用 ACME；无域名用自签 + `pinSHA256`；可开启端口跳跃。 |
| 5 | Xray + 官方 HY2 四合一 | 同机部署 Vision、XHTTP、HY2、SS-2022。 | 推荐综合模式：Vision 443、XHTTP 8443、HY2 UDP 443、SS-2022 2053。 |
| 6 | sing-box Vision | 用 sing-box 部署 VLESS-Vision-Reality。 | 适合低内存机器。 |
| 7 | sing-box SS-2022 | 用 sing-box 部署 SS-2022。 | 默认 `2053/TCP+UDP`。 |
| 8 | sing-box Vision + SS-2022 | Vision 主链路 + SS 回程。 | 适合需要前置/落地链路但不需要 HY2 的轻量配置。 |
| 9 | sing-box HY2 | 用 sing-box 部署 Hysteria 2。 | 适合 UDP/QUIC 移动链路。 |
| 10 | sing-box 三合一 | sing-box Vision + HY2 + SS-2022。 | 不包含 XHTTP。 |
| 11 | 综合工具箱 | 包含系统测速、IP 检测、本地 SNI 优选、WARP、Swap。 | 进入后选择 1-5。 |
| 12 | VPS 一键优化 | 注入 BBR/FQ、文件句柄、TCP KeepAlive、健康探针、logrotate/fail2ban。 | 部署后执行一次即可。 |
| 13 | 全部节点参数显示 | 输出 URI、二维码、Clash/Mihomo YAML、sing-box 出站、v2rayN/v2rayNG JSON。 | Clash/Mihomo 通常不能直接扫单条 `vless://` QR，优先复制 YAML 或订阅。 |
| 14 | 脚本说明书 | 在终端显示完整菜单解释和参数说明。 | 支持中文/英文界面。 |
| 15 | OTA 与 Geo 更新 | 更新 Aio-box 脚本与 Loyalsoldier `geoip.dat` / `geosite.dat`。 | Geo 每周一 03:00 自动更新。 |
| 16 | 清空卸载 | 删除代理栈、服务、防火墙规则。 | 可选择完全清场或保留 `sb` 入口。 |
| 17 | 环境初始化 | 清理残留进程、陈旧防火墙规则、破损配置与服务。 | 适合重装前修复环境。 |
| 18 | 每月流量管控 | 用 vnStat 统计月流量，超过阈值后停止服务。 | 适合有流量配额的云服务器。 |
| 19 | SS-2022 白名单 | 添加/删除前置机 IP/CIDR；对非白名单执行 DROP。 | 支持 IPv4 / IPv6 / CIDR；建议保护 `2053/TCP+UDP`。 |
| 20 | 语言设置 | 中文/英文切换。 | 保存到 `/etc/ddr/.lang`。 |

#### 菜单 11：综合工具箱子功能

| 子菜单 | 功能 | 说明 |
| :--- | :--- | :--- |
| 1 | bench.sh | VPS 基础硬件和下载测速。 |
| 2 | Check.Place | IP 纯净度、流媒体解锁与回程测试。 |
| 3 | 本地 SNI 优选 | 对 100 个全球白名单域名进行 DNS、TCP、TLS、TTFB 测试，用于筛选 REALITY SNI。 |
| 4 | Cloudflare WARP | 调用 fscarmen WARP 菜单脚本，管理 WARP 出站。 |
| 5 | 2G Swap | 创建 `/swapfile`，写入 `/etc/fstab`，用于降低小内存机器 OOM 风险。 |

---

<a name="-params-cn"></a>

### 🧩 参数与协议建议

| 参数 | 当前策略 |
| :--- | :--- |
| `Y/N` 输入 | 提示统一显示 `[Y/N]`；输入 `y` 或 `Y` 均视为确认。 |
| REALITY SNI | 443 默认 `www.apple.com`；非 443 默认 `www.microsoft.com`；非 443 使用 Apple/iCloud 类域名会提示风险。 |
| XHTTP | 推荐 `mode=stream-one`、`alpn: h2`、`smux:false`。 |
| SS-2022 | 默认 `2053/TCP+UDP`；建议只开放给前置机或使用白名单。 |
| HY2证书 | 有域名优先 ACME；无域名使用自签证书 + 指纹锁定。 |
| HY2伪装 URL | 只影响普通 HTTP/3 探测时展示的伪装页面，不等于 SNI 或证书。 |
| WARP | 作为出站网络管理工具使用，执行前会提示确认。 |
| Swap | 默认创建 2G `/swapfile`；若已存在则跳过重复创建。 |

---

<a name="-english-description"></a>

## 🌐 English Description

**Aio-box** is an automated encrypted tunnel deployment and operations script for Linux servers. The current version is built around **Xray-core, sing-box, and official Hysteria 2**, with support for VLESS-Reality, VLESS-XHTTP-Reality, Shadowsocks-2022, Hysteria 2, system tuning, traffic quota control, whitelist management, health probes, SNI benchmarking, Cloudflare WARP, Swap allocation, and Chinese/English UI switching.

> ⚠️ Compliance & Disclaimer：This project is positioned as an automated tool for network architecture testing, cybersecurity research, and personal privacy protection.

> 1. Legal Compliance: It is strictly prohibited to use the scripts and technologies provided by this project for any activities that violate the laws and regulations of your country or region. Users must ensure their actions comply with local telecommunications, cybersecurity, and internet service regulations.
> 2. Limitation of Liability: This project is intended for technical exchange, protocol research, and legitimate privacy enhancement under authorized environments. The user shall bear full responsibility for any legal consequences or security risks arising from non-compliance or improper use. The developers shall not be held liable for any such actions.
> 3. Technical Intent: The encryption protocols and routing technologies involved are designed to enhance data transmission security. Use of this tool for illegal attacks, unauthorized network access, or endangering network infrastructure is strictly forbidden.
> 4. Acceptance of Terms: By downloading, copying, or running this script, you acknowledge that you have read, understood, and agreed to all terms of this disclaimer.

---

### 📑 Table of Contents

1. [✨ Key Features](#-key-features)
2. [🏗️ Architecture and Protocol Layout](#-architecture-comparison)
3. [🚀 Quick Start](#-quick-start)
4. [🛠️ Management & Operations](#-management--operations)
5. [📋 Panel Menu Reference](#-menu-en)
6. [🧩 Parameter Notes](#-params-en)
7. [💻 System Requirements](#-system-requirements)
8. [📄 License](#-license)

<a name="-key-features"></a>

### ✨ Key Features

| Module | Current capability |
| :--- | :--- |
| Automated deployment | One-click deployment for Xray, sing-box, and official Hysteria 2; Systemd / OpenRC supported. |
| Dual architecture | Xray + official Hysteria 2 hybrid mode, or sing-box single-core mode. |
| Protocol set | VLESS-Vision-Reality, VLESS-XHTTP-Reality, Shadowsocks-2022, Hysteria 2. |
| SNI policy | Port 443 defaults to `www.apple.com`; non-443 defaults to `www.microsoft.com`; Apple/iCloud-like SNI on non-443 ports triggers a risk warning. |
| XHTTP tuning | Xray XHTTP exports `mode=stream-one`; Clash/Mihomo examples use `alpn: h2`, `smux: false`, and `encryption: ""`. |
| SS-2022 | Default port is `2053`; Xray uses `tcp,udp`; sing-box leaves `network` empty for TCP/UDP default behavior. |
| HY2 | Supports ACME domain certificates, self-signed certificate with pinning, port hopping, and masquerade URL. |
| Language switch | First-run language selection, menu item `20`, `--lang zh/en`, persisted in `/etc/ddr/.lang`. |
| Startup acceleration | Public IP cache at `/etc/ddr/.public_ip.cache`, default TTL 600 seconds; deployment refreshes IP before validation. |
| Export formats | URI, QR, Clash/Mihomo YAML, sing-box outbound examples, v2rayN/v2rayNG XHTTP JSON. |
| Toolbox | bench.sh, Check.Place, 100-domain local SNI benchmark, Cloudflare WARP manager, 2G Swap allocation. |
| Operations | BBR/FQ, KeepAlive, Fail2Ban, logrotate, health probe, Geo data cron update, vnStat monthly quota cutoff, SS-2022 whitelist. |
| Self-test | `--self-test` validates input checks, Xray/sing-box JSON generation, SS-2022 2053, and SNI split logic. |

---

<a name="-architecture-comparison"></a>

### 🏗️ Architecture and Protocol Layout

| Menu | Mode | Default ports | Purpose |
| :--- | :--- | :--- | :--- |
| 1 | Xray VLESS-Vision-Reality | TCP 443 | Long-term primary path; port 443 defaults to `www.apple.com`. |
| 2 | Xray VLESS-XHTTP-Reality | TCP 8443 | High-throughput desktop path; non-443 defaults to `www.microsoft.com`; Mihomo v1.19.24+ recommended. |
| 3 | Xray Shadowsocks-2022 | TCP/UDP 2053 | Relay / landing inbound; best behind frontend proxies with whitelist. |
| 4 | Native Hysteria 2 | UDP 443 | UDP/QUIC/H3 acceleration for mobile or lossy links. |
| 5 | Xray + Native HY2 All-in-one | Vision TCP 443 + XHTTP TCP 8443 + HY2 UDP 443 + SS-2022 TCP/UDP 2053 | Recommended balanced mode. |
| 6 | sing-box Vision | TCP 443 | Low-memory single-process Vision deployment. |
| 7 | sing-box SS-2022 | TCP/UDP 2053 | Low-memory SS-2022 relay deployment. |
| 8 | sing-box Vision + SS-2022 | TCP 443 + TCP/UDP 2053 | Vision main path plus SS relay. |
| 9 | sing-box HY2 | UDP 443 | HY2 on sing-box. |
| 10 | sing-box All-in-one | Vision + HY2 + SS-2022 | Low-memory unified mode; XHTTP intentionally excluded. |

| Dimension | Xray-Hybrid | sing-box |
| :--- | :--- | :--- |
| Core engines | Xray-core + official Hysteria 2 | Pure sing-box |
| Protocol split | Xray handles TCP; official HY2 handles UDP | One process handles Vision / HY2 / SS-2022 |
| Resource usage | Medium | Low |
| Best for | Full XHTTP, Vision, and native HY2 capability | Low-RAM VPS and unified management |

---

<a name="-quick-start"></a>

### 🚀 Quick Start

**Global channel:**

```bash
curl -fsSL https://raw.githubusercontent.com/alariclin/aio-box/main/install.sh > aio.sh && sudo bash aio.sh
```

**Mirror channel:**

```bash
curl -fsSL https://ghp.ci/https://raw.githubusercontent.com/alariclin/aio-box/main/install.sh > aio.sh && sudo bash aio.sh
```

**Start with selected language:**

```bash
sudo bash aio.sh --lang zh
sudo bash aio.sh --lang en
```

**Static self-test:**

```bash
sudo bash aio.sh --self-test
```

Offline launcher after installation:

```bash
sb
```

---

<a name="-management--operations"></a>

### 🛠️ Management & Operations

| Command | Purpose |
| :--- | :--- |
| `sb` | Open the Aio-box control panel. |
| `bash aio.sh --lang zh` | Start with Chinese UI and save language preference. |
| `bash aio.sh --lang en` | Start with English UI and save language preference. |
| `bash aio.sh --self-test` | Run static self-test without side effects. |
| `bash aio.sh --help` | Show CLI help. |

---

<a name="-menu-en"></a>

### 📋 Panel Menu Reference

| Menu | Name | Description | Common settings |
| :--- | :--- | :--- | :--- |
| 1 | Xray VLESS-Vision-Reality | Deploy TCP REALITY + Vision. Best as primary long-term path. | Port `443`; SNI defaults to `www.apple.com`; fingerprint `chrome`; TCP KeepAlive optional. |
| 2 | Xray VLESS-XHTTP-Reality | Deploy XHTTP over REALITY. Best for high-throughput desktop use. | Port `8443`; SNI defaults to `www.microsoft.com`; Mihomo v1.19.24+; `stream-one + h2 + smux:false`. |
| 3 | Xray Shadowsocks-2022 | Deploy SS-2022 relay / landing inbound. | Default `2053/TCP+UDP`; use menu 19 for frontend whitelist. |
| 4 | Native Hysteria 2 | Deploy official HY2. | ACME with domain when available; otherwise self-signed certificate + `pinSHA256`; port hopping optional. |
| 5 | Xray + Native HY2 All-in-one | Deploy Vision, XHTTP, HY2, and SS-2022 on one host. | Recommended balanced mode. |
| 6 | sing-box Vision | Deploy VLESS-Vision-Reality on sing-box. | Low-memory hosts. |
| 7 | sing-box SS-2022 | Deploy SS-2022 on sing-box. | Default `2053/TCP+UDP`. |
| 8 | sing-box Vision + SS-2022 | Vision main path plus SS relay. | Lightweight two-protocol mode. |
| 9 | sing-box HY2 | HY2 on sing-box. | UDP/QUIC mobile links. |
| 10 | sing-box All-in-one | sing-box Vision + HY2 + SS-2022. | XHTTP intentionally excluded. |
| 11 | Toolbox | Benchmark, IP check, local SNI benchmark, WARP, Swap. | Select submenu 1-5. |
| 12 | VPS One-click Optimization | BBR/FQ, file descriptor limits, TCP KeepAlive, health probe, logrotate/fail2ban. | Run once after deployment. |
| 13 | Display Node Parameters | Print URI, QR, Clash/Mihomo YAML, sing-box outbounds, v2rayN/v2rayNG JSON. | Clash/Mihomo usually needs YAML/subscription rather than a single `vless://` QR. |
| 14 | Manual | Terminal manual. | Follows selected UI language. |
| 15 | OTA & Geo Update | Update Aio-box and Loyalsoldier `geoip.dat` / `geosite.dat`. | Geo cron: Monday 03:00. |
| 16 | Uninstall | Remove proxy stack, services, and firewall rules. | Full wipe or keep `sb` launcher. |
| 17 | Environment Reset | Remove orphan processes, stale firewall rules, broken configs, and services. | Use before clean redeployment. |
| 18 | Monthly Traffic Limit | vnStat-based monthly traffic quota cutoff. | Useful for traffic-limited cloud servers. |
| 19 | SS-2022 Whitelist Manager | Add/remove frontend IP/CIDR and DROP non-whitelisted sources. | IPv4 / IPv6 / CIDR supported. |
| 20 | Language | Switch Chinese / English UI. | Saved to `/etc/ddr/.lang`. |

#### Menu 11: Toolbox submenus

| Submenu | Function | Description |
| :--- | :--- | :--- |
| 1 | bench.sh | Hardware and download benchmark. |
| 2 | Check.Place | IP quality, streaming unlock, and route test. |
| 3 | Local SNI benchmark | Test DNS, TCP, TLS, and TTFB for 100 global whitelist domains. |
| 4 | Cloudflare WARP | Run fscarmen WARP manager for outbound WARP management. |
| 5 | 2G Swap | Create `/swapfile`, persist it in `/etc/fstab`, and reduce OOM risk on low-memory hosts. |

---

<a name="-params-en"></a>

### 🧩 Parameter Notes

| Parameter | Current policy |
| :--- | :--- |
| `Y/N` input | Prompt format is `[Y/N]`; `y` and `Y` both mean yes. |
| REALITY SNI | Port 443 defaults to `www.apple.com`; non-443 defaults to `www.microsoft.com`; Apple/iCloud-like non-443 SNI triggers a warning. |
| XHTTP | Recommended: `mode=stream-one`, `alpn: h2`, `smux:false`. |
| SS-2022 | Default `2053/TCP+UDP`; whitelist recommended. |
| HY2 certificate | Prefer ACME with your own domain; otherwise use self-signed certificate + pinning. |
| HY2 masquerade URL | Only controls the page shown to ordinary HTTP/3 probes; it is not SNI or certificate identity. |
| WARP | Remote manager script is executed only after confirmation. |
| Swap | Creates 2G `/swapfile`; skips creation when it already exists. |

---

<a name="-system-requirements"></a>

## 💻 系统要求 / System Requirements

| 项目 / Item | 要求 / Requirement |
| :--- | :--- |
| 操作系统 / OS | Debian 10+, Ubuntu 20.04+, CentOS/RHEL/Rocky/AlmaLinux 8+, Alpine Linux |
| 初始化系统 / Init | Systemd 或 OpenRC / Systemd or OpenRC |
| CPU 架构 / CPU | amd64 / x86_64, arm64 / aarch64 |
| 权限 / Privilege | root 或 sudo / root or sudo |
| 网络 / Network | 可访问 GitHub Release 与系统包管理源 / Access to GitHub Releases and OS package repositories |

---

## 🤝 反馈与交流 / Feedback & Support

如果您在使用过程中遇到任何问题或有改进建议，欢迎通过以下方式参与讨论：

If you encounter any issues or have suggestions, please join the discussion via:

* **[GitHub Issues](https://github.com/alariclin/aio-box/issues)**: 提交缺陷报告或新功能提议 / Submit bug reports or feature requests.

---

<a name="-license"></a>

## 📄 许可证 / License

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

本项目采用的许可证授权是 **[Apache License 2.0](LICENSE)** 。

This project is licensed under the **[Apache License 2.0](LICENSE)**.
