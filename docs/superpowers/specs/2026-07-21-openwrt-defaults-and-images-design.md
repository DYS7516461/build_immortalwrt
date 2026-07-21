# OpenWrt 默认配置与固件产物设计

## 目标

让本仓库编译出的 Xiaomi Mi Router 3G 固件满足以下要求：

- 默认管理地址为 `192.168.100.1`。
- 管理后台和 SSH 默认账号为 `root`，密码为 `password`。
- 发布产物同时包含小米 3G 全量刷机包和在线更新包。

## 当前情况

仓库通过 `diy-part2.sh` 在 feeds 安装完成后修改上游 ImmortalWrt 源码。当前脚本会把 `package/base-files/files/bin/config_generate` 中的默认 LAN 地址从 `192.168.1.1` 改成 `10.0.0.1`，并把默认子网掩码从 `255.255.255.0` 改成 `255.255.252.0`。

仓库已有 `99-default-settings`，其中包含首次启动默认设置和 root 密码 hash。但 `diy-part2.sh` 里复制该文件到固件默认设置包的命令目前是注释状态，因此这个密码设置可能没有进入最终固件。

`.config` 当前目标为 `ramips/mt7621/xiaomi_mi-router-3g`。此前 GitHub Actions 产物中曾出现 `adslr_g7-initramfs-kernel.bin`，根因是使用了错误的设备符号 `xiaomi_mir3g`，被 `make defconfig` 丢弃后回落到默认设备。因此 CI 实际使用的最终目标设备需要在 workflow 中显式校验，不能只依赖 Release 文案判断。

## 设计

继续沿用 `diy-part2.sh` 修改 `config_generate` 的方式设置默认网络。把默认 LAN 地址改为 `192.168.100.1`，默认子网掩码恢复为 `255.255.255.0`，即 `192.168.100.1/24`。

启用现有 `99-default-settings`：在 `diy-part2.sh` 中把它复制到 `package/emortal/default-settings/files/99-default-settings`。同时更新 `99-default-settings` 内的 root 密码 hash，使默认明文密码为 `password`。用户名保持 OpenWrt 默认的 `root`。

保持 `.config` 的目标设备为 `xiaomi_mi-router-3g`，并显式启用 squashfs 根文件系统、禁用 initramfs-only 固件。小米 3G 的全量刷机通常使用拆分镜像，因此 Release 说明和产物校验统一使用：

- `*kernel1.bin`：全量刷机内核分区镜像。
- `*rootfs0.bin`：全量刷机根文件系统分区镜像。
- `*sysupgrade.bin`：OpenWrt/ImmortalWrt 后台在线更新包。

workflow 在 `make defconfig` 后读取最终 `.config` 中的 `CONFIG_TARGET_*_DEVICE_*=y`，若不是 `xiaomi_mi-router-3g` 就立即失败。编译完成并进入固件目录后，workflow 必须检查 `*kernel1.bin`、`*rootfs0.bin`、`*sysupgrade.bin` 是否都存在；缺少任意一个就失败，避免发布错误或不完整产物。

## 验证

本地验证检查：

- `diy-part2.sh` 包含 `192.168.100.1`，不再设置 `10.0.0.1`。
- `diy-part2.sh` 会复制 `99-default-settings` 到默认设置包。
- `99-default-settings` 内 root 密码 hash 非空，并对应密码 `password`。
- `.config` 启用 `CONFIG_TARGET_ROOTFS_SQUASHFS=y`，并禁用 `CONFIG_TARGET_ROOTFS_INITRAMFS`。
- workflow 会校验最终目标设备为 `xiaomi_mi-router-3g`。
- workflow 会校验 `kernel1.bin`、`rootfs0.bin`、`sysupgrade.bin` 都存在。
- GitHub Release 文案包含 `kernel1.bin`、`rootfs0.bin` 和 `sysupgrade.bin`。
- `git diff --check` 没有空白错误。

完整固件验证需要运行 GitHub Actions 编译，并在发布产物中确认存在对应的 factory 和 sysupgrade 固件文件。
