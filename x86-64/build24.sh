#!/bin/bash
# Log file for debugging
source shell/custom-packages.sh
echo "第三方软件包: $CUSTOM_PACKAGES"
LOGFILE="/tmp/uci-defaults-log.txt"
echo "Starting 99-custom.sh at $(date)" >> $LOGFILE
echo "编译固件大小为: $PROFILE MB"
echo "Include Docker: $INCLUDE_DOCKER"

echo "Create pppoe-settings"
mkdir -p  /home/build/immortalwrt/files/etc/config

# 创建pppoe配置文件 yml传入环境变量ENABLE_PPPOE等 写入配置文件 供99-custom.sh读取
cat << EOF > /home/build/immortalwrt/files/etc/config/pppoe-settings
enable_pppoe=${ENABLE_PPPOE}
pppoe_account=${PPPOE_ACCOUNT}
pppoe_password=${PPPOE_PASSWORD}
EOF

echo "cat pppoe-settings"
cat /home/build/immortalwrt/files/etc/config/pppoe-settings

if [ -z "$CUSTOM_PACKAGES" ]; then
  echo "⚪️ 未选择 任何第三方软件包"
else
  # ============= 同步第三方插件库==============
  # 同步第三方软件仓库run/ipk
  echo "🔄 正在同步第三方软件仓库 Cloning run file repo..."
  # git clone --depth=1 https://github.com/wukongdaily/store.git /tmp/store-run-repo
  git clone --depth=1 https://github.com/weihull/store.git /tmp/store-run-repo

  # 拷贝 run/x86 下所有 run 文件和ipk文件 到 extra-packages 目录
  mkdir -p /home/build/immortalwrt/extra-packages
  cp -r /tmp/store-run-repo/run/x86/* /home/build/immortalwrt/extra-packages/

  echo "✅ Run files copied to extra-packages:"
  ls -lh /home/build/immortalwrt/extra-packages/*.run
  # 解压并拷贝ipk到packages目录
  sh shell/prepare-packages.sh
  ls -lah /home/build/immortalwrt/packages/
fi

# 输出调试信息
echo "$(date '+%Y-%m-%d %H:%M:%S') - 开始构建固件..."

# ============= imm仓库内的插件==============
# 定义所需安装的包列表 下列插件你都可以自行删减
PACKAGES=""
PACKAGES="$PACKAGES curl"
PACKAGES="$PACKAGES luci-i18n-diskman-zh-cn"
PACKAGES="$PACKAGES luci-i18n-firewall-zh-cn"
PACKAGES="$PACKAGES luci-theme-argon"
PACKAGES="$PACKAGES luci-app-argon-config"
PACKAGES="$PACKAGES luci-i18n-argon-config-zh-cn"
#24.10
PACKAGES="$PACKAGES luci-i18n-package-manager-zh-cn"
PACKAGES="$PACKAGES luci-i18n-ttyd-zh-cn"
PACKAGES="$PACKAGES luci-i18n-passwall-zh-cn"
PACKAGES="$PACKAGES luci-app-openclash"
PACKAGES="$PACKAGES luci-i18n-homeproxy-zh-cn"
PACKAGES="$PACKAGES openssh-sftp-server"
PACKAGES="$PACKAGES luci-i18n-samba4-zh-cn"
# 文件管理器
PACKAGES="$PACKAGES luci-i18n-filemanager-zh-cn"
# 静态文件服务器dufs(推荐)
PACKAGES="$PACKAGES luci-i18n-dufs-zh-cn"
#
PACKAGES="$PACKAGES luci-proto-wireguard"
PACKAGES="$PACKAGES luci-app-smartdns"
PACKAGES="$PACKAGES luci-i18n-smartdns-zh-cn"
# 防IP地址伪造攻击 
PACKAGES="$PACKAGES luci-app-banip"
PACKAGES="$PACKAGES luci-i18n-banip-zh-cn"
PACKAGES="$PACKAGES luci-app-bcp38"
PACKAGES="$PACKAGES luci-i18n-bcp38-zh-cn"
PACKAGES="$PACKAGES luci-app-fwknopd"
PACKAGES="$PACKAGES luci-i18n-fwknopd-zh-cn"
# 内存清理工具（释放空闲内存）
PACKAGES="$PACKAGES luci-app-ramfree"
PACKAGES="$PACKAGES luci-i18n-ramfree-zh-cn"
# 基于 DNS 的广告过滤工具）
PACKAGES="$PACKAGES luci-app-adblock"
PACKAGES="$PACKAGES luci-i18n-adblock-zh-cn"
# zerotier内网穿透工具
PACKAGES="$PACKAGES luci-i18n-zerotier-zh-cn"
# NPS 内网穿透服务器
PACKAGES="$PACKAGES luci-app-nps"
PACKAGES="$PACKAGES luci-i18n-nps-zh-cn"
# 动态 DNS 服务配置（支持多种提供商）
PACKAGES="$PACKAGES luci-app-ddns"
PACKAGES="$PACKAGES luci-i18n-ddns-zh-cn"
PACKAGES="$PACKAGES luci-app-ddns-go"
PACKAGES="$PACKAGES luci-i18n-ddns-go-zh-cn"
# Frp 内网穿透客户端
PACKAGES="$PACKAGES luci-app-frpc"
PACKAGES="$PACKAGES luci-i18n-frpc-zh-cn"
# Frp 内网穿透服务端
PACKAGES="$PACKAGES luci-app-frps"
PACKAGES="$PACKAGES luci-i18n-frps-zh-cn"
# Ngrok 内网穿透客户端
PACKAGES="$PACKAGES luci-app-ngrokc"
PACKAGES="$PACKAGES luci-i18n-ngrokc-zh-cn"
# Aria2 多协议下载工具（支持 HTTP/BT/磁力链接）
PACKAGES="$PACKAGES luci-app-aria2"
PACKAGES="$PACKAGES luci-i18n-aria2-zh-cn"
# 解锁网易云音乐灰色歌曲
PACKAGES="$PACKAGES luci-app-unblockneteasemusic"
# openlist
PACKAGES="$PACKAGES luci-app-openlist"
PACKAGES="$PACKAGES luci-i18n-openlist-zh-cn"
# netdata监控面板
PACKAGES="$PACKAGES luci-app-netdata"
PACKAGES="$PACKAGES luci-i18n-netdata-zh-cn"
# 自动获取和更新SSL证书
PACKAGES="$PACKAGES luci-app-acme"
PACKAGES="$PACKAGES luci-i18n-acme-zh-cn"
# 管理用户访问控制列表
PACKAGES="$PACKAGES luci-app-acl"
PACKAGES="$PACKAGES luci-i18n-acl-zh-cn"
# 用于配置和管理QoS（服务质量）
PACKAGES="$PACKAGES luci-app-qos"
PACKAGES="$PACKAGES luci-i18n-qos-zh-cn"
PACKAGES="$PACKAGES luci-app-eqos"
PACKAGES="$PACKAGES luci-i18n-eqos-zh-cn"
# 配置V2RayA代理工具
PACKAGES="$PACKAGES luci-app-v2raya"
PACKAGES="$PACKAGES luci-i18n-v2raya-zh-cn"
# 配置Watchcat断网重启工具PACKAGES="$PACKAGES "
PACKAGES="$PACKAGES luci-app-watchcat"
PACKAGES="$PACKAGES luci-i18n-watchcat-zh-cn"
# 用于在 OpenWrt 上配置和管理 NAT 映射功能，使内部网络的设备可以通过公共 IP 地址进行外部访问
PACKAGES="$PACKAGES luci-app-natmap"
PACKAGES="$PACKAGES luci-i18n-natmap-zh-cn"
# USB 打印机共享服务
PACKAGES="$PACKAGES luci-app-usb-printer"
PACKAGES="$PACKAGES luci-i18n-usb-printer-zh-cn"
# 网络打印服务器（支持 RAW 打印）
PACKAGES="$PACKAGES luci-app-p910nd"
PACKAGES="$PACKAGES luci-i18n-p910nd-zh-cn"
# ======== shell/custom-packages.sh =======
# 合并imm仓库以外的第三方插件
PACKAGES="$PACKAGES $CUSTOM_PACKAGES"


# 判断是否需要编译 Docker 插件
if [ "$INCLUDE_DOCKER" = "yes" ]; then
    PACKAGES="$PACKAGES luci-i18n-dockerman-zh-cn"
    echo "Adding package: luci-i18n-dockerman-zh-cn"
fi

# 若构建openclash 则添加内核
if echo "$PACKAGES" | grep -q "luci-app-openclash"; then
    echo "✅ 已选择 luci-app-openclash，添加 openclash core"
    mkdir -p files/etc/openclash/core
    # Download clash_meta
    META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-amd64.tar.gz"
    wget -qO- $META_URL | tar xOvz > files/etc/openclash/core/clash_meta
    chmod +x files/etc/openclash/core/clash_meta
    # Download GeoIP and GeoSite
    wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -O files/etc/openclash/GeoIP.dat
    wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -O files/etc/openclash/GeoSite.dat
else
    echo "⚪️ 未选择 luci-app-openclash"
fi

# 构建镜像
echo "$(date '+%Y-%m-%d %H:%M:%S') - Building image with the following packages:"
echo "$PACKAGES"

make image PROFILE="generic" PACKAGES="$PACKAGES" FILES="/home/build/immortalwrt/files" ROOTFS_PARTSIZE=$PROFILE

if [ $? -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Build failed!"
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Build completed successfully."
