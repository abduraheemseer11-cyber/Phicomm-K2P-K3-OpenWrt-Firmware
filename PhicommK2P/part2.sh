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

# ======================================================================
# 1. تعديل اسم المضيف (Hostname)
# ======================================================================
sed -i "s/hostname='OpenWrt'/hostname='Phicomm-K2P'/g" package/base-files/files/bin/config_generate
cat package/base-files/files/bin/config_generate |grep hostname=
echo 'Alert Hostname OK!====================='

# ======================================================================
# 2. كسر قيود طاقة الإرسال (Tx-Power) إلى 24 dBm
# ======================================================================
echo "Creating custom Tx-Power patch for mt76 driver..."
mkdir -p package/kernel/mt76/patches
cat > package/kernel/mt76/patches/999-force-txpower.patch << 'EOF'
--- a/mt7615/eeprom.c
+++ b/mt7615/eeprom.c
@@ -1339,7 +1339,7 @@ s8 mt7615_eeprom_get_target_power(struct mt7615_dev *dev,
 	if (val == 0)
 		return -EINVAL;
 
-	return val;
+	return 24;
 }
EOF
echo 'SUCCESS: Tx-Power patch created!====================='

# ======================================================================
# 3. استبدال شعار LuCI (Logo)
# ======================================================================
LOGO_URL="https://raw.githubusercontent.com/abduraheemseer11-cyber/Phicomm-K2P-K3-OpenWrt-Firmware/main/custom_logo.png"

# استبدال شعار ثيم Argon (المسار الصحيح بناءً على diy-part1.sh)
if [ -d "package/luci-theme-argon/htdocs/luci-static/argon/img/" ]; then
    wget -O package/luci-theme-argon/htdocs/luci-static/argon/img/logo.png $LOGO_URL
    echo 'Argon Logo Updated!'
else
    echo 'Argon theme path not found, skipping...'
fi

# استبدال شعار ثيم Bootstrap (الافتراضي)
if [ -d "feeds/luci/themes/luci-theme-bootstrap/htdocs/luci-static/bootstrap/" ]; then
    wget -O feeds/luci/themes/luci-theme-bootstrap/htdocs/luci-static/bootstrap/logo.png $LOGO_URL
    echo 'Bootstrap Logo Updated!'
else
    echo 'Bootstrap theme path not found, skipping...'
fi

# ======================================================================
# 4. تقليل حجم الفيرموير (حذف الترجمات والوثائق)
# ======================================================================
echo "Removing unnecessary language and doc files to save space..."
# تم تعديل السطر التالي لتجنب حذف ملفات حزمة default-settings المطلوبة للبناء
find package/ feeds/ -type f \( -name '*.po' -o -name '*.pot' \) -not -path 'package/lean/*' -delete 2>/dev/null || true
find package/ -type d -name 'doc' -exec rm -rf {} + 2>/dev/null || true
find package/ -type d -name 'docs' -exec rm -rf {} + 2>/dev/null || true
find package/ -type d -name 'examples' -exec rm -rf {} + 2>/dev/null || true
echo 'Size reduction OK!====================='

# ======================================================================
# 5. إنشاء سكربت الإعدادات الافتراضية (UCI Defaults)
# ======================================================================
mkdir -p package/base-files/files/etc/uci-defaults/
cat << 'EOF' > package/base-files/files/etc/uci-defaults/99-custom-k2p-settings
#!/bin/sh

# تعيين اللغة إلى الإنجليزية
uci set luci.main.lang='en'

# تعديل عنوان IP للشبكة المحلية إلى 192.168.1.20
uci set network.lan.ipaddr='192.168.1.20'

# دمج منفذ WAN مع LAN (تحويل الراوتر إلى سويتش)
uci set network.lan.ifname='eth0.1 eth0.2'
uci -q delete network.wan
uci -q delete network.wan6

# إيقاف DHCP و DHCPv6
uci set dhcp.lan.ignore='1'
uci set dhcp.lan.dhcpv6='disabled'
uci set dhcp.lan.ra='disabled'
uci set dhcp.lan.ndp='disabled'

# إعداد 2.4G واي فاي (طاقة 24 dBm)
uci set wireless.radio0.disabled='0'
uci set wireless.radio0.channel='5'
uci set wireless.radio0.htmode='HT20'
uci set wireless.radio0.txpower='24'
uci set wireless.radio0.country='US'
uci set wireless.default_radio0.ssid='AbduRaheem_2G'
uci set wireless.default_radio0.network='lan'
uci set wireless.default_radio0.mode='ap'

# إعداد 5G واي فاي (طاقة 24 dBm + WDS)
uci set wireless.radio1.disabled='0'
uci set wireless.radio1.channel='116'
uci set wireless.radio1.htmode='VHT40'
uci set wireless.radio1.txpower='24'
uci set wireless.radio1.country='US'
uci set wireless.default_radio1.ssid='AbduRaheem_5G'
uci set wireless.default_radio1.network='lan'
uci set wireless.default_radio1.mode='ap'
uci set wireless.default_radio1.wds='1'

# حفظ التغييرات
uci commit luci
uci commit network
uci commit dhcp
uci commit wireless

exit 0
EOF

chmod +x package/base-files/files/etc/uci-defaults/99-custom-k2p-settings
echo 'Alert Custom Settings OK!====================='
