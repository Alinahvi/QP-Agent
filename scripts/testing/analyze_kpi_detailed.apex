// Detailed Analysis of KPI Service and Handler
System.debug('=== DETAILED ANALYSIS OF KPI SERVICE AND HANDLER ===');

// 1. Test actual functionality with different analysis types
System.debug('\n=== TESTING FUNCTIONALITY WITH DIFFERENT ANALYSIS TYPES ===');

// Test GROWTH_FACTORS analysis
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest growthRequest = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    growthRequest.analysisType = 'GROWTH_FACTORS';
    growthRequest.primaryDimension = 'OU_NAME';
    growthRequest.primaryValue = 'AMER ACC';
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> growthResponses = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ growthRequest });
    
    System.debug('✅ GROWTH_FACTORS Analysis Result:');
    System.debug('  - Success: ' + growthResponses[0].success);
    System.debug('  - Message: ' + growthResponses[0].message);
    
} catch (Exception e) {
    System.debug('❌ GROWTH_FACTORS Analysis Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}

// Test MEETINGS analysis
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest meetingRequest = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    meetingRequest.analysisType = 'MEETINGS';
    meetingRequest.primaryDimension = 'OU_NAME';
    meetingRequest.primaryValue = 'AMER ACC';
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> meetingResponses = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ meetingRequest });
    
    System.debug('✅ MEETINGS Analysis Result:');
    System.debug('  - Success: ' + meetingResponses[0].success);
    System.debug('  - Message: ' + meetingResponses[0].message);
    
} catch (Exception e) {
    System.debug('❌ MEETINGS Analysis Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}

// 2. Analyze data availability by OU
System.debug('\n=== ANALYZING DATA AVAILABILITY BY OU ===');
try {
    List<AggregateResult> ouData = [
        SELECT OU_NAME__c, COUNT(Id) recordCount
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE OU_NAME__c != null
        GROUP BY OU_NAME__c 
        ORDER BY COUNT(Id) DESC
        LIMIT 10
    ];
    
    System.debug('Top 10 OUs by record count:');
    for (AggregateResult ou : ouData) {
        String ouName = (String) ou.get('OU_NAME__c');
        Integer totalCount = (Integer) ou.get('recordCount');
        
        System.debug('  - ' + ouName + ': ' + totalCount + ' total records');
    }
} catch (Exception e) {
    System.debug('Error analyzing OU data: ' + e.getMessage());
}

// 3. Check for missing fields in SOQL queries
System.debug('\n=== CHECKING FOR MISSING FIELDS IN SOQL QUERIES ===');
try {
    // Test what happens when we try to access ACTIONABLE__c without querying it
    List<AGENT_OU_PIPELINE_V2__c> testRecords = [
        SELECT Id, EMP_ID__c, FULL_NAME__c, OU_NAME__c, DEFINITION__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE OU_NAME__c = 'AMER ACC' 
        LIMIT 1
    ];
    
    if (!testRecords.isEmpty()) {
        try {
            String actionable = testRecords[0].ACTIONABLE__c;
            System.debug('✅ ACTIONABLE__c accessible without explicit query');
        } catch (Exception e) {
            System.debug('❌ ACTIONABLE__c NOT accessible without explicit query: ' + e.getMessage());
        }
    }
} catch (Exception e) {
    System.debug('Error testing field access: ' + e.getMessage());
}

// 4. Analyze performance and limits
System.debug('\n=== ANALYZING PERFORMANCE AND LIMITS ===');
try {
    // Check current governor limits
    System.debug('Current Governor Limits:');
    System.debug('  - SOQL Queries: ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
    System.debug('  - Query Rows: ' + Limits.getQueryRows() + '/' + Limits.getLimitQueryRows());
    System.debug('  - CPU Time: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());
    System.debug('  - Heap Size: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
    
    // Test query performance
    Long startTime = System.currentTimeMillis();
    List<AGENT_OU_PIPELINE_V2__c> perfTest = [
        SELECT Id, EMP_ID__c, FULL_NAME__c, OU_NAME__c, DEFINITION__c, ACTIONABLE__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE OU_NAME__c = 'AMER ACC' 
        LIMIT 100
    ];
    Long endTime = System.currentTimeMillis();
    
    System.debug('Query Performance: ' + (endTime - startTime) + 'ms for ' + perfTest.size() + ' records');
    
} catch (Exception e) {
    System.debug('Error analyzing performance: ' + e.getMessage());
}
