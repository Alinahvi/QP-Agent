// Test the enhanced KPI service implementation
System.debug('=== TESTING ENHANCED KPI SERVICE ===');

try {
    // Test GROWTH_FACTORS analysis for AMER ACC
    System.debug('\\n=== TESTING GROWTH_FACTORS ANALYSIS ===');
    
    ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request.analysisType = 'GROWTH_FACTORS';
    request.primaryDimension = 'OU_NAME';
    request.primaryValue = 'AMER ACC';
    request.timeFrame = 'CURRENT';
    request.includeRampAnalysis = true;
    request.maxResults = 10;
    
    List<ANAgentKPIAnalysisService.KPIResponse> responses = 
        ANAgentKPIAnalysisService.analyzeKPIs(new List<ANAgentKPIAnalysisService.KPIAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentKPIAnalysisService.KPIResponse response = responses[0];
        System.debug('✅ GROWTH_FACTORS Analysis Result:');
        System.debug('  - Success: ' + response.success);
        System.debug('  - Message: ' + response.message);
        System.debug('  - Analysis Type: ' + response.analysisType);
        System.debug('  - Timeframe: ' + response.timeframe);
        System.debug('  - OU Name: ' + response.ouName);
        System.debug('  - Total AEs: ' + response.totalAEs);
        System.debug('  - Total Records: ' + response.totalRecordCount);
        System.debug('  - Warnings: ' + response.warnings);
        
        if (response.agg != null) {
            System.debug('  - Average Score: ' + response.agg.avgScore);
            System.debug('  - Average Coverage: ' + response.agg.avgCoverage);
            System.debug('  - Total ACV: ' + response.agg.totalACV);
            System.debug('  - Total PG: ' + response.agg.totalPG);
        }
        
        if (response.rows != null && !response.rows.isEmpty()) {
            System.debug('  - Sample Row:');
            ANAgentKPIAnalysisService.KPIResponse.Row sampleRow = response.rows[0];
            System.debug('    * AE Name: ' + sampleRow.aeName);
            System.debug('    * Email: ' + sampleRow.email);
            System.debug('    * OU: ' + sampleRow.ou);
            System.debug('    * AE Score: ' + sampleRow.aeScore);
            System.debug('    * Coverage: ' + sampleRow.coverage);
            System.debug('    * Actionable: ' + (String.isNotBlank(sampleRow.actionable) ? 'Present' : 'Missing'));
            System.debug('    * Definition: ' + sampleRow.definition);
            System.debug('    * Is Ramping: ' + sampleRow.isRamping);
            System.debug('    * Ramp Track: ' + sampleRow.rampTrack);
        }
    } else {
        System.debug('❌ No responses received');
    }
    
} catch (Exception e) {
    System.debug('❌ GROWTH_FACTORS Analysis Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}

// Test MEETINGS analysis
try {
    System.debug('\\n=== TESTING MEETINGS ANALYSIS ===');
    
    ANAgentKPIAnalysisService.KPIAnalysisRequest meetingRequest = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    meetingRequest.analysisType = 'MEETINGS';
    meetingRequest.primaryDimension = 'OU_NAME';
    meetingRequest.primaryValue = 'AMER ACC';
    meetingRequest.timeFrame = 'CURRENT';
    meetingRequest.maxResults = 10;
    
    List<ANAgentKPIAnalysisService.KPIResponse> meetingResponses = 
        ANAgentKPIAnalysisService.analyzeKPIs(new List<ANAgentKPIAnalysisService.KPIAnalysisRequest>{meetingRequest});
    
    if (!meetingResponses.isEmpty()) {
        ANAgentKPIAnalysisService.KPIResponse response = meetingResponses[0];
        System.debug('✅ MEETINGS Analysis Result:');
        System.debug('  - Success: ' + response.success);
        System.debug('  - Message: ' + response.message);
        System.debug('  - Total AEs: ' + response.totalAEs);
        
        if (response.agg != null) {
            System.debug('  - Total Meetings: ' + response.agg.totalMeetings);
            System.debug('  - Total Call Connects: ' + response.agg.totalCallConnects);
        }
    } else {
        System.debug('❌ No meeting responses received');
    }
    
} catch (Exception e) {
    System.debug('❌ MEETINGS Analysis Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}

// Test REVENUE analysis
try {
    System.debug('\\n=== TESTING REVENUE ANALYSIS ===');
    
    ANAgentKPIAnalysisService.KPIAnalysisRequest revenueRequest = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    revenueRequest.analysisType = 'REVENUE';
    revenueRequest.primaryDimension = 'OU_NAME';
    revenueRequest.primaryValue = 'AMER ACC';
    revenueRequest.timeFrame = 'CURRENT';
    revenueRequest.maxResults = 10;
    
    List<ANAgentKPIAnalysisService.KPIResponse> revenueResponses = 
        ANAgentKPIAnalysisService.analyzeKPIs(new List<ANAgentKPIAnalysisService.KPIAnalysisRequest>{revenueRequest});
    
    if (!revenueResponses.isEmpty()) {
        ANAgentKPIAnalysisService.KPIResponse response = revenueResponses[0];
        System.debug('✅ REVENUE Analysis Result:');
        System.debug('  - Success: ' + response.success);
        System.debug('  - Message: ' + response.message);
        System.debug('  - Total AEs: ' + response.totalAEs);
        
        if (response.agg != null) {
            System.debug('  - Total ACV: ' + response.agg.totalACV);
            System.debug('  - Total PG: ' + response.agg.totalPG);
        }
    } else {
        System.debug('❌ No revenue responses received');
    }
    
} catch (Exception e) {
    System.debug('❌ REVENUE Analysis Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}

// Test legacy method
try {
    System.debug('\\n=== TESTING LEGACY METHOD ===');
    
    String legacyResult = ANAgentKPIAnalysisService.analyzeKPIs('GROWTH_FACTORS', 'CURRENT', 'OU_NAME', 
                                                               'OU_NAME__c=\'AMER ACC\'', null, false, 10, 'COUNT');
    
    System.debug('✅ Legacy Method Result: ' + legacyResult);
    
} catch (Exception e) {
    System.debug('❌ Legacy Method Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}