# Aio-box

- **[中文说明](#-中文说明) | [English Description](#-english-description)**
- **致谢 / Credits:** 感谢 [Xray-core](https://github.com/XTLS/Xray-core) 与 [Sing-box](https://github.com/SagerNet/sing-box) 提供的强大网络路由核心引擎。 / Thanks to [Xray-core](https://github.com/XTLS/Xray-core) and [Sing-box](https://github.com/SagerNet/sing-box).

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![GitHub Stars](https://img.shields.io/github/stars/alariclin/all-in-one-duo?style=flat&color=yellow)](https://github.com/alariclin/all-in-one-duo/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/alariclin/all-in-one-duo?style=flat&color=orange)](https://github.com/alariclin/all-in-one-duo/network/members)
[![GitHub Issues](https://img.shields.io/github/issues/alariclin/all-in-one-duo?style=flat&color=red)](https://github.com/alariclin/all-in-one-duo/issues)

---

<a name="-中文说明"></a>
## 中文说明

**Aio-box** 是一款专为网络安全与路由优化打造的“双核·高可用”一键部署环境。本项目将底层架构聚焦于 Xray-core 与 Sing-box 的无缝切换，并集成了内核级流量熔断与系统网络栈极客级调优机制。

### ✨ 核心特性
* **双核自适应驱动:** 智能调度 Xray-core 与 Sing-box 路由引擎。支持模块化组合部署，或单协议独立部署。
* **高安全协议矩阵:** 原生集成 VLESS-TCP-Vision (REALITY)、Hysteria 2 (Salamander 流量混淆)、Shadowsocks 2022，提供最高级别的隐私保护与客户端兼容性。
* **本地化网络自愈:** 全局 `sb` 快捷指令改为**本地物理执行**，核心支持“云端拉取 + 本地离线缓存”双轨机制，彻底免疫网络波动或云端宕机。
* **YAML 引擎直通:** 部署完成瞬间，自动化生成通用 URI 链接与 **Clash Meta (Mihomo) 标准 YAML 拓扑节点组 (已默认启用 uTLS)**。
* **内核级流量守卫:** 基于底层 API 实时统计流量，支持自定义阈值断网熔断，有效防御恶意 CC 盗刷。
* **极客级网络调优:** 自动化释放 Linux 系统并发限制 (Ulimit)，注入虚拟内存，优化 BBR 与 TCP 拥塞控制算法。

### 🚀 快速部署

**⚠️ 前置要求：** 执行脚本前，请务必获取最高系统权限。请在终端输入以下指令并回车切换至 Root 用户：
```bash
sudo su -
```

获取 Root 权限后，执行以下指令开始安装：
```bash
bash <(curl -Ls https://raw.githubusercontent.com/alariclin/all-in-one-duo/main/install.sh)
```

**快速分发镜像节点 (中国大陆机器推荐):**
```bash
bash <(curl -Ls https://ghp.ci/https://raw.githubusercontent.com/alariclin/all-in-one-duo/main/install.sh)
```

#### ⚡ 全局管理指令
首次初始化完成后，只需在终端输入下方指令即可瞬间唤醒中控台（支持断网离线唤醒）：
```bash
sb
```

### 📂 架构一览
| 引擎模式 | 适用场景 | 核心技术点 |
| :--- | :--- | :--- |
| **🛡️ Xray-core** | 强隐私网络隔离 | `TCP-Vision` 极致流控, REALITY 动态流量填充 |
| **⚡ Sing-box** | 高并发吞吐路由 | ACME 自动化证书引擎, 多路复用与端口跳跃 |

### 🛠️ 系统管理功能
* **[选项 09] 流量监控**: 底层 API 精准核对，自定义月度流量熔断限额。
* **[选项 10] 诊断测速**: IP 信誉度检测 (IP Reputation) 与服务器综合网络基准测试。
* **[选项 11] 系统调优**: 一键释放内核并发能力，极客级优化网络栈。
* **[选项 13] 配置输出**: 渲染各协议的 URI 与 **Clash Meta (Mihomo) YAML** 拓扑配置。
* **[选项 14] OTA 更新**: 一键强制从云端同步并校验最新源码至本地库。
* **[选项 15] 纯净卸载**: 智能双轨卸载，可选择物理清场或保留 `sb` 缓存火种供后续极速恢复。

---

<a name="-english-description"></a>
## English Description

**Aio-box** is a high-availability, robust deployment environment designed for network security and routing optimization. Built on a dual-core architecture, it seamlessly integrates Xray-core and Sing-box, featuring automated YAML topology generation, offline core caching, and kernel-level TCP/BBR tuning.

### ✨ Key Features
* **Dual-Core Routing:** Native support for both Xray and Sing-box engines. Deploy modular network protocols with extreme flexibility.
* **Secure Protocol Matrix:** Incorporates VLESS-TCP-Vision (REALITY), Hysteria 2 (Salamander obfuscation), and Shadowsocks 2022 for ultimate privacy and client compatibility.
* **Bulletproof Local Exec:** The `sb` dashboard runs strictly locally. Core binaries are cached offline, ensuring 100% install success even if remote repositories go down.
* **YAML Parser Engine:** Auto-renders standard URIs AND **Clash Meta (Mihomo) YAML proxies** immediately after compilation (uTLS enabled by default).
* **Traffic Quota Guard:** API-based real-time bandwidth monitoring with an auto-killswitch to prevent malicious traffic abuse and overage billing.
* **Geek-Level Tuning:** Automates Ulimit lifting, Swap memory injection, and advanced TCP congestion control (BBR) optimizations.

### 🚀 Quick Start

**⚠️ Prerequisite:** You must run this script as the Root user. Switch to Root by executing:
```bash
sudo su -
```

Once you have root access, run the following command to install:
```bash
bash <(curl -Ls https://raw.githubusercontent.com/alariclin/all-in-one-duo/main/install.sh)
```

**Fast Global Mirror:**
```bash
bash <(curl -Ls https://ghp.ci/https://raw.githubusercontent.com/alariclin/all-in-one-duo/main/install.sh)
```

#### ⚡ Global Dashboard
Once compiled, type the following command to wake the management console instantly (Offline-capable):
```bash
sb
```

### 📂 Architecture Overview
| Engine Base | Target Use Case | Technical Highlights |
| :--- | :--- | :--- |
| **🛡️ Xray-core** | Strong Privacy | `TCP-Vision` flow control, REALITY dynamic padding |
| **⚡ Sing-box** | High Concurrency | ACME automation, Port-hopping, Multiplexing |

### 🛠️ System Management
* **[Option 09] Quota Monitor**: Precision API bandwidth tracking with automated network killswitch limits.
* **[Option 10] Diagnostics**: IP Reputation checks and comprehensive server network benchmarks.
* **[Option 11] VPS Tuning**: Unlock kernel concurrency, modify file-max, and tune BBR stacks.
* **[Option 13] Export Topology**: Instantly render Universal URIs and **Clash Meta YAML structures**.
* **[Option 14] OTA Update**: Force-sync the local bash instance with the latest cloud repository.
* **[Option 15] Clean Purge**: Smart uninstaller with the option to keep the `sb` trigger and offline core cache for rapid recovery.

---

## ⚠️ 系统要求 / System Requirements
* **OS**: Debian 10+, Ubuntu 20.04+, CentOS 8+, AlmaLinux.
* **Init System**: Systemd is strictly required for daemon persistence.
* **Network**: Dual-stack IPv4 / IPv6 resolution fully supported.

## 🤝 反馈与交流 / Feedback & Support
Submit logs or suggestions at:
* [GitHub Issues](https://github.com/alariclin/all-in-one-duo/issues)

## 📄 许可证 / License
Released under the [MIT License](https://opensource.org/licenses/MIT).
