// Test script for the exact user scenario:
// "show me top 10 AEs with a product renewal opportunity that contains word 'Tableau' within AMER ICE, please also add their email address here for me"

System.debug('=== Testing Tableau Renewal Opportunities with Email Addresses ===');

try {
    // Create the exact request from the user
    ABAgentRenewalsAnalysisHandler.Request req = new ABAgentRenewalsAnalysisHandler.Request();
    req.ouName = 'AMER ICE';
    req.groupBy = 'AE';
    req.analysisType = 'AE_ANALYSIS';
    req.filterCriteria = 'renewal_prod_nm LIKE \'%Tableau%\'';
    req.limitN = 10; // Top 10 as requested
    
    List<ABAgentRenewalsAnalysisHandler.Request> requests = new List<ABAgentRenewalsAnalysisHandler.Request>{req};
    
    // Call the handler
    List<ABAgentRenewalsAnalysisHandler.Response> responses = ABAgentRenewalsAnalysisHandler.analyzeRenewals(requests);
    
    if (!responses.isEmpty()) {
        String message = responses[0].message;
        System.debug('=== COMPLETE RESPONSE ===');
        System.debug(message);
        System.debug('=== END RESPONSE ===');
        
        // Verify email addresses are included
        if (message.contains('Email:')) {
            System.debug('✅ SUCCESS: Email addresses are included!');
            
            // Count how many AEs have email addresses
            List<String> lines = message.split('\n');
            Integer aeWithEmails = 0;
            for (String line : lines) {
                if (line.contains('Email:') && line.contains('**')) {
                    aeWithEmails++;
                    System.debug('AE ' + aeWithEmails + ': ' + line.trim());
                }
            }
            System.debug('Total AEs with email addresses: ' + aeWithEmails);
            
        } else {
            System.debug('❌ FAILURE: No email addresses found in output');
        }
        
    } else {
        System.debug('❌ FAILURE: No responses received');
    }
    
} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== Test Complete ===');
