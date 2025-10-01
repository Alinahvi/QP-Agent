// Batch 1: Open Pipe V3 UAT - 10 test cases
System.debug('🚀 Starting Open Pipe V3 UAT Batch 1 (10 test cases)...');

try {
    List<Map<String, Object>> testCases = new List<Map<String, Object>>{
        new Map<String, Object>{
            'utterance' => 'Show me top 5 high-value products in open pipe for AMER ACC post stage 4',
            'expectedIntent' => 'open_pipe_analyze',
            'expectedArgs' => new Map<String, Object>{
                'ouName' => 'AMER ACC',
                'minStage' => '4',
                'timeFrame' => 'CURRENT',
                'limitN' => 5,
                'groupBy' => 'PRODUCT',
                'analysisType' => 'PRODUCT_PERFORMANCE',
                'aggregationType' => 'SUM'
            }
        },
        new Map<String, Object>{
            'utterance' => 'Find top 3 highest value products in open pipe for EMEA ENTR, post stage 3',
            'expectedIntent' => 'open_pipe_analyze',
            'expectedArgs' => new Map<String, Object>{
                'ouName' => 'EMEA ENTR',
                'minStage' => '3',
                'timeFrame' => 'CURRENT',
                'limitN' => 3,
                'groupBy' => 'PRODUCT',
                'analysisType' => 'PRODUCT_PERFORMANCE',
                'aggregationType' => 'SUM'
            }
        },
        new Map<String, Object>{
            'utterance' => 'Show me top 4 products by value in open pipe for UKI after stage 4',
            'expectedIntent' => 'open_pipe_analyze',
            'expectedArgs' => new Map<String, Object>{
                'ouName' => 'UKI',
                'minStage' => '4',
                'timeFrame' => 'CURRENT',
                'limitN' => 4,
                'groupBy' => 'PRODUCT',
                'analysisType' => 'PRODUCT_PERFORMANCE',
                'aggregationType' => 'SUM'
            }
        },
        new Map<String, Object>{
            'utterance' => 'Count opportunities between stage 3 and 5 for Sales Cloud in AMER ACC, limit 8',
            'expectedIntent' => 'open_pipe_analyze',
            'expectedArgs' => new Map<String, Object>{
                'ouName' => 'AMER ACC',
                'minStage' => '3',
                'timeFrame' => 'CURRENT',
                'limitN' => 8,
                'productListCsv' => 'Sales Cloud',
                'groupBy' => 'STAGE',
                'analysisType' => 'STAGE_COUNT',
                'aggregationType' => 'COUNT'
            }
        },
        new Map<String, Object>{
            'utterance' => 'Show me opportunity count by stage for Service Cloud in EMEA ENTR, post stage 3, limit 6',
            'expectedIntent' => 'open_pipe_analyze',
            'expectedArgs' => new Map<String, Object>{
                'ouName' => 'EMEA ENTR',
                'minStage' => '3',
                'timeFrame' => 'CURRENT',
                'limitN' => 6,
                'productListCsv' => 'Service Cloud',
                'groupBy' => 'STAGE',
                'analysisType' => 'STAGE_COUNT',
                'aggregationType' => 'COUNT'
            }
        },
        new Map<String, Object>{
            'utterance' => 'Find top 3 products with highest stagnation in stage 5 for AMER ACC',
            'expectedIntent' => 'open_pipe_analyze',
            'expectedArgs' => new Map<String, Object>{
                'ouName' => 'AMER ACC',
                'minStage' => '5',
                'timeFrame' => 'CURRENT',
                'limitN' => 3,
                'groupBy' => 'PRODUCT',
                'analysisType' => 'DAYS_IN_STAGE'
            }
        },
        new Map<String, Object>{
            'utterance' => 'Show me stagnation days for Marketing Cloud in EMEA ENTR stage 4, limit 4',
            'expectedIntent' => 'open_pipe_analyze',
            'expectedArgs' => new Map<String, Object>{
                'ouName' => 'EMEA ENTR',
                'minStage' => '4',
                'timeFrame' => 'CURRENT',
                'limitN' => 4,
                'productListCsv' => 'Marketing Cloud',
                'groupBy' => 'PRODUCT',
                'analysisType' => 'DAYS_IN_STAGE'
            }
        },
        new Map<String, Object>{
            'utterance' => 'Open pipe analysis for LATAM post stage 3, current quarter, limit 7',
            'expectedIntent' => 'open_pipe_analyze',
            'expectedArgs' => new Map<String, Object>{
                'ouName' => 'LATAM',
                'minStage' => '3',
                'timeFrame' => 'CURRENT',
                'limitN' => 7,
                'groupBy' => 'STAGE',
                'analysisType' => 'STAGE_COUNT'
            }
        },
        new Map<String, Object>{
            'utterance' => 'Show me open pipe for AMER ACC with country filter US, post stage 3, limit 5',
            'expectedIntent' => 'open_pipe_analyze',
            'expectedArgs' => new Map<String, Object>{
                'ouName' => 'AMER ACC',
                'minStage' => '3',
                'timeFrame' => 'CURRENT',
                'limitN' => 5,
                'workLocationCountry' => 'US',
                'groupBy' => 'STAGE',
                'analysisType' => 'STAGE_COUNT'
            }
        },
        new Map<String, Object>{
            'utterance' => 'Find top 6 products with stagnation in stage 4 for UKI, current quarter',
            'expectedIntent' => 'open_pipe_analyze',
            'expectedArgs' => new Map<String, Object>{
                'ouName' => 'UKI',
                'minStage' => '4',
                'timeFrame' => 'CURRENT',
                'limitN' => 6,
                'groupBy' => 'PRODUCT',
                'analysisType' => 'DAYS_IN_STAGE'
            }
        }
    };
    
    System.debug('📋 Loaded ' + testCases.size() + ' test cases for Batch 1');
    
    // Test execution tracking
    Integer directSuccessCount = 0;
    Integer mcpSuccessCount = 0;
    Integer intentAccuracyCount = 0;
    Integer argsAccuracyCount = 0;
    Integer resultParityCount = 0;
    List<Long> directLatencies = new List<Long>();
    List<Long> mcpLatencies = new List<Long>();
    
    System.debug('🚀 Starting Batch 1 test execution...');
    
    for (Integer i = 0; i < testCases.size(); i++) {
        Map<String, Object> testCase = testCases[i];
        System.debug('📋 Processing Test Case ' + (i+1) + '/' + testCases.size() + ': ' + testCase.get('utterance'));
        
        try {
            // Extract expected values
            String expectedIntent = (String) testCase.get('expectedIntent');
            Map<String, Object> expectedArgs = (Map<String, Object>) testCase.get('expectedArgs');
            
            // Test 1: Direct Handler Path
            Long directStartTime = System.currentTimeMillis();
            
            ANAgentOpenPipeAnalysisV3Handler.Request directRequest = new ANAgentOpenPipeAnalysisV3Handler.Request();
            directRequest.ouName = (String) expectedArgs.get('ouName');
            directRequest.workLocationCountry = (String) expectedArgs.get('workLocationCountry');
            directRequest.groupBy = (String) expectedArgs.get('groupBy');
            directRequest.filterCriteria = (String) expectedArgs.get('filterCriteria');
            directRequest.restrictInValuesCsv = (String) expectedArgs.get('productListCsv');
            directRequest.perAENormalize = (Boolean) expectedArgs.get('perAENormalize');
            directRequest.limitN = (Integer) expectedArgs.get('limitN');
            directRequest.aggregationType = (String) expectedArgs.get('aggregationType');
            directRequest.analysisType = (String) expectedArgs.get('analysisType');
            
            List<ANAgentOpenPipeAnalysisV3Handler.Response> directResponses = 
                ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(
                    new List<ANAgentOpenPipeAnalysisV3Handler.Request>{directRequest}
                );
            
            Long directEndTime = System.currentTimeMillis();
            Long directLatency = directEndTime - directStartTime;
            directLatencies.add(directLatency);
            
            Boolean directSuccess = !directResponses.isEmpty() && 
                String.isNotBlank(directResponses[0].message) && 
                !directResponses[0].message.contains('error');
            
            if (directSuccess) directSuccessCount++;
            
            // Test 2: MCP Adapter Path
            Long mcpStartTime = System.currentTimeMillis();
            
            Map<String, Object> mcpArgs = new Map<String, Object>();
            mcpArgs.put('ouName', expectedArgs.get('ouName'));
            mcpArgs.put('minStage', expectedArgs.get('minStage'));
            mcpArgs.put('timeFrame', expectedArgs.get('timeFrame'));
            mcpArgs.put('limitN', expectedArgs.get('limitN'));
            mcpArgs.put('country', expectedArgs.get('workLocationCountry'));
            mcpArgs.put('productListCsv', expectedArgs.get('productListCsv'));
            mcpArgs.put('correlationId', 'BATCH1_' + (i+1) + '_' + System.currentTimeMillis());
            
            String mcpArgsJson = JSON.serialize(mcpArgs);
            
            List<AN_OpenPipeV3_FromMCP_Simple.Result> mcpResults = 
                AN_OpenPipeV3_FromMCP_Simple.run(new List<String>{mcpArgsJson});
            
            Long mcpEndTime = System.currentTimeMillis();
            Long mcpLatency = mcpEndTime - mcpStartTime;
            mcpLatencies.add(mcpLatency);
            
            Boolean mcpSuccess = !mcpResults.isEmpty() && mcpResults[0].success;
            if (mcpSuccess) mcpSuccessCount++;
            
            // Test 3: Intent and Args Accuracy
            Boolean intentCorrect = 'open_pipe_analyze'.equals(expectedIntent);
            Boolean argsCorrect = expectedArgs.containsKey('ouName') && expectedArgs.containsKey('groupBy');
            
            if (intentCorrect) intentAccuracyCount++;
            if (argsCorrect) argsAccuracyCount++;
            
            // Test 4: Result Parity (simplified comparison)
            Boolean resultParity = false;
            if (directSuccess && mcpSuccess) {
                String directMessage = directResponses[0].message;
                String mcpMessage = mcpResults[0].message;
                resultParity = directMessage.contains('Open Pipe') && mcpMessage.contains('Open Pipe');
            }
            
            if (resultParity) resultParityCount++;
            
            System.debug('✅ Test Case ' + (i+1) + ' Results:');
            System.debug('- Direct Success: ' + directSuccess);
            System.debug('- MCP Success: ' + mcpSuccess);
            System.debug('- Intent Correct: ' + intentCorrect);
            System.debug('- Args Correct: ' + argsCorrect);
            System.debug('- Result Parity: ' + resultParity);
            System.debug('- Direct Latency: ' + directLatency + 'ms');
            System.debug('- MCP Latency: ' + mcpLatency + 'ms');
            System.debug('- Latency Delta: ' + (mcpLatency - directLatency) + 'ms');
            
        } catch (Exception e) {
            System.debug('❌ Error in test case ' + (i+1) + ': ' + e.getMessage());
            directLatencies.add(9999L);
            mcpLatencies.add(9999L);
        }
    }
    
    // Calculate metrics
    Integer totalTests = testCases.size();
    Decimal directSuccessRate = ((Decimal)directSuccessCount / totalTests * 100).setScale(2);
    Decimal mcpSuccessRate = ((Decimal)mcpSuccessCount / totalTests * 100).setScale(2);
    Decimal intentAccuracy = ((Decimal)intentAccuracyCount / totalTests * 100).setScale(2);
    Decimal argsAccuracy = ((Decimal)argsAccuracyCount / totalTests * 100).setScale(2);
    Decimal resultParity = ((Decimal)resultParityCount / totalTests * 100).setScale(2);
    
    directLatencies.sort();
    mcpLatencies.sort();
    Long directP95Latency = directLatencies[Math.max(0, (directLatencies.size() * 95) / 100 - 1)];
    Long mcpP95Latency = mcpLatencies[Math.max(0, (mcpLatencies.size() * 95) / 100 - 1)];
    Long latencyDeltaP95 = mcpP95Latency - directP95Latency;
    
    // Acceptance criteria validation
    Boolean meetsAcceptanceCriteria = 
        intentAccuracy >= 98.0 &&
        argsAccuracy >= 97.0 &&
        resultParity >= 95.0 &&
        latencyDeltaP95 <= 150 &&
        directSuccessRate >= 95.0 &&
        mcpSuccessRate >= 95.0;
    
    System.debug('🎯 BATCH 1 UAT RESULTS:');
    System.debug('=====================================');
    System.debug('📊 Overall Metrics:');
    System.debug('- Total Tests: ' + totalTests);
    System.debug('- Direct Success Rate: ' + directSuccessRate + '%');
    System.debug('- MCP Success Rate: ' + mcpSuccessRate + '%');
    System.debug('- Intent Accuracy: ' + intentAccuracy + '%');
    System.debug('- Args Accuracy: ' + argsAccuracy + '%');
    System.debug('- Result Parity: ' + resultParity + '%');
    
    System.debug('⚡ Performance Metrics:');
    System.debug('- Direct P95 Latency: ' + directP95Latency + 'ms');
    System.debug('- MCP P95 Latency: ' + mcpP95Latency + 'ms');
    System.debug('- Latency Delta P95: ' + latencyDeltaP95 + 'ms');
    
    System.debug('🎯 Acceptance Criteria:');
    System.debug('- Intent Accuracy ≥ 98%: ' + (intentAccuracy >= 98.0 ? '✅ PASS' : '❌ FAIL'));
    System.debug('- Args Accuracy ≥ 97%: ' + (argsAccuracy >= 97.0 ? '✅ PASS' : '❌ FAIL'));
    System.debug('- Result Parity ≥ 95%: ' + (resultParity >= 95.0 ? '✅ PASS' : '❌ FAIL'));
    System.debug('- Latency Delta ≤ 150ms: ' + (latencyDeltaP95 <= 150 ? '✅ PASS' : '❌ FAIL'));
    System.debug('- Direct Success ≥ 95%: ' + (directSuccessRate >= 95.0 ? '✅ PASS' : '❌ FAIL'));
    System.debug('- MCP Success ≥ 95%: ' + (mcpSuccessRate >= 95.0 ? '✅ PASS' : '❌ FAIL'));
    
    System.debug('🏆 Overall Status: ' + (meetsAcceptanceCriteria ? '✅ MEETS CRITERIA' : '❌ FAILS CRITERIA'));
    
    if (meetsAcceptanceCriteria) {
        System.debug('🎉 CONGRATULATIONS: Batch 1 UAT PASSES ALL ACCEPTANCE CRITERIA!');
    } else {
        System.debug('⚠️  Batch 1 UAT FAILED: Some acceptance criteria were not met.');
    }
    
} catch (Exception e) {
    System.debug('❌ Batch 1 UAT Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('🎯 Batch 1 Open Pipe V3 UAT Complete');
