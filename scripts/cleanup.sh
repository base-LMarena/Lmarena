#!/bin/bash

# LM Battle Project Cleanup Script
# This script removes duplicate files and unused code

set -e

echo "🧹 Starting cleanup process..."
echo ""

# Navigate to frontend directory
cd "$(dirname "$0")/../frontend" || exit 1

# Remove duplicate directories
echo "📁 Removing duplicate directories..."
if [ -d "hooks" ]; then
  rm -rf hooks
  echo "  ✅ Removed frontend/hooks (duplicate)"
fi

if [ -d "providers" ]; then
  rm -rf providers
  echo "  ✅ Removed frontend/providers (duplicate)"
fi

if [ -d "store" ]; then
  rm -rf store
  echo "  ✅ Removed frontend/store (duplicate)"
fi

if [ -d "components" ] && [ ! "$(ls -A components)" ]; then
  rm -rf components
  echo "  ✅ Removed frontend/components (empty directory)"
fi

# Remove unused config files
echo ""
echo "📄 Removing unused config files..."
if [ -f "lib/privy-config.ts" ]; then
  rm -f lib/privy-config.ts
  echo "  ✅ Removed lib/privy-config.ts (merged into providers.tsx)"
fi

if [ -f "lib/wagmi-config.ts" ]; then
  rm -f lib/wagmi-config.ts
  echo "  ✅ Removed lib/wagmi-config.ts (merged into providers.tsx)"
fi

# Remove backup files
echo ""
echo "🗑️  Removing backup files..."
if [ -f "app/components/Sidebar_backup.tsx" ]; then
  rm -f app/components/Sidebar_backup.tsx
  echo "  ✅ Removed Sidebar_backup.tsx"
fi

if [ -f "app/providers/providers-simple.tsx" ]; then
  rm -f app/providers/providers-simple.tsx
  echo "  ✅ Removed providers-simple.tsx"
fi

# Remove npm artifacts (using pnpm only)
echo ""
echo "📦 Removing npm artifacts (pnpm project)..."
if [ -f "package-lock.json" ]; then
  rm -f package-lock.json
  echo "  ✅ Removed package-lock.json (npm artifact)"
fi

if [ -f "yarn.lock" ]; then
  rm -f yarn.lock
  echo "  ✅ Removed yarn.lock (yarn artifact)"
fi

echo ""
echo "✨ Cleanup completed successfully!"
echo ""
echo "📊 Summary:"
echo "  - Removed duplicate directories: hooks/, providers/, store/"
echo "  - Removed unused config files"
echo "  - Removed backup files"
echo "  - Removed npm/yarn artifacts (pnpm-only project)"
echo ""
echo "💡 Next steps:"
echo "  1. Run 'git status' to review changes"
echo "  2. Run 'pnpm install' to verify dependencies"
echo "  3. Run 'pnpm dev' to test the application"
echo ""
echo "ℹ️  This project uses pnpm exclusively"

