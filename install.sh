#!/usr/bin/env bash
# ====================================================================
# All-in-One Duo Ultimate Console [Dual-Core Omni | Shortcut 'sb']
# Features: TCP-Vision, YAML, Local Cache, Smart Uninstall, Key-Guard
# Author: Nbody | Version: 2026.04.Apex
# ====================================================================

set -e
export DEBIAN_FRONTEND=noninteractive
export LC_ALL=C

RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[0;33m' BLUE='\033[0;36m' PURPLE='\033[0;35m' CYAN='\033[0;36m' NC='\033[0m' BOLD='\033[1m'
trap 'echo -e "\n${RED}[!] 触发安全自愈，系统中断并回滚 / Rollback initiated.${NC}"; exit 1' ERR

# --- [0] 本地化快捷指令引擎 ---
setup_shortcut() {
    mkdir -p /etc/ddr
    if [[ ! -f /etc/ddr/aio.sh || "$1" == "update" ]]; then
        curl -Ls https://raw.githubusercontent.com/alariclin/all-in-one-duo/main/install.sh > /etc/ddr/aio.sh
        chmod +x /etc/ddr/aio.sh
    fi
    if [[ ! -f /usr/local/bin/sb ]]; then
        echo '#!/usr/bin/env bash' > /usr/local/bin/sb
        echo 'bash /etc/ddr/aio.sh' >> /usr/local/bin/sb
        chmod +x /usr/local/bin/sb
    fi
}

# --- [1] 环境初始化与依赖 ---
check_base() {
    if [[ ! -d /run/systemd/system ]]; then echo -e "${RED}[!] 错误: 不支持无 Systemd 的系统.${NC}"; exit 1; fi
    if command -v apt-get >/dev/null; then PKG_MGR="apt-get"; PKG_INSTALL="apt-get install -y -q"; PKG_UPDATE="apt-get update -y -q"
    elif command -v yum >/dev/null; then PKG_MGR="yum"; PKG_INSTALL="yum install -y -q"; PKG_UPDATE="yum makecache -y -q"
    else echo -e "${RED}[!] 仅支持 Debian/Ubuntu 或 RHEL/CentOS.${NC}"; exit 1; fi
}

check_env() {
    check_base
    if ! command -v jq >/dev/null || ! command -v bc >/dev/null || ! command -v unzip >/dev/null; then
        echo -e "${YELLOW}[*] 安装底层依赖 / Base dependencies...${NC}"
        $PKG_UPDATE >/dev/null 2>&1 || true
        $PKG_INSTALL wget curl jq openssl uuid-runtime psmisc socat cron chrony fail2ban iptables iproute2 python3 bc unzip >/dev/null 2>&1 || true
        if [[ "$PKG_MGR" == "apt-get" ]]; then $PKG_INSTALL iptables-persistent >/dev/null 2>&1 || true; fi
        systemctl enable cron 2>/dev/null || true; systemctl start cron 2>/dev/null || true
    fi
}

# --- [1.5] 极限网络自愈与本地核心缓存引擎 ---
fetch_core() {
    local file_name=$1
    local download_url=$2
    local cache_dir="/etc/ddr/.core_cache"
    mkdir -p "$cache_dir"

    if [[ -f "${cache_dir}/${file_name}" ]]; then
        echo -e "${GREEN} -> 检测到本地物理缓存 [${file_name}]，极速离线提取中...${NC}"
        cp "${cache_dir}/${file_name}" "/tmp/${file_name}"
        return 0
    fi

    echo -e "${YELLOW} -> 正在拉取云端核心 [${file_name}]...${NC}"
    local mirrors=("" "https://ghp.ci/" "https://ghproxy.net/" "https://fastgh.js.org/" "https://mirror.ghproxy.com/")
    local success=0
    for mirror in "${mirrors[@]}"; do
        if curl -fL --connect-timeout 5 --max-time 30 "${mirror}${download_url}" -o "/tmp/${file_name}" 2>/dev/null; then
            if [[ -s "/tmp/${file_name}" ]]; then
                cp "/tmp/${file_name}" "${cache_dir}/${file_name}"
                success=1
                echo -e "${GREEN}   ✔ 获取成功，已写入本地永久缓存区。${NC}"
                break
            fi
        fi
    done

    if [[ $success -eq 0 ]]; then
        echo -e "${RED}[!] 致命错误：云端节点均不可用，且无本地缓存！请检查 VPS 网络。${NC}"
        exit 1
    fi
}

# --- [2] VPS 网络调优 ---
tune_vps() {
    clear; echo -e "${BLUE}======================================================${NC}\n${BOLD}${CYAN}  VPS 系统并发限制解除与网络栈调优 / VPS Init & Tuning ${NC}\n${BLUE}======================================================${NC}"; check_base
    if command -v getenforce >/dev/null && [ "$(getenforce)" == "Enforcing" ]; then
        $PKG_INSTALL policycoreutils-python-utils 2>/dev/null || true
        semanage port -a -t http_port_t -p tcp 443 2>/dev/null || true; semanage port -a -t http_port_t -p tcp 2053 2>/dev/null || true
    fi
    PHY_MEM=$(free -m | awk '/^Mem:/{print $2}'); SWAP_MEM=$(free -m | awk '/^Swap:/{print $2}')
    if [[ "$SWAP_MEM" == "0" ]] && [[ "$PHY_MEM" -le 1500 ]]; then
        fallocate -l 1G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=1024 >/dev/null 2>&1
        chmod 600 /swapfile; mkswap /swapfile >/dev/null 2>&1; swapon /swapfile >/dev/null 2>&1
        grep -q '/swapfile' /etc/fstab || echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
    fi
    grep -q '1048576' /etc/security/limits.conf || { echo "* soft nofile 1048576" >> /etc/security/limits.conf; echo "* hard nofile 1048576" >> /etc/security/limits.conf; }
    systemctl restart fail2ban 2>/dev/null || true; systemctl enable chronyd 2>/dev/null || true; systemctl start chronyd 2>/dev/null || true
    date -s "$(curl -sI https://google.com | grep -i Date | sed 's/Date: //g')" >/dev/null 2>&1 || true; modprobe tcp_bbr 2>/dev/null || true
    cat > /etc/sysctl.d/99-ddr-tune.conf << 'EOF'
fs.file-max = 1048576
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 10000
net.core.somaxconn = 32768
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_mtu_probing = 1
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
EOF
    sysctl -p /etc/sysctl.d/99-ddr-tune.conf >/dev/null 2>&1 || true
    echo -e "${GREEN}✔ 优化完成 / Tuning Complete.${NC}"; read -p "按回车返回 / Press Enter..."
}

get_system_info() {
    IPV4=$(curl -s4m3 api.ipify.org || echo ""); IPV6=$(curl -s6m3 api64.ipify.org || echo "")
    [[ -n "$IPV4" ]] && PUBLIC_IP="$IPV4" && LINK_IP="$IPV4" && DNS_TYPE="A" || { PUBLIC_IP="$IPV6"; LINK_IP="[$IPV6]"; DNS_TYPE="AAAA"; }
    if systemctl is-active --quiet xray; then STATUS="${GREEN}Xray-core Running${NC}"; CORE_RUNNING="xray"
    elif systemctl is-active --quiet sing-box; then STATUS="${CYAN}Sing-box Running${NC}"; CORE_RUNNING="singbox"
    else STATUS="${RED}Stopped / 未运行${NC}"; CORE_RUNNING="none"; fi
    [[ -n "$PUBLIC_IP" ]] && ASN_ORG=$(curl -sm3 "ipinfo.io/$PUBLIC_IP/org" | tr '[:lower:]' '[:upper:]' | cut -d ' ' -f 2- || echo "GENERIC") || ASN_ORG="UNKNOWN"
    COUNTRY=$(curl -sm3 "ipinfo.io/$PUBLIC_IP/country" | tr '[:lower:]' '[:upper:]' | tr -d '\n\r' || echo "US")
}

check_port_conflict() {
    if [[ "$CORE_RUNNING" != "none" ]] || ss -tulpn | grep -qE ':(443|2053|8443) '; then
        echo -e "${RED}[!] 核心已运行或端口冲突 / Ports occupied.${NC}"
        read -p "    清空旧配置并释放端口？/ Clean ports? [y/N]: " rm_old
        if [[ "${rm_old,,}" == "y" ]]; then
            systemctl stop xray sing-box nginx 2>/dev/null || true; systemctl disable xray sing-box nginx 2>/dev/null || true
            rm -rf /usr/local/etc/xray /etc/sing-box /usr/local/bin/xray /usr/local/bin/sing-box
            if command -v fuser >/dev/null 2>&1; then fuser -k 443/tcp 443/udp 2053/tcp 8443/tcp 8443/udp 80/tcp 2>/dev/null || true; fi
        else exit 1; fi
    fi
}

calculate_sni() {
    ASN_UPPER=$(echo "$ASN_ORG" | tr '[:lower:]' '[:upper:]')
    if [[ "$ASN_UPPER" == *"AMAZON"* ]]; then case "$COUNTRY" in "JP") AUTO_REALITY="s3.ap-northeast-1.amazonaws.com" ;; "SG") AUTO_REALITY="s3.ap-southeast-1.amazonaws.com" ;; "HK") AUTO_REALITY="s3.ap-east-1.amazonaws.com" ;; "GB") AUTO_REALITY="s3.eu-west-2.amazonaws.com" ;; *) AUTO_REALITY="s3.us-west-2.amazonaws.com" ;; esac
    elif [[ "$ASN_UPPER" == *"GOOGLE"* ]]; then AUTO_REALITY="storage.googleapis.com"
    elif [[ "$ASN_UPPER" == *"MICROSOFT"* || "$ASN_UPPER" == *"AZURE"* ]]; then AUTO_REALITY="dl.delivery.mp.microsoft.com"
    elif [[ "$ASN_UPPER" == *"ALIBABA"* || "$ASN_UPPER" == *"ALIPAY"* ]]; then AUTO_REALITY="www.alibabacloud.com"
    elif [[ "$ASN_UPPER" == *"TENCENT"* ]]; then AUTO_REALITY="intl.cloud.tencent.com"
    elif [[ "$ASN_UPPER" == *"CLOUDFLARE"* ]]; then AUTO_REALITY="time.cloudflare.com"
    elif [[ "$ASN_UPPER" == *"ORACLE"* ]]; then AUTO_REALITY="docs.oracle.com"
    else case "$COUNTRY" in "CN"|"HK"|"TW"|"SG"|"JP"|"KR") AUTO_REALITY="gateway.icloud.com" ;; "US"|"CA") AUTO_REALITY="swcdn.apple.com" ;; *) AUTO_REALITY="www.microsoft.com" ;; esac; fi
    AUTO_HY2="api-sync.network"
}

