#!/bin/bash

# 🔙 Rollback Script for Consolidated Content Search V2
# Version: v1.0.0-consolidated-content-search
# Date: October 1, 2025

echo "🔄 Starting rollback to v1.0.0-consolidated-content-search..."

# Check if tag exists
if ! git tag -l | grep -q "v1.0.0-consolidated-content-search"; then
    echo "❌ Error: Tag v1.0.0-consolidated-content-search not found!"
    exit 1
fi

# Create backup of current state
echo "📦 Creating backup of current state..."
git checkout -b backup/pre-rollback-$(date +%Y%m%d-%H%M%S)
git checkout feature/consolidated-content-search-v2

# Perform rollback
echo "🔙 Rolling back to v1.0.0-consolidated-content-search..."
git reset --hard v1.0.0-consolidated-content-search

# Verify rollback
echo "✅ Verifying rollback..."
git log --oneline -5

echo "🎉 Rollback completed successfully!"
echo "📍 Current state: v1.0.0-consolidated-content-search"
echo "💾 Backup created: backup/pre-rollback-$(date +%Y%m%d-%H%M%S)"
