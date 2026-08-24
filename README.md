# x86_64 ImmortalWrt 云编译固件

[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/WLGH01/Actions-OpenWrt/openwrt-builder.yml?label=云编译&logo=github)](https://github.com/WLGH01/Actions-OpenWrt/actions)
[![Latest Release](https://img.shields.io/github/v/release/WLGH01/Actions-OpenWrt?label=最新固件&logo=openwrt)](https://github.com/WLGH01/Actions-OpenWrt/releases)
[![Target](https://img.shields.io/badge/目标-x86__64-blue?logo=openwrt)](https://github.com/WLGH01/Actions-OpenWrt)

本项目使用 GitHub Actions 自动编译 **ImmortalWrt 24.10 x86_64** 固件，适用于通用 x86_64 软路由、虚拟机和物理机。

## 固件信息

| 项目 | 详情 |
| --- | --- |
| 源码 | [ImmortalWrt](https://github.com/immortalwrt/immortalwrt) |
| 分支 | `openwrt-24.10` |
| 目标平台 | `x86/64` |
| 目标设备 | `generic` |
| 文件系统 | SquashFS |
| 编译方式 | GitHub Actions |

## 集成内容

- LuCI Web 管理界面
- 常用网络、存储和系统工具
- `luci-app-daed` 与 `daed`
- BTF / BPF 工具链支持
- `vmlinux-btf` 软件包源
- 当前配置中的其他插件以 [`.config`](.config) 为准

## 软件源

软件包源配置在 [`feeds.conf.default`](feeds.conf.default)，当前使用：

- ImmortalWrt `packages`
- ImmortalWrt `luci`
- OpenWrt `routing`
- OpenWrt `telephony`
- [QiuSimons/luci-app-daed](https://github.com/QiuSimons/luci-app-daed)
- [QiuSimons/vmlinux-btf](https://github.com/QiuSimons/vmlinux-btf)

## 使用方法

1. 打开仓库的 [Actions](https://github.com/WLGH01/Actions-OpenWrt/actions) 页面。
2. 选择 **OpenWrt Builder**。
3. 点击 **Run workflow** 手动开始编译。
4. 编译完成后，在 Artifacts 下载固件，或在 Releases 页面下载发布版本。

工作流文件位于：[` .github/workflows/openwrt-builder.yml`](.github/workflows/openwrt-builder.yml)。

## DIY 脚本说明

仓库中的 [`diy-part1.sh`](diy-part1.sh) 和 [`diy-part2.sh`](diy-part2.sh) 是原模板遗留的自定义脚本：

- `diy-part1.sh`：原本在更新 feeds 前执行，会额外添加 `kenzo`、`small`、`helloworld`、`modem`、`passwall`、`qmodem` 等第三方源，替换部分软件包，并尝试替换 Golang 工具链。
- `diy-part2.sh`：原本在载入配置后执行，会把默认 LAN 地址从 `192.168.1.1` 改为 `192.168.10.1`。

当前的 [`openwrt-builder.yml`](.github/workflows/openwrt-builder.yml) 和 [`custom-builder.yml`](.github/workflows/custom-builder.yml) **不会调用这两个脚本**，而是直接使用仓库中的 [`feeds.conf.default`](feeds.conf.default) 和 [`.config`](.config)。这样可以避免旧脚本重复添加 feeds，并避免其中针对特定 ARM 设备的硬件 PWM 命令影响 x86_64 编译。

如果后续需要启用 DIY 脚本，应先确认第三方 feeds 与 ImmortalWrt 24.10 兼容，再在工作流中显式增加脚本执行步骤。


- 源码和 feeds 下载失败时自动重试 3 次。
- 编译并发使用 Runner 逻辑 CPU 数减 2，至少保留 1 个并发任务。
- 并行编译失败后自动使用单线程重试。
- 并行和单线程均失败时，任务会正确标记为失败。
- 无论编译是否成功，都会尝试上传 `build.log`，便于排查失败原因。

## 常见问题

### 编译中途失败

优先在失败的 Actions 运行记录中下载 `openwrt-build-log`，查看最后一个失败的 package 和具体错误。常见原因包括源码下载失败、上游 feed 更新导致的依赖变化、GitHub Runner 内存不足以及第三方插件源码临时不可用。

### daed 的 BTF 依赖

`luci-app-daed` 使用 BPF/CO-RE 能力。当前配置已启用内核 BTF 和 BPF 工具链，并加入 `vmlinux-btf` feed。若上游依赖发生变化，以 Actions 中 `make defconfig` 和编译日志的实际结果为准。

## 许可证

本项目沿用 [MIT License](LICENSE)。
