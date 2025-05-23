#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
sed -i '1i src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default
sed -i '3i src-git-full hellworld https://github.com/fw876/helloworld.git' feeds.conf.default
sed -i '4i src-git-full modem https://github.com/Siriling/5G-Modem-Support.git' feeds.conf.default
# sed -i '5i src-git-full clash https://github.com/vernesong/OpenClash.git' feeds.conf.default
sed -i '6i src-git-full passwall https://github.com/xiaorouji/openwrt-passwall-packages.git' feeds.conf.default
sed -i '7i src-git qmodem https://github.com/FUjr/modem_feeds.git;main' feeds.conf.default
./scripts/feeds update -a && rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,v2ray*,sing*,smartdns}
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/packages/lang/golang
git clone https://github.com/kenzok8/golang feeds/packages/lang/golang
./scripts/feeds install -a 
sed -i '3i echo 50 > /sys/class/hwmon/hwmon1/pwm1' package/base-files/files/etc/rc.local

