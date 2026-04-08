#!/usr/bin/env bash
# ====================================================================
# Aio-box Ultimate Console [Virgin State Check & Auto-Fix Integrated]
# Version: 2026.04.Apex-Stable-V46-AutoFix
# ====================================================================

export DEBIAN_FRONTEND=noninteractive
RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[0;33m' BLUE='\033[0;36m' PURPLE='\033[0;35m' CYAN='\033[0;36m' NC='\033[0m' BOLD='\033[1m'

if [[ $EUID -ne 0 ]]; then
    if command -v sudo >/dev/null 2>&1; then
        exec sudo bash "$0" "$@"
    else
        echo -e "${RED}[!] 必须使用 Root 权限运行！请执行 'sudo su -'${NC}"; exit 1
    fi
fi
sed -i '/acme.sh.env/d' ~/.bashrc >/dev/null 2>&1 || true

setup_shortcut() {
    mkdir -p /etc/ddr
    if [[ ! -f /etc/ddr/aio.sh || "$1" == "update" ]]; then
        curl -Ls https://raw.githubusercontent.com/alariclin/aio-box/main/install.sh > /etc/ddr/aio.sh
        chmod +x /etc/ddr/aio.sh
    fi
    if [[ ! -f /usr/local/bin/sb ]]; then
        printf '#!/bin/bash\nsudo bash /etc/ddr/aio.sh "$@"\n' > /usr/local/bin/sb
        chmod +x /usr/local/bin/sb
    fi
}

check_env() {
    if ! command -v jq >/dev/null || ! command -v fuser >/dev/null || ! command -v unzip >/dev/null || ! command -v lsof >/dev/null; then
        echo -e "${YELLOW}[*] 正在同步系统依赖环境...${NC}"
        apt-get update -y -q || yum makecache -y -q
        local deps=(wget curl jq openssl uuid-runtime cron fail2ban python3 bc unzip vnstat iptables tar psmisc lsof)
        if command -v apt-get >/dev/null; then apt-get install -y -q "${deps[@]}"; else yum install -y -q "${deps[@]}"; fi
        systemctl enable cron vnstat 2>/dev/null || true
        systemctl start cron vnstat 2>/dev/null || true
    fi
}

get_architecture() {
    local ARCH=$(uname -m)
    case "$ARCH" in
        x86_64) XRAY_ARCH="64"; SB_ARCH="amd64" ;;
        aarch64) XRAY_ARCH="arm64-v8a"; SB_ARCH="arm64" ;;
        *) echo -e "${RED}[!] 不支持的架构: $ARCH${NC}"; exit 1 ;;
    esac
}

fetch_github_release() {
    local repo=$1; local keyword=$2; local output_file=$3
    echo -e "${YELLOW} -> 正在从 GitHub 获取最新版本 [${repo}]...${NC}"
    local api_url="https://api.github.com/repos/${repo}/releases/latest"
    local download_url=$(curl -sL "$api_url" | jq -r ".assets[] | select(.name | contains(\"$keyword\")) | .browser_download_url" | head -n 1)
    if [[ -z "$download_url" || "$download_url" == "null" ]]; then
        download_url=$(curl -sL "https://ghp.ci/$api_url" | jq -r ".assets[] | select(.name | contains(\"$keyword\")) | .browser_download_url" | head -n 1)
    fi
    if [[ -z "$download_url" || "$download_url" == "null" ]]; then
        echo -e "${RED}[!] 无法获取 $repo 下载链接。${NC}"; exit 1
    fi
    local mirrors=("" "https://ghp.ci/" "https://ghproxy.net/")
    for mirror in "${mirrors[@]}"; do
        if curl -fLs --connect-timeout 10 "${mirror}${download_url}" -o "/tmp/${output_file}" && [[ -s "/tmp/${output_file}" ]]; then
            echo -e "${GREEN}   ✔ 核心获取成功！${NC}"; return 0
        fi
    done
    echo -e "${RED}[!] 下载失败。${NC}"; exit 1
}

fetch_geo_data() {
    local file_name=$1; local official_url=$2
    local mirrors=("" "https://ghp.ci/" "https://ghproxy.net/")
    for mirror in "${mirrors[@]}"; do
        if curl -fLs --connect-timeout 10 "${mirror}${official_url}" -o "/tmp/${file_name}" && [[ -s "/tmp/${file_name}" ]]; then return 0; fi
    done
    exit 1
}

pre_install_setup() {
    local MODE=$1
    AUTO_REALITY="www.microsoft.com"
    echo -e "\n${CYAN}======================================================================${NC}"
    echo -e "${BOLD}🚀 部署前向导：正统 443 端口部署方案${NC}"
    echo -e "   强制使用防封 SNI: ${GREEN}$AUTO_REALITY${NC}"
    echo -e "${BLUE}----------------------------------------------------------------------${NC}"
    if [[ "$MODE" == *"VLESS"* ]] || [[ "$MODE" == *"ALL"* ]]; then
        read -ep "   [VLESS] 请输入伪装 SNI (回车默认使用微软): " INPUT_V_SNI
        VLESS_SNI=${INPUT_V_SNI:-$AUTO_REALITY}
        read -ep "   [VLESS] 请输入监听端口 (回车默认使用 443): " INPUT_V_PORT
        VLESS_PORT=${INPUT_V_PORT:-443}
    fi
    if [[ "$MODE" == *"HY2"* ]] || [[ "$MODE" == *"ALL"* ]]; then
        read -ep "   [HY2] 请输入伪装 SNI (回车默认使用微软): " INPUT_H_SNI
        HY2_SNI=${INPUT_H_SNI:-$AUTO_REALITY}
        read -ep "   [HY2] 请输入监听端口 (回车默认使用 443): " INPUT_H_PORT
        HY2_PORT=${INPUT_H_PORT:-443}
    fi
    if [[ "$MODE" == *"SS"* ]] || [[ "$MODE" == *"ALL"* ]]; then
        read -ep "   [SS] 请输入备用监听端口 (回车默认 2053): " INPUT_S_PORT
        SS_PORT=${INPUT_S_PORT:-2053}
    fi
    echo -e "${CYAN}======================================================================${NC}\n"
    VLESS_SNI=${VLESS_SNI:-$AUTO_REALITY}; HY2_SNI=${HY2_SNI:-$AUTO_REALITY}
    VLESS_PORT=${VLESS_PORT:-443}; HY2_PORT=${HY2_PORT:-443}; SS_PORT=${SS_PORT:-2053}
}

release_ports() {
    echo -e "${YELLOW}[*] 正在执行内核级端口强制释放清理...${NC}"
    systemctl stop xray sing-box hysteria 2>/dev/null || true
    killall -9 xray sing-box hysteria 2>/dev/null || true
    local ports_to_clean=($VLESS_PORT $HY2_PORT $SS_PORT 443 2053)
    for p in $(echo "${ports_to_clean[@]}" | tr ' ' '\n' | sort -u); do
        fuser -k -9 ${p}/tcp 2>/dev/null || true
        fuser -k -9 ${p}/udp 2>/dev/null || true
        lsof -ti:${p} | xargs kill -9 2>/dev/null || true
    done
    sleep 2
}

deploy_xray() {
    local MODE=$1; clear; echo -e "${BOLD}${GREEN} 部署 Xray-core [$MODE] ${NC}"; check_env; pre_install_setup "$MODE"
    release_ports; get_architecture
    fetch_github_release "XTLS/Xray-core" "Xray-linux-${XRAY_ARCH}.zip" "xray_core.zip"
    fetch_geo_data "geoip.dat" "https://github.com/v2fly/geoip/releases/latest/download/geoip.dat"
    fetch_geo_data "geosite.dat" "https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat"
    rm -rf /tmp/xray_ext; unzip -qo "/tmp/xray_core.zip" -d /tmp/xray_ext
    mv /tmp/xray_ext/xray /usr/local/bin/xray; chmod +x /usr/local/bin/xray
    mkdir -p /usr/local/share/xray /usr/local/etc/xray; mv /tmp/geoip.dat /usr/local/share/xray/; mv /tmp/geosite.dat /usr/local/share/xray/
    PK=$(/usr/local/bin/xray x25519 | grep -i "Private" | awk '{print $NF}'); PBK=$(/usr/local/bin/xray x25519 | grep -i "Public" | awk '{print $NF}')
    UUID=$(uuidgen); SHORT_ID=$(openssl rand -hex 4 | tr -d '\n\r'); SS_PASS=$(openssl rand -base64 16 | tr -d '\n\r')
    HY2_PASS=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9'); HY2_OBFS=$(openssl rand -base64 8 | tr -dc 'a-zA-Z0-9')
    mkdir -p /usr/local/etc/xray; openssl ecparam -genkey -name prime256v1 -out /usr/local/etc/xray/hy2.key 2>/dev/null
    openssl req -new -x509 -days 36500 -key /usr/local/etc/xray/hy2.key -out /usr/local/etc/xray/hy2.crt -subj "/CN=${HY2_SNI}" 2>/dev/null
    JSON_VLESS=$(cat << EOF
    {
      "listen": "0.0.0.0", "port": ${VLESS_PORT}, "protocol": "vless",
      "settings": { "clients": [{"id": "${UUID}", "flow": "xtls-rprx-vision"}], "decryption": "none" },
      "streamSettings": {
        "network": "tcp", "security": "reality",
        "realitySettings": { "dest": "${VLESS_SNI}:443", "serverNames": ["${VLESS_SNI}"], "privateKey": "${PK}", "shortIds": ["${SHORT_ID}"] }
      }
    }
EOF
)
    JSON_HY2=$(cat << EOF
    {
      "listen": "0.0.0.0", "port": ${HY2_PORT}, "protocol": "hysteria", "tag": "hy2-in",
      "settings": {
        "auth": "pass", "auth_str": "${HY2_PASS}", "obfs": "salamander", "obfs_password": "${HY2_OBFS}",
        "certificates": [{ "certificateFile": "/usr/local/etc/xray/hy2.crt", "keyFile": "/usr/local/etc/xray/hy2.key" }]
      }
    }
EOF
)
    JSON_SS=$(cat << EOF
    {
      "listen": "0.0.0.0", "port": ${SS_PORT}, "protocol": "shadowsocks",
      "settings": { "method": "2022-blake3-aes-128-gcm", "password": "${SS_PASS}", "network": "tcp,udp" }
    }
EOF
)
    case $MODE in "VLESS") INBOUNDS="[$JSON_VLESS]" ;; "HY2") INBOUNDS="[$JSON_HY2]" ;; "SS") INBOUNDS="[$JSON_SS]" ;; "ALL") INBOUNDS="[$JSON_VLESS, $JSON_HY2, $JSON_SS]" ;; esac
    cat > /usr/local/etc/xray/config.json << EOF
{ "log": { "loglevel": "warning" }, "inbounds": ${INBOUNDS}, "outbounds": [{ "protocol": "freedom" }] }
EOF
    cat > /etc/systemd/system/xray.service << SVC_EOF
