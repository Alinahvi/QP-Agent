// UAT Test: Renewals TSV Export
// Tests the complete flow from analysis to TSV export

System.debug('=== RENEWALS TSV EXPORT UAT TEST ===');

try {
    // Step 1: Simulate renewals analysis data
    Map<String, Object> renewalsData = new Map<String, Object>{
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
    
    // Store in memory context
    String sessionId = 'uat-renewals-' + String.valueOf(System.now().getTime());
    ANAgentMemoryContext.storeAnalysisData(
        sessionId,
        'RENEWALS',
        renewalsData,
        'UAT Renewals Analysis: Top 3 products by value in AMER-ACC',
        new Map<String, Object>{
            'region' => 'AMER-ACC',
            'timeframe' => 'Current Quarter',
            'testType' => 'UAT'
        }
    );
    
    System.debug('✅ Stored renewals analysis data for session: ' + sessionId);
    
    // Step 2: Export to TSV
    ANAgentGenericTSVExportHandler.GenericTSVExportRequest request = 
        new ANAgentGenericTSVExportHandler.GenericTSVExportRequest();
    request.analysisTypeFilter = 'RENEWALS';
    request.customFileName = 'UAT_Renewals_AMER_ACC_Export';
    request.includeMetadata = true;
    request.requestId = 'UAT-RENEWALS-001';
    
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
        System.assert(response.recordCount == 3, 'Should have 3 product records');
        System.assertEquals('RENEWALS', response.analysisType, 'Analysis type should be RENEWALS');
        System.assert(response.fileName.contains('UAT_Renewals_AMER_ACC_Export'), 'File name should contain custom name');
        System.assertNotEquals(null, response.downloadLink, 'Download link should be provided');
        
        System.debug('✅ RENEWALS TSV EXPORT UAT TEST PASSED');
        
    } else {
        System.debug('❌ No response received from TSV export');
    }
    
} catch (Exception e) {
    System.debug('❌ RENEWALS TSV EXPORT UAT TEST FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