setup_traffic_guard() {
    local quota_gb=$1; local core_name=$2
    if [[ "$quota_gb" -le 0 ]]; then rm -f /etc/ddr/.quota /usr/local/bin/ddr-quota.sh; crontab -l 2>/dev/null | grep -v 'ddr-quota.sh' | crontab -; return; fi
    echo "$quota_gb" > /etc/ddr/.quota
    cat > /usr/local/bin/ddr-quota.sh << EOF
#!/bin/bash
QUOTA_GB=\$(cat /etc/ddr/.quota)
if [[ "$core_name" == "xray" ]]; then STATS=\$(/usr/local/bin/xray api statsquery -server=127.0.0.1:10085 2>/dev/null); [[ -z "\$STATS" ]] && exit 0; TOTAL_BYTES=\$(echo "\$STATS" | jq '[.stat[] | .value] | add')
else STATS=\$(/usr/local/bin/sing-box stats query --json 2>/dev/null); [[ -z "\$STATS" || "\$STATS" == "null" ]] && exit 0; TOTAL_BYTES=\$(echo "\$STATS" | jq '[.[].stats | .rx + .tx] | add'); fi
TOTAL_GB=\$(echo "scale=2; \$TOTAL_BYTES / 1073741824" | bc)
if (( \$(echo "\$TOTAL_GB >= \$QUOTA_GB" | bc -l) )); then systemctl stop $core_name; echo "Traffic Quota Exceeded." > /var/log/ddr-quota.log; fi
EOF
    chmod +x /usr/local/bin/ddr-quota.sh
    (crontab -l 2>/dev/null | grep -v 'ddr-quota.sh'; echo "*/5 * * * * /usr/local/bin/ddr-quota.sh") | crontab -
    (crontab -l 2>/dev/null | grep -v "$core_name restart"; echo "0 0 1 * * systemctl restart $core_name") | crontab -
}