[Unit]
After=network.target
[Service]
$(if [[ "$MODE" == *"HY2"* ]] || [[ "$MODE" == *"ALL"* ]]; then echo -e "ExecStartPre=-/bin/sh -c '/sbin/iptables -t nat -D PREROUTING -p udp --dport 20000:50000 -j REDIRECT --to-ports $HY2_PORT 2>/dev/null || true'\nExecStartPre=-/bin/sh -c '/sbin/ip6tables -t nat -D PREROUTING -p udp --dport 20000:50000 -j REDIRECT --to-ports $HY2_PORT 2>/dev/null || true'\nExecStartPre=-/bin/sh -c '/sbin/iptables -t nat -A PREROUTING -p udp --dport 20000:50000 -j REDIRECT --to-ports $HY2_PORT 2>/dev/null || true'\nExecStartPre=-/bin/sh -c '/sbin/ip6tables -t nat -A PREROUTING -p udp --dport 20000:50000 -j REDIRECT --to-ports $HY2_PORT 2>/dev/null || true'"; fi)
ExecStart=/usr/local/bin/xray run -config /usr/local/etc/xray/config.json
$(if [[ "$MODE" == *"HY2"* ]] || [[ "$MODE" == *"ALL"* ]]; then echo -e "ExecStopPost=-/bin/sh -c '/sbin/iptables -t nat -D PREROUTING -p udp --dport 20000:50000 -j REDIRECT --to-ports $HY2_PORT 2>/dev/null || true'\nExecStopPost=-/bin/sh -c '/sbin/ip6tables -t nat -D PREROUTING -p udp --dport 20000:50000 -j REDIRECT --to-ports $HY2_PORT 2>/dev/null || true'"; fi)
Restart=always
LimitNOFILE=1048576
LimitNPROC=infinity
[Install]
WantedBy=multi-user.target
SVC_EOF
    systemctl daemon-reload && systemctl enable --now xray; systemctl restart xray
    sleep 2; systemctl is-active --quiet xray || { echo -e "${RED}[!] 致命错误：Xray 核心启动失败！${NC}"; journalctl -u xray --no-pager -n 20; exit 1; }
    cat > /etc/ddr/.env << ENV_EOF
