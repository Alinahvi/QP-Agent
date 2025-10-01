// Test Negative Filters for Open Pipe Analysis V3
System.debug('=== NEGATIVE FILTERS TEST FOR OPEN PIPE ANALYSIS V3 ===');

// Test 1: UKI AEs without Agentforce deals
System.debug('\n=== TEST 1: UKI AEs without Agentforce ===');
try {
    String result1 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'UKI',                    // ouName
        '',                       // workLocationCountry
        'AE',                     // groupBy
        '',                       // filterCriteria
        '',                       // restrictInValuesCsv
        false,                    // perAENormalize
        50,                       // limitN
        'COUNT',                  // aggregationType
        'STAGE_COUNT',            // analysisType
        false,                    // includeClosureProb
        false,                    // includeStageBottlenecks
        false,                    // includePMF
        false,                    // includeAEBenchmarks
        false,                    // includeHealthScore
        'Agentforce',             // excludeProductListCsv
        true,                     // requireNoProductMatch
        true                      // negativeIntent
    );
    
    System.debug('UKI without Agentforce Result:');
    System.debug(result1);
} catch (Exception e) {
    System.debug('Error in Test 1: ' + e.getMessage());
}

// Test 2: AMER ACC AEs excluding Data Cloud and Slack
System.debug('\n=== TEST 2: AMER ACC excluding Data Cloud and Slack ===');
try {
    String result2 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'AMER ACC',               // ouName
        '',                       // workLocationCountry
        'AE',                     // groupBy
        '',                       // filterCriteria
        '',                       // restrictInValuesCsv
        false,                    // perAENormalize
        50,                       // limitN
        'COUNT',                  // aggregationType
        'STAGE_COUNT',            // analysisType
        false,                    // includeClosureProb
        false,                    // includeStageBottlenecks
        false,                    // includePMF
        false,                    // includeAEBenchmarks
        false,                    // includeHealthScore
        'Data Cloud,Slack',       // excludeProductListCsv
        true,                     // requireNoProductMatch
        true                      // negativeIntent
    );
    
    System.debug('AMER ACC excluding Data Cloud and Slack Result:');
    System.debug(result2);
} catch (Exception e) {
    System.debug('Error in Test 2: ' + e.getMessage());
}

// Test 3: EMEA AEs without Salesforce Platform deals
System.debug('\n=== TEST 3: EMEA without Salesforce Platform ===');
try {
    String result3 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'EMEA',                   // ouName
        '',                       // workLocationCountry
        'AE',                     // groupBy
        '',                       // filterCriteria
        '',                       // restrictInValuesCsv
        false,                    // perAENormalize
        50,                       // limitN
        'COUNT',                  // aggregationType
        'STAGE_COUNT',            // analysisType
        false,                    // includeClosureProb
        false,                    // includeStageBottlenecks
        false,                    // includePMF
        false,                    // includeAEBenchmarks
        false,                    // includeHealthScore
        'Salesforce Platform',    // excludeProductListCsv
        true,                     // requireNoProductMatch
        true                      // negativeIntent
    );
    
    System.debug('EMEA without Salesforce Platform Result:');
    System.debug(result3);
} catch (Exception e) {
    System.debug('Error in Test 3: ' + e.getMessage());
}

// Test 4: US AEs without Marketing Cloud deals (with country filter)
System.debug('\n=== TEST 4: US AEs without Marketing Cloud ===');
try {
    String result4 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'AMER',                   // ouName
        'US',                     // workLocationCountry
        'AE',                     // groupBy
        '',                       // filterCriteria
        '',                       // restrictInValuesCsv
        false,                    // perAENormalize
        50,                       // limitN
        'COUNT',                  // aggregationType
        'STAGE_COUNT',            // analysisType
        false,                    // includeClosureProb
        false,                    // includeStageBottlenecks
        false,                    // includePMF
        false,                    // includeAEBenchmarks
        false,                    // includeHealthScore
        'Marketing Cloud',        // excludeProductListCsv
        true,                     // requireNoProductMatch
        true                      // negativeIntent
    );
    
    System.debug('US AEs without Marketing Cloud Result:');
    System.debug(result4);
} catch (Exception e) {
    System.debug('Error in Test 4: ' + e.getMessage());
}

// Test 5: Test with no excluded products (should return error)
System.debug('\n=== TEST 5: No excluded products (error case) ===');
try {
    String result5 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'UKI',                    // ouName
        '',                       // workLocationCountry
        'AE',                     // groupBy
        '',                       // filterCriteria
        '',                       // restrictInValuesCsv
        false,                    // perAENormalize
        50,                       // limitN
        'COUNT',                  // aggregationType
        'STAGE_COUNT',            // analysisType
        false,                    // includeClosureProb
        false,                    // includeStageBottlenecks
        false,                    // includePMF
        false,                    // includeAEBenchmarks
        false,                    // includeHealthScore
        '',                       // excludeProductListCsv (empty)
        true,                     // requireNoProductMatch
        true                      // negativeIntent
    );
    
    System.debug('No excluded products Result:');
    System.debug(result5);
} catch (Exception e) {
    System.debug('Error in Test 5: ' + e.getMessage());
}

// Test 6: Test regular analysis (not negative filter)
System.debug('\n=== TEST 6: Regular analysis (not negative filter) ===');
try {
    String result6 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'UKI',                    // ouName
        '',                       // workLocationCountry
        'AE',                     // groupBy
        '',                       // filterCriteria
        '',                       // restrictInValuesCsv
        false,                    // perAENormalize
        50,                       // limitN
        'COUNT',                  // aggregationType
        'STAGE_COUNT',            // analysisType
        false,                    // includeClosureProb
        false,                    // includeStageBottlenecks
        false,                    // includePMF
        false,                    // includeAEBenchmarks
        false,                    // includeHealthScore
        '',                       // excludeProductListCsv
        false,                    // requireNoProductMatch
        false                     // negativeIntent
    );
    
    System.debug('Regular analysis Result:');
    System.debug(result6);
} catch (Exception e) {
    System.debug('Error in Test 6: ' + e.getMessage());
}

System.debug('\n=== NEGATIVE FILTERS TEST COMPLETE ===');
