# OpenWrt 网络唤醒设计

## 目标

在已能成功编译和运行的 Xiaomi Mi Router 3G 固件中加入局域网设备网络唤醒能力。用户在 LuCI 后台中手动填写设备 MAC 地址，并通过页面发送 Wake-on-LAN Magic Packet。

## 范围

本次只加入 LuCI 页面和底层唤醒工具，不预设任何固定设备 MAC，不增加定时任务，也不新增自定义脚本。

## 设计

使用 OpenWrt/ImmortalWrt 现成包：

- `luci-app-wol`：提供 LuCI Web 管理页面。
- `etherwake`：提供底层 Magic Packet 发送工具。

为了让配置稳定进入固件，包配置同时写入：

- `.config`：作为仓库基础配置。
- `diy-part2.sh`：在 feeds 安装后追加配置，避免后续 defconfig 或手动配置调整时遗漏。

## 验证

本地验证检查：

- `.config` 包含 `CONFIG_PACKAGE_luci-app-wol=y`。
- `.config` 包含 `CONFIG_PACKAGE_etherwake=y`。
- `diy-part2.sh` 追加配置中包含上述两项。
- `git diff --check` 无空白错误。

完整验证需要重新运行 GitHub Actions 编译，并在刷入固件后确认 LuCI 菜单中出现网络唤醒页面。