CORE="xray"; MODE="$MODE"; UUID="$UUID"; VLESS_SNI="$VLESS_SNI"; VLESS_PORT="$VLESS_PORT"; HY2_SNI="$HY2_SNI"; HY2_PORT="$HY2_PORT"; SS_PORT="$SS_PORT"; PUBLIC_KEY="$PBK"; SHORT_ID="$SHORT_ID"; HY2_PASS="$HY2_PASS"; HY2_OBFS="$HY2_OBFS"; SS_PASS="$SS_PASS"; LINK_IP="$(curl -s4 api.ipify.org)"
ENV_EOF
    view_config "deploy"
}

deploy_singbox() {
    local MODE=$1; clear; echo -e "${BOLD}${GREEN} 部署 Sing-box [$MODE] ${NC}"; check_env; pre_install_setup "$MODE"
    release_ports; get_architecture
    fetch_github_release "SagerNet/sing-box" "linux-${SB_ARCH}.tar.gz" "singbox_core.tar.gz"
    tar -xzf "/tmp/singbox_core.tar.gz" -C /tmp; mv /tmp/sing-box-*/sing-box /usr/local/bin/; chmod +x /usr/local/bin/sing-box
    PK=$(/usr/local/bin/sing-box generate reality-keypair | grep -i "Private" | awk '{print $NF}'); PBK=$(/usr/local/bin/sing-box generate reality-keypair | grep -i "Public" | awk '{print $NF}')
    if [[ -z "$PK" ]]; then echo -e "${RED}[!] 核心不兼容 / Core incompatible.${NC}"; exit 1; fi
    UUID=$(uuidgen); SHORT_ID=$(openssl rand -hex 4 | tr -d '\n\r'); SS_PASS=$(openssl rand -base64 16 | tr -d '\n\r')
    HY2_PASS=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9'); HY2_OBFS=$(openssl rand -base64 8 | tr -dc 'a-zA-Z0-9')
    mkdir -p /etc/sing-box; openssl ecparam -genkey -name prime256v1 -out /etc/sing-box/hy2.key 2>/dev/null
    openssl req -new -x509 -days 36500 -key /etc/sing-box/hy2.key -out /etc/sing-box/hy2.crt -subj "/CN=${HY2_SNI}" 2>/dev/null
    JSON_VLESS=$(cat << EOF
    {
      "type": "vless", "listen": "::", "listen_port": ${VLESS_PORT}, "tcp_fast_open": true,
      "users": [{"uuid": "${UUID}", "flow": "xtls-rprx-vision"}],
      "tls": {
        "enabled": true, "server_name": "${VLESS_SNI}",
        "reality": { "enabled": true, "handshake": { "server": "${VLESS_SNI}", "server_port": 443 }, "private_key": "${PK}", "short_id": ["${SHORT_ID}"] }
      }
    }
EOF
)
    JSON_HY2=$(cat << EOF
    {
      "type": "hysteria2", "listen": "::", "listen_port": ${HY2_PORT}, "up_mbps": 3000, "down_mbps": 3000,
      "obfs": { "type": "salamander", "password": "${HY2_OBFS}" },
      "users": [{"password": "${HY2_PASS}"}],
      "tls": { "enabled": true, "certificate_path": "/etc/sing-box/hy2.crt", "key_path": "/etc/sing-box/hy2.key" }
    }
EOF
)
    JSON_SS=$(cat << EOF
    {
      "type": "shadowsocks", "listen": "::", "listen_port": ${SS_PORT}, "tcp_fast_open": true,
      "method": "2022-blake3-aes-128-gcm", "password": "${SS_PASS}"
    }
EOF
)
    case $MODE in "VLESS") INBOUNDS="[$JSON_VLESS]" ;; "HY2") INBOUNDS="[$JSON_HY2]" ;; "SS") INBOUNDS="[$JSON_SS]" ;; "ALL") INBOUNDS="[$JSON_VLESS, $JSON_HY2, $JSON_SS]" ;; esac
    cat > /etc/sing-box/config.json << EOF
{ "log": { "level": "warn" }, "inbounds": ${INBOUNDS}, "outbounds": [{ "type": "direct" }] }
EOF
    cat > /etc/systemd/system/sing-box.service << SVC_EOF
