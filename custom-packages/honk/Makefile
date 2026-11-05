#
# OpenWrt package: honk (https://github.com/daeuniverse/honk)
#
# honk-core is installed from the upstream signed release archive instead of
# being compiled here: the upstream OpenWrt package expects the Rust sources in
# ./src and a host with rustup, nightly Rust and bpf-linker, which this
# buildroot does not provide. The release binary is statically linked against
# musl, embeds the eBPF object and the doona UI, and is built for x86_64.
#
# The kernel must provide BTF (CONFIG_KERNEL_DEBUG_INFO_BTF=y, enabled in
# .config) so the embedded CO-RE eBPF object can resolve kernel types.

include $(TOPDIR)/rules.mk

PKG_NAME:=honk
PKG_VERSION:=0.1.0_beta5
PKG_RELEASE:=1

PKG_SOURCE:=honk-core-v0.1.0-beta.5-x86_64-unknown-linux-musl-full.tar.gz
PKG_SOURCE_URL:=https://github.com/daeuniverse/honk/releases/download/v0.1.0-beta.5
PKG_HASH:=50fa1933a168f3061e5e5360c544198f79269c2b5180d8ac892c75f2bbb36a6c
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-upstream-$(PKG_VERSION)

PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(TAR) -xzf $(DL_DIR)/$(PKG_SOURCE) -C $(PKG_BUILD_DIR) --strip-components=1
endef

define Package/honk
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=eBPF transparent proxy engine (honk-core, embedded doona UI)
  URL:=https://github.com/daeuniverse/honk
  LICENSE:=GPL-3.0-only
  DEPENDS:=+jsonfilter +kmod-veth +kmod-sched-core +kmod-sched-bpf \
           +kmod-nft-core +kmod-nft-queue +kmod-nfnetlink-queue \
           +kmod-nf-conntrack +kmod-nft-tproxy +kmod-nft-fib \
           +v2ray-geoip +v2ray-geosite
endef

define Package/honk/description
 honk is an eBPF transparent proxy engine. honk-core embeds its eBPF object and
 needs kernel BTF for CO-RE relocations. This build is the upstream prebuilt
 static musl release with the Clash API, the native API and the embedded doona
 dashboard (served at /ui on the native API listener).

 honk and dae cannot run at the same time: both create the dae0 link pair and
 the daens network namespace. Enable only one of them.
endef

define Package/honk/conffiles
/etc/config/honk
/etc/honk/config.dae
endef

define Package/honk/postinst
#!/bin/sh
[ -z "$${IPKG_INSTROOT}" ] || exit 0
/etc/init.d/honk enabled && /etc/init.d/honk restart
exit 0
endef

define Package/honk/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/honk-core $(1)/usr/bin/honk-core
	$(INSTALL_DIR) $(1)/usr/share/licenses/honk
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/LICENSE $(1)/usr/share/licenses/honk/LICENSE
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/honk.init $(1)/etc/init.d/honk
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/honk.config $(1)/etc/config/honk
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(CURDIR)/files/honk.uci-defaults $(1)/etc/uci-defaults/90-honk-autostart
	$(INSTALL_DIR) $(1)/etc/honk
	$(INSTALL_CONF) $(CURDIR)/files/config.dae $(1)/etc/honk/config.dae
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	printf '%s\n' '/etc/honk/data/' > $(1)/lib/upgrade/keep.d/honk
	$(INSTALL_DIR) $(1)/usr/share/honk
	$(LN) ../v2ray/geoip.dat $(1)/usr/share/honk/geoip.dat
	$(LN) ../v2ray/geosite.dat $(1)/usr/share/honk/geosite.dat
endef

$(eval $(call BuildPackage,honk))
