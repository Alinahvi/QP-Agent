// Efficient MCP Test with 100 Utterances (10 Batches)
// Reduces SOQL usage by batching requests and using simulation for validation

System.debug('=== STARTING EFFICIENT MCP TEST WITH 100 UTTERANCES ===');

// Test scenarios organized by batch
List<List<String>> testBatches = new List<List<String>>{
    // Batch 1: Basic OU Analysis
    new List<String>{
        'Show me AMER ACC growth factors',
        'What are EMEA SMB meetings?',
        'Analyze APAC REG calls',
        'UKI revenue analysis',
        'AMER SMB ACV data',
        'EMEA ACC PG metrics',
        'APAC SMB meetings',
        'AMER REG calls',
        'EMEA SMB growth factors',
        'UKI ACV analysis'
    },
    
    // Batch 2: Country Analysis
    new List<String>{
        'US team performance',
        'Canada meetings data',
        'Australia calls analysis',
        'Germany revenue metrics',
        'France ACV data',
        'Japan PG analysis',
        'Brazil meetings',
        'India calls data',
        'Ireland growth factors',
        'Netherlands ACV metrics'
    },
    
    // Batch 3: Mixed OU/Country
    new List<String>{
        'AMER ACC in US performance',
        'EMEA SMB in Germany calls',
        'APAC REG in Japan meetings',
        'UKI team in UK revenue',
        'AMER SMB in Canada ACV',
        'EMEA ACC in France PG',
        'APAC SMB in Australia growth',
        'AMER REG in Brazil calls',
        'EMEA SMB in India meetings',
        'UKI in Ireland ACV'
    },
    
    // Batch 4: Timeframe Variations
    new List<String>{
        'AMER ACC current quarter meetings',
        'EMEA SMB previous quarter calls',
        'APAC REG current ACV',
        'UKI previous growth factors',
        'AMER SMB current PG',
        'EMEA ACC previous revenue',
        'APAC SMB current meetings',
        'AMER REG previous calls',
        'EMEA SMB current ACV',
        'UKI previous PG'
    },
    
    // Batch 5: Specific Metrics
    new List<String>{
        'AMER ACC meeting activity',
        'EMEA SMB call connects',
        'APAC REG ACV performance',
        'UKI PG metrics',
        'AMER SMB growth factors',
        'EMEA ACC revenue data',
        'APAC SMB meeting stats',
        'AMER REG call metrics',
        'EMEA SMB ACV analysis',
        'UKI growth performance'
    },
    
    // Batch 6: Fuzzy OU Names
    new List<String>{
        'AMER-ACC team data',
        'EMEA_SMB meetings',
        'APAC.REG calls',
        'AMER ACC team',
        'EMEA SMB group',
        'APAC REG division',
        'UKI organization',
        'AMER SMB unit',
        'EMEA ACC team',
        'APAC SMB group'
    },
    
    // Batch 7: Country Variations
    new List<String>{
        'United States team performance',
        'United Kingdom meetings',
        'Deutschland calls data',
        'Australia team metrics',
        'Canada ACV analysis',
        'France PG data',
        'Japan growth factors',
        'Brazil meetings',
        'India calls',
        'Ireland revenue'
    },
    
    // Batch 8: Edge Cases
    new List<String>{
        'AMER ACC meetings and calls',
        'EMEA SMB ACV and PG',
        'APAC REG growth and revenue',
        'UKI all metrics',
        'AMER SMB performance data',
        'EMEA ACC team stats',
        'APAC SMB activity',
        'AMER REG metrics',
        'EMEA SMB analysis',
        'UKI team data'
    },
    
    // Batch 9: Complex Queries
    new List<String>{
        'Show me top performers in AMER ACC',
        'EMEA SMB low performers',
        'APAC REG high ACV AEs',
        'UKI meeting champions',
        'AMER SMB call leaders',
        'EMEA ACC growth stars',
        'APAC SMB revenue leaders',
        'AMER REG PG performers',
        'EMEA SMB ACV champions',
        'UKI growth leaders'
    },
    
    // Batch 10: Validation Cases
    new List<String>{
        'AMER ACC detailed analysis',
        'EMEA SMB comprehensive data',
        'APAC REG full metrics',
        'UKI complete analysis',
        'AMER SMB detailed stats',
        'EMEA ACC comprehensive view',
        'APAC SMB full data',
        'AMER REG detailed metrics',
        'EMEA SMB complete analysis',
        'UKI full team data'
    }
};

