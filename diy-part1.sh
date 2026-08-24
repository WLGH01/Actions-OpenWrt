#!/bin/bash
# OpenWrt DIY script part 1: customize feeds before feed update.
set -e

# Additional third-party feeds used by the current configuration.
sed -i '1i src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default
sed -i '3i src-git-full hellworld https://github.com/fw876/helloworld.git' feeds.conf.default
sed -i '4i src-git-full modem https://github.com/Siriling/5G-Modem-Support.git' feeds.conf.default
sed -i '5i src-git-full passwall https://github.com/xiaorouji/openwrt-passwall-packages.git' feeds.conf.default
sed -i '6i src-git qmodem https://github.com/FUjr/modem_feeds.git;main' feeds.conf.default

# QiuSimons/vmlinux-btf is a standalone package repository, not a normal feed.
# A normal feed requires package subdirectories and therefore produces a broken
# .files-packageinfo.mk when this repository is registered as src-git.
rm -rf package/vmlinux-btf
git clone --depth=1 --single-branch --branch master \
  https://github.com/QiuSimons/vmlinux-btf.git package/vmlinux-btf

# Do not add ARM-specific PWM commands: this build targets x86_64.
