// UAT Test: MCP TSV Integration
// Tests the MCP integration for TSV export

System.debug('=== MCP TSV INTEGRATION UAT TEST ===');

try {
    // Step 1: Simulate KPI analysis data
    Map<String, Object> kpiData = new Map<String, Object>{
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
    
    // Store in memory context
    String sessionId = 'uat-mcp-kpi-' + String.valueOf(System.now().getTime());
    ANAgentMemoryContext.storeAnalysisData(
        sessionId,
        'KPIS',
        kpiData,
        'UAT KPI Analysis: AE performance in AMER-ACC',
        new Map<String, Object>{
            'region' => 'AMER-ACC',
            'timeframe' => 'Current Quarter',
            'testType' => 'UAT-MCP'
        }
    );
    
    System.debug('✅ Stored KPI analysis data for session: ' + sessionId);
    
    // Step 2: Test MCP integration
    ANAgentTSVExportViaMCP.MCPTSVExportRequest mcpRequest = 
        new ANAgentTSVExportViaMCP.MCPTSVExportRequest();
    mcpRequest.analysisType = 'KPIS';
    mcpRequest.limitRecords = 2; // Test record limiting
    mcpRequest.customFileName = 'UAT_MCP_KPI_Export';
    mcpRequest.requestId = 'UAT-MCP-001';
    
    List<ANAgentTSVExportViaMCP.MCPTSVExportResponse> mcpResponses = 
        ANAgentTSVExportViaMCP.exportAnalysisAsTSV(
            new List<ANAgentTSVExportViaMCP.MCPTSVExportRequest>{mcpRequest}
        );
    
    // Step 3: Validate MCP results
    if (!mcpResponses.isEmpty()) {
        ANAgentTSVExportViaMCP.MCPTSVExportResponse mcpResponse = mcpResponses[0];
        
        System.debug('📊 MCP TSV Export Results:');
        System.debug('Success: ' + mcpResponse.success);
        System.debug('Message: ' + mcpResponse.message);
        System.debug('File Name: ' + mcpResponse.fileName);
        System.debug('Record Count: ' + mcpResponse.recordCount);
        System.debug('Analysis Type: ' + mcpResponse.analysisType);
        System.debug('Download URL: ' + mcpResponse.downloadUrl);
        
        // Assertions
        System.assert(mcpResponse.success, 'MCP TSV export should succeed');
        System.assertEquals('KPIS', mcpResponse.analysisType, 'Analysis type should be KPIS');
        System.assert(mcpResponse.fileName.contains('UAT_MCP_KPI_Export'), 'File name should contain custom name');
        System.assertNotEquals(null, mcpResponse.downloadUrl, 'Download URL should be provided');
        
        System.debug('✅ MCP TSV INTEGRATION UAT TEST PASSED');
        
    } else {
        System.debug('❌ No response received from MCP TSV export');
    }
    
    // Step 4: Test helper methods
    Boolean hasData = ANAgentTSVExportViaMCP.hasRecentAnalysisData();
    String recentType = ANAgentTSVExportViaMCP.getMostRecentAnalysisType();
    
    System.debug('📊 MCP Helper Methods:');
    System.debug('Has Recent Data: ' + hasData);
    System.debug('Most Recent Type: ' + recentType);
    
    System.assert(hasData, 'Should have recent analysis data');
    System.assertEquals('KPIS', recentType, 'Most recent type should be KPIS');
    
    System.debug('✅ MCP HELPER METHODS UAT TEST PASSED');
    
} catch (Exception e) {
    System.debug('❌ MCP TSV INTEGRATION UAT TEST FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

