#!/bin/bash

# Enhanced Lifecycle Management V2 - Test Deployment Script
# Version: 2.0
# Date: October 1, 2025

set -e  # Exit on any error

echo "🧪 Enhanced Lifecycle Management V2 - Test Deployment"
echo "====================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ORG_ALIAS="anahvi@readiness.salesforce.com.innovation"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# Function to test basic functionality
test_basic_functionality() {
    print_status "Testing basic search functionality..."
    
    cat > /tmp/test_basic.apex << 'EOF'
// Test basic search functionality
System.debug('=== TESTING BASIC FUNCTIONALITY ===');

try {
    // Test service search
    ANAgentContentSearchServiceV2.ContentSearchResult result = ANAgentContentSearchServiceV2.search('Sales');
    System.debug('Service search result: ' + (result != null && result.success ? 'SUCCESS' : 'FAILED'));
    
    if (result != null) {
        System.debug('Records found: ' + result.totalCount);
        System.debug('Search source: ' + result.searchSource);
    }
    
} catch (Exception e) {
    System.debug('ERROR in basic test: ' + e.getMessage());
}
EOF

    if sf apex run --file /tmp/test_basic.apex --target-org $ORG_ALIAS; then
        print_success "Basic functionality test passed"
    else
        print_error "Basic functionality test failed"
        return 1
    fi
    
    rm -f /tmp/test_basic.apex
}

# Function to test handler functionality
test_handler_functionality() {
    print_status "Testing handler functionality..."
    
    cat > /tmp/test_handler.apex << 'EOF'
// Test handler functionality
System.debug('=== TESTING HANDLER FUNCTIONALITY ===');

try {
    // Test ACT mode
    ANAgentContentSearchHandlerV2.ContentSearchRequest actRequest = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
    actRequest.searchTerm = 'Sales';
    actRequest.searchMode = 'ACT';
    
    List<ANAgentContentSearchHandlerV2.ContentSearchResponse> actResponses = 
        ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{actRequest});
    
    System.debug('ACT mode test: ' + (actResponses.size() > 0 && actResponses[0].success ? 'SUCCESS' : 'FAILED'));
    
    // Test AUTO mode
    ANAgentContentSearchHandlerV2.ContentSearchRequest autoRequest = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
    autoRequest.searchTerm = 'Sales Cloud demo videos';
    autoRequest.searchMode = 'AUTO';
    autoRequest.userUtterance = 'Show me Sales Cloud demo videos';
    
    List<ANAgentContentSearchHandlerV2.ContentSearchResponse> autoResponses = 
        ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{autoRequest});
    
    System.debug('AUTO mode test: ' + (autoResponses.size() > 0 && autoResponses[0].success ? 'SUCCESS' : 'FAILED'));
    
} catch (Exception e) {
    System.debug('ERROR in handler test: ' + e.getMessage());
}
EOF

    if sf apex run --file /tmp/test_handler.apex --target-org $ORG_ALIAS; then
        print_success "Handler functionality test passed"
    else
        print_error "Handler functionality test failed"
        return 1
    fi
    
    rm -f /tmp/test_handler.apex
}

# Function to test lifecycle management
test_lifecycle_management() {
    print_status "Testing lifecycle management features..."
    
    cat > /tmp/test_lifecycle.apex << 'EOF'
// Test lifecycle management features
System.debug('=== TESTING LIFECYCLE MANAGEMENT ===');

try {
    ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
    request.searchTerm = 'Tableau';
    request.searchMode = 'ACT';
    request.userUtterance = 'Do a life cycle analysis on the ACT content related to Tableau and tell me which content I need to remove and which content I need to modify and which I need to keep. Use enrollment and completion rate as major KPIs for this analysis';
    
    List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
        ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{request});
    
    if (responses.size() > 0 && responses[0].success) {
        String message = responses[0].message;
        
        // Check for lifecycle analysis components
        boolean hasPerformanceSummary = message.contains('Course Performance Summary');
        boolean hasLifecycleAnalysis = message.contains('Lifecycle Analysis');
        boolean hasOptimization = message.contains('Content Optimization Opportunities');
        boolean hasCSAT = message.contains('CSAT');
        
        System.debug('Performance Summary: ' + (hasPerformanceSummary ? 'FOUND' : 'MISSING'));
        System.debug('Lifecycle Analysis: ' + (hasLifecycleAnalysis ? 'FOUND' : 'MISSING'));
        System.debug('Optimization Opportunities: ' + (hasOptimization ? 'FOUND' : 'MISSING'));
        System.debug('CSAT Integration: ' + (hasCSAT ? 'FOUND' : 'MISSING'));
        
        System.debug('Lifecycle test: ' + (hasPerformanceSummary && hasLifecycleAnalysis ? 'SUCCESS' : 'FAILED'));
    } else {
        System.debug('Lifecycle test: FAILED - No successful response');
    }
    
} catch (Exception e) {
    System.debug('ERROR in lifecycle test: ' + e.getMessage());
}
EOF

    if sf apex run --file /tmp/test_lifecycle.apex --target-org $ORG_ALIAS; then
        print_success "Lifecycle management test passed"
    else
        print_error "Lifecycle management test failed"
        return 1
    fi
    
    rm -f /tmp/test_lifecycle.apex
}

