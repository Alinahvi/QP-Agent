// Efficient test for KPI Analysis Agent Action with 100 utterances - optimized for SOQL limits
System.debug('=== KPI ANALYSIS AGENT ACTION - EFFICIENT 100 UTTERANCES TEST ===');

// Test data - 100 realistic utterances for KPI analysis
List<String> utterances = new List<String>{
    // AMER/AMERICAS variations
    'What are the growth factors for AMER ACC?',
    'Show me growth factors for AMERICAS',
    'AMER growth factors analysis',
    'AMERICA OU growth factors',
    'North America growth factors',
    'AMER ACC performance metrics',
    'AMERICAS team growth factors',
    'AMER OU KPI analysis',
    'AMERICA region growth factors',
    'AMER ACC team performance',
    
    // EMEA variations
    'EMEA growth factors analysis',
    'EMEA-APAC growth factors',
    'Europe growth factors',
    'EU region growth factors',
    'EMEA team performance',
    'European OU growth factors',
    'EMEA ACC growth factors',
    'EMEA region KPI analysis',
    'Europe team growth factors',
    'EMEA performance metrics',
    
    // APAC/ASIA variations
    'APAC growth factors',
    'Asia Pacific growth factors',
    'ASIA growth factors',
    'APAC team performance',
    'Asia region growth factors',
    'APAC OU KPI analysis',
    'Asia Pacific team growth factors',
    'APAC performance metrics',
    'ASIA region growth factors',
    'Asia team performance',
    
    // Country-based queries
    'US growth factors analysis',
    'USA team growth factors',
    'United States growth factors',
    'US OU performance',
    'USA region KPI analysis',
    'United States team performance',
    'US country growth factors',
    'USA OU growth factors',
    'US region performance',
    'United States OU analysis',
    
    // UK/Canada variations
    'UK growth factors',
    'United Kingdom growth factors',
    'UK team performance',
    'United Kingdom OU analysis',
    'UK region growth factors',
    'Canada growth factors',
    'Canadian team performance',
    'Canada OU analysis',
    'Canadian region growth factors',
    'Canada team KPI analysis',
    
    // Australia variations
    'Australia growth factors',
    'Australian team performance',
    'Australia OU analysis',
    'Australian region growth factors',
    'Australia team KPI analysis',
    'AUS growth factors',
    'AU team performance',
    'Australian OU growth factors',
    'Australia region performance',
    'AUS team analysis',
    
    // Meetings analysis variations
    'AMER ACC meetings analysis',
    'EMEA meetings performance',
    'APAC meetings data',
    'US meetings analysis',
    'UK meetings performance',
    'Canada meetings data',
    'Australia meetings analysis',
    'AMERICAS meetings performance',
    'Europe meetings data',
    'Asia meetings analysis',
    
    // Combined queries
    'AMER US growth factors',
    'EMEA UK performance',
    'APAC Australia analysis',
    'AMER Canada growth factors',
    'EMEA Germany performance',
    'APAC Japan analysis',
    'AMER Mexico growth factors',
    'EMEA France performance',
    'APAC India analysis',
    'AMER Brazil growth factors',
    
    // Specific team queries
    'AMER ACC team growth factors',
    'EMEA ACC performance',
    'APAC ACC analysis',
    'AMER sales team growth factors',
    'EMEA sales performance',
    'APAC sales analysis',
    'AMER marketing team growth factors',
    'EMEA marketing performance',
    'APAC marketing analysis',
    'AMER support team growth factors',
    
    // Performance metrics queries
    'AMER ACC performance metrics',
    'EMEA performance metrics',
    'APAC performance metrics',
    'US performance metrics',
    'UK performance metrics',
    'Canada performance metrics',
    'Australia performance metrics',
    'AMERICAS performance metrics',
    'Europe performance metrics',
    'Asia performance metrics'
};

