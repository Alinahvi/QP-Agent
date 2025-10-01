#!/bin/bash

# Script to remove non-critical Apex classes from the ACTUAL current org
# Created: $(date)

set -e

BACKUP_DIR="backup/non-critical-classes-removal-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "🚀 Starting removal of non-critical Apex classes from current org..."
echo "📁 Backup directory: $BACKUP_DIR"

# Define non-critical classes to remove from the ACTUAL current org
declare -a NON_CRITICAL_CLASSES=(
    # Test classes (can be regenerated)
    "ABAgentFuturePipeAnalysisServiceEnhanced_Test"
    "ANAgentContentSearchHandlerV2Test"
    "ANAgentContentSearchServiceV2Test"
    "ANAgentGenericTSVExportHandlerTest"
    "ANAgentKPIAnalysisHandlerTest"
    "ANAgentKPIAnalysisServiceTest"
    "ANAgentKPIOutlierServiceTest"
    "ANAgentKPIResponseFormatterTest"
    "ANAgentOpenPipeAnalysisV3IntelligenceTest"
    "SalesCoachFeedbackServiceTest"
    "TestEnhancedFuturePipelineAnalysis"
    "TicketControllerTest"
    "AN_ContentSearch_Schema_Tests"
    
    # OLD/Deprecated classes
    "ABAgentRenewalsAnalysisService_OLD"
    
    # Simple/Utility classes
    "AgentLog"
    "ANGeneralService"
    "AN_RefineByField"
    "AN_KPIRecord"
    
    # Duplicate/Alternative versions
    "ANAgentContentSearchHandler"  # Keep V2 version
    "ANAgentContentSearchService"  # Keep V2 version
    "ANContentSearchHandler"  # Duplicate of above
    "ANContentSearchService"  # Duplicate of above
    "ANAgentSMESearchHandlerSimple"  # Keep main version
    "ANAgentSMESearchServiceSimple"  # Keep main version
    "ANAgentContentSearchHandlerV2Optimized"  # Keep main V2 version
    
    # Minimal/Alternative versions
    "ABAgentRenewalsAnalysisHandlerMinimal"
    "ABAgentRenewalsAnalysisServiceMinimal"
    "AN_FuturePipeline_FromMCP_Simple"
    "AN_SearchContent_FromMCP_Simple"
    "AN_SearchSME_FromMCP_Simple"
    "AN_Workflow_FromMCP_Simple"
    "AN_KPI_FromMCP_Simple"
    
    # Basic/Simple versions
    "ANAgentOfferingEfficacyHandlerBasic"
    "ANAgentOfferingEfficacyServiceBasic"
    
    # Test/Utility classes
    "ABAgentRenewalsAnalysisTests"
)

# Function to backup and remove a class
remove_class() {
    local class_name="$1"
    local class_file="force-app/main/default/classes/${class_name}.cls"
    local meta_file="force-app/main/default/classes/${class_name}.cls-meta.xml"
    
    echo "📦 Processing: $class_name"
    
    # Check if class exists
    if [ ! -f "$class_file" ]; then
        echo "   ⚠️  Class not found: $class_name"
        return 0
    fi
    
    # Backup the class
    echo "   💾 Backing up to $BACKUP_DIR/"
    cp "$class_file" "$BACKUP_DIR/" 2>/dev/null || true
    cp "$meta_file" "$BACKUP_DIR/" 2>/dev/null || true
    
    # Remove the class files
    echo "   🗑️  Removing class files..."
    rm -f "$class_file" "$meta_file"
    
    echo "   ✅ Removed: $class_name"
}

# Process each class
for class in "${NON_CRITICAL_CLASSES[@]}"; do
    remove_class "$class"
done

echo ""
echo "🎉 Non-critical class removal completed!"
echo "📁 Backup saved to: $BACKUP_DIR"
echo "📊 Total classes processed: ${#NON_CRITICAL_CLASSES[@]}"
echo ""
echo "⚠️  Next steps:"
echo "1. Deploy changes to your org"
echo "2. Run tests to verify functionality"
echo "3. Check for any remaining references"
echo "4. If issues arise, restore from backup"
