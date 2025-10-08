#!/bin/bash

###############################################################################
# Package Verification Script
# Verifies the integrity and completeness of the SME Search V3 package
###############################################################################

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ ${NC}$1"; }
print_error() { echo -e "${RED}❌ ${NC}$1"; }
print_info() { echo -e "${BLUE}ℹ️  ${NC}$1"; }

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  SME Search V3 Package Verification"
echo "═══════════════════════════════════════════════════════"
echo ""

ERRORS=0

# Check required files
print_info "Checking required files..."

FILES=(
    "README.md"
    "QUICKSTART.md"
    "CHANGELOG.md"
    "TESTING.md"
    "AGENT_ACTION_CONFIG.md"
    "TECHNICAL_REFERENCE.md"
    "PACKAGE_INFO.md"
    "deploy.sh"
    "package.xml"
    "force-app/main/default/classes/ANAgentSMESearchHandlerV3.cls"
    "force-app/main/default/classes/ANAgentSMESearchHandlerV3.cls-meta.xml"
    "force-app/main/default/classes/ANAgentSMESearchServiceV3.cls"
    "force-app/main/default/classes/ANAgentSMESearchServiceV3.cls-meta.xml"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        print_success "$file"
    else
        print_error "$file - MISSING"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""
print_info "Checking file permissions..."

if [ -x "deploy.sh" ]; then
    print_success "deploy.sh is executable"
else
    print_error "deploy.sh is not executable"
    echo "  Fix with: chmod +x deploy.sh"
    ERRORS=$((ERRORS + 1))
fi

if [ -x "verify_package.sh" ]; then
    print_success "verify_package.sh is executable"
else
    print_error "verify_package.sh is not executable"
    echo "  Fix with: chmod +x verify_package.sh"
    ERRORS=$((ERRORS + 1))
fi

echo ""
print_info "Checking Apex class structure..."

# Check handler has invocable method
if grep -q "@InvocableMethod" "force-app/main/default/classes/ANAgentSMESearchHandlerV3.cls"; then
    print_success "Handler has @InvocableMethod annotation"
else
    print_error "Handler missing @InvocableMethod annotation"
    ERRORS=$((ERRORS + 1))
fi

# Check service has searchSMEsEnhanced method
if grep -q "searchSMEsEnhanced" "force-app/main/default/classes/ANAgentSMESearchServiceV3.cls"; then
    print_success "Service has searchSMEsEnhanced method"
else
    print_error "Service missing searchSMEsEnhanced method"
    ERRORS=$((ERRORS + 1))
fi

# Check handler uses service
if grep -q "ANAgentSMESearchServiceV3" "force-app/main/default/classes/ANAgentSMESearchHandlerV3.cls"; then
    print_success "Handler references ServiceV3"
else
    print_error "Handler doesn't reference ServiceV3"
    ERRORS=$((ERRORS + 1))
fi

# Check response has only message field
if grep -q "public String message" "force-app/main/default/classes/ANAgentSMESearchHandlerV3.cls"; then
    print_success "Response has message field"
else
    print_error "Response missing message field"
    ERRORS=$((ERRORS + 1))
fi

# Check security implementation
if grep -q "Security.stripInaccessible" "force-app/main/default/classes/ANAgentSMESearchServiceV3.cls"; then
    print_success "Service implements FLS security"
else
    print_error "Service missing FLS security implementation"
    ERRORS=$((ERRORS + 1))
fi

# Check SOQL escaping
if grep -q "String.escapeSingleQuotes" "force-app/main/default/classes/ANAgentSMESearchServiceV3.cls"; then
    print_success "Service implements SOQL injection prevention"
else
    print_error "Service missing SOQL injection prevention"
    ERRORS=$((ERRORS + 1))
fi

echo ""
print_info "Checking metadata files..."

# Check API version in metadata
if grep -q "<apiVersion>62.0</apiVersion>" "force-app/main/default/classes/ANAgentSMESearchHandlerV3.cls-meta.xml"; then
    print_success "Handler metadata has correct API version (62.0)"
else
    print_error "Handler metadata has incorrect API version"
    ERRORS=$((ERRORS + 1))
fi

if grep -q "<apiVersion>62.0</apiVersion>" "force-app/main/default/classes/ANAgentSMESearchServiceV3.cls-meta.xml"; then
    print_success "Service metadata has correct API version (62.0)"
else
    print_error "Service metadata has incorrect API version"
    ERRORS=$((ERRORS + 1))
fi

echo ""
print_info "Checking package manifest..."

if grep -q "ANAgentSMESearchHandlerV3" "package.xml"; then
    print_success "Handler in package.xml"
else
    print_error "Handler missing from package.xml"
    ERRORS=$((ERRORS + 1))
fi

if grep -q "ANAgentSMESearchServiceV3" "package.xml"; then
    print_success "Service in package.xml"
else
    print_error "Service missing from package.xml"
    ERRORS=$((ERRORS + 1))
fi

if grep -q "<version>62.0</version>" "package.xml"; then
    print_success "Package manifest has correct version"
else
    print_error "Package manifest has incorrect version"
    ERRORS=$((ERRORS + 1))
fi

echo ""
print_info "Checking documentation completeness..."

# Check README has key sections
SECTIONS=(
    "Overview"
    "Package Contents"
    "Architecture"
    "Deployment Instructions"
    "Integration with Agentforce"
    "Testing"
    "Troubleshooting"
)

for section in "${SECTIONS[@]}"; do
    if grep -q "$section" "README.md"; then
        print_success "README has '$section' section"
    else
        print_error "README missing '$section' section"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""
echo "═══════════════════════════════════════════════════════"

if [ $ERRORS -eq 0 ]; then
    print_success "Package verification PASSED! ✨"
    echo ""
    print_info "Package is ready for:"
    echo "  • Deployment to sandbox/production"
    echo "  • Upload to GitHub"
    echo "  • Distribution to team"
    echo ""
    print_info "Next steps:"
    echo "  1. Review README.md for deployment instructions"
    echo "  2. Run: ./deploy.sh YOUR_ORG_ALIAS"
    echo "  3. Follow AGENT_ACTION_CONFIG.md for agent setup"
    echo ""
else
    print_error "Package verification FAILED with $ERRORS error(s)"
    echo ""
    print_info "Please fix the errors above and run verification again"
    exit 1
fi

echo "═══════════════════════════════════════════════════════"
echo ""
