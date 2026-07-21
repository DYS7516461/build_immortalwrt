# Tailscale 与 Argon 实施计划

> **给自动化执行者：** 必需子技能：使用 `superpowers:subagent-driven-development`（推荐）或 `superpowers:executing-plans` 逐项执行本计划。步骤使用复选框（`- [ ]`）语法跟踪进度。

**目标：** 在固件中加入 Tailscale 及 LuCI 管理界面，安装 Argon 主题，并在固件定制阶段套用仓库本地 `argon/` 目录下的背景和图标资源。

**架构：** 保持现有 OpenWrt 定制流程不变。`.config` 记录目标软件包选择；`diy-part2.sh` 在 feeds 安装完成后再次追加关键软件包选择，并复制本地 Argon 资源；`99-default-settings` 在首次启动时把 LuCI 默认主题设置为 Argon。当前 workflow 使用 ImmortalWrt `v25.12.1` 源码，该版本锁定的 LuCI feed 已包含 `luci-app-tailscale-community`，不需要额外克隆 Tailscale UI 包。

**技术栈：** ImmortalWrt/OpenWrt 构建配置、shell 定制脚本、LuCI 软件包。

---

### 任务 1：软件包选择

**文件：**
- 修改：`.config`
- 修改：`diy-part2.sh`

- [x] **步骤 1：记录软件包需求**

确保选择以下软件包：

```text
CONFIG_PACKAGE_tailscale=y
CONFIG_PACKAGE_luci-app-tailscale-community=y
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-app-argon-config=y
```

- [x] **步骤 2：保持软件包选择可复现**

在 `diy-part2.sh` 中追加同样的软件包选择，确保后续刷新配置后仍保留 Tailscale、Tailscale LuCI 管理界面、Argon 主题和 Argon 配置页。

- [x] **步骤 3：使用 LuCI feed 中的 Tailscale UI 包**

使用 ImmortalWrt `v25.12.1` 锁定的 LuCI feed 中自带的 `luci-app-tailscale-community`。该源码版本不需要额外克隆独立 UI 包。

### 任务 2：Argon 资源

**文件：**
- 修改：`diy-part2.sh`
- 修改：`99-default-settings`

- [x] **步骤 1：定制阶段复制本地 Argon 资源**

把 `$GITHUB_WORKSPACE/argon` 下的资源复制到 `feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon`。

- [x] **步骤 2：把 Argon 设为默认 LuCI 主题**

把 LuCI collection Makefile 中的默认主题从 `luci-theme-openwrt-2020` 替换为 `luci-theme-argon`。

- [x] **步骤 3：设置运行时默认 LuCI 主题**

在 `99-default-settings` 中把 `luci.main.mediaurlbase` 设置为 `/luci-static/argon`，并把 `argon.@global[0].online_wallpaper` 设置为 `none`，让首次启动后使用 Argon 和本地背景资源，即使固件中同时安装了其他主题。

### 任务 3：验证

**文件：**
- 检查：`.config`
- 检查：`diy-part2.sh`
- 检查：`argon/*`

- [x] **步骤 1：验证配置和脚本引用**

运行：

```powershell
rg -n "CONFIG_PACKAGE_(tailscale|luci-app-tailscale-community|luci-theme-argon|luci-app-argon-config)|luci-theme-openwrt-2020/luci-theme-argon|argon/(img|icon|favicon)" .config diy-part2.sh
```

- [x] **步骤 2：验证本地资源文件存在**

运行：

```powershell
Get-ChildItem -Recurse -File argon | Select-Object FullName,Length
```

- [x] **步骤 3：在可用环境中验证脚本语法**

如果主机可用 `bash`，运行：

```bash
bash -n diy-part2.sh
```