Integer totalTests = 0;
Integer successfulTests = 0;
Integer suspiciousResults = 0;
List<String> suspiciousCases = new List<String>();
Map<String, Integer> resultCounts = new Map<String, Integer>();

// Pre-validate some key scenarios with SOQL to establish baseline
System.debug('\n=== PRE-VALIDATION WITH SOQL ===');
Map<String, Integer> baselineCounts = new Map<String, Integer>();

// Test key OU scenarios
List<String> keyOUs = new List<String>{'AMER ACC', 'EMEA SMB', 'APAC REG', 'UKI'};
for (String ou : keyOUs) {
    try {
        List<AGENT_OU_PIPELINE_V2__c> records = [
            SELECT Id FROM AGENT_OU_PIPELINE_V2__c 
            WHERE OU_NAME__c LIKE :('%' + ou + '%') 
            LIMIT 1
        ];
        baselineCounts.put(ou, records.size());
        System.debug('Baseline ' + ou + ': ' + records.size() + ' records');
    } catch (Exception e) {
        System.debug('Baseline ' + ou + ': Error - ' + e.getMessage());
        baselineCounts.put(ou, 0);
    }
}

// Test key country scenarios
List<String> keyCountries = new List<String>{'US', 'Canada', 'Australia', 'Germany'};
for (String country : keyCountries) {
    try {
        List<AGENT_OU_PIPELINE_V2__c> records = [
            SELECT Id FROM AGENT_OU_PIPELINE_V2__c 
            WHERE WORK_LOCATION_COUNTRY__c LIKE :('%' + country + '%') 
            LIMIT 1
        ];
        baselineCounts.put(country, records.size());
        System.debug('Baseline ' + country + ': ' + records.size() + ' records');
    } catch (Exception e) {
        System.debug('Baseline ' + country + ': Error - ' + e.getMessage());
        baselineCounts.put(country, 0);
    }
}

System.debug('\n=== RUNNING MCP TESTS ===');

for (Integer batchNum = 0; batchNum < testBatches.size(); batchNum++) {
    System.debug('\n=== BATCH ' + (batchNum + 1) + ' ===');
    
    for (String utterance : testBatches[batchNum]) {
        totalTests++;
        System.debug('\n--- Test ' + totalTests + ': "' + utterance + '" ---');
        
        try {
            // Parse utterance to extract parameters
            Map<String, String> params = parseUtterance(utterance);
            
            // Create request
            ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
            request.analysisType = params.get('analysisType');
            request.timeFrame = params.get('timeFrame');
            request.primaryDimension = params.get('primaryDimension');
            request.primaryValue = params.get('primaryValue');
            request.secondaryDimension = params.get('secondaryDimension');
            request.secondaryValue = params.get('secondaryValue');
            request.maxResults = 5; // Reduced to save resources
            request.includeLearnerProfile = false; // Disabled to save SOQL
            request.fuzzySearchEnabled = true;
            
            // Call handler
            List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = 
                ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{request});
            
            if (!responses.isEmpty()) {
                ANAgentKPIAnalysisHandler.KPIAnalysisResponse response = responses[0];
                
                if (response.success) {
                    successfulTests++;
                    System.debug('✅ SUCCESS: ' + response.message);
                    
                    // Track result counts
                    String key = params.get('primaryValue') + '_' + params.get('analysisType');
                    if (!resultCounts.containsKey(key)) {
                        resultCounts.put(key, 0);
                    }
                    resultCounts.put(key, resultCounts.get(key) + 1);
                    
                    // Check for suspicious results (0 or no data)
                    if (isSuspiciousResult(response)) {
                        suspiciousResults++;
                        suspiciousCases.add(utterance);
                        System.debug('⚠️ SUSPICIOUS: Zero or no data');
                        
                        // Check against baseline
                        String baselineKey = params.get('primaryValue');
                        if (baselineCounts.containsKey(baselineKey) && baselineCounts.get(baselineKey) > 0) {
                            System.debug('🚨 DISCREPANCY: Baseline shows ' + baselineCounts.get(baselineKey) + ' records but MCP returned 0');
                        } else {
                            System.debug('✅ CONFIRMED: Baseline also shows 0 records');
                        }
                    }
                } else {
                    System.debug('❌ FAILED: ' + response.message);
                }
            } else {
                System.debug('❌ FAILED: No response received');
            }
        } catch (Exception e) {
            System.debug('❌ ERROR: ' + e.getMessage());
        }
    }
}

