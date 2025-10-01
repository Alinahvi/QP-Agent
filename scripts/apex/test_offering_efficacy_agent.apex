// Test script for ANAgentOfferingEfficacyHandler and ANAgentOfferingEfficacyService
// Run this in Developer Console or via SFDX

// Test 1: Search for specific offering efficacy data
System.debug('=== TEST 1: SEARCH ACTION ===');
ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest searchRequest = new ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest();
searchRequest.action = 'Search';
searchRequest.offeringLabel = 'FY25 Fast Start - RKO - Einstein 1';
searchRequest.programType = 'Fast Start';
searchRequest.region = 'ANZ';
searchRequest.maxResults = 20;

try {
    List<ANAgentOfferingEfficacyHandler.EfficacyAnalysisResponse> searchResponses = 
        ANAgentOfferingEfficacyHandler.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest>{searchRequest});
    
    if (!searchResponses.isEmpty()) {
        ANAgentOfferingEfficacyHandler.EfficacyAnalysisResponse response = searchResponses[0];
        System.debug('Search Results:');
        System.debug('Success: ' + response.success);
        System.debug('Message: ' + response.message);
        System.debug('Total Records: ' + response.totalRecordCount);
        System.debug('Summary Metrics: ' + response.summaryMetrics);
        System.debug('Regional Breakdown: ' + response.regionalBreakdown);
        System.debug('Segment Breakdown: ' + response.segmentBreakdown);
        System.debug('KPI Breakdown: ' + response.kpiBreakdown);
        
        if (!response.efficacyRecords.isEmpty()) {
            System.debug('Sample Record:');
            System.debug('Offering: ' + response.efficacyRecords[0].offeringLabel);
            System.debug('Effectiveness: ' + response.efficacyRecords[0].effectivenessDisplay);
            System.debug('Lift: ' + response.efficacyRecords[0].liftDisplay);
            System.debug('ACV: ' + response.efficacyRecords[0].acvDisplay);
        }
    }
} catch (Exception e) {
    System.debug('Error in search test: ' + e.getMessage());
}

// Test 2: Comprehensive analysis
System.debug('\n=== TEST 2: ANALYZE ACTION ===');
ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest analyzeRequest = new ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest();
analyzeRequest.action = 'Analyze';
analyzeRequest.programType = 'Fast Start';
analyzeRequest.fiscalQuarter = '2024-Q1';

try {
    List<ANAgentOfferingEfficacyHandler.EfficacyAnalysisResponse> analyzeResponses = 
        ANAgentOfferingEfficacyHandler.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest>{analyzeRequest});
    
    if (!analyzeResponses.isEmpty()) {
        ANAgentOfferingEfficacyHandler.EfficacyAnalysisResponse response = analyzeResponses[0];
        System.debug('Analysis Results:');
        System.debug('Success: ' + response.success);
        System.debug('Message: ' + response.message);
        System.debug('Total Records: ' + response.totalRecordCount);
        System.debug('Summary Metrics: ' + response.summaryMetrics);
        
        if (!response.topPerformers.isEmpty()) {
            System.debug('Top Performers:');
            for (Integer i = 0; i < Math.min(3, response.topPerformers.size()); i++) {
                System.debug((i+1) + '. ' + response.topPerformers[i].offeringLabel + 
                           ' - Effectiveness: ' + response.topPerformers[i].effectivenessDisplay);
            }
        }
    }
} catch (Exception e) {
    System.debug('Error in analyze test: ' + e.getMessage());
}

// Test 3: Summary generation
System.debug('\n=== TEST 3: SUMMARY ACTION ===');
ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest summaryRequest = new ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest();
summaryRequest.action = 'Summary';
summaryRequest.programType = 'Fast Start';

try {
    List<ANAgentOfferingEfficacyHandler.EfficacyAnalysisResponse> summaryResponses = 
        ANAgentOfferingEfficacyHandler.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest>{summaryRequest});
    
    if (!summaryResponses.isEmpty()) {
        ANAgentOfferingEfficacyHandler.EfficacyAnalysisResponse response = summaryResponses[0];
        System.debug('Summary Results:');
        System.debug('Success: ' + response.success);
        System.debug('Message: ' + response.message);
        System.debug('Total Records: ' + response.totalRecordCount);
        System.debug('Summary Metrics: ' + response.summaryMetrics);
        System.debug('Regional Breakdown: ' + response.regionalBreakdown);
        System.debug('Segment Breakdown: ' + response.segmentBreakdown);
        System.debug('KPI Breakdown: ' + response.kpiBreakdown);
    }
} catch (Exception e) {
    System.debug('Error in summary test: ' + e.getMessage());
}

// Test 4: Direct service call for specific KPI
System.debug('\n=== TEST 4: DIRECT SERVICE CALL ===');
try {
    ANAgentOfferingEfficacyService.EfficacySearchResult serviceResult = 
        ANAgentOfferingEfficacyService.searchEfficacyData(
            null, 'Fast Start', 'ANZ', 'ESMB', '2024-Q1', 'PIPE_QUALITY', 'ALL', 10
        );
    
    System.debug('Direct Service Call Results:');
    System.debug('Success: ' + serviceResult.success);
    System.debug('Message: ' + serviceResult.message);
    System.debug('Total Records: ' + serviceResult.totalRecordCount);
    
    if (!serviceResult.efficacyRecords.isEmpty()) {
        System.debug('Sample Efficacy Record:');
        ANAgentOfferingEfficacyService.EfficacyRecord record = serviceResult.efficacyRecords[0];
        System.debug('Offering: ' + record.offeringLabel);
        System.debug('Program Type: ' + record.programType);
        System.debug('Region: ' + record.region);
        System.debug('Segment: ' + record.macroSegment);
        System.debug('KPI: ' + record.kpiName);
        System.debug('Effectiveness: ' + record.effectivenessDisplay);
        System.debug('Lift: ' + record.liftDisplay);
        System.debug('ACV: ' + record.acvDisplay);
        System.debug('Learners: ' + record.learnersDisplay);
        System.debug('Significance: ' + record.significanceIndicator);
    }
} catch (Exception e) {
    System.debug('Error in direct service call: ' + e.getMessage());
}

System.debug('\n=== TESTING COMPLETED ==='); 