print_links() {
    source /etc/ddr/.env 2>/dev/null || return
    local SKIP_CERT=$([[ "$HY2_INSECURE_FLAG" == "1" ]] && echo "true" || echo "false")
    
    echo -e "\n${YELLOW}--- 节点订阅链接 (通用 URI) ---${NC}"
    if [[ "$CORE" == "xray" ]]; then
        if grep -q "vless-in" /usr/local/etc/xray/config.json 2>/dev/null; then echo -e "${CYAN}[ Xray VLESS-TCP-Vision ]${NC}\nvless://$UUID@$LINK_IP:443?encryption=none&flow=xtls-rprx-vision&security=reality&sni=$REALITY_SNI&fp=chrome&pbk=$PUBLIC_KEY&sid=$SHORT_ID&type=tcp#Xray-Reality\n"; fi
        if grep -q "hy2-in" /usr/local/etc/xray/config.json 2>/dev/null; then echo -e "${CYAN}[ Xray Hysteria2 (Salamander) ]${NC}\nhy2://$HY2_PASS@$LINK_IP:8443?insecure=1&sni=$HY2_SNI&mport=20000-50000&obfs=salamander&obfs-password=$HY2_OBFS#Xray-Hy2\n"; fi
        if grep -q "ss-in" /usr/local/etc/xray/config.json 2>/dev/null; then echo -e "${CYAN}[ Xray SS-2022 ]${NC}\nss://${SS_SIP_CORE}@$LINK_IP:2053#Xray-SS\n"; fi
    else
        if grep -q "vless-in" /etc/sing-box/config.json 2>/dev/null; then echo -e "${GREEN}[ Sing-box VLESS-TCP-Vision ]${NC}\nvless://$UUID@$LINK_IP:443?encryption=none&flow=xtls-rprx-vision&security=reality&sni=$REALITY_SNI&fp=chrome&pbk=$PUBLIC_KEY&sid=$SHORT_ID&type=tcp#SB-Reality\n"; fi
        if grep -q "hy2-in" /etc/sing-box/config.json 2>/dev/null; then
            if [[ "$HY2_INSECURE_FLAG" == "0" ]]; then echo -e "${GREEN}[ Sing-box Hysteria 2 (Real CA) ]${NC}\nhy2://$HY2_PASS@$LINK_IP:443?sni=$HY2_SNI&mport=20000-50000&obfs=salamander&obfs-password=$HY2_OBFS#SB-Hy2-CA\n"
            else echo -e "${GREEN}[ Sing-box Hysteria 2 (Self-Signed) ]${NC}\nhy2://$HY2_PASS@$LINK_IP:443?insecure=1&sni=$HY2_SNI&mport=20000-50000&obfs=salamander&obfs-password=$HY2_OBFS#SB-Hy2-Self\n"; fi
        fi
        if grep -q "ss-in" /etc/sing-box/config.json 2>/dev/null; then echo -e "${GREEN}[ Sing-box SS-2022 ]${NC}\nss://${SS_SIP_CORE}@$LINK_IP:2053#SB-SS\n"; fi
    fi

    echo -e "${PURPLE}--- Clash Meta (Mihomo) YAML 拓扑节点 (已默认启用 uTLS) ---${NC}"
    echo -e "proxies:"
    if [[ "$CORE" == "xray" ]]; then
        if grep -q "vless-in" /usr/local/etc/xray/config.json 2>/dev/null; then
            echo -e "  - name: Xray-VLESS-TCP-Vision\n    type: vless\n    server: $LINK_IP\n    port: 443\n    uuid: $UUID\n    network: tcp\n    tls: true\n    udp: true\n    xudp: true\n    flow: xtls-rprx-vision\n    servername: $REALITY_SNI\n    client-fingerprint: chrome\n    reality-opts:\n      public-key: $PUBLIC_KEY\n      short-id: $SHORT_ID"
        fi
        if grep -q "hy2-in" /usr/local/etc/xray/config.json 2>/dev/null; then
            echo -e "  - name: Xray-Hysteria2\n    type: hysteria2\n    server: $LINK_IP\n    port: 8443\n    password: $HY2_PASS\n    sni: $HY2_SNI\n    skip-cert-verify: $SKIP_CERT\n    obfs: salamander\n    obfs-password: $HY2_OBFS\n    ports: 20000-50000"
        fi
        if grep -q "ss-in" /usr/local/etc/xray/config.json 2>/dev/null; then
            echo -e "  - name: Xray-SS2022\n    type: ss\n    server: $LINK_IP\n    port: 2053\n    cipher: 2022-blake3-aes-128-gcm\n    password: $SS_PASS"
        fi
    else
        if grep -q "vless-in" /etc/sing-box/config.json 2>/dev/null; then
            echo -e "  - name: SB-VLESS-TCP-Vision\n    type: vless\n    server: $LINK_IP\n    port: 443\n    uuid: $UUID\n    network: tcp\n    tls: true\n    udp: true\n    xudp: true\n    flow: xtls-rprx-vision\n    servername: $REALITY_SNI\n    client-fingerprint: chrome\n    reality-opts:\n      public-key: $PUBLIC_KEY\n      short-id: $SHORT_ID"
        fi
        if grep -q "hy2-in" /etc/sing-box/config.json 2>/dev/null; then
            echo -e "  - name: SB-Hysteria2\n    type: hysteria2\n    server: $LINK_IP\n    port: 443\n    password: $HY2_PASS\n    sni: $HY2_SNI\n    skip-cert-verify: $SKIP_CERT\n    obfs: salamander\n    obfs-password: $HY2_OBFS\n    ports: 20000-50000"
        fi
        if grep -q "ss-in" /etc/sing-box/config.json 2>/dev/null; then
            echo -e "  - name: SB-SS2022\n    type: ss\n    server: $LINK_IP\n    port: 2053\n    cipher: 2022-blake3-aes-128-gcm\n    password: $SS_PASS"
        fi
    fi
    echo -e ""
}

