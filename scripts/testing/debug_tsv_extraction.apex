// Debug TSV Extraction Script
// This script debugs the TSV data extraction process

System.debug('🔍 DEBUGGING TSV EXTRACTION');
System.debug('============================');

try {
    // Create test renewals data
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
    
    String sessionId = 'debug-renewals-' + String.valueOf(System.now().getTime());
    ANAgentMemoryContext.storeAnalysisData(
        sessionId,
        'RENEWALS',
        renewalsData,
        'Debug renewals data',
        new Map<String, Object>{'testType' => 'debug'}
    );
    
    System.debug('✅ Stored renewals data for session: ' + sessionId);
    
    // Test analysis type detection
    Map<String, Object> analysisData = ANAgentMemoryContext.getMostRecentAnalysisData();
    System.debug('📊 Analysis Data Retrieved:');
    System.debug('Keys: ' + analysisData.keySet());
    System.debug('Analysis Type: ' + analysisData.get('analysisType'));
    
    // Test schema detection
    ANAgentTSVSchemaRegistry.AnalysisType analysisType = ANAgentTSVSchemaRegistry.detectAnalysisType(analysisData);
    System.debug('Detected Analysis Type: ' + analysisType);
    
    // Test schema retrieval
    List<ANAgentTSVSchemaRegistry.Column> schema = ANAgentTSVSchemaRegistry.schemaFor(analysisType);
    System.debug('Schema Columns:');
    for (ANAgentTSVSchemaRegistry.Column col : schema) {
        System.debug('- ' + col.header + ' (path: ' + col.path + ', format: ' + col.format + ')');
    }
    
    // Test data extraction
    Map<String, Object> detailedData = (Map<String, Object>) analysisData.get('analysisData');
    System.debug('Detailed Data Keys: ' + detailedData.keySet());
    
    List<Object> productData = (List<Object>) detailedData.get('product_performance');
    System.debug('Product Data Size: ' + (productData != null ? String.valueOf(productData.size()) : 'null'));
    
    if (productData != null) {
        for (Integer i = 0; i < productData.size(); i++) {
            Object item = productData[i];
            System.debug('Product ' + i + ': ' + item);
            if (item instanceof Map<String, Object>) {
                Map<String, Object> itemMap = (Map<String, Object>) item;
                System.debug('  Keys: ' + itemMap.keySet());
                for (String key : itemMap.keySet()) {
                    System.debug('  ' + key + ': ' + itemMap.get(key));
                }
            }
        }
    }
    
    // Test TSV export
    ANAgentGenericTSVExportHandler.GenericTSVExportRequest request = 
        new ANAgentGenericTSVExportHandler.GenericTSVExportRequest();
    request.analysisTypeFilter = 'RENEWALS';
    request.customFileName = 'Debug_Renewals_Export';
    request.includeMetadata = true;
    request.requestId = 'DEBUG-001';
    
    List<ANAgentGenericTSVExportHandler.GenericTSVExportResponse> responses = 
        ANAgentGenericTSVExportHandler.exportAnyAnalysisAsTSV(
            new List<ANAgentGenericTSVExportHandler.GenericTSVExportRequest>{request}
        );
    
    if (!responses.isEmpty()) {
        ANAgentGenericTSVExportHandler.GenericTSVExportResponse response = responses[0];
        
        System.debug('📊 TSV Export Results:');
        System.debug('Success: ' + response.success);
        System.debug('Message: ' + response.message);
        System.debug('Record Count: ' + response.recordCount);
        System.debug('Analysis Type: ' + response.analysisType);
        
        if (response.success) {
            // Get the actual TSV content
            ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion WHERE Id = :response.downloadLink.substringAfterLast('/') LIMIT 1];
            String tsvContent = cv.VersionData.toString();
            
            System.debug('📄 TSV Content:');
            System.debug('===============');
            System.debug(tsvContent);
            System.debug('===============');
            
            // Count lines
            String[] lines = tsvContent.split('\n');
            System.debug('Total Lines: ' + lines.size());
            for (Integer i = 0; i < lines.size(); i++) {
                System.debug('Line ' + i + ': ' + lines[i]);
            }
        }
    }
    
} catch (Exception e) {
    System.debug('❌ DEBUG FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
