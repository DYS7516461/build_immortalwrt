# OpenWrt 默认配置与固件产物实施计划

> **给 agentic workers：** 必须使用 superpowers:executing-plans 按任务执行。步骤使用复选框语法跟踪。

**目标：** 修改 OpenWrt 编译配置，使固件默认地址为 `192.168.100.1`、默认登录为 `root/password`，并保证 Xiaomi Mi Router 3G 产物包含 `kernel1.bin`、`rootfs0.bin`、`sysupgrade.bin`。

**架构：** 网络默认值继续由 `diy-part2.sh` 修改上游 `config_generate`。默认密码通过已有 `99-default-settings` 进入固件。固件产物类型由 `xiaomi_mi-router-3g` 目标生成，workflow 在构建前校验目标设备，在构建后校验 `kernel1.bin`、`rootfs0.bin`、`sysupgrade.bin`。

**技术栈：** Bash、OpenWrt/ImmortalWrt 构建系统、GitHub Actions。

---

### 任务 1：修改默认网络与启用默认设置脚本

**文件：**

- 修改：`diy-part2.sh`

- [x] **步骤 1：把默认 LAN 地址改为 192.168.100.1**

将：

```bash
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate
```

改为：

```bash
sed -i 's/192.168.1.1/192.168.100.1/g' package/base-files/files/bin/config_generate
```

- [x] **步骤 2：把默认子网掩码保持为 255.255.255.0**

移除当前把 `255.255.255.0` 改成 `255.255.252.0` 的替换效果，保留一行幂等命令：

```bash
sed -i 's/255.255.255.0/255.255.255.0/g' package/base-files/files/bin/config_generate
```

- [x] **步骤 3：启用 99-default-settings 复制**

将注释掉的复制命令启用：

```bash
cp -f $GITHUB_WORKSPACE/99-default-settings package/emortal/default-settings/files/99-default-settings
```

### 任务 2：设置 root 默认密码

**文件：**

- 修改：`99-default-settings`

- [x] **步骤 1：更新 root 密码 hash**

把 `/etc/shadow` 中 root 的空密码替换为密码 `password` 对应的 hash：

```sh
sed -i 's#root::0:0:99999:7:::#root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::#g' /etc/shadow
```

### 任务 3：固定目标设备和镜像类型

**文件：**

- 修改：`.config`

- [x] **步骤 1：保持目标设备为 xiaomi_mi-router-3g**

确认 `.config` 包含：

```text
CONFIG_TARGET_ramips=y
CONFIG_TARGET_ramips_mt7621=y
CONFIG_TARGET_ramips_mt7621_DEVICE_xiaomi_mi-router-3g=y
```

- [x] **步骤 2：启用 squashfs 并禁用 initramfs-only 固件**

加入：

```text
CONFIG_TARGET_ROOTFS_SQUASHFS=y
# CONFIG_TARGET_ROOTFS_INITRAMFS is not set
```

### 任务 4：更新 workflow 校验与 Release 说明

**文件：**

- 修改：`.github/workflows/openwrt-builder.yml`

- [x] **步骤 1：设置预期目标设备**

在全局 `env` 中加入：

```yaml
  EXPECTED_DEVICE: xiaomi_mi-router-3g
```

- [x] **步骤 2：make defconfig 后校验目标设备**

在下载软件包步骤中 `make defconfig` 后检查最终设备：

```bash
DEVICE_NAME="$(grep '^CONFIG_TARGET.*DEVICE.*=y' .config | sed -r 's/.*DEVICE_(.*)=y/\1/')"
echo "Selected device: $DEVICE_NAME"
if [ "$DEVICE_NAME" != "$EXPECTED_DEVICE" ]; then
  echo "Expected $EXPECTED_DEVICE, got $DEVICE_NAME"
  exit 1
fi
```

- [x] **步骤 3：整理固件时校验必需产物**

在固件目录中检查：

```bash
for pattern in '*kernel1.bin' '*rootfs0.bin' '*sysupgrade.bin'; do
  if ! compgen -G "$pattern" > /dev/null; then
    echo "Missing required firmware artifact: $pattern"
    exit 1
  fi
done
```

- [x] **步骤 1：更新管理地址与密码文案**

将 Release 文案中的管理地址改为 `192.168.100.1`，子网掩码改为 `255.255.255.0`，密码改为 `password`。

- [x] **步骤 4：补充固件包用途**

在 Release 文案中加入：

```text
全新刷机内核: *kernel1.bin
全新刷机根文件系统: *rootfs0.bin
在线更新: *-sysupgrade.bin
```

### 任务 5：验证

**文件：**

- 检查：`diy-part2.sh`
- 检查：`99-default-settings`
- 检查：`.github/workflows/openwrt-builder.yml`

- [x] **步骤 1：搜索关键配置**

运行：

```powershell
rg -n "EXPECTED_DEVICE|xiaomi_mi-router-3g|adslr_g7|ROOTFS_SQUASHFS|ROOTFS_INITRAMFS|kernel1\.bin|rootfs0\.bin|sysupgrade\.bin|192\.168\.100\.1|99-default-settings|password" .config diy-part2.sh 99-default-settings .github\workflows\openwrt-builder.yml
```

预期：

- 能看到 `192.168.100.1`。
- 能看到 `99-default-settings` 复制命令。
- 能看到 `EXPECTED_DEVICE: xiaomi_mi-router-3g`。
- 能看到 `kernel1.bin`、`rootfs0.bin` 和 `sysupgrade.bin`。
- 不应再看到有效的 `adslr_g7`、`10.0.0.1` 或 `255.255.252.0` 配置。

- [x] **步骤 2：检查 diff 空白问题**

运行：

```powershell
git diff --check
```

预期：退出码为 0。
