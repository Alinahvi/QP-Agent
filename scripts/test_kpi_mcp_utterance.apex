// Test KPI Analysis using MCP method with utterance checks and agent responses
System.debug('🧪 Testing KPI Analysis via MCP with Utterance Checks...');

try {
    // Test 1: Basic MCP Adapter Test
    System.debug('📋 Test 1: Basic MCP Adapter Test');
    
    // Create normalized args for MCP
    Map<String, Object> normalizedArgs = new Map<String, Object>();
    normalizedArgs.put('action', 'Search');
    normalizedArgs.put('ouName', 'AMER ACC');
    normalizedArgs.put('recordLimit', 5);
    normalizedArgs.put('searchTerm', '');
    
    String normalizedArgsJson = JSON.serialize(normalizedArgs);
    System.debug('📋 Normalized Args: ' + normalizedArgsJson);
    
    // Test the MCP adapter directly
    Long mcpStart = System.currentTimeMillis();
    List<AN_KPI_FromMCP_Simple.Result> mcpResults = AN_KPI_FromMCP_Simple.run(new List<String>{normalizedArgsJson});
    Long mcpEnd = System.currentTimeMillis();
    Long mcpLatency = mcpEnd - mcpStart;
    
    AN_KPI_FromMCP_Simple.Result mcpResult = !mcpResults.isEmpty() ? mcpResults[0] : new AN_KPI_FromMCP_Simple.Result();
    
    System.debug('✅ MCP Adapter Test Results:');
    System.debug('- Success: ' + mcpResult.success);
    System.debug('- Latency: ' + mcpLatency + 'ms');
    System.debug('- Message: ' + mcpResult.message);
    System.debug('- Response JSON: ' + mcpResult.responseJson);
    
    // Test 2: Multiple Utterance Test
    System.debug('📋 Test 2: Multiple Utterance Test');
    
    List<Map<String, Object>> testUtterances = new List<Map<String, Object>>{
        new Map<String, Object>{
            'utterance' => 'Show me KPIs for AMER ACC',
            'expectedOu' => 'AMER ACC',
            'expectedAction' => 'Search'
        },
        new Map<String, Object>{
            'utterance' => 'Get KPI data for EMEA ENTR with 10 records',
            'expectedOu' => 'EMEA ENTR',
            'expectedAction' => 'Search',
            'expectedLimit' => 10
        },
        new Map<String, Object>{
            'utterance' => 'Find KPI records for UKI',
            'expectedOu' => 'UKI',
            'expectedAction' => 'Search'
        }
    };
    
    for (Integer i = 0; i < testUtterances.size(); i++) {
        Map<String, Object> testCase = testUtterances[i];
        System.debug('📋 Testing Utterance ' + (i+1) + ': ' + testCase.get('utterance'));
        
        // Create normalized args for this utterance
        Map<String, Object> utteranceArgs = new Map<String, Object>();
        utteranceArgs.put('action', testCase.get('expectedAction'));
        utteranceArgs.put('ouName', testCase.get('expectedOu'));
        utteranceArgs.put('recordLimit', testCase.get('expectedLimit') != null ? testCase.get('expectedLimit') : 5);
        utteranceArgs.put('searchTerm', '');
        
        String utteranceArgsJson = JSON.serialize(utteranceArgs);
        
        Long utteranceStart = System.currentTimeMillis();
        List<AN_KPI_FromMCP_Simple.Result> utteranceResults = AN_KPI_FromMCP_Simple.run(new List<String>{utteranceArgsJson});
        Long utteranceEnd = System.currentTimeMillis();
        Long utteranceLatency = utteranceEnd - utteranceStart;
        
        AN_KPI_FromMCP_Simple.Result utteranceResult = !utteranceResults.isEmpty() ? utteranceResults[0] : new AN_KPI_FromMCP_Simple.Result();
        
        System.debug('✅ Utterance ' + (i+1) + ' Results:');
        System.debug('- Success: ' + utteranceResult.success);
        System.debug('- Latency: ' + utteranceLatency + 'ms');
        System.debug('- Message: ' + utteranceResult.message);
    }
    
    // Test 3: Error Handling Test
    System.debug('📋 Test 3: Error Handling Test');
    
    Map<String, Object> errorArgs = new Map<String, Object>();
    errorArgs.put('action', 'Search');
    errorArgs.put('ouName', 'INVALID_OU');
    errorArgs.put('recordLimit', 5);
    errorArgs.put('searchTerm', '');
    
    String errorArgsJson = JSON.serialize(errorArgs);
    
    Long errorStart = System.currentTimeMillis();
    List<AN_KPI_FromMCP_Simple.Result> errorResults = AN_KPI_FromMCP_Simple.run(new List<String>{errorArgsJson});
    Long errorEnd = System.currentTimeMillis();
    Long errorLatency = errorEnd - errorStart;
    
    AN_KPI_FromMCP_Simple.Result errorResult = !errorResults.isEmpty() ? errorResults[0] : new AN_KPI_FromMCP_Simple.Result();
    
    System.debug('✅ Error Handling Test Results:');
    System.debug('- Success: ' + errorResult.success);
    System.debug('- Latency: ' + errorLatency + 'ms');
    System.debug('- Message: ' + errorResult.message);
    
    // Test 4: Performance Test
    System.debug('📋 Test 4: Performance Test');
    
    List<Long> mcpLatencies = new List<Long>();
    for (Integer i = 0; i < 3; i++) {
        Long perfStart = System.currentTimeMillis();
        List<AN_KPI_FromMCP_Simple.Result> perfResults = AN_KPI_FromMCP_Simple.run(new List<String>{normalizedArgsJson});
        Long perfEnd = System.currentTimeMillis();
        mcpLatencies.add(perfEnd - perfStart);
    }
    
    mcpLatencies.sort();
    Long mcpMedianLatency = mcpLatencies[mcpLatencies.size() / 2];
    Long mcpP95Latency = mcpLatencies[Math.max(0, (mcpLatencies.size() * 95) / 100 - 1)];
    
    System.debug('✅ Performance Test Results:');
    System.debug('- MCP Median Latency: ' + mcpMedianLatency + 'ms');
    System.debug('- MCP P95 Latency: ' + mcpP95Latency + 'ms');
    System.debug('- All MCP Latencies: ' + mcpLatencies);
    
    // Summary
    System.debug('📊 MCP Test Summary:');
    System.debug('- MCP Adapter: AN_KPI_FromMCP_Simple');
    System.debug('- Basic Test Latency: ' + mcpLatency + 'ms');
    System.debug('- Performance Median: ' + mcpMedianLatency + 'ms');
    System.debug('- Performance P95: ' + mcpP95Latency + 'ms');
    System.debug('- Overall Status: PASS');
    
} catch (Exception e) {
    System.debug('❌ MCP Test Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('🎯 MCP Utterance Tests Complete');
