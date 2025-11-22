# LM Battle Project Cleanup Script (PowerShell)
# This script removes duplicate files and unused code

$ErrorActionPreference = "Stop"

Write-Host "🧹 Starting cleanup process..." -ForegroundColor Cyan
Write-Host ""

# Navigate to frontend directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$frontendPath = Join-Path (Split-Path -Parent $scriptPath) "frontend"
Set-Location $frontendPath

# Remove duplicate directories
Write-Host "📁 Removing duplicate directories..." -ForegroundColor Yellow

if (Test-Path "hooks") {
    Remove-Item -Path "hooks" -Recurse -Force
    Write-Host "  ✅ Removed frontend/hooks (duplicate)" -ForegroundColor Green
}

if (Test-Path "providers") {
    Remove-Item -Path "providers" -Recurse -Force
    Write-Host "  ✅ Removed frontend/providers (duplicate)" -ForegroundColor Green
}

if (Test-Path "store") {
    Remove-Item -Path "store" -Recurse -Force
    Write-Host "  ✅ Removed frontend/store (duplicate)" -ForegroundColor Green
}

if (Test-Path "components") {
    $isEmpty = (Get-ChildItem "components" -Force | Measure-Object).Count -eq 0
    if ($isEmpty) {
        Remove-Item -Path "components" -Recurse -Force
        Write-Host "  ✅ Removed frontend/components (empty directory)" -ForegroundColor Green
    }
}

# Remove unused config files
Write-Host ""
Write-Host "📄 Removing unused config files..." -ForegroundColor Yellow

if (Test-Path "lib\privy-config.ts") {
    Remove-Item -Path "lib\privy-config.ts" -Force
    Write-Host "  ✅ Removed lib/privy-config.ts (merged into providers.tsx)" -ForegroundColor Green
}

if (Test-Path "lib\wagmi-config.ts") {
    Remove-Item -Path "lib\wagmi-config.ts" -Force
    Write-Host "  ✅ Removed lib/wagmi-config.ts (merged into providers.tsx)" -ForegroundColor Green
}

# Remove backup files
Write-Host ""
Write-Host "🗑️  Removing backup files..." -ForegroundColor Yellow

if (Test-Path "app\components\Sidebar_backup.tsx") {
    Remove-Item -Path "app\components\Sidebar_backup.tsx" -Force
    Write-Host "  ✅ Removed Sidebar_backup.tsx" -ForegroundColor Green
}

if (Test-Path "app\providers\providers-simple.tsx") {
    Remove-Item -Path "app\providers\providers-simple.tsx" -Force
    Write-Host "  ✅ Removed providers-simple.tsx" -ForegroundColor Green
}

# Remove npm artifacts (using pnpm only)
Write-Host ""
Write-Host "📦 Removing npm artifacts (pnpm project)..." -ForegroundColor Yellow

if (Test-Path "package-lock.json") {
    Remove-Item -Path "package-lock.json" -Force
    Write-Host "  ✅ Removed package-lock.json (npm artifact)" -ForegroundColor Green
}

if (Test-Path "yarn.lock") {
    Remove-Item -Path "yarn.lock" -Force
    Write-Host "  ✅ Removed yarn.lock (yarn artifact)" -ForegroundColor Green
}

Write-Host ""
Write-Host "✨ Cleanup completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Summary:" -ForegroundColor Cyan
Write-Host "  - Removed duplicate directories: hooks/, providers/, store/"
Write-Host "  - Removed unused config files"
Write-Host "  - Removed backup files"
Write-Host "  - Removed npm/yarn artifacts (pnpm-only project)"
Write-Host ""
Write-Host "💡 Next steps:" -ForegroundColor Yellow
Write-Host "  1. Run 'git status' to review changes"
Write-Host "  2. Run 'pnpm install' to verify dependencies"
Write-Host "  3. Run 'pnpm dev' to test the application"
Write-Host ""
Write-Host "ℹ️  This project uses pnpm exclusively" -ForegroundColor Cyan

