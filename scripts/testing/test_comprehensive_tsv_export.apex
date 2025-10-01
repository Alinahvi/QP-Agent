// Comprehensive TSV Export Testing with Real Agent Response Simulation
// This script tests the complete TSV export functionality with realistic data

System.debug('🚀 COMPREHENSIVE TSV EXPORT TESTING STARTED');
System.debug('================================================');

// Test 1: Renewals Analysis Export
System.debug('📊 TEST 1: RENEWALS ANALYSIS EXPORT');
System.debug('-----------------------------------');

try {
    // Simulate real renewals analysis data as it would come from agent
    Map<String, Object> renewalsAnalysisData = new Map<String, Object>{
        'product_performance' => new List<Object>{
            new Map<String, Object>{
                'product' => 'Data Cloud',
                'totalValue' => 2500000.50,
                'opportunityCount' => 15,
                'avgDealSize' => 166666.70,
                'region' => 'AMER-ACC',
                'timeframe' => 'Current Quarter'
            },
            new Map<String, Object>{
                'product' => 'Einstein Analytics',
                'totalValue' => 1800000.00,
                'opportunityCount' => 12,
                'avgDealSize' => 150000.00,
                'region' => 'AMER-ACC',
                'timeframe' => 'Current Quarter'
            },
            new Map<String, Object>{
                'product' => 'Sales Cloud',
                'totalValue' => 3200000.25,
                'opportunityCount' => 20,
                'avgDealSize' => 160000.01,
                'region' => 'AMER-ACC',
                'timeframe' => 'Current Quarter'
            },
            new Map<String, Object>{
                'product' => 'Service Cloud',
                'totalValue' => 1500000.75,
                'opportunityCount' => 8,
                'avgDealSize' => 187500.09,
                'region' => 'AMER-ACC',
                'timeframe' => 'Current Quarter'
            },
            new Map<String, Object>{
                'product' => 'Marketing Cloud',
                'totalValue' => 950000.00,
                'opportunityCount' => 6,
                'avgDealSize' => 158333.33,
                'region' => 'AMER-ACC',
                'timeframe' => 'Current Quarter'
            }
        },
        'summary' => new Map<String, Object>{
            'totalValue' => 9950001.50,
            'totalOpportunities' => 61,
            'avgDealSize' => 163114.78,
            'topProduct' => 'Sales Cloud'
        }
    };
    
    // Store in memory context
    String sessionId = 'test-renewals-' + String.valueOf(System.now().getTime());
    ANAgentMemoryContext.storeAnalysisData(
        sessionId,
        'RENEWALS',
        renewalsAnalysisData,
        'Renewals Analysis: Top 5 products by value in AMER-ACC region for Current Quarter. Sales Cloud leads with $3.2M across 20 opportunities.',
        new Map<String, Object>{
            'region' => 'AMER-ACC',
            'timeframe' => 'Current Quarter',
            'analysisType' => 'product_performance',
            'testType' => 'comprehensive'
        }
    );
    
    System.debug('✅ Stored renewals analysis data for session: ' + sessionId);
    
    // Test direct Apex export
    ANAgentGenericTSVExportHandler.GenericTSVExportRequest request = 
        new ANAgentGenericTSVExportHandler.GenericTSVExportRequest();
    request.analysisTypeFilter = 'RENEWALS';
    request.customFileName = 'Renewals_AMER_ACC_Current_Quarter';
    request.includeMetadata = true;
    request.requestId = 'TEST-RENEWALS-001';
    
    List<ANAgentGenericTSVExportHandler.GenericTSVExportResponse> responses = 
        ANAgentGenericTSVExportHandler.exportAnyAnalysisAsTSV(
            new List<ANAgentGenericTSVExportHandler.GenericTSVExportRequest>{request}
        );
    
    if (!responses.isEmpty()) {
        ANAgentGenericTSVExportHandler.GenericTSVExportResponse response = responses[0];
        
        System.debug('📊 RENEWALS TSV EXPORT RESULTS:');
        System.debug('Success: ' + response.success);
        System.debug('Message: ' + response.message);
        System.debug('File Name: ' + response.fileName);
        System.debug('Record Count: ' + response.recordCount);
        System.debug('Analysis Type: ' + response.analysisType);
        System.debug('Download Link: ' + response.downloadLink);
        
        // Validate results
        System.assert(response.success, 'Renewals TSV export should succeed');
        System.assertEquals('RENEWALS', response.analysisType, 'Analysis type should be RENEWALS');
        System.assert(response.recordCount == 5, 'Should have 5 product records');
        System.assert(response.fileName.contains('Renewals_AMER_ACC_Current_Quarter'), 'File name should contain custom name');
        System.assertNotEquals(null, response.downloadLink, 'Download link should be provided');
        
        System.debug('✅ RENEWALS TSV EXPORT TEST PASSED');
    } else {
        System.debug('❌ No response received from renewals TSV export');
    }
    
} catch (Exception e) {
    System.debug('❌ RENEWALS TSV EXPORT TEST FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('');
System.debug('📊 TEST 2: OPEN PIPE ANALYSIS EXPORT');
System.debug('------------------------------------');

try {
    // Simulate real open pipe analysis data
    Map<String, Object> openPipeAnalysisData = new Map<String, Object>{
        'opportunity_data' => new List<Object>{
            new Map<String, Object>{
                'aeEmail' => 'john.doe@company.com',
                'learnerProfileId' => 'LP001',
                'product' => 'Data Cloud',
                'opportunityName' => 'Acme Corp Data Cloud Implementation',
                'stage' => '03 - Validating Benefits & Value',
                'stagnationDays' => 45,
                'amount' => 500000.00,
                'opportunityUrl' => 'https://company.lightning.force.com/lightning/r/Opportunity/006123456789/view',
                'aeName' => 'John Doe',
                'accountName' => 'Acme Corp',
                'region' => 'AMER-ACC'
            },
            new Map<String, Object>{
                'aeEmail' => 'jane.smith@company.com',
                'learnerProfileId' => 'LP002',
                'product' => 'Einstein Analytics',
                'opportunityName' => 'Tech Solutions Analytics Platform',
                'stage' => '02 - Qualifying',
                'stagnationDays' => 30,
                'amount' => 750000.00,
                'opportunityUrl' => 'https://company.lightning.force.com/lightning/r/Opportunity/006987654321/view',
                'aeName' => 'Jane Smith',
                'accountName' => 'Tech Solutions',
                'region' => 'AMER-ACC'
            },
            new Map<String, Object>{
                'aeEmail' => 'bob.wilson@company.com',
                'learnerProfileId' => 'LP003',
                'product' => 'Sales Cloud',
                'opportunityName' => 'Global Corp CRM Implementation',
                'stage' => '04 - Proposing',
                'stagnationDays' => 60,
                'amount' => 1200000.00,
                'opportunityUrl' => 'https://company.lightning.force.com/lightning/r/Opportunity/006555666777/view',
                'aeName' => 'Bob Wilson',
                'accountName' => 'Global Corp',
                'region' => 'AMER-ACC'
            },
            new Map<String, Object>{
                'aeEmail' => 'sarah.johnson@company.com',
                'learnerProfileId' => 'LP004',
                'product' => 'Service Cloud',
                'opportunityName' => 'Customer Service Transformation',
                'stage' => '03 - Validating Benefits & Value',
                'stagnationDays' => 35,
                'amount' => 900000.00,
                'opportunityUrl' => 'https://company.lightning.force.com/lightning/r/Opportunity/006111222333/view',
                'aeName' => 'Sarah Johnson',
                'accountName' => 'Service Corp',
                'region' => 'AMER-ACC'
            }
        },
        'summary' => new Map<String, Object>{
            'totalOpportunities' => 4,
            'totalValue' => 3350000.00,
            'avgStagnationDays' => 42.5,
            'stagnatingCount' => 3
        }
    };
    
    // Store in memory context
    String sessionId = 'test-openpipe-' + String.valueOf(System.now().getTime());
    ANAgentMemoryContext.storeAnalysisData(
        sessionId,
        'OPEN_PIPE',
        openPipeAnalysisData,
        'Open Pipe Analysis: 4 stagnating opportunities in AMER-ACC region. Total value $3.35M with average 42.5 days in current stage.',
        new Map<String, Object>{
            'region' => 'AMER-ACC',
            'analysisType' => 'stagnation',
            'testType' => 'comprehensive'
        }
    );
    
    System.debug('✅ Stored open pipe analysis data for session: ' + sessionId);
    
    // Test MCP integration
    ANAgentTSVExportViaMCP.MCPTSVExportRequest mcpRequest = 
        new ANAgentTSVExportViaMCP.MCPTSVExportRequest();
    mcpRequest.analysisType = 'OPEN_PIPE';
    mcpRequest.limitRecords = 4;
    mcpRequest.customFileName = 'OpenPipe_Stagnation_AMER_ACC';
    mcpRequest.requestId = 'TEST-OPENPIPE-001';
    
    List<ANAgentTSVExportViaMCP.MCPTSVExportResponse> mcpResponses = 
        ANAgentTSVExportViaMCP.exportAnalysisAsTSV(
            new List<ANAgentTSVExportViaMCP.MCPTSVExportRequest>{mcpRequest}
        );
    
    if (!mcpResponses.isEmpty()) {
        ANAgentTSVExportViaMCP.MCPTSVExportResponse mcpResponse = mcpResponses[0];
        
        System.debug('📊 OPEN PIPE MCP TSV EXPORT RESULTS:');
        System.debug('Success: ' + mcpResponse.success);
        System.debug('Message: ' + mcpResponse.message);
        System.debug('File Name: ' + mcpResponse.fileName);
        System.debug('Record Count: ' + mcpResponse.recordCount);
        System.debug('Analysis Type: ' + mcpResponse.analysisType);
        System.debug('Download URL: ' + mcpResponse.downloadUrl);
        
        // Validate results
        System.assert(mcpResponse.success, 'Open Pipe MCP TSV export should succeed');
        System.assertEquals('OPEN_PIPE', mcpResponse.analysisType, 'Analysis type should be OPEN_PIPE');
        System.assert(mcpResponse.recordCount == 4, 'Should have 4 opportunity records');
        System.assert(mcpResponse.fileName.contains('OpenPipe_Stagnation_AMER_ACC'), 'File name should contain custom name');
        System.assertNotEquals(null, mcpResponse.downloadUrl, 'Download URL should be provided');
        
        System.debug('✅ OPEN PIPE TSV EXPORT TEST PASSED');
    } else {
        System.debug('❌ No response received from open pipe TSV export');
    }
    
} catch (Exception e) {
    System.debug('❌ OPEN PIPE TSV EXPORT TEST FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('');
System.debug('📊 TEST 3: KPI ANALYSIS EXPORT');
System.debug('------------------------------');

try {
    // Simulate real KPI analysis data
    Map<String, Object> kpiAnalysisData = new Map<String, Object>{
        'ae_performance' => new List<Object>{
            new Map<String, Object>{
                'aeEmail' => 'john.doe@company.com',
                'learnerProfileId' => 'LP001',
                'ou' => 'AMER-ACC',
                'aeScore' => 4.2,
                'coverage' => 85.5,
                'timeframe' => 'Current Quarter',
                'aeName' => 'John Doe',
                'manager' => 'Jane Manager',
                'territory' => 'Enterprise West'
            },
            new Map<String, Object>{
                'aeEmail' => 'jane.smith@company.com',
                'learnerProfileId' => 'LP002',
                'ou' => 'AMER-ACC',
                'aeScore' => 3.8,
                'coverage' => 92.0,
                'timeframe' => 'Current Quarter',
                'aeName' => 'Jane Smith',
                'manager' => 'Bob Manager',
                'territory' => 'Enterprise East'
            },
            new Map<String, Object>{
                'aeEmail' => 'bob.wilson@company.com',
                'learnerProfileId' => 'LP003',
                'ou' => 'AMER-ACC',
                'aeScore' => 4.5,
                'coverage' => 78.3,
                'timeframe' => 'Current Quarter',
                'aeName' => 'Bob Wilson',
                'manager' => 'Sarah Manager',
                'territory' => 'Mid Market Central'
            },
            new Map<String, Object>{
                'aeEmail' => 'sarah.johnson@company.com',
                'learnerProfileId' => 'LP004',
                'ou' => 'AMER-ACC',
                'aeScore' => 4.0,
                'coverage' => 88.7,
                'timeframe' => 'Current Quarter',
                'aeName' => 'Sarah Johnson',
                'manager' => 'Mike Manager',
                'territory' => 'SMB North'
            },
            new Map<String, Object>{
                'aeEmail' => 'mike.brown@company.com',
                'learnerProfileId' => 'LP005',
                'ou' => 'AMER-ACC',
                'aeScore' => 3.5,
                'coverage' => 95.2,
                'timeframe' => 'Current Quarter',
                'aeName' => 'Mike Brown',
                'manager' => 'Lisa Manager',
                'territory' => 'SMB South'
            }
        },
        'summary' => new Map<String, Object>{
            'totalAEs' => 5,
            'avgScore' => 4.0,
            'avgCoverage' => 87.94,
            'topPerformer' => 'Bob Wilson'
        }
    };
    
    // Store in memory context
    String sessionId = 'test-kpi-' + String.valueOf(System.now().getTime());
    ANAgentMemoryContext.storeAnalysisData(
        sessionId,
        'KPIS',
        kpiAnalysisData,
        'KPI Analysis: 5 AEs in AMER-ACC region for Current Quarter. Average score 4.0 with 87.94% coverage. Top performer: Bob Wilson.',
        new Map<String, Object>{
            'region' => 'AMER-ACC',
            'timeframe' => 'Current Quarter',
            'analysisType' => 'ae_performance',
            'testType' => 'comprehensive'
        }
    );
    
    System.debug('✅ Stored KPI analysis data for session: ' + sessionId);
    
    // Test direct Apex export
    ANAgentGenericTSVExportHandler.GenericTSVExportRequest request = 
        new ANAgentGenericTSVExportHandler.GenericTSVExportRequest();
    request.analysisTypeFilter = 'KPIS';
    request.customFileName = 'KPI_AMER_ACC_Current_Quarter';
    request.includeMetadata = false; // Keep TSV clean
    request.requestId = 'TEST-KPI-001';
    
    List<ANAgentGenericTSVExportHandler.GenericTSVExportResponse> responses = 
        ANAgentGenericTSVExportHandler.exportAnyAnalysisAsTSV(
            new List<ANAgentGenericTSVExportHandler.GenericTSVExportRequest>{request}
        );
    
    if (!responses.isEmpty()) {
        ANAgentGenericTSVExportHandler.GenericTSVExportResponse response = responses[0];
        
        System.debug('📊 KPI TSV EXPORT RESULTS:');
        System.debug('Success: ' + response.success);
        System.debug('Message: ' + response.message);
        System.debug('File Name: ' + response.fileName);
        System.debug('Record Count: ' + response.recordCount);
        System.debug('Analysis Type: ' + response.analysisType);
        System.debug('Download Link: ' + response.downloadLink);
        
        // Validate results
        System.assert(response.success, 'KPI TSV export should succeed');
        System.assertEquals('KPIS', response.analysisType, 'Analysis type should be KPIS');
        System.assert(response.recordCount == 5, 'Should have 5 AE records');
        System.assert(response.fileName.contains('KPI_AMER_ACC_Current_Quarter'), 'File name should contain custom name');
        System.assertNotEquals(null, response.downloadLink, 'Download link should be provided');
        
        System.debug('✅ KPI TSV EXPORT TEST PASSED');
    } else {
        System.debug('❌ No response received from KPI TSV export');
    }
    
} catch (Exception e) {
    System.debug('❌ KPI TSV EXPORT TEST FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('');
System.debug('📊 TEST 4: SME ANALYSIS EXPORT');
System.debug('------------------------------');

try {
    // Simulate real SME analysis data
    Map<String, Object> smeAnalysisData = new Map<String, Object>{
        'sme_data' => new List<Object>{
            new Map<String, Object>{
                'smeName' => 'Dr. Sarah Johnson',
                'smeEmail' => 'sarah.johnson@company.com',
                'smeOu' => 'AMER-ACC',
                'productL2' => 'Data Cloud',
                'excellenceAcademy' => 'Data Cloud Expert',
                'totalAcv' => 5000000.00,
                'expertiseLevel' => 'Senior',
                'certifications' => 'Data Cloud Architect, Data Cloud Specialist'
            },
            new Map<String, Object>{
                'smeName' => 'John Smith',
                'smeEmail' => 'john.smith@company.com',
                'smeOu' => 'AMER-ACC',
                'productL2' => 'Einstein Analytics',
                'excellenceAcademy' => 'Analytics Expert',
                'totalAcv' => 3500000.00,
                'expertiseLevel' => 'Principal',
                'certifications' => 'Einstein Analytics Architect, Tableau Specialist'
            },
            new Map<String, Object>{
                'smeName' => 'Jane Wilson',
                'smeEmail' => 'jane.wilson@company.com',
                'smeOu' => 'AMER-ACC',
                'productL2' => 'Sales Cloud',
                'excellenceAcademy' => 'Sales Cloud Expert',
                'totalAcv' => 4200000.00,
                'expertiseLevel' => 'Senior',
                'certifications' => 'Sales Cloud Architect, CPQ Specialist'
            }
        },
        'summary' => new Map<String, Object>{
            'totalSMEs' => 3,
            'totalACV' => 12700000.00,
            'topProduct' => 'Data Cloud',
            'topSME' => 'Dr. Sarah Johnson'
        }
    };
    
    // Store in memory context
    String sessionId = 'test-sme-' + String.valueOf(System.now().getTime());
    ANAgentMemoryContext.storeAnalysisData(
        sessionId,
        'SME',
        smeAnalysisData,
        'SME Analysis: 3 subject matter experts in AMER-ACC region. Total ACV $12.7M. Top SME: Dr. Sarah Johnson (Data Cloud).',
        new Map<String, Object>{
            'region' => 'AMER-ACC',
            'analysisType' => 'sme_identification',
            'testType' => 'comprehensive'
        }
    );
    
    System.debug('✅ Stored SME analysis data for session: ' + sessionId);
    
    // Test MCP integration
    ANAgentTSVExportViaMCP.MCPTSVExportRequest mcpRequest = 
        new ANAgentTSVExportViaMCP.MCPTSVExportRequest();
    mcpRequest.analysisType = 'SME';
    mcpRequest.customFileName = 'SME_AMER_ACC_Experts';
    mcpRequest.requestId = 'TEST-SME-001';
    
    List<ANAgentTSVExportViaMCP.MCPTSVExportResponse> mcpResponses = 
        ANAgentTSVExportViaMCP.exportAnalysisAsTSV(
            new List<ANAgentTSVExportViaMCP.MCPTSVExportRequest>{mcpRequest}
        );
    
    if (!mcpResponses.isEmpty()) {
        ANAgentTSVExportViaMCP.MCPTSVExportResponse mcpResponse = mcpResponses[0];
        
        System.debug('📊 SME MCP TSV EXPORT RESULTS:');
        System.debug('Success: ' + mcpResponse.success);
        System.debug('Message: ' + mcpResponse.message);
        System.debug('File Name: ' + mcpResponse.fileName);
        System.debug('Record Count: ' + mcpResponse.recordCount);
        System.debug('Analysis Type: ' + mcpResponse.analysisType);
        System.debug('Download URL: ' + mcpResponse.downloadUrl);
        
        // Validate results
        System.assert(mcpResponse.success, 'SME MCP TSV export should succeed');
        System.assertEquals('SME', mcpResponse.analysisType, 'Analysis type should be SME');
        System.assert(mcpResponse.recordCount == 3, 'Should have 3 SME records');
        System.assert(mcpResponse.fileName.contains('SME_AMER_ACC_Experts'), 'File name should contain custom name');
        System.assertNotEquals(null, mcpResponse.downloadUrl, 'Download URL should be provided');
        
        System.debug('✅ SME TSV EXPORT TEST PASSED');
    } else {
        System.debug('❌ No response received from SME TSV export');
    }
    
} catch (Exception e) {
    System.debug('❌ SME TSV EXPORT TEST FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('');
System.debug('📊 TEST 5: ERROR SCENARIOS');
System.debug('---------------------------');

try {
    // Test 5a: No analysis data
    System.debug('Testing no analysis data scenario...');
    ANAgentGenericTSVExportHandler.GenericTSVExportRequest noDataRequest = 
        new ANAgentGenericTSVExportHandler.GenericTSVExportRequest();
    noDataRequest.requestId = 'TEST-NODATA-001';
    
    List<ANAgentGenericTSVExportHandler.GenericTSVExportResponse> noDataResponses = 
        ANAgentGenericTSVExportHandler.exportAnyAnalysisAsTSV(
            new List<ANAgentGenericTSVExportHandler.GenericTSVExportRequest>{noDataRequest}
        );
    
    if (!noDataResponses.isEmpty()) {
        ANAgentGenericTSVExportHandler.GenericTSVExportResponse noDataResponse = noDataResponses[0];
        System.debug('No data response: ' + noDataResponse.message);
        System.assert(!noDataResponse.success, 'Should fail when no data available');
        System.assert(noDataResponse.message.contains('No analysis data found'), 'Should indicate no data found');
        System.debug('✅ No data error handling test passed');
    }
    
    // Test 5b: Analysis type mismatch
    System.debug('Testing analysis type mismatch scenario...');
    ANAgentGenericTSVExportHandler.GenericTSVExportRequest mismatchRequest = 
        new ANAgentGenericTSVExportHandler.GenericTSVExportRequest();
    mismatchRequest.analysisTypeFilter = 'OPEN_PIPE'; // But we have RENEWALS data
    mismatchRequest.requestId = 'TEST-MISMATCH-001';
    
    List<ANAgentGenericTSVExportHandler.GenericTSVExportResponse> mismatchResponses = 
        ANAgentGenericTSVExportHandler.exportAnyAnalysisAsTSV(
            new List<ANAgentGenericTSVExportHandler.GenericTSVExportRequest>{mismatchRequest}
        );
    
    if (!mismatchResponses.isEmpty()) {
        ANAgentGenericTSVExportHandler.GenericTSVExportResponse mismatchResponse = mismatchResponses[0];
        System.debug('Mismatch response: ' + mismatchResponse.message);
        System.assert(!mismatchResponse.success, 'Should fail when type mismatch');
        System.assert(mismatchResponse.message.contains('No OPEN_PIPE analysis data found'), 'Should indicate type mismatch');
        System.debug('✅ Type mismatch error handling test passed');
    }
    
} catch (Exception e) {
    System.debug('❌ ERROR SCENARIOS TEST FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('');
System.debug('📊 TEST 6: MCP HELPER METHODS');
System.debug('-----------------------------');

try {
    // Test helper methods
    Boolean hasData = ANAgentTSVExportViaMCP.hasRecentAnalysisData();
    String recentType = ANAgentTSVExportViaMCP.getMostRecentAnalysisType();
    
    System.debug('Has Recent Data: ' + hasData);
    System.debug('Most Recent Type: ' + recentType);
    
    System.assert(hasData, 'Should have recent analysis data');
    System.assertNotEquals(null, recentType, 'Should have recent analysis type');
    
    System.debug('✅ MCP helper methods test passed');
    
} catch (Exception e) {
    System.debug('❌ MCP HELPER METHODS TEST FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('');
System.debug('🎉 COMPREHENSIVE TSV EXPORT TESTING COMPLETED');
System.debug('==============================================');
System.debug('All tests have been executed. Check the results above for any failures.');

