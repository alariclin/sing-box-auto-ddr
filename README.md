# A-Box | One-click Linux Network Gateway Toolkit

[English](README.md) | [简体中文](README-zh.md) | [Русский](README-ru.md) | [فارسی](README-fa.md)

<img width="1254" alt="A-Box Project Banner" src="https://github.com/user-attachments/assets/a3d48aac-b33d-4061-918c-1d1e93e3cee2" />

**A-Box** is an all-in-one, production-ready Linux network gateway automation toolkit. It integrates full-cycle proxy service deployment, system performance tuning, traffic management, access control, service health self-healing, client configuration export, network quality testing, and a bilingual interactive terminal UI into a single standalone bash script. No complex dependencies, no remote script dependencies, one command to get started.

**Credits**: Sincere thanks to Xray-core, sing-box, Hysteria and related open-source projects for technical inspiration and ecosystem support. A-Box is an independent automation orchestration toolkit.

[![Version](https://img.shields.io/badge/Version-2026.05.04-success.svg?style=flat-square)](https://github.com/alariclin/a-box/releases)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg?style=flat-square)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/alariclin/a-box?style=flat-square&color=yellow)](https://github.com/alariclin/a-box/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/alariclin/a-box?style=flat-square&color=orange)](https://github.com/alariclin/a-box/network/members)

---

## ⚠️ Compliance & Disclaimer
This project is designed for **network architecture testing, cybersecurity research, and legitimate privacy protection in fully authorized environments**.

1. **Legal Compliance**: You must not use this project for any activities that violate the laws and regulations of your country/region.
2. **User Responsibility**: Users bear full legal, operational and security responsibility for any consequences caused by misuse or improper operation.
3. **Technical Intent**: The routing and encryption technologies involved are designed to improve the security and privacy of data transmission. Do not use this tool for illegal attacks, unauthorized access, or damage to network infrastructure.
4. **Acceptance**: By downloading, copying, or running this script, you confirm that you have read, understood and accepted all the terms above.

---

## 🚀 Quick Start
### One-click Run (Global Channel)
```bash
curl -fsSL https://raw.githubusercontent.com/alariclin/a-box/main/install.sh | sudo bash
```

### One-click Run (Mirror Channel, for restricted networks)
```bash
curl -fsSL https://ghp.ci/https://raw.githubusercontent.com/alariclin/a-box/main/install.sh | sudo bash
```

### Specify Language Directly
```bash
# Chinese UI
curl -fsSL https://raw.githubusercontent.com/alariclin/a-box/main/install.sh > A-Box.sh && sudo bash A-Box.sh --lang zh

# English UI
curl -fsSL https://raw.githubusercontent.com/alariclin/a-box/main/install.sh > A-Box.sh && sudo bash A-Box.sh --lang en
```

### Self-test & Status Check
```bash
# Static syntax and function self-test (no side effects)
sudo bash A-Box.sh --self-test

# Show current deployment status and service running state
sudo bash A-Box.sh --status

# Show full CLI help
sudo bash A-Box.sh --help
```

### Post-installation Console Entry
After the first run, you can open the interactive menu at any time with a single command:
```bash
sb
```

---

## ✨ Core Features
Fully aligned with the script's built-in logic, no false descriptions:

| Module | Detailed Description |
| :--- | :--- |
| One-click Deployment | Native support for Xray-core, sing-box, and official Apernet Hysteria 2 core, with automatic dependency installation, environment initialization, and service orchestration. |
| Full Protocol Stack | VLESS-Vision-Reality, VLESS-XHTTP-Reality, Shadowsocks-2022, Hysteria 2, with standardized configuration generation and compatibility verification. |
| Standard Port Policy | Vision `443/TCP`, XHTTP `8443/TCP`, HY2 `443/UDP`, SS-2022 `2053/TCP+UDP`, with automatic port conflict detection and pre-occupation check. |
| Secure SNI Policy | **All ports default to `www.microsoft.com`** (script explicitly avoids Apple/iCloud as default targets to reduce blocking risk); non-443 ports using Apple/iCloud SNI will trigger a security warning and secondary confirmation. |
| Built-in SNI Radar | Full local SNI preference library (thousands of high-quality candidate domains), no remote script dependency; supports full mode and mini mode (for low-spec hosts), with TLS 1.3, ALPN, SAN, ASN topology scoring. |
| XHTTP Optimization | Native XHTTP protocol support, exports `stream-one + h2 + smux disabled` configuration for optimal throughput, compatible with Mihomo v1.19.24+. |
| Full-featured HY2 | Supports ACME HTTP-01 / Cloudflare DNS-01 domain certificates, self-signed certificates with pinning, native/iptables port hopping, HTTP/3 masquerade, and salamander obfuscation. |
| Integrated Toolbox | System hardware & download benchmark, IP quality/streaming unlock/route testing, local SNI preference, Cloudflare WARP one-click management, 2G Swap virtual memory allocation. |
| Production-grade O&M | One-click BBR/FQ system tuning, TCP KeepAlive anti-idle disconnection, Fail2Ban active defense, logrotate log management, L4 socket health self-healing probe, scheduled Geo data update, monthly traffic quota auto cutoff, SS-2022 IP whitelist management. |
| Client Configuration Export | One-click generation of standard URI, terminal QR code, Clash/Mihomo full YAML configuration, sing-box outbound template, v2rayN/v2rayNG JSON configuration. |
| Deployment Security Protection | New deployment will automatically stop managed old services, clean up A-Box firewall rules, and avoid port conflicts; full uninstall and environment reset are supported. |

---

## 📋 Full Menu Reference
1:1 aligned with the script's interactive menu, no missing or wrong functions:

| Menu ID | Function Name | Core Use Case |
| :--- | :--- | :--- |
| 1 | Xray VLESS-Vision-Reality | Long-term stable primary TCP path, best for stealth and compatibility |
| 2 | Xray VLESS-XHTTP-Reality | High-throughput desktop backup path, optimized for large bandwidth scenarios |
| 3 | Xray Shadowsocks-2022 | Relay/landing inbound, recommended to use with IP whitelist for security |
| 4 | Official Hysteria 2 (Apernet) | UDP/QUIC/H3 acceleration path, ideal for mobile networks and high packet loss links |
| 5 | Xray + Official HY2 All-in-one | Balanced full-protocol deployment: Vision + XHTTP + HY2 + SS-2022 |
| 6 | sing-box VLESS-Vision-Reality | Low-memory footprint single-core Vision deployment, for low-spec hosts |
| 7 | sing-box Shadowsocks-2022 | Lightweight SS-2022 relay deployment, minimal resource usage |
| 8 | sing-box VLESS + SS-2022 | Lightweight dual-protocol deployment, main path + relay path in one process |
| 9 | sing-box Hysteria 2 | HY2 implementation based on sing-box, compatible with standard clients |
| 10 | sing-box All-in-one | Sing-box full-protocol deployment: Vision + HY2 + SS-2022 (XHTTP excluded by design) |
| 11 | Integrated Toolbox | System benchmark, IP quality test, SNI preference, WARP management, Swap allocation |
| 12 | VPS One-click Optimization | System performance tuning, security hardening, and O&M capability deployment |
| 13 | Display All Node Parameters | Show all connection links, QR codes, and full client configuration files |
| 14 | Script Manual | Full terminal help documentation, detailed function description |
| 15 | OTA, Geo & Core Upgrade | Script online update, Xray Geo data update, core binary upgrade without resetting node parameters |
| 16 | Full Clean Uninstall | Remove proxy stack, services, configs, firewall rules, and optional sb shortcut |
| 17 | Delete Nodes & Reinitialize Environment | Kill orphan processes, clean stale firewall rules, remove broken configs and services |
| 18 | Monthly Traffic Limit Management | vnStat-based monthly traffic quota, auto stop services when quota is reached |
| 19 | SS-2022 Whitelist Manager | Add/remove frontend IP/CIDR, enforce DROP for non-whitelisted sources |
| 20 | Language Settings | Switch between Chinese/English UI, persistent save to local file |
| 0 | Exit Script | Exit the interactive menu |

---

## 🛠️ Toolbox Submenu Details
| Submenu ID | Function | Detailed Description |
| :--- | :--- | :--- |
| 1 | System Benchmark | Run bench.sh for hardware performance and multi-node download speed test |
| 2 | IP Quality & Route Test | Run Check.Place for IP purity, streaming service unlock, and return route test |
| 3 | Full Local SNI Preference | Run built-in full SNI radar library, with HTTPS/TLS 1.3 metrics, OpenSSL verification, and ASN topology scoring |
| 4 | Mini Host Local SNI Preference | Same candidate library as full mode, with reduced concurrency and verification depth, optimized for low-spec/low-bandwidth hosts |
| 5 | Cloudflare WARP Manager | Run fscarmen/warp menu for outbound IP masking and streaming unlock |
| 6 | 2G Swap Allocation | One-click create `/swapfile` to reduce OOM crash risk on low-memory hosts |

---

## 🎯 Recommended Deployment Schemes
| Scenario & Goal | Recommended Option |
| :--- | :--- |
| Balanced production deployment | Menu `5`: Xray + Official HY2 All-in-one |
| Low-memory lightweight deployment | Menu `10`: sing-box All-in-one |
| Long-term stable primary TCP path | Menu `1`: Xray VLESS-Vision-Reality (443/TCP) |
| High-throughput desktop backup path | Menu `2`: Xray VLESS-XHTTP-Reality (8443/TCP) |
| Mobile/high packet loss network | Menu `4`: Official Hysteria 2 (443/UDP) |
| Relay/landing node | Menu `3`: Xray SS-2022 (2053/TCP+UDP) + IP whitelist |

---

## 🖥️ System Requirements
| Item | Minimum Requirement |
| :--- | :--- |
| Operating System | Debian 10+, Ubuntu 20.04+, CentOS/RHEL/Rocky/AlmaLinux 8+, Alpine Linux |
| Init System | Systemd or OpenRC |
| CPU Architecture | amd64/x86_64, arm64/aarch64 |
| Privilege | root user or sudo permission |
| Network | Access to system package repositories and GitHub Releases |
| Basic Dependencies | bash, curl (script will automatically install all missing dependencies) |

---

## ❓ Frequently Asked Questions
### Q: The script prompts "no interactive TTY available"
A: Please run the script in a terminal with interactive TTY, or use `sudo bash A-Box.sh` instead of piping to bash via non-interactive channels.

### Q: Port is occupied, deployment failed
A: The script will automatically check for port occupation by non-A-Box processes. Please manually release the occupied port before deployment, or choose a different port in the parameter wizard.

### Q: ACME certificate application failed
A: For HTTP-01 verification, ensure port 80/tcp is not occupied and accessible from the public network; for Cloudflare DNS-01 verification, ensure the API Token has correct DNS edit permissions for the domain.

### Q: How to choose the best SNI?
A: Use the built-in SNI radar in Toolbox menu 3/4, prefer domains with `tls13=1`, `san=1`, `asnmatch=1`/`samecountry=1`, avoid Apple/iCloud SNI on non-443 ports.

### Q: The service stops automatically after reaching the traffic limit
A: The traffic limit function will stop all managed services when the monthly quota is reached. You can adjust or disable the limit via menu 18, and restart the services manually.

---

## 📬 Feedback & Contribution
- Bug reports and feature requests: [GitHub Issues](https://github.com/alariclin/a-box/issues)
- Code contributions: Welcome to submit Pull Requests to the main repository

---

## 📄 License
This project is licensed under the [Apache License 2.0](LICENSE) open-source license.
