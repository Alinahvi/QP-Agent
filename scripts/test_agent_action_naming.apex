// Test Agent Action with Naming Variations
System.debug('🧪 TESTING AGENT ACTION WITH NAMING VARIATIONS');
System.debug('==============================================');

// Test Open Pipe Analysis with naming variations
System.debug('Testing Open Pipe Analysis with naming variations:');

try {
    String result = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'AMERACC',              // ouName (should be normalized to AMER ACC)
        null,                   // workLocationCountry
        'PRODUCT',              // groupBy
        null,                   // filterCriteria
        null,                   // restrictInValuesCsv
        false,                  // perAENormalize
        5,                      // limitN
        'COUNT',                // aggregationType
        'TOP_PRODUCTS'          // analysisType
    );
    
    if (result != null && result.length() > 0) {
        System.debug('✅ Open Pipe Analysis with AMERACC -> SUCCESS');
        System.debug('Result length: ' + result.length() + ' characters');
    } else {
        System.debug('⚠️ Open Pipe Analysis with AMERACC -> NO RESULTS');
    }
} catch (Exception e) {
    System.debug('❌ Open Pipe Analysis with AMERACC -> ERROR: ' + e.getMessage());
}

try {
    String result = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'EMEAENTR',             // ouName (should be normalized to EMEA ENTR)
        null,                   // workLocationCountry
        'PRODUCT',              // groupBy
        null,                   // filterCriteria
        null,                   // restrictInValuesCsv
        false,                  // perAENormalize
        5,                      // limitN
        'COUNT',                // aggregationType
        'TOP_PRODUCTS'          // analysisType
    );
    
    if (result != null && result.length() > 0) {
        System.debug('✅ Open Pipe Analysis with EMEAENTR -> SUCCESS');
        System.debug('Result length: ' + result.length() + ' characters');
    } else {
        System.debug('⚠️ Open Pipe Analysis with EMEAENTR -> NO RESULTS');
    }
} catch (Exception e) {
    System.debug('❌ Open Pipe Analysis with EMEAENTR -> ERROR: ' + e.getMessage());
}

// Test KPI Analysis with naming variations
System.debug('');
System.debug('Testing KPI Analysis with naming variations:');

try {
    Map<String, Object> filters = new Map<String, Object>();
    filters.put('OU Name', 'AMERACC');  // Should be normalized to AMER ACC
    
    ANAGENTKPIAnalysisServiceV3.OpenPipeSearchResult result = ANAGENTKPIAnalysisServiceV3.searchOpenPipeRecords(
        null,                   // searchTerm
        filters,                // filters
        'FULL_NAME__c',         // sortBy
        'ASC',                  // sortOrder
        5,                      // recordLimit
        0                       // offset
    );
    
    if (result != null && result.records != null) {
        System.debug('✅ KPI Analysis with AMERACC -> SUCCESS (' + result.records.size() + ' records)');
    } else {
        System.debug('⚠️ KPI Analysis with AMERACC -> NO RESULTS');
    }
} catch (Exception e) {
    System.debug('❌ KPI Analysis with AMERACC -> ERROR: ' + e.getMessage());
}

try {
    Map<String, Object> filters = new Map<String, Object>();
    filters.put('OU Name', 'EMEAENTR');  // Should be normalized to EMEA ENTR
    
    ANAGENTKPIAnalysisServiceV3.OpenPipeSearchResult result = ANAGENTKPIAnalysisServiceV3.searchOpenPipeRecords(
        null,                   // searchTerm
        filters,                // filters
        'FULL_NAME__c',         // sortBy
        'ASC',                  // sortOrder
        5,                      // recordLimit
        0                       // offset
    );
    
    if (result != null && result.records != null) {
        System.debug('✅ KPI Analysis with EMEAENTR -> SUCCESS (' + result.records.size() + ' records)');
    } else {
        System.debug('⚠️ KPI Analysis with EMEAENTR -> NO RESULTS');
    }
} catch (Exception e) {
    System.debug('❌ KPI Analysis with EMEAENTR -> ERROR: ' + e.getMessage());
}

System.debug('');
System.debug('✅ AGENT ACTION NAMING TEST COMPLETED!');
System.debug('=====================================');
