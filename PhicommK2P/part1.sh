#!/bin/bash

#
# Copyright 2021 yangxu52<https://github.com/yangxu52>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# ======================================================================
# مصدر helloworld مُعطَّل
# ======================================================================
# مصدر helloworld يوفّر luci-app-ssr-plus الذي يتطلب dnsmasq-full
# ويتعارض مع dnsmasq العادي، ويسبب أخطاء:
#   - check_data_file_clashes: /usr/share/dnsmasq/rfc6761.conf
#   - recursive dependency detected (dnsmasq_full_ipset)
#
# هذا الجهاز مُعدّ للعمل كـ Access Point على LAN فقط:
#   - DHCP مُغلق
#   - DHCPv6 مُغلق
#   - بدون VPN/Proxy
# لذلك لا حاجة لمصدر helloworld ولا لحزمة ssr-plus.
#
# إذا أردت تفعيل مصدر helloworld مستقبلًا، أزل التعليق عن السطرين التاليين:
# sed -i '/helloworld/d' feeds.conf.default
# sed -i '$a src-git helloworld https://github.com/fw876/helloworld' feeds.conf.default

# حذف أي أثر قديم لمصدر helloworld (احتياطيًا، إذا كان feeds.conf.default يحويه)
sed -i '/helloworld/d' feeds.conf.default

echo '========= Feed configuration OK (helloworld feed disabled) ========='
cat feeds.conf.default