view_links_and_config() {
    clear; source /etc/ddr/.env 2>/dev/null || { echo "未安装或配置丢失 / Not installed"; sleep 2; return; }
    echo -e "${BLUE}======================================================${NC}\n${BOLD}${CYAN}   核心参数明细与节点配置 / Parameters & Nodes ${NC}\n${BLUE}======================================================${NC}"
    echo -e "${BOLD}1. 核心/Core:${NC} $([[ "$CORE" == "xray" ]] && echo 'Xray-core' || echo 'Sing-box')"
    echo -e "\n${BOLD}2. VLESS-REALITY:${NC} 目标 SNI: $REALITY_SNI\n   - pbk: $PUBLIC_KEY | sid: $SHORT_ID"
    echo -e "\n${BOLD}3. Hysteria 2:${NC} 伪装 SNI: $HY2_SNI\n   - CA: $([[ "$HY2_INSECURE_FLAG" == "0" ]] && echo 'Real' || echo 'Self-Signed')"
    echo -e "\n${BOLD}4. Shadowsocks 2022:${NC} Port: 2053\n${BLUE}======================================================${NC}"
    print_links
    read -p "按回车返回主菜单 / Press Enter to return..."
}

clean_uninstall() {
    clear; echo -e "${RED}======================================================\n ⚠️ 警告：您正在执行彻底卸载操作 / Clean Uninstall\n======================================================${NC}"
    read -p " [?] 是否保留 'sb' 快捷指令和本地核心缓存以便未来快速重装？ [Y/n]: " keep_sb
    
    systemctl stop xray sing-box 2>/dev/null || true
    systemctl disable xray sing-box 2>/dev/null || true
    
    rm -rf /usr/local/etc/xray /etc/sing-box /usr/local/bin/xray /usr/local/bin/sing-box /usr/local/bin/ddr-quota.sh ~/.acme.sh /etc/sysctl.d/99-ddr-tune.conf
    sysctl --system >/dev/null 2>&1 || true
    crontab -l 2>/dev/null | grep -v 'ddr-quota.sh' | crontab -
    iptables -t nat -D PREROUTING -p udp --dport 20000:50000 -j REDIRECT --to-ports 443 2>/dev/null || true
    iptables -t nat -D PREROUTING -p udp --dport 20000:50000 -j REDIRECT --to-ports 8443 2>/dev/null || true

    if [[ "${keep_sb,,}" == "n" ]]; then
        rm -rf /etc/ddr /usr/local/bin/sb
        echo -e "${GREEN}✔ 卸载完成！系统已彻底清空，包含脚本本体与核心缓存已全部物理删除。${NC}"
    else
        rm -rf /etc/ddr/.env /etc/ddr/.quota
        echo -e "${GREEN}✔ 核心清理成功！已为您保留 'sb' 快捷指令及离线核心缓存，随时可重装。${NC}"
    fi
    sleep 2
}