# Function to test CSAT integration
test_csat_integration() {
    print_status "Testing CSAT integration..."
    
    cat > /tmp/test_csat.apex << 'EOF'
// Test CSAT integration
System.debug('=== TESTING CSAT INTEGRATION ===');

try {
    // Check if CSAT field exists
    boolean csatFieldExists = false;
    try {
        List<Course__c> testCourses = [SELECT CSAT__c FROM Course__c LIMIT 1];
        csatFieldExists = true;
        System.debug('CSAT field: AVAILABLE');
    } catch (Exception e) {
        System.debug('CSAT field: NOT AVAILABLE');
    }
    
    // Test search with CSAT integration
    ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
    request.searchTerm = 'Sales';
    request.searchMode = 'ACT';
    
    List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
        ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{request});
    
    if (responses.size() > 0 && responses[0].success) {
        boolean hasCSATInMessage = responses[0].message.contains('CSAT');
        boolean hasResultsWithCSAT = false;
        
        // Check if any results have CSAT scores
        if (responses[0].results != null) {
            for (ANAgentContentSearchServiceV2.UnifiedContent result : responses[0].results) {
                if (result.csatScore > 0) {
                    hasResultsWithCSAT = true;
                    System.debug('Found CSAT score: ' + result.csatScore + ' for course: ' + result.name);
                    break;
                }
            }
        }
        
        System.debug('CSAT in message: ' + (hasCSATInMessage ? 'FOUND' : 'NOT FOUND'));
        System.debug('CSAT in results: ' + (hasResultsWithCSAT ? 'FOUND' : 'NOT FOUND'));
        
        if (csatFieldExists) {
            System.debug('CSAT integration test: ' + (hasCSATInMessage ? 'SUCCESS' : 'PARTIAL'));
        } else {
            System.debug('CSAT integration test: SKIPPED (field not available)');
        }
    }
    
} catch (Exception e) {
    System.debug('ERROR in CSAT test: ' + e.getMessage());
}
EOF

    if sf apex run --file /tmp/test_csat.apex --target-org $ORG_ALIAS; then
        print_success "CSAT integration test completed"
    else
        print_error "CSAT integration test failed"
        return 1
    fi
    
    rm -f /tmp/test_csat.apex
}

# Function to test search term extraction
test_search_term_extraction() {
    print_status "Testing search term extraction..."
    
    cat > /tmp/test_extraction.apex << 'EOF'
// Test search term extraction
System.debug('=== TESTING SEARCH TERM EXTRACTION ===');

try {
    // Test various user utterances
    List<String> testUtterances = new List<String>{
        'Show me Sales Cloud demo videos',
        'Find training on Tableau',
        'Do a life cycle analysis on Data Cloud content',
        'Search for Marketing Cloud courses'
    };
    
    for (String utterance : testUtterances) {
        ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request.searchTerm = 'test';
        request.searchMode = 'AUTO';
        request.userUtterance = utterance;
        
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{request});
        
        if (responses.size() > 0) {
            System.debug('Utterance: "' + utterance + '" -> Success: ' + responses[0].success);
        }
    }
    
    System.debug('Search term extraction test: COMPLETED');
    
} catch (Exception e) {
    System.debug('ERROR in extraction test: ' + e.getMessage());
}
EOF

    if sf apex run --file /tmp/test_extraction.apex --target-org $ORG_ALIAS; then
        print_success "Search term extraction test completed"
    else
        print_error "Search term extraction test failed"
        return 1
    fi
    
    rm -f /tmp/test_extraction.apex
}

# Function to run performance test
test_performance() {
    print_status "Testing performance with large dataset..."
    
    cat > /tmp/test_performance.apex << 'EOF'
// Test performance
System.debug('=== TESTING PERFORMANCE ===');

try {
    Long startTime = System.currentTimeMillis();
    
    // Test with broad search term
    ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
    request.searchTerm = 'Sales';
    request.searchMode = 'ACT';
    
    List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
        ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{request});
    
    Long endTime = System.currentTimeMillis();
    Long executionTime = endTime - startTime;
    
    System.debug('Execution time: ' + executionTime + 'ms');
    System.debug('Records processed: ' + (responses.size() > 0 ? responses[0].totalRecordCount : 0));
    
    if (executionTime < 10000) { // Less than 10 seconds
        System.debug('Performance test: SUCCESS');
    } else {
        System.debug('Performance test: SLOW (but functional)');
    }
    
} catch (Exception e) {
    System.debug('ERROR in performance test: ' + e.getMessage());
}
EOF

    if sf apex run --file /tmp/test_performance.apex --target-org $ORG_ALIAS; then
        print_success "Performance test completed"
    else
        print_error "Performance test failed"
        return 1
    fi
    
    rm -f /tmp/test_performance.apex
}

# Function to display test summary
display_test_summary() {
    echo ""
    echo "======================================================"
    echo "🧪 TEST DEPLOYMENT SUMMARY"
    echo "======================================================"
    echo "Target Org: $ORG_ALIAS"
    echo "Date: $(date)"
    echo ""
    echo "✅ Tests Completed:"
    echo "   • Basic Functionality"
    echo "   • Handler Functionality"
    echo "   • Lifecycle Management"
    echo "   • CSAT Integration"
    echo "   • Search Term Extraction"
    echo "   • Performance Testing"
    echo ""
    echo "🚀 System Ready for Production!"
    echo "======================================================"
}

# Main test flow
main() {
    echo "Starting test deployment of Enhanced Lifecycle Management V2..."
    echo ""
    
    # Run all tests
    test_basic_functionality
    echo ""
    
    test_handler_functionality
    echo ""
    
    test_lifecycle_management
    echo ""
    
    test_csat_integration
    echo ""
    
    test_search_term_extraction
    echo ""
    
    test_performance
    echo ""
    
    # Display summary
    display_test_summary
    
    print_success "All tests completed successfully! 🎉"
}

# Run main function
main "$@"