[Unit]
After=network.target
[Service]
$(if [[ "$MODE" == *"HY2"* ]] || [[ "$MODE" == *"ALL"* ]]; then echo -e "ExecStartPre=-/bin/sh -c '/sbin/iptables -t nat -D PREROUTING -p udp --dport 20000:50000 -j REDIRECT --to-ports $HY2_PORT 2>/dev/null || true'\nExecStartPre=-/bin/sh -c '/sbin/ip6tables -t nat -D PREROUTING -p udp --dport 20000:50000 -j REDIRECT --to-ports $HY2_PORT 2>/dev/null || true'\nExecStartPre=-/bin/sh -c '/sbin/iptables -t nat -A PREROUTING -p udp --dport 20000:50000 -j REDIRECT --to-ports $HY2_PORT 2>/dev/null || true'\nExecStartPre=-/bin/sh -c '/sbin/ip6tables -t nat -A PREROUTING -p udp --dport 20000:50000 -j REDIRECT --to-ports $HY2_PORT 2>/dev/null || true'"; fi)
ExecStart=/usr/local/bin/sing-box run -c /etc/sing-box/config.json
$(if [[ "$MODE" == *"HY2"* ]] || [[ "$MODE" == *"ALL"* ]]; then echo -e "ExecStopPost=-/bin/sh -c '/sbin/iptables -t nat -D PREROUTING -p udp --dport 20000:50000 -j REDIRECT --to-ports $HY2_PORT 2>/dev/null || true'\nExecStopPost=-/bin/sh -c '/sbin/ip6tables -t nat -D PREROUTING -p udp --dport 20000:50000 -j REDIRECT --to-ports $HY2_PORT 2>/dev/null || true'"; fi)
Restart=always
LimitNOFILE=1048576
LimitNPROC=infinity
[Install]
WantedBy=multi-user.target
SVC_EOF
    systemctl daemon-reload && systemctl enable --now sing-box; systemctl restart sing-box
    sleep 2; systemctl is-active --quiet sing-box || { echo -e "${RED}[!] 致命错误：Sing-box 无法启动。${NC}"; journalctl -u sing-box --no-pager -n 20; exit 1; }
    cat > /etc/ddr/.env << ENV_EOF
