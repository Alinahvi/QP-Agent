// Comprehensive test for KPI Analysis Agent Action with 100 utterances in 10 batches
System.debug('=== KPI ANALYSIS AGENT ACTION - 100 UTTERANCES TEST ===');

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

// Function to test a single utterance
public static void testUtterance(String utterance, Integer batchNumber, Integer utteranceNumber) {
    try {
        System.debug('Batch ' + batchNumber + ', Utterance ' + utteranceNumber + ': ' + utterance);
        
        // Parse utterance to determine analysis type and parameters
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
        request.maxResults = 10;
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
        
        // Execute analysis
        List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{request});
        
        if (!responses.isEmpty()) {
            ANAgentKPIAnalysisHandler.KPIAnalysisResponse response = responses[0];
            System.debug('  ✓ Success: ' + response.success + ', Records: ' + response.totalRecordCount + ', Type: ' + analysisType);
            
            if (response.warnings != null && !response.warnings.isEmpty()) {
                System.debug('  ⚠ Warnings: ' + response.warnings);
            }
            
            if (response.learnerProfiles != null && !response.learnerProfiles.isEmpty()) {
                System.debug('  👥 Learner Profiles: ' + response.learnerProfiles.size());
            }
        } else {
            System.debug('  ✗ No responses received');
        }
        
    } catch (Exception e) {
        System.debug('  ❌ Error: ' + e.getMessage());
    }
}

// Execute tests in 10 batches of 10 utterances each
System.debug('\n=== STARTING 100 UTTERANCE TEST IN 10 BATCHES ===');

for (Integer batch = 1; batch <= 10; batch++) {
    System.debug('\n--- BATCH ' + batch + ' (Utterances ' + ((batch-1)*10 + 1) + '-' + (batch*10) + ') ---');
    
    for (Integer i = 0; i < 10; i++) {
        Integer utteranceIndex = (batch - 1) * 10 + i;
        if (utteranceIndex < utterances.size()) {
            testUtterance(utterances[utteranceIndex], batch, i + 1);
        }
    }
    
    // Small delay between batches to manage CPU usage
    if (batch < 10) {
        System.debug('  ⏳ Batch ' + batch + ' complete. Proceeding to next batch...');
    }
}

System.debug('\n=== 100 UTTERANCE TEST COMPLETE ===');
System.debug('Total utterances tested: ' + utterances.size());
System.debug('Batches executed: 10');
System.debug('Expected total tests: 100');
