# install.ps1 — Windows 安装入口（替代上游的 install.sh）
#
# 用法：
#   .\install.ps1                 # 装到用户级 ~\.dsh\skills（DSH 会自动发现）
#   .\install.ps1 -Project        # 装到当前项目 .dsh\skills
#   .\install.ps1 -Uninstall      # 移除用户级安装
#
# 说明：上游 install.sh 用 bash + 符号链接，Windows 上不可用。
# DSH 只要求 <name>/SKILL.md 且 frontmatter 的 name 为 kebab-case，直接复制目录即可。

param(
  [switch]$Project,
  [switch]$Uninstall
)

$ErrorActionPreference = "Stop"
$name = "nature-genome-plot"
$src = $PSScriptRoot

if ($Project) {
  $dest = Join-Path (Get-Location) ".dsh\skills\$name"
} else {
  $dest = Join-Path $env:USERPROFILE ".dsh\skills\$name"
}

if ($Uninstall) {
  if (Test-Path $dest) {
    Remove-Item -Recurse -Force $dest
    Write-Host "removed $dest"
  } else {
    Write-Host "not installed: $dest"
  }
  exit 0
}

if (-not (Test-Path (Join-Path $src "SKILL.md"))) {
  throw "SKILL.md not found next to install.ps1 ($src)"
}

New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
Copy-Item -Recurse -Force $src $dest

Write-Host "installed -> $dest"
Write-Host ""
Write-Host "verify (需要 R，先设置 PATH)："
Write-Host "  `$env:PATH = '<workspace>\r-env\Scripts;<workspace>\r-env\Library\bin;' + `$env:PATH"
Write-Host "  Rscript scripts/doctor.R"
Write-Host ""
Write-Host "在 DSH 中无需重启，技能会被自动收录。"
