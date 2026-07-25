$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $repoRoot ".config"
$diyPart1Path = Join-Path $repoRoot "diy-part1.sh"

$config = Get-Content -Raw $configPath
$diyPart1 = Get-Content -Raw $diyPart1Path
$diyPart1Active = (($diyPart1 -split "\r?\n") | Where-Object { $_ -notmatch "^\s*#" }) -join "`n"

function Assert-Contains {
    param(
        [string] $Content,
        [string] $Expected,
        [string] $Message
    )

    if (-not $Content.Contains($Expected)) {
        throw $Message
    }
}

function Assert-NotContains {
    param(
        [string] $Content,
        [string] $Unexpected,
        [string] $Message
    )

    if ($Content.Contains($Unexpected)) {
        throw $Message
    }
}

Assert-Contains $diyPart1Active "src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main" "PassWall packages feed must be enabled for current proxy core dependencies."
Assert-Contains $diyPart1Active "src-git passwall2 https://github.com/Openwrt-Passwall/openwrt-passwall2.git;main" "PassWall2 feed must be enabled for Xray/3x-ui nodes."
Assert-NotContains $diyPart1Active "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" "Nikki feed should stay disabled on this low-resource Xray client build."

Assert-Contains $config "CONFIG_PACKAGE_luci-app-passwall2=y" "luci-app-passwall2 must be selected."
Assert-Contains $config "CONFIG_PACKAGE_xray-core=y" "xray-core must be selected for 3x-ui/Xray nodes."
Assert-Contains $config "# CONFIG_PACKAGE_mihomo is not set" "Mihomo should stay disabled to reduce memory and flash usage."
Assert-Contains $config "# CONFIG_PACKAGE_mihomo-alpha is not set" "mihomo-alpha should stay disabled to avoid core conflicts."
Assert-Contains $config "# CONFIG_PACKAGE_mihomo-meta is not set" "mihomo-meta should stay disabled to avoid core conflicts."

Write-Host "Proxy build configuration is consistent."
