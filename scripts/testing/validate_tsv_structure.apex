// TSV Structure Validation Script
// This script validates the actual TSV file structure and content

System.debug('🔍 TSV STRUCTURE VALIDATION STARTED');
System.debug('====================================');

try {
    // Test 1: Validate Renewals TSV Structure
    System.debug('📊 VALIDATING RENEWALS TSV STRUCTURE');
    System.debug('------------------------------------');
    
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
            }
        }
    };
    
    String sessionId = 'validate-renewals-' + String.valueOf(System.now().getTime());
    ANAgentMemoryContext.storeAnalysisData(
        sessionId,
        'RENEWALS',
        renewalsData,
        'Test renewals data for structure validation',
        new Map<String, Object>{'testType' => 'structure_validation'}
    );
    
    // Export to TSV
    ANAgentGenericTSVExportHandler.GenericTSVExportRequest request = 
        new ANAgentGenericTSVExportHandler.GenericTSVExportRequest();
    request.analysisTypeFilter = 'RENEWALS';
    request.customFileName = 'Structure_Validation_Renewals';
    request.includeMetadata = true;
    request.requestId = 'VALIDATE-RENEWALS-001';
    
    List<ANAgentGenericTSVExportHandler.GenericTSVExportResponse> responses = 
        ANAgentGenericTSVExportHandler.exportAnyAnalysisAsTSV(
            new List<ANAgentGenericTSVExportHandler.GenericTSVExportRequest>{request}
        );
    
    if (!responses.isEmpty()) {
        ANAgentGenericTSVExportHandler.GenericTSVExportResponse response = responses[0];
        
        if (response.success) {
            // Get the actual TSV content from the file
            // Extract ContentDocumentId from the download URL
            String contentDocumentId = response.downloadLink.substringAfterLast('/');
            ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId LIMIT 1];
            String tsvContent = cv.VersionData.toString();
            
            System.debug('📄 RENEWALS TSV CONTENT:');
            System.debug('========================');
            System.debug(tsvContent);
            System.debug('========================');
            
            // Validate TSV structure
            String[] lines = tsvContent.split('\n');
            
            // Check metadata section
            Boolean hasMetadata = false;
            Boolean hasDataSection = false;
            Integer dataLineCount = 0;
            
            for (String line : lines) {
                if (line.startsWith('# Analysis Export Metadata')) {
                    hasMetadata = true;
                    System.debug('✅ Found metadata section');
                } else if (line.startsWith('Product\tTotal_Value\tOpportunity_Count\tAvg_Deal_Size')) {
                    hasDataSection = true;
                    System.debug('✅ Found data header row');
                } else if (!line.startsWith('#') && !line.startsWith('Product\t') && line.trim() != '') {
                    dataLineCount++;
                    System.debug('Data row ' + dataLineCount + ': ' + line);
                }
            }
            
            // Validate structure
            System.assert(hasMetadata, 'Should have metadata section');
            System.assert(hasDataSection, 'Should have data header row');
            System.assertEquals(2, dataLineCount, 'Should have 2 data rows');
            
            // Validate specific data content
            Boolean foundDataCloud = false;
            Boolean foundEinstein = false;
            
            for (String line : lines) {
                if (line.contains('Data Cloud') && line.contains('2500000.50') && line.contains('15') && line.contains('166666.70')) {
                    foundDataCloud = true;
                    System.debug('✅ Found Data Cloud row with correct data');
                }
                if (line.contains('Einstein Analytics') && line.contains('1800000.00') && line.contains('12') && line.contains('150000.00')) {
                    foundEinstein = true;
                    System.debug('✅ Found Einstein Analytics row with correct data');
                }
            }
            
            System.assert(foundDataCloud, 'Should find Data Cloud row with correct data');
            System.assert(foundEinstein, 'Should find Einstein Analytics row with correct data');
            
            // Validate TSV format (tab separators)
            for (String line : lines) {
                if (!line.startsWith('#') && line.trim() != '') {
                    String[] columns = line.split('\t');
                    if (line.startsWith('Product\t')) {
                        System.assertEquals(4, columns.size(), 'Header should have 4 columns');
                    } else {
                        System.assertEquals(4, columns.size(), 'Data row should have 4 columns');
                    }
                }
            }
            
            System.debug('✅ RENEWALS TSV STRUCTURE VALIDATION PASSED');
            
        } else {
            System.debug('❌ Renewals TSV export failed: ' + response.message);
        }
    }
    
} catch (Exception e) {
    System.debug('❌ RENEWALS TSV STRUCTURE VALIDATION FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('');
System.debug('📊 VALIDATING OPEN PIPE TSV STRUCTURE');
System.debug('-------------------------------------');

try {
    // Test 2: Validate Open Pipe TSV Structure
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
            }
        }
    };
    
    String sessionId = 'validate-openpipe-' + String.valueOf(System.now().getTime());
    ANAgentMemoryContext.storeAnalysisData(
        sessionId,
        'OPEN_PIPE',
        openPipeData,
        'Test open pipe data for structure validation',
        new Map<String, Object>{'testType' => 'structure_validation'}
    );
    
    // Export to TSV
    ANAgentGenericTSVExportHandler.GenericTSVExportRequest request = 
        new ANAgentGenericTSVExportHandler.GenericTSVExportRequest();
    request.analysisTypeFilter = 'OPEN_PIPE';
    request.customFileName = 'Structure_Validation_OpenPipe';
    request.includeMetadata = false; // Keep clean for validation
    request.requestId = 'VALIDATE-OPENPIPE-001';
    
    List<ANAgentGenericTSVExportHandler.GenericTSVExportResponse> responses = 
        ANAgentGenericTSVExportHandler.exportAnyAnalysisAsTSV(
            new List<ANAgentGenericTSVExportHandler.GenericTSVExportRequest>{request}
        );
    
    if (!responses.isEmpty()) {
        ANAgentGenericTSVExportHandler.GenericTSVExportResponse response = responses[0];
        
        if (response.success) {
            // Get the actual TSV content from the file
            // Extract ContentDocumentId from the download URL
            String contentDocumentId = response.downloadLink.substringAfterLast('/');
            ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId LIMIT 1];
            String tsvContent = cv.VersionData.toString();
            
            System.debug('📄 OPEN PIPE TSV CONTENT:');
            System.debug('=========================');
            System.debug(tsvContent);
            System.debug('=========================');
            
            // Validate TSV structure
            String[] lines = tsvContent.split('\n');
            
            // Check for proper header
            Boolean hasCorrectHeader = false;
            for (String line : lines) {
                if (line.startsWith('AE_Email\tLearner_Profile_Id\tProduct\tOpportunity_Name\tStage\tStagnation_Days\tAmount\tOpportunity_URL')) {
                    hasCorrectHeader = true;
                    System.debug('✅ Found correct Open Pipe header');
                    break;
                }
            }
            
            System.assert(hasCorrectHeader, 'Should have correct Open Pipe header');
            
            // Validate data row
            Boolean foundDataRow = false;
            for (String line : lines) {
                if (line.contains('john.doe@company.com') && 
                    line.contains('LP001') && 
                    line.contains('Data Cloud') && 
                    line.contains('Acme Corp Data Cloud Implementation') &&
                    line.contains('03 - Validating Benefits & Value') &&
                    line.contains('45') &&
                    line.contains('500000.00') &&
                    line.contains('https://company.lightning.force.com')) {
                    foundDataRow = true;
                    System.debug('✅ Found correct Open Pipe data row');
                    break;
                }
            }
            
            System.assert(foundDataRow, 'Should find correct Open Pipe data row');
            
            // Validate column count
            for (String line : lines) {
                if (!line.startsWith('AE_Email\t') && line.trim() != '') {
                    String[] columns = line.split('\t');
                    if (line.startsWith('AE_Email\t')) {
                        System.assertEquals(8, columns.size(), 'Header should have 8 columns');
                    } else {
                        System.assertEquals(8, columns.size(), 'Data row should have 8 columns');
                    }
                }
            }
            
            System.debug('✅ OPEN PIPE TSV STRUCTURE VALIDATION PASSED');
            
        } else {
            System.debug('❌ Open Pipe TSV export failed: ' + response.message);
        }
    }
    
} catch (Exception e) {
    System.debug('❌ OPEN PIPE TSV STRUCTURE VALIDATION FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('');
System.debug('📊 VALIDATING KPI TSV STRUCTURE');
System.debug('-------------------------------');

try {
    // Test 3: Validate KPI TSV Structure
    Map<String, Object> kpiData = new Map<String, Object>{
        'ae_performance' => new List<Object>{
            new Map<String, Object>{
                'aeEmail' => 'jane.smith@company.com',
                'learnerProfileId' => 'LP002',
                'ou' => 'AMER-ACC',
                'aeScore' => 4.2,
                'coverage' => 85.5,
                'timeframe' => 'Current Quarter'
            }
        }
    };
    
    String sessionId = 'validate-kpi-' + String.valueOf(System.now().getTime());
    ANAgentMemoryContext.storeAnalysisData(
        sessionId,
        'KPIS',
        kpiData,
        'Test KPI data for structure validation',
        new Map<String, Object>{'testType' => 'structure_validation'}
    );
    
    // Export to TSV
    ANAgentGenericTSVExportHandler.GenericTSVExportRequest request = 
        new ANAgentGenericTSVExportHandler.GenericTSVExportRequest();
    request.analysisTypeFilter = 'KPIS';
    request.customFileName = 'Structure_Validation_KPI';
    request.includeMetadata = false;
    request.requestId = 'VALIDATE-KPI-001';
    
    List<ANAgentGenericTSVExportHandler.GenericTSVExportResponse> responses = 
        ANAgentGenericTSVExportHandler.exportAnyAnalysisAsTSV(
            new List<ANAgentGenericTSVExportHandler.GenericTSVExportRequest>{request}
        );
    
    if (!responses.isEmpty()) {
        ANAgentGenericTSVExportHandler.GenericTSVExportResponse response = responses[0];
        
        if (response.success) {
            // Get the actual TSV content from the file
            // Extract ContentDocumentId from the download URL
            String contentDocumentId = response.downloadLink.substringAfterLast('/');
            ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId LIMIT 1];
            String tsvContent = cv.VersionData.toString();
            
            System.debug('📄 KPI TSV CONTENT:');
            System.debug('===================');
            System.debug(tsvContent);
            System.debug('===================');
            
            // Validate TSV structure
            String[] lines = tsvContent.split('\n');
            
            // Check for proper header
            Boolean hasCorrectHeader = false;
            for (String line : lines) {
                if (line.startsWith('AE_Email\tLearner_Profile_Id\tOU\tAE_Score\tCoverage\tTimeframe')) {
                    hasCorrectHeader = true;
                    System.debug('✅ Found correct KPI header');
                    break;
                }
            }
            
            System.assert(hasCorrectHeader, 'Should have correct KPI header');
            
            // Validate data row
            Boolean foundDataRow = false;
            for (String line : lines) {
                if (line.contains('jane.smith@company.com') && 
                    line.contains('LP002') && 
                    line.contains('AMER-ACC') && 
                    line.contains('4.2') &&
                    line.contains('85.5') &&
                    line.contains('Current Quarter')) {
                    foundDataRow = true;
                    System.debug('✅ Found correct KPI data row');
                    break;
                }
            }
            
            System.assert(foundDataRow, 'Should find correct KPI data row');
            
            // Validate numeric formatting (no currency symbols)
            for (String line : lines) {
                if (!line.startsWith('AE_Email\t') && line.trim() != '') {
                    System.assert(!line.contains('$'), 'Should not contain currency symbols');
                    System.assert(!line.contains(','), 'Should not contain commas in numbers');
                }
            }
            
            System.debug('✅ KPI TSV STRUCTURE VALIDATION PASSED');
            
        } else {
            System.debug('❌ KPI TSV export failed: ' + response.message);
        }
    }
    
} catch (Exception e) {
    System.debug('❌ KPI TSV STRUCTURE VALIDATION FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('');
System.debug('🎉 TSV STRUCTURE VALIDATION COMPLETED');
System.debug('=====================================');
System.debug('All TSV structure validations have been executed. Check the results above for any failures.');
