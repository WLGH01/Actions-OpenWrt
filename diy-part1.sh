#!/bin/bash
# OpenWrt DIY script part 1: customize feeds before feed update.
set -e

# Third-party feeds required by the current x86_64 configuration.
sed -i '1i src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default

# Remove packages replaced by the kenzok8/small feed, then use its
# matching Go toolchain as documented by the feed.
./scripts/feeds update -a
# daed and luci-app-daed come from the dedicated QiuSimons feed below.
# Remove duplicate copies from kenzok8/small to avoid package conflicts.
rm -rf feeds/small/daed feeds/small/luci-app-daed
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,sing*,smartdns}
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/packages/lang/golang
git clone --depth=1 --single-branch --branch 1.26 \
  https://github.com/kenzok8/golang feeds/packages/lang/golang

# vmlinux-btf is a standalone package repository, not a normal feed.
rm -rf package/vmlinux-btf
git clone --depth=1 --single-branch --branch master \
  https://github.com/QiuSimons/vmlinux-btf.git package/vmlinux-btf

# Do not add ARM/5G-specific feeds or PWM commands to this x86_64 build.
