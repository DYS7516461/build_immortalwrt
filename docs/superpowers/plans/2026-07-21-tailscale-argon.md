# Tailscale And Argon Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Include Tailscale with LuCI UI, install Argon, and apply the repository-local Argon background and icon assets during firmware customization.

**Architecture:** Keep the changes in the existing OpenWrt customization flow. `.config` records the desired package selection, while `diy-part2.sh` adds the missing standalone Tailscale LuCI package, re-appends the important package selections, and copies local assets after feeds are available. `99-default-settings` sets Argon as the default LuCI media URL on first boot.

**Tech Stack:** ImmortalWrt/OpenWrt build config, shell customization scripts, LuCI packages.

---

### Task 1: Package Selection

**Files:**
- Modify: `.config`
- Modify: `diy-part2.sh`

- [x] **Step 1: Record package requirements**

Ensure these packages are selected:

```text
CONFIG_PACKAGE_tailscale=y
CONFIG_PACKAGE_luci-app-tailscale-community=y
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-app-argon-config=y
```

- [x] **Step 2: Keep package selections reproducible**

Append the same package selections in `diy-part2.sh` so future config refreshes keep Tailscale, the Tailscale community UI, Argon, and Argon config.

- [x] **Step 3: Add standalone Tailscale UI source**

Clone the upstream `Tokisaki-Galaxy/luci-app-tailscale-community` package into `package/`, because the LuCI commit pinned by ImmortalWrt `v24.10.6` does not include a Tailscale UI package.

### Task 2: Argon Assets

**Files:**
- Modify: `diy-part2.sh`
- Modify: `99-default-settings`

- [x] **Step 1: Copy local Argon assets during customization**

Enable copies from `$GITHUB_WORKSPACE/argon` into `feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon`.

- [x] **Step 2: Set Argon as default LuCI theme**

Patch the LuCI collection Makefile from `luci-theme-openwrt-2020` to `luci-theme-argon`.

- [x] **Step 3: Set runtime LuCI theme default**

Set `luci.main.mediaurlbase` to `/luci-static/argon` and `argon.@global[0].online_wallpaper` to `none` in `99-default-settings`, so first boot uses Argon and the local background assets even when other themes are installed.

### Task 3: Verification

**Files:**
- Check: `.config`
- Check: `diy-part2.sh`
- Check: `argon/*`

- [x] **Step 1: Verify config/script references**

Run:

```powershell
rg -n "CONFIG_PACKAGE_(tailscale|luci-app-tailscale-community|luci-theme-argon|luci-app-argon-config)|luci-theme-openwrt-2020/luci-theme-argon|argon/(img|icon|favicon)" .config diy-part2.sh
```

- [x] **Step 2: Verify local source assets exist**

Run:

```powershell
Get-ChildItem -Recurse -File argon | Select-Object FullName,Length
```

- [x] **Step 3: Verify script syntax where available**

Run `bash -n diy-part2.sh` if `bash` is available on the host.
