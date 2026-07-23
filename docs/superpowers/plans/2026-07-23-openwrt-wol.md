# OpenWrt 网络唤醒实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 给固件加入 LuCI 网络唤醒页面，让用户可以在后台手动唤醒局域网设备。

**Architecture:** 使用 OpenWrt/ImmortalWrt 现成包，不写自定义唤醒脚本。`.config` 固定基础包选择，`diy-part2.sh` 在 feeds 安装后再次追加包配置，保证 CI 编译时配置稳定。

**Tech Stack:** OpenWrt/ImmortalWrt Kconfig、LuCI、etherwake。

---

### Task 1: 加入网络唤醒包配置

**Files:**

- Modify: `.config`
- Modify: `diy-part2.sh`

- [ ] **Step 1: 修改 `.config`**

在 LuCI 或基础工具区域加入：

```text
CONFIG_PACKAGE_luci-app-wol=y
CONFIG_PACKAGE_etherwake=y
```

- [ ] **Step 2: 修改 `diy-part2.sh`**

在追加到 `.config` 的多行配置中加入：

```text
# Wake-on-LAN
CONFIG_PACKAGE_luci-app-wol=y
CONFIG_PACKAGE_etherwake=y
```

### Task 2: 验证

**Files:**

- Check: `.config`
- Check: `diy-part2.sh`

- [ ] **Step 1: 搜索关键配置**

Run:

```powershell
rg -n "luci-app-wol|etherwake|Wake-on-LAN" .config diy-part2.sh
```

Expected:

- `.config` 中存在 `CONFIG_PACKAGE_luci-app-wol=y`。
- `.config` 中存在 `CONFIG_PACKAGE_etherwake=y`。
- `diy-part2.sh` 中存在同样两项配置。

- [ ] **Step 2: 检查 diff 空白问题**

Run:

```powershell
git diff --check
```

Expected: exit code 为 0。
