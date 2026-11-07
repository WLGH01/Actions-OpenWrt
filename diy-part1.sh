#!/bin/bash
# OpenWrt DIY script part 1: customize feeds before feed update.
# Branch: 25.12 (ImmortalWrt openwrt-25.12, x86_64)
set -e

# Third-party feeds required by the current x86_64 configuration.
sed -i '1i src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default

./scripts/feeds update -a

# daed, dae and their LuCI apps come from the ImmortalWrt feeds on 25.12.
# Drop the copies bundled in kenzok8/small so the native packages win.
rm -rf feeds/small/daed feeds/small/luci-app-daed feeds/small/daed-geoip feeds/small/daed-geosite
rm -rf feeds/small/dae feeds/small/luci-app-dae

# Remove conflicting native packages so the selected third-party feed wins.
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,sing*,smartdns}
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/packages/lang/golang
git clone --depth=1 --single-branch --branch 1.27 \
  https://github.com/kenzok8/golang feeds/packages/lang/golang

# Local packages: honk (prebuilt upstream release) and its LuCI apps.
# Building honk from source needs rustup + nightly Rust + bpf-linker on the
# host, so the verified upstream musl release is packaged instead.
if [ -d "$GITHUB_WORKSPACE/custom-packages" ]; then
  cp -a "$GITHUB_WORKSPACE/custom-packages/." package/
fi