CORE="singbox"; MODE="$MODE"; UUID="$UUID"; VLESS_SNI="$VLESS_SNI"; VLESS_PORT="$VLESS_PORT"; HY2_SNI="$HY2_SNI"; HY2_PORT="$HY2_PORT"; SS_PORT="$SS_PORT"; PUBLIC_KEY="$PBK"; SHORT_ID="$SHORT_ID"; HY2_PASS="$HY2_PASS"; HY2_OBFS="$HY2_OBFS"; SS_PASS="$SS_PASS"; LINK_IP="$(curl -s4 api.ipify.org)"
ENV_EOF
    view_config "deploy"
}

view_config() {
    local CALLER=$1; clear; [[ ! -f /etc/ddr/.env ]] && { echo -e "${RED}未检测到配置！${NC}"; sleep 2; return 0; }
    source /etc/ddr/.env
    echo -e "${BLUE}======================================================================${NC}\n${BOLD}${CYAN}   协议全部节点参数 (${MODE}) / All Protocol Parameters ${NC}\n${BLUE}======================================================================${NC}"
    echo -e "${BOLD}Engine:${NC} $CORE | ${BOLD}Mode:${NC} $MODE\n${BLUE}----------------------------------------------------------------------${NC}"
    if [[ "$MODE" == *"VLESS"* ]] || [[ "$MODE" == *"ALL"* ]]; then
        echo -e "${YELLOW}[ VLESS-Vision 通用链接 ]${NC}\n(注: 小火箭务必将 uTLS 设置为 chrome, 否则秒被服务端断开)\nvless://$UUID@$LINK_IP:$VLESS_PORT?encryption=none&flow=xtls-rprx-vision&security=reality&sni=$VLESS_SNI&fp=chrome&pbk=$PUBLIC_KEY&sid=$SHORT_ID&type=tcp#Aio-VLESS\n"
    fi
    if [[ "$MODE" == *"HY2"* ]] || [[ "$MODE" == *"ALL"* ]]; then
        echo -e "${YELLOW}[ Hysteria 2 通用链接 ]${NC}\n(注: iOS小火箭请开启 \"允许不安全\")\nhysteria2://$HY2_PASS@$LINK_IP:$HY2_PORT/?insecure=1&sni=$HY2_SNI&alpn=h3&obfs=salamander&obfs-password=$HY2_OBFS&mport=20000-50000#Aio-Hy2\n"
    fi
    if [[ "$MODE" == *"SS"* ]] || [[ "$MODE" == *"ALL"* ]]; then
        SS_BASE64=$(echo -n "2022-blake3-aes-128-gcm:${SS_PASS}" | base64 -w 0 2>/dev/null || echo -n "2022-blake3-aes-128-gcm:${SS_PASS}" | base64 | tr -d '\n')
        echo -e "${YELLOW}[ Shadowsocks-2022 通用链接 ]${NC}\nss://${SS_BASE64}@${LINK_IP}:$SS_PORT#Aio-SS\n"
    fi
    [[ "$CALLER" == "deploy" ]] && echo -e "${GREEN}✔ 部署成功！如果要查询节点明细请随时进入菜单 13。${NC}"
    read -ep "按回车返回主菜单..."
}