# --- [5] Xray-core 本地化部署 ---
install_xray() {
    local MODE=$1; clear; echo -e "${BLUE}======================================================${NC}\n${BOLD}${GREEN} 部署 Xray-core [经典 TCP-Vision 强隐私架构] - Mode: $MODE ${NC}\n${BLUE}======================================================${NC}"
    check_env; check_port_conflict
    read -p " [?] 输入每月限额(GB，0为不限制): " QUOTA_GB; [[ -z "$QUOTA_GB" || ! "$QUOTA_GB" =~ ^[0-9]+$ ]] && QUOTA_GB=0
    echo -e "\n [?] 路由规则:  1. 全局代理   2. 智能分流 (屏蔽广告+按需直连) (推荐)"; read -p " 选择 [1-2, default 2]: " ROUTE_CHOICE; [[ -z "$ROUTE_CHOICE" ]] && ROUTE_CHOICE=2
    
    echo -e "\n${YELLOW}[1/4] 本地化网络自愈获取核心...${NC}"
    XRAY_VER=$(curl -sm5 "https://api.github.com/repos/XTLS/Xray-core/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")' || echo "")
    [[ -z "$XRAY_VER" ]] && XRAY_VER="v1.8.24"
    ARCH=$(uname -m | sed 's/x86_64/64/;s/aarch64/arm64-v8a/')
    fetch_core "xray_${XRAY_VER}_${ARCH}.zip" "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VER}/Xray-linux-${ARCH}.zip"
    fetch_core "geoip.dat" "https://github.com/v2fly/geoip/releases/latest/download/geoip.dat"
    fetch_core "geosite.dat" "https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat"

    rm -rf /tmp/xray_ext; unzip -qo "/tmp/xray_${XRAY_VER}_${ARCH}.zip" -d /tmp/xray_ext
    mv /tmp/xray_ext/xray /usr/local/bin/xray; chmod +x /usr/local/bin/xray
    mkdir -p /usr/local/share/xray
    mv /tmp/geoip.dat /usr/local/share/xray/geoip.dat; mv /tmp/geosite.dat /usr/local/share/xray/geosite.dat

    echo -e "${YELLOW}[2/4] SNI 矩阵计算与加密配置...${NC}"; calculate_sni
    echo -e "${CYAN} -> 推荐 REALITY SNI: ${AUTO_REALITY}${NC}"; read -p " -> 自定义 (回车默认): " CUSTOM_REALITY; REALITY_SNI=${CUSTOM_REALITY:-$AUTO_REALITY}
    echo -e "${CYAN} -> 推荐 Hysteria2 SNI: ${AUTO_HY2}${NC}"; read -p " -> 自定义 (回车默认): " CUSTOM_HY2; HY2_SNI=${CUSTOM_HY2:-$AUTO_HY2}

    UUID=$(uuidgen); HY2_PASS=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9'); HY2_OBFS=$(openssl rand -base64 8 | tr -dc 'a-zA-Z0-9')
    SS_PASS=$(openssl rand -base64 16 | tr -d '\n\r'); SS_SIP_CORE=$(echo -n "2022-blake3-aes-128-gcm:${SS_PASS}" | base64 -w 0)
    
    # -------------------------------------------------------------
    # 🚨 终极防空密钥熔断阻断机制 (Fail-Safe Key Guard)
    # -------------------------------------------------------------
    echo -e "${YELLOW} -> 生成底层 REALITY 密钥对...${NC}"
    KEYS=$(/usr/local/bin/xray x25519 2>&1 || true)
    PRIVATE_KEY=$(echo "$KEYS" | grep -i "Private" | awk '{print $NF}' || true)
    PUBLIC_KEY=$(echo "$KEYS" | grep -i "Public" | awk '{print $NF}' || true)
    SHORT_ID=$(openssl rand -hex 4)
    
    if [[ -z "$PRIVATE_KEY" || -z "$PUBLIC_KEY" ]]; then
        echo -e "\n${RED}======================================================${NC}"
        echo -e "${RED}[!] 致命错误：核心无法执行，密钥生成完全失败！${NC}"
        echo -e "${YELLOW}系统阻断：已防止生成损坏的空密钥配置文件。${NC}"
        echo -e "${YELLOW}常见原因：您的系统 CPU 架构 (${ARCH}) 不受支持，或缺少底层 C 运行库。${NC}"
        echo -e "${RED}详细核心报错日志：\n${KEYS}${NC}"
        echo -e "${RED}======================================================${NC}\n"
        exit 1
    fi
    # -------------------------------------------------------------
    
    mkdir -p /usr/local/etc/xray /etc/ddr; HY2_INSECURE_FLAG="1"
    if [[ "$MODE" == "all" || "$MODE" == "hy2" ]]; then
        read -p " [?] 输入已解析域名以申请证书(回车跳过自签): " USER_DOMAIN
        if [[ -n "$USER_DOMAIN" ]]; then
            echo -e "${CYAN} -> 域名溯源验证...${NC}"; systemctl stop nginx 2>/dev/null || true; if command -v fuser >/dev/null 2>&1; then fuser -k 80/tcp 2>/dev/null || true; sleep 1; fi
            RESOLVED_IP=$(curl -sH "accept: application/dns-json" "https://cloudflare-dns.com/dns-query?name=$USER_DOMAIN&type=$DNS_TYPE" | jq -r '.Answer[0].data' || echo "")
            if [[ "$RESOLVED_IP" == "$PUBLIC_IP" ]]; then
                curl -s https://get.acme.sh | sh >/dev/null 2>&1; ~/.acme.sh/acme.sh --register-account -m "ddr@$USER_DOMAIN" --server letsencrypt >/dev/null 2>&1
                if ~/.acme.sh/acme.sh --issue -d "$USER_DOMAIN" --standalone -k ec-256; then
                    ~/.acme.sh/acme.sh --installcert -d "$USER_DOMAIN" --fullchainpath /usr/local/etc/xray/hy2.crt --keypath /usr/local/etc/xray/hy2.key >/dev/null 2>&1
                    HY2_SNI="$USER_DOMAIN"; HY2_INSECURE_FLAG="0"; echo -e "${GREEN} -> ACME 验证成功！${NC}"
                fi
            fi
        fi
        if [[ "$HY2_INSECURE_FLAG" == "1" ]]; then openssl ecparam -genkey -name prime256v1 -out /usr/local/etc/xray/hy2.key 2>/dev/null; openssl req -new -x509 -days 36500 -key /usr/local/etc/xray/hy2.key -out /usr/local/etc/xray/hy2.crt -subj "/CN=$HY2_SNI" 2>/dev/null; fi
    fi

    echo -e "${YELLOW}[3/4] 编译配置拓扑...${NC}"; INBOUNDS=""
    if [[ "$MODE" == "all" || "$MODE" == "vless" ]]; then INBOUNDS+='{ "port": 443, "protocol": "vless", "tag": "vless-in", "settings": { "clients": [{"id": "'$UUID'", "flow": "xtls-rprx-vision"}], "decryption": "none" }, "streamSettings": { "network": "tcp", "security": "reality", "realitySettings": { "dest": "'$REALITY_SNI':443", "serverNames": ["'$REALITY_SNI'"], "privateKey": "'$PRIVATE_KEY'", "shortIds": ["'$SHORT_ID'"] } } },'; fi
    if [[ "$MODE" == "all" || "$MODE" == "hy2" ]]; then INBOUNDS+='{ "port": 8443, "protocol": "hysteria2", "tag": "hy2-in", "settings": { "users": [{"password": "'$HY2_PASS'"}] }, "streamSettings": { "network": "hysteria2", "security": "tls", "tlsSettings": { "alpn": ["h3"], "certificates": [{ "certificateFile": "/usr/local/etc/xray/hy2.crt", "keyFile": "/usr/local/etc/xray/hy2.key" }] }, "hysteria2Settings": { "obfs": "salamander", "obfsPassword": "'$HY2_OBFS'" } } },'; fi
    if [[ "$MODE" == "all" || "$MODE" == "ss" ]]; then INBOUNDS+='{ "port": 2053, "protocol": "shadowsocks", "tag": "ss-in", "settings": { "method": "2022-blake3-aes-128-gcm", "password": "'$SS_PASS'", "network": "tcp,udp" } },'; fi
    INBOUNDS+='{ "listen": "127.0.0.1", "port": 10085, "protocol": "dokodemo-door", "settings": { "address": "127.0.0.1" }, "tag": "api-in" }'
    if [[ "$ROUTE_CHOICE" == "2" ]]; then ROUTE_RULES='[{"type":"field","outboundTag":"direct","domain":["geosite:cn"]},{"type":"field","outboundTag":"direct","ip":["geoip:cn","geoip:private"]},{"type":"field","outboundTag":"block","domain":["geosite:category-ads-all"]},{"inboundTag":["api-in"],"outboundTag":"api","type":"field"}]'; else ROUTE_RULES='[{"inboundTag":["api-in"],"outboundTag":"api","type":"field"}]'; fi

    cat > /usr/local/etc/xray/config.json << EOF
{ "log": { "loglevel": "warning" }, "stats": {}, "api": { "services": ["StatsService"], "tag": "api" }, "policy": { "system": { "statsInboundDownlink": true, "statsInboundUplink": true }, "levels": { "0": { "statsUserUplink": true, "statsUserDownlink": true } } }, "inbounds": [ $INBOUNDS ], "outbounds": [ { "protocol": "freedom", "tag": "direct" }, { "protocol": "blackhole", "tag": "block" } ], "routing": { "domainStrategy": "IPIfNonMatch", "rules": $ROUTE_RULES } }
EOF

    echo -e "${YELLOW}[4/4] 路由规则与系统守护...${NC}"
    iptables -t nat -F PREROUTING 2>/dev/null || true; iptables -t nat -A PREROUTING -p udp --dport 20000:50000 -j REDIRECT --to-ports 8443
    iptables -I INPUT -p tcp -m multiport --dports 80,443,2053,8443 -j ACCEPT; iptables -I INPUT -p udp -m multiport --dports 443,2053,8443,20000:50000 -j ACCEPT
    if command -v netfilter-persistent >/dev/null; then netfilter-persistent save 2>/dev/null || true; fi
    cat > /etc/systemd/system/xray.service << SVC_EOF
[Unit]
After=network.target nss-lookup.target
[Service]
ExecStart=/usr/local/bin/xray run -config /usr/local/etc/xray/config.json
Restart=always
LimitNPROC=infinity
LimitNOFILE=infinity
[Install]
WantedBy=multi-user.target
SVC_EOF
    systemctl daemon-reload && systemctl enable --now xray; setup_traffic_guard "$QUOTA_GB" "xray"

    cat > /etc/ddr/.env << ENV_EOF
CORE="xray"
UUID="$UUID"
HY2_PASS="$HY2_PASS"
HY2_OBFS="$HY2_OBFS"
REALITY_SNI="$REALITY_SNI"
HY2_SNI="$HY2_SNI"
PUBLIC_KEY="$PUBLIC_KEY"
SHORT_ID="$SHORT_ID"
HY2_INSECURE_FLAG="$HY2_INSECURE_FLAG"
LINK_IP="$LINK_IP"
SS_SIP_CORE="$SS_SIP_CORE"
ENV_EOF
    
    echo -e "\n${GREEN}✔ Xray-core 部署成功！${NC}"; print_links; read -p "按回车返回主菜单..."
}

