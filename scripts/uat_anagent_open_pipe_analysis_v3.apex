// UAT Test for ANAGENT Open Pipe Analysis V3
System.debug('🧪 UAT: ANAGENT Open Pipe Analysis V3 - Small Test');

try {
    ANAgentOpenPipeAnalysisV3Handler.Request request = new ANAgentOpenPipeAnalysisV3Handler.Request();
    request.ouName = 'AMER ACC';
    request.workLocationCountry = 'USA';
    request.groupBy = 'PRODUCT';
    request.filterCriteria = null;
    request.restrictInValuesCsv = null;
    request.perAENormalize = false;
    request.limitN = 5;
    request.aggregationType = 'COUNT';
    request.analysisType = 'STAGE_COUNT';
    
    List<ANAgentOpenPipeAnalysisV3Handler.Request> requests = new List<ANAgentOpenPipeAnalysisV3Handler.Request>{request};
    List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(requests);
    
    if (responses != null && !responses.isEmpty()) {
        System.debug('✅ SUCCESS: ' + responses[0].message);
    } else {
        System.debug('⚠️ No response received');
    }
} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
}

System.debug('✅ Test completed!');