clean_uninstall() {
    clear; echo -e "${RED}⚠️  正在执行核弹级清理...${NC}"
    systemctl stop xray sing-box hysteria 2>/dev/null || true
    systemctl disable xray sing-box hysteria 2>/dev/null || true
    killall -9 xray sing-box hysteria 2>/dev/null || true
    iptables -t nat -F PREROUTING 2>/dev/null || true
    iptables -F INPUT 2>/dev/null || true
    rm -rf /usr/local/etc/xray /etc/sing-box /usr/local/bin/xray /usr/local/bin/sing-box /etc/systemd/system/xray.service /etc/systemd/system/sing-box.service /etc/systemd/system/hysteria.service /usr/local/bin/hysteria /etc/hysteria
    systemctl daemon-reload
    rm -rf /etc/ddr /usr/local/bin/sb
    echo -e "${GREEN}✔ 物理清场完成！${NC}"; exit 0
}

check_virgin_state() {
    clear
    echo -e "\n\033[1;33m========================================================\033[0m"
    echo -e "\033[1;33m       Aio-box 终极环境自愈审计 (Auto-Fix Virgin Check)     \033[0m"
    echo -e "\033[1;33m========================================================\033[0m\n"

    echo -e "\033[1;36m[1/5] 检查端口与进程死锁...\033[0m"
    local BAD_PROC=$(ps aux | grep -E 'xray|sing-box|hysteria' | grep -v grep 2>/dev/null)
    local BAD_PORT=$(ss -tulpn | grep -E ':80\b|:443\b|:2053\b|:8443\b' 2>/dev/null)
    if [[ -n "$BAD_PROC" || -n "$BAD_PORT" ]]; then
        echo -e "${YELLOW}  [!] 发现干扰项，正在执行全自动绞杀修复...${NC}"
        systemctl stop xray sing-box hysteria 2>/dev/null || true
        killall -9 xray sing-box hysteria 2>/dev/null || true
        fuser -k -9 443/tcp 443/udp 2053/tcp 2053/udp 80/tcp 2>/dev/null || true
        echo -e "${GREEN}  ✔ 修复完成：端口已释放，进程已归零。${NC}"
    else
        echo -e "${GREEN}  ✔ 完美：无端口死锁，无幽灵进程。${NC}"
    fi

    echo -e "\n\033[1;36m[2/5] 检查内核 NAT 链污染...\033[0m"
    local NAT_C=$(iptables -t nat -L PREROUTING -nv | grep -i REDIRECT 2>/dev/null)
    if [[ -n "$NAT_C" ]]; then
        echo -e "${YELLOW}  [!] 发现 NAT 转发残留，正在重置防火墙规则...${NC}"
        iptables -t nat -F PREROUTING 2>/dev/null
        echo -e "${GREEN}  ✔ 修复完成：内核转发链已清空。${NC}"
    else
        echo -e "${GREEN}  ✔ 完美：防火墙链条纯净。${NC}"
    fi

    echo -e "\n\033[1;36m[3/5] 检查 Systemd 服务残留...\033[0m"
    if [[ -f /etc/systemd/system/xray.service || -f /etc/systemd/system/sing-box.service ]]; then
        echo -e "${YELLOW}  [!] 发现旧服务注册项，正在物理注销...${NC}"
        rm -f /etc/systemd/system/xray.service /etc/systemd/system/sing-box.service 2>/dev/null
        systemctl daemon-reload
        echo -e "${GREEN}  ✔ 修复完成：系统服务已注销。${NC}"
    else
        echo -e "${GREEN}  ✔ 完美：服务注册表纯净。${NC}"
    fi

    echo -e "\n\033[1;36m[4/5] 检查物理文件污染...\033[0m"
    local DIR_C=$(ls -d /usr/local/etc/xray /etc/sing-box /etc/hysteria 2>/dev/null)
    if [[ -n "$DIR_C" ]]; then
        echo -e "${YELLOW}  [!] 发现残留配置目录，正在执行粉碎删除...${NC}"
        rm -rf /usr/local/etc/xray /etc/sing-box /etc/hysteria /usr/local/bin/xray /usr/local/bin/sing-box 2>/dev/null
        echo -e "${GREEN}  ✔ 修复完成：残留文件已彻底移除。${NC}"
    else
        echo -e "${GREEN}  ✔ 完美：文件系统纯净。${NC}"
    fi

    echo -e "\n\033[1;36m[5/5] 检查 VPS 网络健康状态...\033[0m"
    if curl -I -s -m 5 https://www.google.com | head -n 1 | grep -qE "200|301|302"; then
        echo -e "${GREEN}  ✔ 完美：服务器出站通畅。${NC}"
    else
        echo -e "${RED}  [!] 警告：出站受阻，请检查云控制台安全组策略！${NC}"
    fi

    echo -e "\n\033[1;33m========================================================\033[0m"
    echo -e "${GREEN}审计与自动修复已完成。您的 VPS 环境现在处于最佳安装状态。${NC}"
    read -ep "按回车返回主菜单..."
}