# --- [6] Sing-box 本地化部署 ---
install_singbox() {
    local MODE=$1; clear; echo -e "${BLUE}======================================================${NC}\n${BOLD}${GREEN} 部署 Sing-box [高并发矩阵架构] - Mode: $MODE ${NC}\n${BLUE}======================================================${NC}"
    check_env; check_port_conflict
    read -p " [?] 输入每月限额(GB，0为不限制): " QUOTA_GB; [[ -z "$QUOTA_GB" || ! "$QUOTA_GB" =~ ^[0-9]+$ ]] && QUOTA_GB=0
    echo -e "\n [?] 路由规则:  1. 全局代理   2. 智能分流 (屏蔽广告+按需直连) (推荐)"; read -p " 选择 [1-2, default 2]: " ROUTE_CHOICE; [[ -z "$ROUTE_CHOICE" ]] && ROUTE_CHOICE=2

    echo -e "\n${YELLOW}[1/4] 本地化网络自愈获取核心...${NC}"
    SB_VER=$(curl -sm5 "https://api.github.com/repos/SagerNet/sing-box/releases/latest" | grep -Po '"tag_name": "v\K[^"]*' || echo "")
    [[ -z "$SB_VER" ]] && SB_VER="1.10.1"
    ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
    fetch_core "singbox_${SB_VER}_${ARCH}.tar.gz" "https://github.com/SagerNet/sing-box/releases/download/v${SB_VER}/sing-box-${SB_VER}-linux-${ARCH}.tar.gz"
    
    tar -xzf "/tmp/singbox_${SB_VER}_${ARCH}.tar.gz" -C /tmp
    mv /tmp/sing-box-*/sing-box /usr/local/bin/; chmod +x /usr/local/bin/sing-box

    echo -e "${YELLOW}[2/4] SNI 矩阵计算与加密配置...${NC}"; calculate_sni
    echo -e "${CYAN} -> 推荐 REALITY SNI: ${AUTO_REALITY}${NC}"; read -p " -> 自定义 (回车默认): " CUSTOM_REALITY; REALITY_SNI=${CUSTOM_REALITY:-$AUTO_REALITY}
    echo -e "${CYAN} -> 推荐 Hysteria2 SNI: ${AUTO_HY2}${NC}"; read -p " -> 自定义 (回车默认): " CUSTOM_HY2; HY2_SNI=${CUSTOM_HY2:-$AUTO_HY2}

    UUID=$(uuidgen); HY2_PASS=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9'); HY2_OBFS=$(openssl rand -base64 8 | tr -dc 'a-zA-Z0-9')
    SS_PASS=$(openssl rand -base64 16 | tr -d '\n\r'); SS_SIP_CORE=$(echo -n "2022-blake3-aes-128-gcm:${SS_PASS}" | base64 -w 0)
    
    # -------------------------------------------------------------
    # 🚨 终极防空密钥熔断阻断机制 (Fail-Safe Key Guard)
    # -------------------------------------------------------------
    echo -e "${YELLOW} -> 生成底层 REALITY 密钥对...${NC}"
    KEYS=$(/usr/local/bin/sing-box generate reality-keypair 2>&1 || true)
    PRIVATE_KEY=$(echo "$KEYS" | grep -i "Private" | awk '{print $NF}' || true)
    PUBLIC_KEY=$(echo "$KEYS" | grep -i "Public" | awk '{print $NF}' || true)
    SHORT_ID=$(openssl rand -hex 4)
    
    if [[ -z "$PRIVATE_KEY" || -z "$PUBLIC_KEY" ]]; then
        echo -e "\n${RED}======================================================${NC}"
        echo -e "${RED}[!] 致命错误：核心无法执行，密钥生成完全失败！${NC}"
        echo -e "${YELLOW}系统阻断：已防止生成损坏的空密钥配置文件。${NC}"
        echo -e "${YELLOW}常见原因：您的系统 CPU 架构 (${ARCH}) 不受支持，或缺少底层 C 运行库。${NC}"
        echo -e "${RED}详细核心报错日志：\n${KEYS}${NC}"
        echo -e "${RED}======================================================${NC}\n"
        exit 1
    fi
    # -------------------------------------------------------------
    
    mkdir -p /etc/sing-box /etc/ddr; HY2_INSECURE_FLAG="1"; MASQUERADE_CFG=""
    if [[ "$MODE" == "all" || "$MODE" == "hy2" ]]; then
        read -p " [?] 输入已解析域名以申请证书(回车跳过自签): " USER_DOMAIN
        if [[ -n "$USER_DOMAIN" ]]; then
            echo -e "${CYAN} -> 域名溯源验证...${NC}"; systemctl stop nginx 2>/dev/null || true; if command -v fuser >/dev/null 2>&1; then fuser -k 80/tcp 2>/dev/null || true; sleep 1; fi
            RESOLVED_IP=$(curl -sH "accept: application/dns-json" "https://cloudflare-dns.com/dns-query?name=$USER_DOMAIN&type=$DNS_TYPE" | jq -r '.Answer[0].data' || echo "")
            if [[ "$RESOLVED_IP" == "$PUBLIC_IP" ]]; then
                curl -s https://get.acme.sh | sh >/dev/null 2>&1; ~/.acme.sh/acme.sh --register-account -m "ddr@$USER_DOMAIN" --server letsencrypt >/dev/null 2>&1
                if ~/.acme.sh/acme.sh --issue -d "$USER_DOMAIN" --standalone -k ec-256; then
                    ~/.acme.sh/acme.sh --installcert -d "$USER_DOMAIN" --fullchainpath /etc/sing-box/hy2.crt --keypath /etc/sing-box/hy2.key >/dev/null 2>&1
                    HY2_SNI="$USER_DOMAIN"; HY2_INSECURE_FLAG="0"; MASQUERADE_CFG='"masquerade": "https://nginx.org",'
                    echo -e "${GREEN} -> ACME 验证成功！${NC}"
                fi
            fi
        fi
        if [[ "$HY2_INSECURE_FLAG" == "1" ]]; then openssl ecparam -genkey -name prime256v1 -out /etc/sing-box/hy2.key 2>/dev/null; openssl req -new -x509 -days 36500 -key /etc/sing-box/hy2.key -out /etc/sing-box/hy2.crt -subj "/CN=$HY2_SNI" 2>/dev/null; fi
    fi

    echo -e "${YELLOW}[3/4] 编译配置拓扑...${NC}"
    if [[ "$ROUTE_CHOICE" == "2" ]]; then ROUTE_RULES='{"rules":[{"geosite":["cn"],"geoip":["cn"],"outbound":"direct"},{"geosite":["category-ads-all"],"outbound":"block"}]}'; else ROUTE_RULES='{"rules":[]}'; fi
    INBOUNDS_JSON=""
    if [[ "$MODE" == "all" || "$MODE" == "vless" ]]; then INBOUNDS_JSON+='{ "type": "vless", "tag": "vless-in", "listen": "::", "listen_port": 443, "users": [ { "uuid": "'$UUID'", "flow": "xtls-rprx-vision" } ], "tls": { "enabled": true, "server_name": "'$REALITY_SNI'", "reality": { "enabled": true, "handshake": { "server": "'$REALITY_SNI'", "server_port": 443 }, "private_key": "'$PRIVATE_KEY'", "short_id": [ "'$SHORT_ID'" ] } } },'; fi
    if [[ "$MODE" == "all" || "$MODE" == "hy2" ]]; then INBOUNDS_JSON+='{ "type": "hysteria2", "tag": "hy2-in", "listen": "::", "listen_port": 443, "up_mbps": 1000, "down_mbps": 2000, "obfs": { "type": "salamander", "password": "'$HY2_OBFS'" }, "users": [ { "password": "'$HY2_PASS'" } ], '$MASQUERADE_CFG' "tls": { "enabled": true, "alpn": [ "h3" ], "certificate_path": "/etc/sing-box/hy2.crt", "key_path": "/etc/sing-box/hy2.key" } },'; fi
    if [[ "$MODE" == "all" || "$MODE" == "ss" ]]; then INBOUNDS_JSON+='{ "type": "shadowsocks", "tag": "ss-in", "listen": "::", "listen_port": 2053, "method": "2022-blake3-aes-128-gcm", "password": "'$SS_PASS'" },'; fi
    INBOUNDS_JSON=${INBOUNDS_JSON%,}

    cat > /etc/sing-box/config.json << CONFIG_EOF
{ "log": { "level": "warn" }, "stats": {}, "experimental": { "v2ray_api": { "stats": { "enabled": true }, "listen": "127.0.0.1:10085" } }, "inbounds": [ $INBOUNDS_JSON ], "outbounds": [ { "type": "direct", "tag": "direct" }, { "type": "block", "tag": "block" } ], "route": ${ROUTE_RULES} }
CONFIG_EOF

    echo -e "${YELLOW}[4/4] 路由规则与系统守护...${NC}"
    iptables -t nat -F PREROUTING 2>/dev/null || true; iptables -t nat -A PREROUTING -p udp --dport 20000:50000 -j REDIRECT --to-ports 443
    iptables -I INPUT -p tcp -m multiport --dports 80,443,2053 -j ACCEPT; iptables -I INPUT -p udp -m multiport --dports 443,2053,20000:50000 -j ACCEPT
    if command -v netfilter-persistent >/dev/null; then netfilter-persistent save 2>/dev/null || true; fi
    cat > /etc/systemd/system/sing-box.service << SVC_EOF
[Unit]
After=network.target nss-lookup.target
[Service]
ExecStart=/usr/local/bin/sing-box run -c /etc/sing-box/config.json
Restart=always
LimitNPROC=infinity
LimitNOFILE=infinity
[Install]
WantedBy=multi-user.target
SVC_EOF
    systemctl daemon-reload && systemctl enable --now sing-box; setup_traffic_guard "$QUOTA_GB" "singbox"

    cat > /etc/ddr/.env << ENV_EOF
CORE="singbox"
UUID="$UUID"
HY2_PASS="$HY2_PASS"
HY2_OBFS="$HY2_OBFS"
REALITY_SNI="$REALITY_SNI"
HY2_SNI="$HY2_SNI"
PUBLIC_KEY="$PUBLIC_KEY"
SHORT_ID="$SHORT_ID"
HY2_INSECURE_FLAG="$HY2_INSECURE_FLAG"
LINK_IP="$LINK_IP"
SS_SIP_CORE="$SS_SIP_CORE"
ENV_EOF
    
    echo -e "\n${GREEN}✔ Sing-box 部署成功！${NC}"; print_links; read -p "按回车返回主菜单..."
}

