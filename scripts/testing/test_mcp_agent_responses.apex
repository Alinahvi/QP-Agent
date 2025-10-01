// MCP Agent Response Testing Script
// This script simulates real agent responses and tests MCP integration

System.debug('🤖 MCP AGENT RESPONSE TESTING STARTED');
System.debug('======================================');

try {
    // Simulate Agent Scenario 1: User asks for renewals analysis, then exports to TSV
    System.debug('📊 SCENARIO 1: RENEWALS ANALYSIS + TSV EXPORT');
    System.debug('----------------------------------------------');
    
    // Step 1: Simulate agent running renewals analysis
    Map<String, Object> renewalsAnalysis = new Map<String, Object>{
        'product_performance' => new List<Object>{
            new Map<String, Object>{
                'product' => 'Data Cloud',
                'totalValue' => 2500000.50,
                'opportunityCount' => 15,
                'avgDealSize' => 166666.70
            },
            new Map<String, Object>{
                'product' => 'Einstein Analytics',
                'totalValue' => 1800000.00,
                'opportunityCount' => 12,
                'avgDealSize' => 150000.00
            },
            new Map<String, Object>{
                'product' => 'Sales Cloud',
                'totalValue' => 3200000.25,
                'opportunityCount' => 20,
                'avgDealSize' => 160000.01
            }
        }
    };
    
    String sessionId = 'agent-renewals-' + String.valueOf(System.now().getTime());
    ANAgentMemoryContext.storeAnalysisData(
        sessionId,
        'RENEWALS',
        renewalsAnalysis,
        'Renewals Analysis: Top 3 products by value in AMER-ACC region. Sales Cloud leads with $3.2M across 20 opportunities, followed by Data Cloud at $2.5M (15 opps) and Einstein Analytics at $1.8M (12 opps).',
        new Map<String, Object>{
            'region' => 'AMER-ACC',
            'timeframe' => 'Current Quarter',
            'analysisType' => 'product_performance'
        }
    );
    
    System.debug('✅ Agent stored renewals analysis data');
    
    // Step 2: Simulate user asking for TSV export
    System.debug('User: "export the renewals data to TSV"');
    
    // Step 3: MCP processes the request and calls TSV export
    ANAgentTSVExportViaMCP.MCPTSVExportRequest mcpRequest = 
        new ANAgentTSVExportViaMCP.MCPTSVExportRequest();
    mcpRequest.analysisType = 'RENEWALS';
    mcpRequest.customFileName = 'Renewals_AMER_ACC_Export';
    mcpRequest.requestId = 'AGENT-RENEWALS-001';
    
    List<ANAgentTSVExportViaMCP.MCPTSVExportResponse> mcpResponses = 
        ANAgentTSVExportViaMCP.exportAnalysisAsTSV(
            new List<ANAgentTSVExportViaMCP.MCPTSVExportRequest>{mcpRequest}
        );
    
    if (!mcpResponses.isEmpty()) {
        ANAgentTSVExportViaMCP.MCPTSVExportResponse mcpResponse = mcpResponses[0];
        
        System.debug('🤖 Agent Response:');
        System.debug('Success: ' + mcpResponse.success);
        System.debug('Message: ' + mcpResponse.message);
        System.debug('File Name: ' + mcpResponse.fileName);
        System.debug('Record Count: ' + mcpResponse.recordCount);
        System.debug('Download URL: ' + mcpResponse.downloadUrl);
        
        // Validate agent response
        System.assert(mcpResponse.success, 'Agent should successfully export renewals data');
        System.assertEquals('RENEWALS', mcpResponse.analysisType, 'Agent should identify RENEWALS analysis type');
        System.assert(mcpResponse.recordCount == 3, 'Agent should export 3 product records');
        System.assert(mcpResponse.fileName.contains('Renewals_AMER_ACC_Export'), 'Agent should use custom file name');
        System.assertNotEquals(null, mcpResponse.downloadUrl, 'Agent should provide download URL');
        
        System.debug('✅ SCENARIO 1 PASSED: Agent successfully exported renewals data to TSV');
    }
    
} catch (Exception e) {
    System.debug('❌ SCENARIO 1 FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('');
System.debug('📊 SCENARIO 2: OPEN PIPE ANALYSIS + TSV EXPORT');
System.debug('----------------------------------------------');

try {
    // Simulate Agent Scenario 2: User asks for open pipe analysis, then exports to TSV
    Map<String, Object> openPipeAnalysis = new Map<String, Object>{
        'opportunity_data' => new List<Object>{
            new Map<String, Object>{
                'aeEmail' => 'john.doe@company.com',
                'learnerProfileId' => 'LP001',
                'product' => 'Data Cloud',
                'opportunityName' => 'Acme Corp Data Cloud Implementation',
                'stage' => '03 - Validating Benefits & Value',
                'stagnationDays' => 45,
                'amount' => 500000.00,
                'opportunityUrl' => 'https://company.lightning.force.com/lightning/r/Opportunity/006123456789/view'
            },
            new Map<String, Object>{
                'aeEmail' => 'jane.smith@company.com',
                'learnerProfileId' => 'LP002',
                'product' => 'Einstein Analytics',
                'opportunityName' => 'Tech Solutions Analytics Platform',
                'stage' => '02 - Qualifying',
                'stagnationDays' => 30,
                'amount' => 750000.00,
                'opportunityUrl' => 'https://company.lightning.force.com/lightning/r/Opportunity/006987654321/view'
            }
        }
    };
    
    String sessionId = 'agent-openpipe-' + String.valueOf(System.now().getTime());
    ANAgentMemoryContext.storeAnalysisData(
        sessionId,
        'OPEN_PIPE',
        openPipeAnalysis,
        'Open Pipe Analysis: 2 stagnating opportunities in AMER-ACC region. Total value $1.25M with average 37.5 days in current stage. John Doe has Data Cloud opportunity at $500K (45 days), Jane Smith has Einstein Analytics at $750K (30 days).',
        new Map<String, Object>{
            'region' => 'AMER-ACC',
            'analysisType' => 'stagnation',
            'timeframe' => 'Current Quarter'
        }
    );
    
    System.debug('✅ Agent stored open pipe analysis data');
    
    // Simulate user asking for TSV export
    System.debug('User: "download the open pipe data as TSV"');
    
    // MCP processes the request
    ANAgentTSVExportViaMCP.MCPTSVExportRequest mcpRequest = 
        new ANAgentTSVExportViaMCP.MCPTSVExportRequest();
    mcpRequest.analysisType = 'OPEN_PIPE';
    mcpRequest.limitRecords = 2;
    mcpRequest.customFileName = 'OpenPipe_Stagnation_Export';
    mcpRequest.requestId = 'AGENT-OPENPIPE-001';
    
    List<ANAgentTSVExportViaMCP.MCPTSVExportResponse> mcpResponses = 
        ANAgentTSVExportViaMCP.exportAnalysisAsTSV(
            new List<ANAgentTSVExportViaMCP.MCPTSVExportRequest>{mcpRequest}
        );
    
    if (!mcpResponses.isEmpty()) {
        ANAgentTSVExportViaMCP.MCPTSVExportResponse mcpResponse = mcpResponses[0];
        
        System.debug('🤖 Agent Response:');
        System.debug('Success: ' + mcpResponse.success);
        System.debug('Message: ' + mcpResponse.message);
        System.debug('File Name: ' + mcpResponse.fileName);
        System.debug('Record Count: ' + mcpResponse.recordCount);
        System.debug('Download URL: ' + mcpResponse.downloadUrl);
        
        // Validate agent response
        System.assert(mcpResponse.success, 'Agent should successfully export open pipe data');
        System.assertEquals('OPEN_PIPE', mcpResponse.analysisType, 'Agent should identify OPEN_PIPE analysis type');
        System.assert(mcpResponse.recordCount == 2, 'Agent should export 2 opportunity records');
        System.assert(mcpResponse.fileName.contains('OpenPipe_Stagnation_Export'), 'Agent should use custom file name');
        System.assertNotEquals(null, mcpResponse.downloadUrl, 'Agent should provide download URL');
        
        System.debug('✅ SCENARIO 2 PASSED: Agent successfully exported open pipe data to TSV');
    }
    
} catch (Exception e) {
    System.debug('❌ SCENARIO 2 FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('');
System.debug('📊 SCENARIO 3: KPI ANALYSIS + TSV EXPORT');
System.debug('----------------------------------------');

try {
    // Simulate Agent Scenario 3: User asks for KPI analysis, then exports to TSV
    Map<String, Object> kpiAnalysis = new Map<String, Object>{
        'ae_performance' => new List<Object>{
            new Map<String, Object>{
                'aeEmail' => 'john.doe@company.com',
                'learnerProfileId' => 'LP001',
                'ou' => 'AMER-ACC',
                'aeScore' => 4.2,
                'coverage' => 85.5,
                'timeframe' => 'Current Quarter'
            },
            new Map<String, Object>{
                'aeEmail' => 'jane.smith@company.com',
                'learnerProfileId' => 'LP002',
                'ou' => 'AMER-ACC',
                'aeScore' => 3.8,
                'coverage' => 92.0,
                'timeframe' => 'Current Quarter'
            },
            new Map<String, Object>{
                'aeEmail' => 'bob.wilson@company.com',
                'learnerProfileId' => 'LP003',
                'ou' => 'AMER-ACC',
                'aeScore' => 4.5,
                'coverage' => 78.3,
                'timeframe' => 'Current Quarter'
            }
        }
    };
    
    String sessionId = 'agent-kpi-' + String.valueOf(System.now().getTime());
    ANAgentMemoryContext.storeAnalysisData(
        sessionId,
        'KPIS',
        kpiAnalysis,
        'KPI Analysis: 3 AEs in AMER-ACC region for Current Quarter. Average score 4.17 with 85.27% coverage. Top performer: Bob Wilson (4.5 score), followed by John Doe (4.2) and Jane Smith (3.8).',
        new Map<String, Object>{
            'region' => 'AMER-ACC',
            'timeframe' => 'Current Quarter',
            'analysisType' => 'ae_performance'
        }
    );
    
    System.debug('✅ Agent stored KPI analysis data');
    
    // Simulate user asking for TSV export
    System.debug('User: "export the KPI data to TSV"');
    
    // MCP processes the request
    ANAgentTSVExportViaMCP.MCPTSVExportRequest mcpRequest = 
        new ANAgentTSVExportViaMCP.MCPTSVExportRequest();
    mcpRequest.analysisType = 'KPIS';
    mcpRequest.customFileName = 'KPI_AMER_ACC_Current_Quarter';
    mcpRequest.requestId = 'AGENT-KPI-001';
    
    List<ANAgentTSVExportViaMCP.MCPTSVExportResponse> mcpResponses = 
        ANAgentTSVExportViaMCP.exportAnalysisAsTSV(
            new List<ANAgentTSVExportViaMCP.MCPTSVExportRequest>{mcpRequest}
        );
    
    if (!mcpResponses.isEmpty()) {
        ANAgentTSVExportViaMCP.MCPTSVExportResponse mcpResponse = mcpResponses[0];
        
        System.debug('🤖 Agent Response:');
        System.debug('Success: ' + mcpResponse.success);
        System.debug('Message: ' + mcpResponse.message);
        System.debug('File Name: ' + mcpResponse.fileName);
        System.debug('Record Count: ' + mcpResponse.recordCount);
        System.debug('Download URL: ' + mcpResponse.downloadUrl);
        
        // Validate agent response
        System.assert(mcpResponse.success, 'Agent should successfully export KPI data');
        System.assertEquals('KPIS', mcpResponse.analysisType, 'Agent should identify KPIS analysis type');
        System.assert(mcpResponse.recordCount == 3, 'Agent should export 3 AE records');
        System.assert(mcpResponse.fileName.contains('KPI_AMER_ACC_Current_Quarter'), 'Agent should use custom file name');
        System.assertNotEquals(null, mcpResponse.downloadUrl, 'Agent should provide download URL');
        
        System.debug('✅ SCENARIO 3 PASSED: Agent successfully exported KPI data to TSV');
    }
    
} catch (Exception e) {
    System.debug('❌ SCENARIO 3 FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('');
System.debug('📊 SCENARIO 4: ERROR HANDLING - NO DATA');
System.debug('---------------------------------------');

try {
    // Simulate Agent Scenario 4: User asks for TSV export without running analysis
    System.debug('User: "export the data to TSV"');
    System.debug('Agent: "I need to run an analysis first..."');
    
    // Clear any existing data
    ANAgentMemoryContext.clearAnalysisData('any-session');
    
    // MCP processes the request
    ANAgentTSVExportViaMCP.MCPTSVExportRequest mcpRequest = 
        new ANAgentTSVExportViaMCP.MCPTSVExportRequest();
    mcpRequest.requestId = 'AGENT-ERROR-001';
    
    List<ANAgentTSVExportViaMCP.MCPTSVExportResponse> mcpResponses = 
        ANAgentTSVExportViaMCP.exportAnalysisAsTSV(
            new List<ANAgentTSVExportViaMCP.MCPTSVExportRequest>{mcpRequest}
        );
    
    if (!mcpResponses.isEmpty()) {
        ANAgentTSVExportViaMCP.MCPTSVExportResponse mcpResponse = mcpResponses[0];
        
        System.debug('🤖 Agent Error Response:');
        System.debug('Success: ' + mcpResponse.success);
        System.debug('Message: ' + mcpResponse.message);
        
        // Validate error handling
        System.assert(!mcpResponse.success, 'Agent should fail when no data available');
        System.assert(mcpResponse.message.contains('No analysis data found'), 'Agent should indicate no data found');
        
        System.debug('✅ SCENARIO 4 PASSED: Agent properly handles no data error');
    }
    
} catch (Exception e) {
    System.debug('❌ SCENARIO 4 FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('');
System.debug('📊 SCENARIO 5: MCP HELPER METHODS');
System.debug('--------------------------------');

try {
    // Test MCP helper methods
    System.debug('Testing MCP helper methods...');
    
    Boolean hasData = ANAgentTSVExportViaMCP.hasRecentAnalysisData();
    String recentType = ANAgentTSVExportViaMCP.getMostRecentAnalysisType();
    
    System.debug('Has Recent Data: ' + hasData);
    System.debug('Most Recent Type: ' + recentType);
    
    // Should have data from previous scenarios
    System.assert(hasData, 'Should have recent analysis data from previous scenarios');
    System.assertNotEquals(null, recentType, 'Should have recent analysis type');
    
    System.debug('✅ SCENARIO 5 PASSED: MCP helper methods work correctly');
    
} catch (Exception e) {
    System.debug('❌ SCENARIO 5 FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('');
System.debug('🎉 MCP AGENT RESPONSE TESTING COMPLETED');
System.debug('=======================================');
System.debug('All agent response scenarios have been tested. Check the results above for any failures.');

