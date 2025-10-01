# 📋 Version Control Guide - Consolidated Content Search V2

## 🏷️ **Current Version**
- **Tag**: `v1.0.0-consolidated-content-search`
- **Date**: October 1, 2025
- **Status**: ✅ Production Ready & Tested

## 🔄 **Version Control Strategy**

### **1. Tag-Based Versioning**
```bash
# View all tags
git tag -l

# View specific tag details
git show v1.0.0-consolidated-content-search

# List tags with messages
git tag -n1
```

### **2. Branch-Based Development**
```bash
# Current working branch
git branch  # Shows: * feature/consolidated-content-search-v2

# Create new feature branch for future changes
git checkout -b feature/new-enhancement

# Create hotfix branch for urgent fixes
git checkout -b hotfix/critical-fix
```

### **3. Backup Strategy**
```bash
# Create backup branch from current state
git checkout -b backup/pre-deployment-$(date +%Y%m%d)

# Create archive of current version
git archive --format=zip --output=backup-v1.0.0-$(date +%Y%m%d).zip v1.0.0-consolidated-content-search
```

## 🔙 **Rollback Procedures**

### **Scenario 1: Revert to Previous Working Version**
```bash
# Method 1: Reset to specific tag
git reset --hard v1.0.0-consolidated-content-search

# Method 2: Create rollback branch
git checkout -b rollback-to-v1.0.0
git reset --hard v1.0.0-consolidated-content-search
```

### **Scenario 2: Undo Specific Changes**
```bash
# View commit history
git log --oneline

# Revert specific commit
git revert <commit-hash>

# Revert to specific file version
git checkout v1.0.0-consolidated-content-search -- path/to/file.cls
```

### **Scenario 3: Emergency Rollback**
```bash
# Quick rollback to last known good state
git checkout main
git reset --hard v1.0.0-consolidated-content-search
git push --force-with-lease origin main
```

## 📦 **Backup Files Available**

### **1. Complete Package**
- **File**: `consolidated-content-search-v2.zip`
- **Size**: 19MB
- **Contents**: All source files + deployment package
- **Usage**: Manual deployment or repository upload

### **2. Patch File**
- **File**: `consolidated-content-search-v2.patch`
- **Size**: 19MB
- **Usage**: Apply changes to any repository
- **Command**: `git apply consolidated-content-search-v2.patch`

### **3. Git Archive**
```bash
# Create archive from tag
git archive --format=zip --output=consolidated-search-v1.0.0.zip v1.0.0-consolidated-content-search
```

## 🔍 **Version Comparison**

### **Check Differences Between Versions**
```bash
# Compare current branch with tagged version
git diff v1.0.0-consolidated-content-search

# Compare specific files
git diff v1.0.0-consolidated-content-search -- force-app/main/default/classes/ANAgentContentSearchHandlerV2.cls

# View file changes
git log --oneline --follow force-app/main/default/classes/ANAgentContentSearchHandlerV2.cls
```

## 🚀 **Deployment Versions**

### **Current Production Version**
- **Handler**: `ANAgentContentSearchHandlerV2.cls`
- **Service**: `ANAgentContentSearchServiceV2.cls`
- **Tests**: `ANAgentContentSearchHandlerV2Test.cls`, `ANAgentContentSearchServiceV2Test.cls`

### **Key Features in v1.0.0**
- ✅ Intelligent routing (ACT/Consensus/Both)
- ✅ Search term extraction
- ✅ Rich text links for Consensus videos
- ✅ Comprehensive test coverage
- ✅ Lifecycle management preserved

## 🔧 **Future Version Planning**

### **v1.1.0 (Planned Enhancements)**
- Performance optimizations
- Additional search filters
- Enhanced error handling

### **v1.2.0 (Future Features)**
- Advanced analytics
- Custom scoring algorithms
- Multi-language support

## 📝 **Version Log Template**
```markdown
## v1.1.0 - [Date]
### Added
- New feature 1
- New feature 2

### Changed
- Modified behavior 1
- Updated algorithm 2

### Fixed
- Bug fix 1
- Bug fix 2

### Removed
- Deprecated feature 1
```

## 🛡️ **Safety Checklist**

Before making changes:
- [ ] Create backup branch
- [ ] Tag current version
- [ ] Run all tests
- [ ] Document changes
- [ ] Test in sandbox first

After deployment:
- [ ] Tag new version
- [ ] Update documentation
- [ ] Verify functionality
- [ ] Monitor for issues

## 📞 **Emergency Contacts**
- **Technical Lead**: [Your Name]
- **Deployment**: Use `deploy.sh` script
- **Rollback**: Follow rollback procedures above