# --- [8] 主面板循环 ---
setup_shortcut
while true; do
    check_env; get_system_info; clear
    echo -e "${BLUE}======================================================${NC}\n${BOLD}${PURPLE}  All-in-One Duo Console [TCP-Vision Stable | 中英] ${NC}\n${BLUE}======================================================${NC}"
    echo -e " ${BOLD}IP:${NC} ${YELLOW}${PUBLIC_IP}${NC} | ${BOLD}ASN:${NC} ${CYAN}${ASN_ORG} (${COUNTRY})${NC}\n ${BOLD}STATUS:${NC} ${STATUS} ${CYAN}(快捷指令: sb)${NC}\n${BLUE}------------------------------------------------------${NC}"
    echo -e " ${BOLD}[ Xray-core 强隐私架构 ]${NC}\n ${GREEN}1.${NC} 部署 全家桶 (VLESS-${YELLOW}TCP-Vision${NC}+Hy2+SS)\n ${GREEN}2.${NC} 仅部署 VLESS-TCP-Vision\n ${GREEN}3.${NC} 仅部署 Hysteria 2\n ${GREEN}4.${NC} 仅部署 SS-2022\n${BLUE}------------------------------------------------------${NC}"
    echo -e " ${BOLD}[ Sing-box 高并发架构 ]${NC}\n ${GREEN}5.${NC} 部署 全家桶 (VLESS+Hy2+SS)\n ${GREEN}6.${NC} 仅部署 VLESS-TCP-Vision\n ${GREEN}7.${NC} 仅部署 Hysteria 2\n ${GREEN}8.${NC} 仅部署 SS-2022\n${BLUE}------------------------------------------------------${NC}"
    echo -e " ${BOLD}[ 运维管理 / Management & Diagnostics ]${NC}\n ${GREEN}9.${NC}  流量监控 / Traffic Monitor & Quota\n ${GREEN}10.${NC} 诊断测速 / Diagnostics & Speedtest\n ${GREEN}11.${NC} VPS 系统与并发调优 / VPS Init & Sys Tuning\n ${GREEN}12.${NC} 账户管理 / Account Management\n ${GREEN}13.${NC} 节点参数与订阅链接 / View Config, Links & YAML\n ${YELLOW}14.${NC} 更新脚本源码 / OTA Update Script\n ${RED}15.${NC} 彻底清空卸载 / Clean Uninstall\n ${GREEN}0.${NC}  退出控制台 / Exit\n${BLUE}======================================================${NC}"
    read -p " 请选择 / Please select [0-15]: " choice
    case $choice in
        1) install_xray "all" ;; 2) install_xray "vless" ;; 3) install_xray "hy2" ;; 4) install_xray "ss" ;;
        5) install_singbox "all" ;; 6) install_singbox "vless" ;; 7) install_singbox "hy2" ;; 8) install_singbox "ss" ;;
        9) check_stats ;; 10) run_diagnostics ;; 11) tune_vps ;; 12) manage_accounts ;; 13) view_links_and_config ;;
        14) setup_shortcut "update"; echo -e "${GREEN}热更新完毕，请重新输入 sb 打开面板。${NC}"; sleep 2; exit 0 ;;
        15) clean_uninstall ;;
        0) clear; exit 0 ;;
        *) sleep 1 ;;
    esac
done
