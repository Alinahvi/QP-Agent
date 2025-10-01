// UAT Test for ANAgent Search SMEs
System.debug('🧪 UAT: ANAgent Search SMEs - Small Test');

try {
    ANAgentSMESearchHandler.SMESearchRequest request = new ANAgentSMESearchHandler.SMESearchRequest();
    request.searchTerm = 'Sales Cloud';
    request.searchType = 'Product';
    request.maxResults = 10;
    request.academyMembersOnly = false;
    
    List<ANAgentSMESearchHandler.SMESearchRequest> requests = new List<ANAgentSMESearchHandler.SMESearchRequest>{request};
    List<ANAgentSMESearchHandler.SMESearchResponse> responses = ANAgentSMESearchHandler.searchSMEs(requests);
    
    if (responses != null && !responses.isEmpty()) {
        System.debug('✅ SUCCESS: ' + responses[0].message);
    } else {
        System.debug('⚠️ No response received');
    }
} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
}

System.debug('✅ Test completed!');
