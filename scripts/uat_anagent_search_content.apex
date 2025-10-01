// UAT Test for ANAgent Search Content
System.debug('🧪 UAT: ANAgent Search Content - Small Test');

try {
    ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
    request.searchTerm = 'Sales Cloud';
    request.contentType = 'Course';
    
    List<ANAgentContentSearchHandlerV2.ContentSearchRequest> requests = new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{request};
    List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = ANAgentContentSearchHandlerV2.searchContent(requests);
    
    if (responses != null && !responses.isEmpty()) {
        System.debug('✅ SUCCESS: ' + responses[0].message);
    } else {
        System.debug('⚠️ No response received');
    }
} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
}

System.debug('✅ Test completed!');
