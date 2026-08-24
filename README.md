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
| RootFS 分区 | 5120 MiB（约 5 GiB） |
| 编译方式 | GitHub Actions |

## 工作流

### OpenWrt Builder

文件：[` .github/workflows/openwrt-builder.yml`](.github/workflows/openwrt-builder.yml)

用于 GitHub 托管 Runner 的标准固件编译：

- 每次运行直接全新克隆 ImmortalWrt，不复用旧源码目录。
- 使用 `feeds.conf.default` 和 `.config`。
- 执行 `diy-part1.sh`、更新并安装 feeds。
- 执行 `make defconfig` 后调用 `diy-part2.sh`。
- 编译结束后，无论成功或失败都会清理 `/workdir/openwrt` 和工作区源码。
- 默认发布固件 Artifact，并可发布 GitHub Release。

### Custom OpenWrt Builder

文件：[` .github/workflows/custom-builder.yml`](.github/workflows/custom-builder.yml)

用于 self-hosted Runner 的自定义固件编译：

- 默认使用 self-hosted Runner。
- 可在手动运行时设置源码仓库、源码分支、配置文件和 feeds 文件。
- 如果 `/workdir/openwrt` 已存在有效 Git 仓库，则进入目录更新源码；不存在时才克隆。
- 保留 `/workdir/openwrt`，用于复用源码、下载缓存和编译中间文件。
- 默认 RootFS 大小为 `5120 MiB`，可通过 `rootfs_size` 输入调整。
- 默认编译并发为逻辑 CPU 线程数减 2，也可以通过 `build_jobs` 手动指定。
- 编译失败后自动使用单线程重试。
- 上传 `custom-openwrt-build-log` 和固件 Artifact。

### Build IPK Packages

文件：[` .github/workflows/ipk-builder.yml`](.github/workflows/ipk-builder.yml)

用于只编译新增或指定软件包，不生成完整固件镜像：

1. 在根目录 [`ipk.config`](ipk.config) 中添加要编译的包。
2. 打开 [Actions](https://github.com/WLGH01/Actions-OpenWrt/actions)。
3. 选择 **Build IPK Packages** 并运行。
4. 编译完成后从 `openwrt-ipk-packages` Artifact 下载 `.ipk`。

示例：

```text
CONFIG_PACKAGE_luci-app-daed=m
CONFIG_PACKAGE_daed=m
CONFIG_PACKAGE_daed-geoip=m
CONFIG_PACKAGE_daed-geosite=m
```

IPK Builder 会加载根目录 `.config` 作为基础配置，再追加 `ipk.config`，更新 feeds，下载源码，并逐个编译选中的包。`build_jobs` 留空时使用逻辑 CPU 数减 2。IPK 编译结束后**不会清理** `/workdir/openwrt`，便于 self-hosted Runner 下次复用缓存。

## 集成内容

- LuCI Web 管理界面
- 常用网络、存储和系统工具
- `luci-app-daed` 与 `daed`
- BTF / BPF 工具链支持
- x86_64 通用目标
- RootFS 分区约 5 GiB
- 当前启用的完整包列表以 [`.config`](.config) 为准

## 软件源和第三方包

基础软件源配置在 [`feeds.conf.default`](feeds.conf.default)，包括：

- ImmortalWrt `packages`
- ImmortalWrt `luci`
- OpenWrt `routing`
- OpenWrt `telephony`
- [QiuSimons/luci-app-daed](https://github.com/QiuSimons/luci-app-daed) 的 `kix` 分支

`vmlinux-btf` 不再作为普通 OpenWrt feed 注册。由于其仓库结构不是标准 feed，`diy-part1.sh` 会将 [QiuSimons/vmlinux-btf](https://github.com/QiuSimons/vmlinux-btf) 直接克隆到 `package/vmlinux-btf`，避免生成损坏的 feed 索引。

## DIY 脚本

### `diy-part1.sh`

在 feeds 更新前执行：

- 添加 `kenzo`、`small`、`hellworld`、`modem`、`passwall`、`qmodem` 等第三方源。
- 将 `luci-app-daed` 使用的 `vmlinux-btf` 作为本地 package 克隆到 `package/vmlinux-btf`。
- 不再使用无效的 daed `main` 分支。
- 不添加 ARM 专用硬件 PWM 命令，因为当前目标是 x86_64。

### `diy-part2.sh`

在载入 `.config` 并执行 `make defconfig` 后执行：

- 将默认 LAN 地址从 `192.168.1.1` 修改为 `192.168.10.1`。

两个固件 Builder 都会调用这两个脚本；IPK Builder 也会调用 `diy-part1.sh` 以获得相同的软件包源。

## 配置说明

- `.config`：完整固件配置，已删除未启用的 `# CONFIG_... is not set` 条目，保留启用配置和说明注释。
- `feeds.conf.default`：基础 feeds 配置。
- `ipk.config`：独立 IPK 编译配置，使用 `=m` 选择要单独编译的包。
- `.config` 中已启用 `luci-app-daed`、`daed`、BTF 和 BPF/LLVM 相关配置。
- RootFS 配置为：`CONFIG_TARGET_ROOTFS_PARTSIZE=5120`。

## 编译策略和失败排查

- 源码和软件包下载失败时自动重试最多 3 次。
- 编译默认使用逻辑 CPU 线程数减 2，至少保留 1 个任务。
- 并行编译失败后自动使用 `make -j1` 重试。
- 网页实时输出已去掉 `V=s`，减少日志刷屏，完整日志仍会写入 `build.log` 或 `ipk-build.log`。
- 固件 Builder 会上传 `openwrt-build-log` 或 `custom-openwrt-build-log`。
- IPK Builder 会上传 `openwrt-ipk-packages`，其中包含 IPK 文件和 `ipk-build.log`。
- 编译失败时优先查看日志末尾最后一个失败的 package；常见原因包括下载源不稳定、第三方 feed 变化、依赖缺失、内存不足和插件上游源码临时不可用。

## 常见问题

### 默认管理地址

固件编译后默认 LAN 地址为：

```text
192.168.10.1
```

### daed 的 BTF 依赖

`luci-app-daed` 使用 BPF/CO-RE 能力。当前配置启用了内核 BTF、BPF 工具链和相关内核选项；`vmlinux-btf` 由 `diy-part1.sh` 作为本地 package 引入。若上游依赖发生变化，以 Actions 中 `make defconfig` 和编译日志的实际结果为准。

### 固件空间

当前 RootFS 分区为约 5 GiB，适合当前大量 LuCI、代理插件和 Docker 相关配置。Docker 运行时数据仍建议放在独立磁盘或扩展分区中，不建议长期存放在固件可写层。

## 许可证

本项目沿用 [MIT License](LICENSE)。
