/**
 * @description Unit tests for ANAgentGenericTSVExportHandler
 * @author AI Assistant
 * @version 1.0
 */
@IsTest
public class ANAgentGenericTSVExportHandlerTest {
  
  @TestSetup
  static void setupTestData() {
    // Create test data for different analysis types
    // This will be used by individual test methods
  }
  
  @IsTest
  static void testRenewalsTSVExport() {
    // Test renewals data export
    Map<String, Object> testAnalysisData = createTestRenewalsData();
    
    ANAgentGenericTSVExportHandler.GenericTSVExportRequest request = 
      new ANAgentGenericTSVExportHandler.GenericTSVExportRequest();
    request.analysisTypeFilter = 'RENEWALS';
    request.customFileName = 'Test_Renewals_Export';
    request.includeMetadata = true;
    request.requestId = 'TEST-001';
    
    Test.startTest();
    List<ANAgentGenericTSVExportHandler.GenericTSVExportResponse> responses = 
      ANAgentGenericTSVExportHandler.exportAnyAnalysisAsTSV(new List<ANAgentGenericTSVExportHandler.GenericTSVExportRequest>{request});
    Test.stopTest();
    
    System.assertEquals(1, responses.size(), 'Should return one response');
    ANAgentGenericTSVExportHandler.GenericTSVExportResponse response = responses[0];
    
    System.assertEquals(true, response.success, 'Export should succeed');
    System.assertNotEquals(null, response.downloadLink, 'Download link should be provided');
    System.assert(response.fileName.contains('Test_Renewals_Export'), 'File name should contain custom name');
    System.assertEquals('RENEWALS', response.analysisType, 'Analysis type should be RENEWALS');
  }
  
  @IsTest
  static void testOpenPipeTSVExport() {
    // Test open pipe data export
    Map<String, Object> testAnalysisData = createTestOpenPipeData();
    
    ANAgentGenericTSVExportHandler.GenericTSVExportRequest request = 
      new ANAgentGenericTSVExportHandler.GenericTSVExportRequest();
    request.analysisTypeFilter = 'OPEN_PIPE';
    request.includeMetadata = false;
    request.requestId = 'TEST-002';
    
    Test.startTest();
    List<ANAgentGenericTSVExportHandler.GenericTSVExportResponse> responses = 
      ANAgentGenericTSVExportHandler.exportAnyAnalysisAsTSV(new List<ANAgentGenericTSVExportHandler.GenericTSVExportRequest>{request});
    Test.stopTest();
    
    System.assertEquals(1, responses.size(), 'Should return one response');
    ANAgentGenericTSVExportHandler.GenericTSVExportResponse response = responses[0];
    
    System.assertEquals(true, response.success, 'Export should succeed');
    System.assertNotEquals(null, response.downloadLink, 'Download link should be provided');
    System.assertEquals('OPEN_PIPE', response.analysisType, 'Analysis type should be OPEN_PIPE');
  }
  
  @IsTest
  static void testKPITSVExport() {
    // Test KPI data export
    Map<String, Object> testAnalysisData = createTestKPIData();
    
    ANAgentGenericTSVExportHandler.GenericTSVExportRequest request = 
      new ANAgentGenericTSVExportHandler.GenericTSVExportRequest();
    request.analysisTypeFilter = 'KPIS';
    request.requestId = 'TEST-003';
    
    Test.startTest();
    List<ANAgentGenericTSVExportHandler.GenericTSVExportResponse> responses = 
      ANAgentGenericTSVExportHandler.exportAnyAnalysisAsTSV(new List<ANAgentGenericTSVExportHandler.GenericTSVExportRequest>{request});
    Test.stopTest();
    
    System.assertEquals(1, responses.size(), 'Should return one response');
    ANAgentGenericTSVExportHandler.GenericTSVExportResponse response = responses[0];
    
    System.assertEquals(true, response.success, 'Export should succeed');
    System.assertEquals('KPIS', response.analysisType, 'Analysis type should be KPIS');
  }
  
  @IsTest
  static void testNoAnalysisDataError() {
    // Test error when no analysis data is available
    ANAgentGenericTSVExportHandler.GenericTSVExportRequest request = 
      new ANAgentGenericTSVExportHandler.GenericTSVExportRequest();
    request.requestId = 'TEST-004';
    
    Test.startTest();
    List<ANAgentGenericTSVExportHandler.GenericTSVExportResponse> responses = 
      ANAgentGenericTSVExportHandler.exportAnyAnalysisAsTSV(new List<ANAgentGenericTSVExportHandler.GenericTSVExportRequest>{request});
    Test.stopTest();
    
    System.assertEquals(1, responses.size(), 'Should return one response');
    ANAgentGenericTSVExportHandler.GenericTSVExportResponse response = responses[0];
    
    System.assertEquals(false, response.success, 'Export should fail');
    System.assert(response.message.contains('No analysis data found'), 'Should indicate no data found');
  }
  
  @IsTest
  static void testAnalysisTypeMismatch() {
    // Test error when analysis type doesn't match
    Map<String, Object> testAnalysisData = createTestRenewalsData();
    
    ANAgentGenericTSVExportHandler.GenericTSVExportRequest request = 
      new ANAgentGenericTSVExportHandler.GenericTSVExportRequest();
    request.analysisTypeFilter = 'OPEN_PIPE'; // Mismatch with renewals data
    request.requestId = 'TEST-005';
    
    Test.startTest();
    List<ANAgentGenericTSVExportHandler.GenericTSVExportResponse> responses = 
      ANAgentGenericTSVExportHandler.exportAnyAnalysisAsTSV(new List<ANAgentGenericTSVExportHandler.GenericTSVExportRequest>{request});
    Test.stopTest();
    
    System.assertEquals(1, responses.size(), 'Should return one response');
    ANAgentGenericTSVExportHandler.GenericTSVExportResponse response = responses[0];
    
    System.assertEquals(false, response.success, 'Export should fail');
    System.assert(response.message.contains('No OPEN_PIPE analysis data found'), 'Should indicate type mismatch');
  }
  
