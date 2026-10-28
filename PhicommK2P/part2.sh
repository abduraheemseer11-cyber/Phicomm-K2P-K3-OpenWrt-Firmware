#!/bin/bash

#
#Copyright 2021 yangxu52<https://github.com/yangxu52>
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.
#

#修改主机名
sed -i "s/hostname='OpenWrt'/hostname='Phicomm-K2P'/g" package/base-files/files/bin/config_generate
cat package/base-files/files/bin/config_generate |grep hostname=
echo 'Alert Hostname OK!====================='

# ======================================================================
# 1. 替换 LuCI 界面 Logo (自定义图片)
# ======================================================================
LOGO_URL="https://raw.githubusercontent.com/abduraheemseer11-cyber/Phicomm-K2P-K3-OpenWrt-Firmware/main/custom_logo.png"

# 替换 Argon 主题的 Logo (修正了路径)
if [ -d "feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/" ]; then
    wget -O feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/logo.png $LOGO_URL
    echo 'Argon Logo Updated!'
else
    echo 'Argon theme path not found, skipping...'
fi

# 替换 Bootstrap 主题（默认主题）的 Logo (修正了路径)
if [ -d "feeds/luci/themes/luci-theme-bootstrap/htdocs/luci-static/bootstrap/" ]; then
    wget -O feeds/luci/themes/luci-theme-bootstrap/htdocs/luci-static/bootstrap/logo.png $LOGO_URL
    echo 'Bootstrap Logo Updated!'
else
    echo 'Bootstrap theme path not found, skipping...'
fi

# ======================================================================
# 2. 创建自定义的 uci-defaults 脚本以应用所有默认设置
# ======================================================================
mkdir -p package/base-files/files/etc/uci-defaults/
cat << 'EOF' > package/base-files/files/etc/uci-defaults/99-custom-k2p-settings
#!/bin/sh

# 设置语言为英文
uci set luci.main.lang='en'

# 修改 LAN IP 为 192.168.1.20
uci set network.lan.ipaddr='192.168.1.20'

# 将所有端口都划分为 LAN (K2P 的 eth0.1 是 LAN，eth0.2 是 WAN)
uci set network.lan.ifname='eth0.1 eth0.2'
uci -q delete network.wan
uci -q delete network.wan6

# 关闭 DHCP 和 DHCPv6
uci set dhcp.lan.ignore='1'
uci set dhcp.lan.dhcpv6='disabled'
uci set dhcp.lan.ra='disabled'
uci set dhcp.lan.ndp='disabled'

# 2.4G WiFi 配置
uci set wireless.radio0.disabled='0'
uci set wireless.radio0.channel='5'
uci set wireless.radio0.htmode='HT20'
uci set wireless.radio0.txpower='30'
uci set wireless.radio0.country='PA'
uci set wireless.default_radio0.ssid='AbduRaheem_2G'
uci set wireless.default_radio0.network='lan'
uci set wireless.default_radio0.mode='ap'

# 5G WiFi 配置 (包含 WDS)
uci set wireless.radio1.disabled='0'
uci set wireless.radio1.channel='116'
uci set wireless.radio1.htmode='VHT40'
uci set wireless.radio1.txpower='30'
uci set wireless.radio1.country='PA'
uci set wireless.default_radio1.ssid='AbduRaheem_5G'
uci set wireless.default_radio1.network='lan'
uci set wireless.default_radio1.mode='ap'
uci set wireless.default_radio1.wds='1'

# 提交修改使其生效
uci commit luci
uci commit network
uci commit dhcp
uci commit wireless

exit 0
EOF

# 赋予脚本执行权限
chmod +x package/base-files/files/etc/uci-defaults/99-custom-k2p-settings
echo 'Alert Custom Settings OK!====================='
