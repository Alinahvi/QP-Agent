// Test script to verify email addresses are included in Renewals Analysis
// This tests the fix for the issue where email addresses weren't showing up

// Test the Renewals Analysis with AE grouping to see if emails are included
System.debug('=== Testing Renewals Analysis Email Inclusion ===');

try {
    // Create a test request
    ABAgentRenewalsAnalysisHandler.Request req = new ABAgentRenewalsAnalysisHandler.Request();
    req.ouName = 'AMER ICE';
    req.groupBy = 'AE';
    req.analysisType = 'AE_ANALYSIS';
    req.filterCriteria = 'renewal_prod_nm LIKE \'%Tableau%\'';
    req.limitN = 5; // Limit to 5 for testing
    
    List<ABAgentRenewalsAnalysisHandler.Request> requests = new List<ABAgentRenewalsAnalysisHandler.Request>{req};
    
    // Call the handler
    List<ABAgentRenewalsAnalysisHandler.Response> responses = ABAgentRenewalsAnalysisHandler.analyzeRenewals(requests);
    
    if (!responses.isEmpty()) {
        String message = responses[0].message;
        System.debug('Response message length: ' + message.length());
        
        // Check if email addresses are included
        if (message.contains('Email:')) {
            System.debug('✅ SUCCESS: Email addresses are included in the output');
            
            // Extract and display the AE information with emails
            List<String> lines = message.split('\n');
            for (String line : lines) {
                if (line.contains('Email:') && line.contains('**')) {
                    System.debug('Found AE with email: ' + line.trim());
                }
            }
        } else {
            System.debug('❌ FAILURE: Email addresses are NOT included in the output');
            System.debug('Message preview: ' + message.substring(0, Math.min(500, message.length())));
        }
        
        // Check if the JSON output includes email field
        if (message.contains('"email":')) {
            System.debug('✅ SUCCESS: Email field is included in JSON output');
        } else {
            System.debug('❌ FAILURE: Email field is NOT included in JSON output');
        }
        
    } else {
        System.debug('❌ FAILURE: No responses received');
    }
    
} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== Test Complete ===');