// Function to parse utterance and create request
public static ANAgentKPIAnalysisHandler.KPIAnalysisRequest parseUtterance(String utterance) {
    String analysisType = 'GROWTH_FACTORS';
    String ouName = null;
    String country = null;
    Boolean fuzzySearch = true;
    Boolean includeLearnerProfile = true;
    
    // Simple parsing logic
    if (utterance.toLowerCase().contains('meeting')) {
        analysisType = 'MEETINGS';
    }
    
    if (utterance.toLowerCase().contains('amer') || utterance.toLowerCase().contains('america')) {
        ouName = 'AMER';
    } else if (utterance.toLowerCase().contains('emea') || utterance.toLowerCase().contains('europe')) {
        ouName = 'EMEA';
    } else if (utterance.toLowerCase().contains('apac') || utterance.toLowerCase().contains('asia')) {
        ouName = 'APAC';
    }
    
    if (utterance.toLowerCase().contains('us') || utterance.toLowerCase().contains('usa') || utterance.toLowerCase().contains('united states')) {
        country = 'US';
    } else if (utterance.toLowerCase().contains('uk') || utterance.toLowerCase().contains('united kingdom')) {
        country = 'UK';
    } else if (utterance.toLowerCase().contains('canada')) {
        country = 'Canada';
    } else if (utterance.toLowerCase().contains('australia') || utterance.toLowerCase().contains('aus')) {
        country = 'Australia';
    }
    
    // Create request
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request.analysisType = analysisType;
    request.timeFrame = 'CURRENT';
    request.maxResults = 5; // Reduced to minimize data
    request.includeLearnerProfile = includeLearnerProfile;
    request.fuzzySearchEnabled = fuzzySearch;
    
    if (ouName != null) {
        request.primaryDimension = 'OU_NAME__c';
        request.primaryValue = ouName;
    }
    
    if (country != null) {
        if (ouName != null) {
            request.secondaryDimension = 'WORK_LOCATION_COUNTRY__c';
            request.secondaryValue = country;
        } else {
            request.primaryDimension = 'WORK_LOCATION_COUNTRY__c';
            request.primaryValue = country;
        }
    }
    
    return request;
}

// Function to test a batch of utterances
public static void testBatch(List<String> batchUtterances, Integer batchNumber) {
    System.debug('\n--- BATCH ' + batchNumber + ' (Utterances ' + batchUtterances.size() + ') ---');
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest> requests = new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>();
    
    // Parse all utterances in this batch
    for (Integer i = 0; i < batchUtterances.size(); i++) {
        String utterance = batchUtterances[i];
        System.debug('Utterance ' + (i + 1) + ': ' + utterance);
        
        ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = parseUtterance(utterance);
        requests.add(request);
    }
    
    // Execute batch analysis
    try {
        List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = ANAgentKPIAnalysisHandler.analyzeKPIs(requests);
        
        System.debug('Batch ' + batchNumber + ' Results:');
        for (Integer i = 0; i < responses.size(); i++) {
            ANAgentKPIAnalysisHandler.KPIAnalysisResponse response = responses[i];
            System.debug('  Utterance ' + (i + 1) + ': Success=' + response.success + 
                        ', Records=' + response.totalRecordCount + 
                        ', Type=' + response.analysisType +
                        ', OU=' + response.ouName +
                        ', Country=' + response.country);
            
            if (response.warnings != null && !response.warnings.isEmpty()) {
                System.debug('    Warnings: ' + response.warnings);
            }
        }
        
        System.debug('  ✓ Batch ' + batchNumber + ' completed successfully with ' + responses.size() + ' responses');
        
    } catch (Exception e) {
        System.debug('  ❌ Batch ' + batchNumber + ' error: ' + e.getMessage());
    }
}

// Execute tests in 10 batches of 10 utterances each
System.debug('\n=== STARTING EFFICIENT 100 UTTERANCE TEST IN 10 BATCHES ===');

Integer totalUtterances = utterances.size();
Integer batchSize = 10;
Integer totalBatches = (Integer) Math.ceil((Decimal) totalUtterances / batchSize);

System.debug('Total utterances: ' + totalUtterances);
System.debug('Batch size: ' + batchSize);
System.debug('Total batches: ' + totalBatches);

for (Integer batch = 1; batch <= totalBatches; batch++) {
    Integer startIndex = (batch - 1) * batchSize;
    Integer endIndex = Math.min(startIndex + batchSize, totalUtterances);
    
    List<String> batchUtterances = new List<String>();
    for (Integer i = startIndex; i < endIndex; i++) {
        batchUtterances.add(utterances[i]);
    }
    
    testBatch(batchUtterances, batch);
    
    // Small delay between batches
    if (batch < totalBatches) {
        System.debug('  ⏳ Batch ' + batch + ' complete. Proceeding to next batch...');
    }
}

System.debug('\n=== EFFICIENT 100 UTTERANCE TEST COMPLETE ===');
System.debug('Total utterances tested: ' + totalUtterances);
System.debug('Batches executed: ' + totalBatches);
System.debug('Expected total tests: 100');