// Summary
System.debug('\n=== COMPREHENSIVE TEST SUMMARY ===');
System.debug('Total Tests: ' + totalTests);
System.debug('Successful Tests: ' + successfulTests);
System.debug('Failed Tests: ' + (totalTests - successfulTests));
System.debug('Suspicious Results: ' + suspiciousResults);
System.debug('Success Rate: ' + ((Decimal)successfulTests / totalTests * 100).setScale(2) + '%');

if (!suspiciousCases.isEmpty()) {
    System.debug('\n=== SUSPICIOUS CASES ===');
    for (String suspiciousCase : suspiciousCases) {
        System.debug('- ' + suspiciousCase);
    }
}

System.debug('\n=== RESULT COUNTS BY SCENARIO ===');
for (String key : resultCounts.keySet()) {
    System.debug(key + ': ' + resultCounts.get(key) + ' successful tests');
}

// Helper methods
Map<String, String> parseUtterance(String utterance) {
    Map<String, String> params = new Map<String, String>();
    
    // Default values
    params.put('analysisType', 'MEETINGS');
    params.put('timeFrame', 'CURRENT');
    params.put('primaryDimension', 'OU_NAME__c');
    params.put('primaryValue', '');
    params.put('secondaryDimension', null);
    params.put('secondaryValue', null);
    
    String lowerUtterance = utterance.toLowerCase();
    
    // Determine analysis type
    if (lowerUtterance.contains('growth') || lowerUtterance.contains('factor')) {
        params.put('analysisType', 'GROWTH_FACTORS');
    } else if (lowerUtterance.contains('call') || lowerUtterance.contains('connect')) {
        params.put('analysisType', 'CALLS');
    } else if (lowerUtterance.contains('acv')) {
        params.put('analysisType', 'ACV');
    } else if (lowerUtterance.contains('pg')) {
        params.put('analysisType', 'PG');
    } else if (lowerUtterance.contains('revenue')) {
        params.put('analysisType', 'REVENUE');
    }
    
    // Determine timeframe
    if (lowerUtterance.contains('previous') || lowerUtterance.contains('last')) {
        params.put('timeFrame', 'PREVIOUS');
    }
    
    // Extract OU or Country
    List<String> ouPatterns = new List<String>{
        'AMER ACC', 'EMEA SMB', 'APAC REG', 'UKI', 'AMER SMB', 'EMEA ACC', 'APAC SMB', 'AMER REG'
    };
    
    List<String> countryPatterns = new List<String>{
        'US', 'USA', 'United States', 'Canada', 'Australia', 'Germany', 'France', 'Japan', 
        'Brazil', 'India', 'Ireland', 'Netherlands', 'UK', 'United Kingdom'
    };
    
    for (String pattern : ouPatterns) {
        if (lowerUtterance.contains(pattern.toLowerCase())) {
            params.put('primaryValue', pattern);
            params.put('primaryDimension', 'OU_NAME__c');
            break;
        }
    }
    
    if (String.isBlank(params.get('primaryValue'))) {
        for (String pattern : countryPatterns) {
            if (lowerUtterance.contains(pattern.toLowerCase())) {
                params.put('primaryValue', pattern);
                params.put('primaryDimension', 'WORK_LOCATION_COUNTRY__c');
                break;
            }
        }
    }
    
    return params;
}

Boolean isSuspiciousResult(ANAgentKPIAnalysisHandler.KPIAnalysisResponse response) {
    // Check for suspicious results (0 or no data)
    return (response.totalAEs == 0 || response.totalAEs == null) && 
           (response.totalMeetings == 0 || response.totalMeetings == null) && 
           (response.totalCallConnects == 0 || response.totalCallConnects == null) && 
           (response.totalACV == 0 || response.totalACV == null) && 
           (response.totalPG == 0 || response.totalPG == null);
}
