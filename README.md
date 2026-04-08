# Aio-box

- **[中文说明](#-中文说明) | [English Description](#-english-description)**
- **致谢 / Credits:** 感谢 Xray-core 与 Sing-box 提供的强大网络路由与加密核心。
- Credits: We would like to thank Xray-core and Sing-box for providing powerful network routing and encryption cores.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![GitHub Stars](https://img.shields.io/github/stars/alariclin/aio-box?style=flat&color=yellow)](https://github.com/alariclin/aio-box/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/alariclin/aio-box?style=flat&color=orange)](https://github.com/alariclin/aio-box/network/members)
[![GitHub Issues](https://img.shields.io/github/issues/alariclin/aio-box?style=flat&color=red)](https://github.com/alariclin/aio-box/issues)

---

<a name="-中文说明"></a>

**Aio-box** 是一款专为网络安全、强隐私保护与路由优化打造的“双核·高可用”一键部署环境。本项目聚焦于 **Xray-core** 与 **Sing-box** 的原生深度集成，彻底解决内核死锁问题，提供物理级防封锁、系统级并发性能优化以及全自动环境自愈功能。

### ✨ 核心特性
* **Sing-box 现代全能架构**: 完美实现 VLESS (TCP 443) 与 Hysteria 2 (UDP 443) 共享单一物理端口，底层原生支持防死锁调度，极致提升连接成功率。
* **Xray-core 极致纯净优选**: 剔除水土不服的 UDP 协议缝合，专注提供最稳定的 TCP/VLESS-Vision 与 Shadowsocks 链路，为强网络审查地区提供坚如磐石的备用方案。
* **Auto-Fix 内核级环境自愈**: 独创的环境审计功能，一键扫描并自动绞杀僵尸进程、清理 NAT 流量黑洞（iptables 劫持残留）及物理文件污染。
* **百万级并发调优**: 一键开启 BBR 拥塞控制引擎，并自动提升 VPS 的 TCP 窗口与系统文件描述符（Soft/Hard Nofile）至 1,048,576 极限级别。
* **OTA 在线无缝同步与智能卸载**: 支持从云端 GitHub 一键热更新脚本代码；提供“核弹级全清空”与“保留菜单快捷指令”的智能双轨卸载选项。

### 🚀 快速部署

无需手动切换用户，请直接在终端复制并执行以下一键安装指令（指令已物理纯化，可直接粘贴）：

**全球高速通道 (推荐海外服务器使用):**
```bash
sudo bash -c "$(curl -Ls https://raw.githubusercontent.com/alariclin/aio-box/main/install.sh)"
```

**分发加速镜像 (中国大陆机器推荐):**
```bash
sudo bash -c "$(curl -Ls https://ghp.ci/https://raw.githubusercontent.com/alariclin/aio-box/main/install.sh)"
```
#### ⚡ 全局管理
安装完成后，在终端输入以下指令即可瞬间唤醒中控面板（支持离线唤醒）：
```bash
sb
```

### 📂 架构一览
引擎模式 (Engine),适用场景 (Use Case),核心技术点 (Highlights)
⚡ Sing-box (主推),单端口全能复用,"原生 Hysteria 2 (Salamander 混淆), TCP/UDP 443 完美共存, 自动接口探测"
🛡️ Xray-core (备选),极度稳定的纯净 TCP,"剔除底层冲突协议, 专注 TCP-Vision 极致流控与 Reality 动态握手"
---

<a name="-english-description"></a>
## English Description

**Aio-boxo** is a high-availability, robust deployment environment designed for network security and routing optimization. Built on a dual-core architecture, it seamlessly integrates Xray-core and Sing-box, featuring automated YAML topology generation, offline core caching, and kernel-level TCP/BBR tuning.

### ✨ Key Features
* **TCP/UDP 443 Dual-Stack Multiplexing**: Seamlessly enables VLESS (TCP) and Hysteria 2 (UDP) to share a single physical port 443, offering unparalleled obfuscation and boosting connection success rates.
* **Next-Generation Routing Protocol Engine**: Natively powered by Xray v26.3.27, featuring built-in Sing-box Port Hopping (NAT Hopping) and robust Chrome fingerprint validation to effectively thwart DPI detection.
* **Dynamic SNI & Self-Signed Certificates**: Supports custom private domains and automatically generates detection-resistant, 100-year self-signed security certificates based on the user-provided SNI.
* **High-Availability Local Execution**: The `sb` shortcut command executes locally on the device; equipped with an offline core cache, it remains completely immune to remote access failures or network fluctuations.
* **Automatic Privilege Escalation & Fail-Safe Design**: The script automatically acquires Root privileges and incorporates safeguards to prevent garbled text from backspace inputs or accidental crashes, delivering an exceptionally smooth and seamless interaction experience for power users.

### 🚀 Quick Start

**Global High-Speed ​​Channel (Recommended for Overseas Servers):**
```bash
sudo bash -c "$(curl -Ls https://raw.githubusercontent.com/alariclin/aio-box/main/install.sh)"
```
#### ⚡ Global Management
Once installation is complete, simply enter the following command in the terminal to instantly launch the Control Panel (offline launch supported):
```bash
sb
```
### 📂 Architecture Overview
| Engine Base | Target Use Case | Technical Highlights |
| :--- | :--- | :--- |
| **🛡️ Xray-core** | Strong Privacy | `TCP-Vision` flow control, REALITY dynamic padding |
| **⚡ Sing-box** | High Concurrency | ACME automation, Port-hopping, Multiplexing |

## ⚠️ 系统要求 / System Requirements
* **OS**: Debian 10+, Ubuntu 20.04+, CentOS 8+, AlmaLinux.
* **Init System**: Systemd is strictly required for daemon persistence.
* **Network**: Dual-stack IPv4 / IPv6 resolution fully supported.

## 🤝 反馈与交流 / Feedback & Support
Submit logs or suggestions at:
* [GitHub Issues](https://github.com/alariclin/all-in-one-duo/issues)

## 📄 许可证 / License
Released under the [MIT License](https://opensource.org/licenses/MIT).
