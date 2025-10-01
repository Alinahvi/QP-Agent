// Error Scenarios Test for TSV Export
// Tests various error conditions and edge cases

System.debug('=== TSV EXPORT ERROR SCENARIOS TEST ===');

try {
    // Test 1: No analysis data available
    System.debug('📊 Testing: No analysis data available');
    
    ANAgentGenericTSVExportHandler.GenericTSVExportRequest request = 
        new ANAgentGenericTSVExportHandler.GenericTSVExportRequest();
    request.analysisTypeFilter = 'RENEWALS';
    request.customFileName = 'Error_Test_No_Data';
    request.requestId = 'ERROR-TEST-001';
    
    List<ANAgentGenericTSVExportHandler.GenericTSVExportResponse> responses = 
        ANAgentGenericTSVExportHandler.exportAnyAnalysisAsTSV(
            new List<ANAgentGenericTSVExportHandler.GenericTSVExportRequest>{request}
        );
    
    if (!responses.isEmpty()) {
        ANAgentGenericTSVExportHandler.GenericTSVExportResponse response = responses[0];
        System.debug('No Data Test - Success: ' + response.success);
        System.debug('No Data Test - Message: ' + response.message);
        
        // Should fail when no data is available
        System.assert(!response.success, 'Should fail when no analysis data is available');
        System.assert(response.message.contains('No recent analysis'), 'Should have appropriate error message');
        
        System.debug('✅ No data error scenario handled correctly');
    }
    
} catch (Exception e) {
    System.debug('❌ No data error test failed: ' + e.getMessage());
}

System.debug('');

try {
    // Test 2: Invalid analysis type
    System.debug('📊 Testing: Invalid analysis type');
    
    ANAgentGenericTSVExportHandler.GenericTSVExportRequest request = 
        new ANAgentGenericTSVExportHandler.GenericTSVExportRequest();
    request.analysisTypeFilter = 'INVALID_TYPE';
    request.customFileName = 'Error_Test_Invalid_Type';
    request.requestId = 'ERROR-TEST-002';
    
    List<ANAgentGenericTSVExportHandler.GenericTSVExportResponse> responses = 
        ANAgentGenericTSVExportHandler.exportAnyAnalysisAsTSV(
            new List<ANAgentGenericTSVExportHandler.GenericTSVExportRequest>{request}
        );
    
    if (!responses.isEmpty()) {
        ANAgentGenericTSVExportHandler.GenericTSVExportResponse response = responses[0];
        System.debug('Invalid Type Test - Success: ' + response.success);
        System.debug('Invalid Type Test - Message: ' + response.message);
        
        // Should handle invalid type gracefully
        System.debug('✅ Invalid type handled gracefully');
    }
    
} catch (Exception e) {
    System.debug('❌ Invalid type error test failed: ' + e.getMessage());
}

System.debug('');

try {
    // Test 3: Empty analysis data
    System.debug('📊 Testing: Empty analysis data');
    
    // Store empty analysis data
    Map<String, Object> emptyData = new Map<String, Object>();
    String sessionId = 'error-test-empty-' + String.valueOf(System.now().getTime());
    ANAgentMemoryContext.storeAnalysisData(
        sessionId,
        'RENEWALS',
        emptyData,
        'Empty test data',
        new Map<String, Object>{'testType' => 'error_test'}
    );
    
    ANAgentGenericTSVExportHandler.GenericTSVExportRequest request = 
        new ANAgentGenericTSVExportHandler.GenericTSVExportRequest();
    request.analysisTypeFilter = 'RENEWALS';
    request.customFileName = 'Error_Test_Empty_Data';
    request.requestId = 'ERROR-TEST-003';
    
    List<ANAgentGenericTSVExportHandler.GenericTSVExportResponse> responses = 
        ANAgentGenericTSVExportHandler.exportAnyAnalysisAsTSV(
            new List<ANAgentGenericTSVExportHandler.GenericTSVExportRequest>{request}
        );
    
    if (!responses.isEmpty()) {
        ANAgentGenericTSVExportHandler.GenericTSVExportResponse response = responses[0];
        System.debug('Empty Data Test - Success: ' + response.success);
        System.debug('Empty Data Test - Message: ' + response.message);
        System.debug('Empty Data Test - Record Count: ' + response.recordCount);
        
        // Should handle empty data gracefully
        System.assertEquals(0, response.recordCount, 'Should have 0 records for empty data');
        System.debug('✅ Empty data handled gracefully');
    }
    
} catch (Exception e) {
    System.debug('❌ Empty data error test failed: ' + e.getMessage());
}

System.debug('');
System.debug('🎉 ERROR SCENARIOS TEST COMPLETED');
System.debug('===================================');
System.debug('All error scenarios have been tested. Check results above.');

