# QP Agent Versioning Strategy

## Overview
This document outlines the versioning strategy for the QP Agent Apex code to ensure proper backup, recovery, and rollback capabilities.

## Version Numbering Scheme
We use [Semantic Versioning](https://semver.org/) (SemVer) for all releases:

### Format: `MAJOR.MINOR.PATCH`
- **MAJOR** (X.0.0): Breaking changes, major feature additions
- **MINOR** (0.X.0): New features, backward compatible
- **PATCH** (0.0.X): Bug fixes, minor improvements

### Examples:
- `v1.0.0` - Initial release
- `v1.1.0` - Added new KPI analysis features
- `v1.1.1` - Fixed critical bug in pipeline analysis
- `v2.0.0` - Major refactor with breaking changes

## Branch Strategy

### Main Branches
1. **`main`** - Production-ready code
   - Always stable and deployable
   - Protected branch (no direct pushes)
   - Only accepts merges from `develop` or `hotfix/*`

2. **`develop`** - Development integration branch
   - Integration branch for features
   - Contains latest delivered development changes
   - Source for `release/*` branches

### Supporting Branches
1. **`feature/*`** - New feature development
   - Branch from: `develop`
   - Merge back to: `develop`
   - Naming: `feature/kpi-analysis-v5`, `feature/pipeline-search`

2. **`release/*`** - Release preparation
   - Branch from: `develop`
   - Merge back to: `main` and `develop`
   - Naming: `release/v1.2.0`

3. **`hotfix/*`** - Critical production fixes
   - Branch from: `main`
   - Merge back to: `main` and `develop`
   - Naming: `hotfix/critical-bug-fix`

## Release Process

### 1. Feature Development
```bash
# Create feature branch
git checkout develop
git pull origin develop
git checkout -b feature/new-kpi-feature

# Develop and test
# ... make changes ...

# Commit changes
git add .
git commit -m "feat: add new KPI analysis capability"

# Push and create PR
git push origin feature/new-kpi-feature
# Create Pull Request to develop
```

### 2. Release Preparation
```bash
# Create release branch
git checkout develop
git pull origin develop
git checkout -b release/v1.2.0

# Final testing and bug fixes
# ... testing and fixes ...

# Update version numbers
# Update CHANGELOG.md
# Update documentation

# Commit release preparation
git add .
git commit -m "chore: prepare release v1.2.0"
```

### 3. Release
```bash
# Merge to main
git checkout main
git pull origin main
git merge release/v1.2.0

# Tag the release
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin v1.2.0

# Merge back to develop
git checkout develop
git pull origin develop
git merge release/v1.2.0

# Delete release branch
git branch -d release/v1.2.0
git push origin --delete release/v1.2.0
```

### 4. Hotfix Process
```bash
# Create hotfix branch
git checkout main
git pull origin main
git checkout -b hotfix/critical-bug

# Fix the bug
# ... make changes ...

# Commit fix
git add .
git commit -m "fix: resolve critical pipeline analysis bug"

# Merge to main
git checkout main
git merge hotfix/critical-bug

# Tag hotfix
git tag -a v1.1.1 -m "Hotfix version 1.1.1"
git push origin v1.1.1

# Merge to develop
git checkout develop
git merge hotfix/critical-bug

# Delete hotfix branch
git branch -d hotfix/critical-bug
git push origin --delete hotfix/critical-bug
```

## Rollback Procedures

### Quick Rollback to Previous Version
```bash
# View available tags
git tag -l

# Rollback to specific version
git checkout v1.1.0

# Create rollback branch
git checkout -b rollback/v1.1.0

# Force push to main (use with caution)
git push origin rollback/v1.1.0:main --force
```

### Safe Rollback Process
1. **Create rollback branch** from the target version
2. **Test thoroughly** in rollback branch
3. **Create hotfix** from rollback branch
4. **Merge hotfix** to main and develop
5. **Tag new version** (e.g., v1.1.2)

## Backup Strategy

### 1. Git Repository Backup
- **Primary**: GitHub (cloud backup)
- **Secondary**: Local clone on development machine
- **Tertiary**: Clone on backup machine/server

### 2. Code Backup
- **Version Control**: All code changes tracked in Git
- **Release Tags**: Each release tagged for easy access
- **Branch Protection**: Main branch protected from direct pushes

### 3. Documentation Backup
- **README.md**: Repository overview and setup
- **CHANGELOG.md**: Detailed change history
- **API Documentation**: Code documentation
- **Deployment Guides**: Step-by-step deployment instructions

## Change Management

### Commit Message Convention
We use [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

feat(kpi): add new KPI calculation method
fix(pipeline): resolve null pointer exception
docs(readme): update deployment instructions
style(format): fix code formatting issues
refactor(service): simplify KPI analysis logic
test(coverage): add unit tests for new feature
chore(deps): update dependency versions
```

### Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test additions/changes
- `chore`: Maintenance tasks

## Emergency Procedures

### When Production Breaks
1. **Immediate**: Create hotfix branch from main
2. **Investigate**: Identify the issue and root cause
3. **Fix**: Implement the fix with minimal changes
4. **Test**: Verify fix works in hotfix branch
5. **Deploy**: Merge hotfix to main and deploy
6. **Document**: Update CHANGELOG and create issue for follow-up

### Communication
- **Slack**: Notify team immediately
- **GitHub Issue**: Create issue with details
- **Status Page**: Update deployment status
- **Rollback Plan**: Have rollback plan ready

## Tools and Automation

### Required Tools
- **Git**: Version control
- **GitHub**: Repository hosting
- **SFDX CLI**: Salesforce deployment
- **VS Code**: Development environment

### Recommended Tools
- **GitHub Actions**: CI/CD automation
- **Semantic Release**: Automated versioning
- **Conventional Changelog**: Automated changelog generation

## Monitoring and Alerts

### What to Monitor
- **Deployment Success**: All deployments should succeed
- **Test Coverage**: Maintain >80% test coverage
- **Code Quality**: Use Salesforce Code Analyzer
- **Performance**: Monitor governor limit usage

### Alert Triggers
- **Deployment Failure**: Immediate alert
- **Test Failure**: Alert within 5 minutes
- **Code Quality Issues**: Daily summary
- **Performance Degradation**: Real-time alerts

---

**Last Updated**: August 2025  
**Version**: 1.0.0  
**Maintainer**: Ali Nahvi (Alinahvi)
