// UAT Test: Open Pipe TSV Export
// Tests the complete flow from open pipe analysis to TSV export

System.debug('=== OPEN PIPE TSV EXPORT UAT TEST ===');

try {
    // Step 1: Simulate open pipe analysis data
    Map<String, Object> openPipeData = new Map<String, Object>{
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
            },
            new Map<String, Object>{
                'aeEmail' => 'bob.wilson@company.com',
                'learnerProfileId' => 'LP003',
                'product' => 'Sales Cloud',
                'opportunityName' => 'Global Corp CRM Implementation',
                'stage' => '04 - Proposing',
                'stagnationDays' => 60,
                'amount' => 1200000.00,
                'opportunityUrl' => 'https://company.lightning.force.com/lightning/r/Opportunity/006555666777/view'
            }
        }
    };
    
    // Store in memory context
    String sessionId = 'uat-openpipe-' + String.valueOf(System.now().getTime());
    ANAgentMemoryContext.storeAnalysisData(
        sessionId,
        'OPEN_PIPE',
        openPipeData,
        'UAT Open Pipe Analysis: Stagnating opportunities in AMER-ACC',
        new Map<String, Object>{
            'region' => 'AMER-ACC',
            'analysisType' => 'stagnation',
            'testType' => 'UAT'
        }
    );
    
    System.debug('✅ Stored open pipe analysis data for session: ' + sessionId);
    
    // Step 2: Export to TSV
    ANAgentGenericTSVExportHandler.GenericTSVExportRequest request = 
        new ANAgentGenericTSVExportHandler.GenericTSVExportRequest();
    request.analysisTypeFilter = 'OPEN_PIPE';
    request.customFileName = 'UAT_OpenPipe_Stagnation_Export';
    request.includeMetadata = false; // Keep TSV clean
    request.requestId = 'UAT-OPENPIPE-001';
    
    List<ANAgentGenericTSVExportHandler.GenericTSVExportResponse> responses = 
        ANAgentGenericTSVExportHandler.exportAnyAnalysisAsTSV(
            new List<ANAgentGenericTSVExportHandler.GenericTSVExportRequest>{request}
        );
    
    // Step 3: Validate results
    if (!responses.isEmpty()) {
        ANAgentGenericTSVExportHandler.GenericTSVExportResponse response = responses[0];
        
        System.debug('📊 TSV Export Results:');
        System.debug('Success: ' + response.success);
        System.debug('Message: ' + response.message);
        System.debug('File Name: ' + response.fileName);
        System.debug('Record Count: ' + response.recordCount);
        System.debug('Analysis Type: ' + response.analysisType);
        System.debug('Download Link: ' + response.downloadLink);
        
        // Assertions
        System.assert(response.success, 'TSV export should succeed');
        System.assert(response.recordCount == 3, 'Should have 3 opportunity records');
        System.assertEquals('OPEN_PIPE', response.analysisType, 'Analysis type should be OPEN_PIPE');
        System.assert(response.fileName.contains('UAT_OpenPipe_Stagnation_Export'), 'File name should contain custom name');
        System.assertNotEquals(null, response.downloadLink, 'Download link should be provided');
        
        System.debug('✅ OPEN PIPE TSV EXPORT UAT TEST PASSED');
        
    } else {
        System.debug('❌ No response received from TSV export');
    }
    
} catch (Exception e) {
    System.debug('❌ OPEN PIPE TSV EXPORT UAT TEST FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