tune_vps() {
    clear; echo -e "${CYAN}正在执行 VPS 全面优化...${NC}"
    grep -q '1048576' /etc/security/limits.conf || { echo "* soft nofile 1048576" >> /etc/security/limits.conf; echo "* hard nofile 1048576" >> /etc/security/limits.conf; }
    modprobe tcp_bbr 2>/dev/null || true
    cat > /etc/sysctl.d/99-ddr-tune.conf << 'EOF'
fs.file-max=1048576
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_fastopen=3
EOF
    sysctl -p /etc/sysctl.d/99-ddr-tune.conf >/dev/null 2>&1 || true
    echo -e "${GREEN}✔ 优化完成。${NC}"; read -ep "按回车返回..."
}

setup_shortcut
while true; do
    IPV4=$(curl -s4m3 api.ipify.org || echo "N/A"); PUBLIC_IP="$IPV4"
    systemctl is-active --quiet xray && STATUS="${GREEN}Running (Xray)${NC}" || { systemctl is-active --quiet sing-box && STATUS="${CYAN}Running (Sing-box)${NC}" || STATUS="${RED}Stopped${NC}"; }
    source /etc/ddr/.env 2>/dev/null && CUR_MODE="[${CORE}-${MODE}]" || CUR_MODE=""
    clear; echo -e "${BLUE}======================================================================${NC}\n${BOLD}${PURPLE}  Aio-box Ultimate Console [Apex V46 AutoFix] ${NC}\n${BLUE}======================================================================${NC}"
    echo -e " IP: ${YELLOW}$IPV4${NC} | STATUS: $STATUS $CUR_MODE\n${BLUE}----------------------------------------------------------------------${NC}"
    echo -e " ${YELLOW}[ Xray-core 部署 ]${NC}          ${CYAN}[ Sing-box 部署 ]${NC}"
    echo -e " ${GREEN}1.${NC} VLESS-Vision (Reality)   ${GREEN}5.${NC} VLESS-Vision (Reality)"
    echo -e " ${GREEN}2.${NC} Hysteria 2               ${GREEN}6.${NC} Hysteria 2"
    echo -e " ${GREEN}3.${NC} Shadowsocks              ${GREEN}7.${NC} Shadowsocks"
    echo -e " ${GREEN}4.${NC} 协议全家桶 / All-in-One  ${GREEN}8.${NC} 协议全家桶 / All-in-One"
    echo -e "${BLUE}----------------------------------------------------------------------${NC}"
    echo -e " ${GREEN}11.${NC} VPS 全面调优优化         ${YELLOW}13.${NC} 全部节点参数导出"
    echo -e " ${CYAN}16.${NC} 环境审计与自动自愈修复   ${RED}15.${NC} 彻底卸载清空退出"
    echo -e " ${GREEN}0.${NC}  退出面板 / Exit"
    echo -e "${BLUE}======================================================================${NC}"
    read -ep " 请选择: " choice
    case $choice in
        1|2|3|4) deploy_xray "$([[ $choice == 1 ]] && echo VLESS || [[ $choice == 2 ]] && echo HY2 || [[ $choice == 3 ]] && echo SS || echo ALL)" ;;
        5|6|7|8) deploy_singbox "$([[ $choice == 5 ]] && echo VLESS || [[ $choice == 6 ]] && echo HY2 || [[ $choice == 7 ]] && echo SS || echo ALL)" ;;
        11) tune_vps ;; 13) view_config "" ;; 
        15) clean_uninstall ;; 16) check_virgin_state ;; 0) clear; exit 0 ;; *) sleep 1 ;;
    esac
done
