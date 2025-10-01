#!/bin/bash

# 🚨 Emergency Restore Script
# Restores from backup files if Git rollback fails

echo "🚨 Emergency restore initiated..."

BACKUP_DIR="backups/$(date +%Y%m%d)"
EMERGENCY_DIR="emergency-restore-$(date +%Y%m%d-%H%M%S)"

# Create emergency restore directory
mkdir -p "$EMERGENCY_DIR"

echo "📁 Created emergency directory: $EMERGENCY_DIR"

# Check for backup files
if [ -f "$BACKUP_DIR/consolidated-content-search-v2.zip" ]; then
    echo "📦 Found backup zip file, extracting..."
    unzip "$BACKUP_DIR/consolidated-content-search-v2.zip" -d "$EMERGENCY_DIR/"
    echo "✅ Files extracted to $EMERGENCY_DIR"
fi

if [ -f "$BACKUP_DIR/consolidated-content-search-v2.patch" ]; then
    echo "🔧 Found patch file, copying..."
    cp "$BACKUP_DIR/consolidated-content-search-v2.patch" "$EMERGENCY_DIR/"
    echo "✅ Patch file copied"
fi

if [ -f "$BACKUP_DIR/consolidated-search-v1.0.0-$(date +%Y%m%d).zip" ]; then
    echo "📦 Found git archive, extracting..."
    unzip "$BACKUP_DIR/consolidated-search-v1.0.0-$(date +%Y%m%d).zip" -d "$EMERGENCY_DIR/git-archive/"
    echo "✅ Git archive extracted"
fi

echo "🎯 Emergency restore completed!"
echo "📂 Restored files available in: $EMERGENCY_DIR"
echo ""
echo "📋 Next steps:"
echo "1. Review files in $EMERGENCY_DIR"
echo "2. Copy needed files back to your project"
echo "3. Deploy using deploy.sh script"
echo "4. Test functionality"
