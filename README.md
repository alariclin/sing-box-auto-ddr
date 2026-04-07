# Aio-box

- **[中文说明](#-中文说明) | [English Description](#-english-description)**
- **致谢 / Credits:** 感谢 [Xray-core](https://github.com/XTLS/Xray-core) 与 [Sing-box](https://github.com/SagerNet/sing-box) 提供的强大网络路由核心。

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![GitHub Stars](https://img.shields.io/github/stars/alariclin/aio-box?style=flat&color=yellow)](https://github.com/alariclin/aio-box/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/alariclin/aio-box?style=flat&color=orange)](https://github.com/alariclin/aio-box/network/members)
[![GitHub Issues](https://img.shields.io/github/issues/alariclin/aio-box?style=flat&color=red)](https://github.com/alariclin/aio-box/issues)

---

<a name="-中文说明"></a>
## 中文说明

**Aio-box** 是一款专为网络安全与路由优化打造的“双核·高可用”一键部署环境。本项目聚焦于 **Xray-core (v26+)** 与 **Sing-box (Testing)** 的原生深度集成，提供物理级防封锁与系统级并发性能优化。

### ✨ 核心特性
* **最新内核原生支持**: 完美适配 Xray-core v26.3.27 的原生 Hysteria 2 支持，修复所有旧版配置冲突。
* **Testing 分支特性**: 支持 Sing-box 原生端口跳跃 (Port Hopping) 与 Chrome Root Store 指纹强校验。
* **三重资源保障**: 优先尝试官方源下载，自动回退至个人备份仓库源，并支持完全本地离线缓存重装。
* **物理防封锁**: 彻底剥离高危 Apple/iCloud 伪装域名，全面转向微软分发网络；内置 uTLS 客户端指纹自动适配。
* **高可用本地化**: `sb` 快捷指令本地化物理执行，内置 OTA 热更新模块，彻底免疫远程网络波动。

### 🚀 快速部署

**⚠️ 前置要求：** 请务必先执行以下指令切换至 Root 用户：
```bash
sudo su -
```

获取权限后，执行一键安装指令：
```bash
bash <(curl -Ls https://raw.githubusercontent.com/alariclin/aio-box/main/install.sh)
```

**分发加速镜像 (中国大陆机器推荐):**
```bash
bash <(curl -Ls https://ghp.ci/https://raw.githubusercontent.com/alariclin/aio-box/main/install.sh)
```

#### ⚡ 全局管理
安装完成后，在终端输入以下指令即可瞬间唤醒中控面板（支持离线唤醒）：
```bash
sb
```

### 📂 架构一览
| 引擎模式 | 适用场景 | 核心技术点 |
| :--- | :--- | :--- |
| **🛡️ Xray-core** | 强隐私网络隔离 | `TCP-Vision` 极致流控, v26 原生 Hy2 支持 |
| **⚡ Sing-box** | 高并发吞吐路由 | 原生端口跳跃, Chrome Root Store 指纹校验 |

### 🛠️ 系统管理功能
* **[选项 11] 本机参数与IP网络测速诊断**: 本机参数明细与服务器综合网络基准测试。
* **[选项 13] 参数明细与节点链接**: 渲染各协议的通用 URI 与 **Clash Meta (Mihomo) YAML** 拓扑配置。
* **[选项 14] 脚本源码 OTA 热更新**: 一键强制从云端同步并校验最新源码至本地库。
* **[选项 15] 彻底清空卸载环境**: 智能双轨卸载，可选择物理清场或保留本地核心缓存火种。

---

<a name="-english-description"></a>
## English Description

**Aio-box** is a high-availability, dual-core (Xray/Sing-box) deployment environment designed for next-gen network security. 

### ✨ Key Features
* **Xray v26 Native**: Fully optimized for Xray-core v26.3.27 with native Hysteria 2 protocol support.
* **Sing-box Testing**: Implements native Port Hopping and Chrome Root Store fingerprinting.
* **Triple-Source Reliability**: Intelligent failover between Official GitHub, Private Mirror, and Local Offline Cache.
* **Anti-Detection**: Strips high-risk Apple SNIs; defaults to Microsoft global CDN for ultimate stealth.
* **Bulletproof UX**: Localized `sb` shortcut with built-in OTA update module.

---

## ⚠️ 系统要求 / System Requirements
* **OS**: Debian 10+, Ubuntu 20.04+, CentOS 8+, AlmaLinux.
* **Init System**: Systemd is strictly required.
* **User**: Root access is mandatory.

## 🤝 反馈与交流 / Feedback & Support
如果您在使用中遇到问题，欢迎提交 Issue：
* [GitHub Issues](https://github.com/alariclin/aio-box/issues)

## 📄 许可证 / License
Released under the [MIT License](https://opensource.org/licenses/MIT).