  @IsTest
  static void testTSVEscaping() {
    // Test TSV escaping for special characters
    Map<String, Object> testData = new Map<String, Object>{
      'analysisType' => 'RENEWALS',
      'sessionId' => 'test-session-123',
      'timestamp' => '2024-01-15 10:30:00',
      'analysisData' => new Map<String, Object>{
        'product_performance' => new List<Object>{
          new Map<String, Object>{
            'product' => 'Data Cloud with "quotes" and\ttabs',
            'totalValue' => 2500000.50,
            'opportunityCount' => 15,
            'avgDealSize' => 166666.70
          }
        }
      }
    };
    
    // Store test data in memory
    ANAgentMemoryContext.storeAnalysisData(
      'test-session-123',
      'RENEWALS',
      (Map<String, Object>) testData.get('analysisData'),
      'Test insights data',
      new Map<String, Object>{'test' => 'metadata'}
    );
    
    ANAgentGenericTSVExportHandler.GenericTSVExportRequest request = 
      new ANAgentGenericTSVExportHandler.GenericTSVExportRequest();
    request.analysisTypeFilter = 'RENEWALS';
    request.requestId = 'TEST-006';
    
    Test.startTest();
    List<ANAgentGenericTSVExportHandler.GenericTSVExportResponse> responses = 
      ANAgentGenericTSVExportHandler.exportAnyAnalysisAsTSV(new List<ANAgentGenericTSVExportHandler.GenericTSVExportRequest>{request});
    Test.stopTest();
    
    System.assertEquals(1, responses.size(), 'Should return one response');
    ANAgentGenericTSVExportHandler.GenericTSVExportResponse response = responses[0];
    
    System.assertEquals(true, response.success, 'Export should succeed');
    System.assertNotEquals(null, response.downloadLink, 'Download link should be provided');
  }
  
  @IsTest
  static void testMCPIntegration() {
    // Test MCP integration class
    Map<String, Object> testAnalysisData = createTestRenewalsData();
    
    ANAgentTSVExportViaMCP.MCPTSVExportRequest request = 
      new ANAgentTSVExportViaMCP.MCPTSVExportRequest();
    request.analysisType = 'RENEWALS';
    request.limitRecords = 5;
    request.customFileName = 'MCP_Test_Export';
    request.requestId = 'MCP-TEST-001';
    
    Test.startTest();
    List<ANAgentTSVExportViaMCP.MCPTSVExportResponse> responses = 
      ANAgentTSVExportViaMCP.exportAnalysisAsTSV(new List<ANAgentTSVExportViaMCP.MCPTSVExportRequest>{request});
    Test.stopTest();
    
    System.assertEquals(1, responses.size(), 'Should return one response');
    ANAgentTSVExportViaMCP.MCPTSVExportResponse response = responses[0];
    
    System.assertEquals(true, response.success, 'MCP export should succeed');
    System.assertNotEquals(null, response.downloadUrl, 'Download URL should be provided');
    System.assertEquals('RENEWALS', response.analysisType, 'Analysis type should be RENEWALS');
  }
  
  // Helper methods to create test data
  
  private static Map<String, Object> createTestRenewalsData() {
    Map<String, Object> analysisData = new Map<String, Object>{
      'analysisType' => 'RENEWALS',
      'sessionId' => 'test-session-renewals',
      'timestamp' => '2024-01-15 10:30:00',
      'analysisData' => new Map<String, Object>{
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
          }
        }
      }
    };
    
    // Store in memory context
    ANAgentMemoryContext.storeAnalysisData(
      'test-session-renewals',
      'RENEWALS',
      (Map<String, Object>) analysisData.get('analysisData'),
      'Test renewals insights',
      new Map<String, Object>{'test' => 'metadata'}
    );
    
    return analysisData;
  }
  
  private static Map<String, Object> createTestOpenPipeData() {
    Map<String, Object> analysisData = new Map<String, Object>{
      'analysisType' => 'OPEN_PIPE',
      'sessionId' => 'test-session-openpipe',
      'timestamp' => '2024-01-15 10:30:00',
      'analysisData' => new Map<String, Object>{
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
      }
    };
    
    // Store in memory context
    ANAgentMemoryContext.storeAnalysisData(
      'test-session-openpipe',
      'OPEN_PIPE',
      (Map<String, Object>) analysisData.get('analysisData'),
      'Test open pipe insights',
      new Map<String, Object>{'test' => 'metadata'}
    );
    
    return analysisData;
  }
  
  private static Map<String, Object> createTestKPIData() {
    Map<String, Object> analysisData = new Map<String, Object>{
      'analysisType' => 'KPIS',
      'sessionId' => 'test-session-kpi',
      'timestamp' => '2024-01-15 10:30:00',
      'analysisData' => new Map<String, Object>{
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
          }
        }
      }
    };
    
    // Store in memory context
    ANAgentMemoryContext.storeAnalysisData(
      'test-session-kpi',
      'KPIS',
      (Map<String, Object>) analysisData.get('analysisData'),
      'Test KPI insights',
      new Map<String, Object>{'test' => 'metadata'}
    );
    
    return analysisData;
  }
}

