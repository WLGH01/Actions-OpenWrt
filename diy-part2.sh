#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.3.1/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# tuic-client 打包修复：kenzok8/small 用的是上游预编译 musl 二进制，
# 2.0.0-dev10 起该二进制动态依赖 libstdc++.so.6，但 feed Makefile 未声明，
# 导致打包阶段报 "Package tuic-client is missing dependencies" 并中断编译。
if [ -f feeds/small/tuic-client/Makefile ]; then
  if ! grep -q 'libstdcpp' feeds/small/tuic-client/Makefile; then
    sed -i 's/^[[:space:]]*DEPENDS:=/  DEPENDS:=+libstdcpp /' feeds/small/tuic-client/Makefile
  fi
fi
