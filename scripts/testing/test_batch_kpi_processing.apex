/**
 * Test Batch KPI Processing
 * Tests the Batch Apex solution for handling large datasets
 */

System.debug('=== BATCH KPI PROCESSING TEST STARTED ===');

// Test 1: Start Batch Processing for Large Dataset
System.debug('\n--- TEST 1: Start Batch Processing for Large Dataset ---');
try {
    // Start batch processing for all US records (we know there are 10,135 records)
    Id batchJobId = ANAgentKPIBatchProcessor.executeBatch('MEETINGS', 'WORK_LOCATION_COUNTRY', 'US', 'CURRENT');
    
    System.debug('✅ Batch Job Started Successfully');
    System.debug('Batch Job ID: ' + batchJobId);
    System.debug('This will process 10,135 US records in batches of 2,000');
    
    // Query the batch job status
    AsyncApexJob batchJob = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, 
                             CreatedDate, CompletedDate
                             FROM AsyncApexJob 
                             WHERE Id = :batchJobId];
    
    System.debug('Batch Job Status: ' + batchJob.Status);
    System.debug('Total Job Items: ' + batchJob.TotalJobItems);
    System.debug('Job Items Processed: ' + batchJob.JobItemsProcessed);
    System.debug('Errors: ' + batchJob.NumberOfErrors);
    
} catch (Exception e) {
    System.debug('❌ Test 1 Error: ' + e.getMessage());
}

// Test 2: Test Batch Processing for AMER ICE (1,138 records - should fit in standard processing)
System.debug('\n--- TEST 2: Test Standard Processing for AMER ICE ---');
try {
    // This should use standard processing since it's under 50,000 records
    ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request.analysisType = 'MEETINGS';
    request.primaryDimension = 'OU_NAME';
    request.primaryValue = 'AMER ICE';
    request.timeFrame = 'CURRENT';
    request.includeStatistics = true;
    request.useBatchProcessing = false; // Force standard processing
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response = 
        ANAgentKPIAnalysisService.analyzeKPIs(request);
    
    System.debug('✅ Standard Processing Test Results:');
    System.debug('Success: ' + response.success);
    System.debug('Total Records: ' + response.totalRecords);
    System.debug('Total Value: ' + response.totalValue);
    System.debug('Average Value: ' + response.averageValue);
    System.debug('Max Value: ' + response.maxValue);
    System.debug('Min Value: ' + response.minValue);
    System.debug('Median Value: ' + response.medianValue);
    System.debug('Processing Mode: ' + response.processingMode);
    
} catch (Exception e) {
    System.debug('❌ Test 2 Error: ' + e.getMessage());
}

// Test 3: Test Batch Processing for Large Dataset (All Records)
System.debug('\n--- TEST 3: Test Batch Processing for All Records ---');
try {
    // This should use batch processing since it's over 50,000 records
    ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request.analysisType = 'MEETINGS';
    request.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request.timeFrame = 'CURRENT';
    request.includeStatistics = true;
    request.useBatchProcessing = true; // Force batch processing
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response = 
        ANAgentKPIAnalysisService.analyzeKPIs(request);
    
    System.debug('✅ Batch Processing Test Results:');
    System.debug('Success: ' + response.success);
    System.debug('Message: ' + response.message);
    System.debug('Batch Job ID: ' + response.batchJobId);
    System.debug('Processing Mode: ' + response.processingMode);
    System.debug('Analysis Type: ' + response.analysisType);
    System.debug('Primary Dimension: ' + response.primaryDimension);
    
} catch (Exception e) {
    System.debug('❌ Test 3 Error: ' + e.getMessage());
}

// Test 4: Test Statistical Functions with Smaller Dataset
System.debug('\n--- TEST 4: Test Statistical Functions with Smaller Dataset ---');
try {
    // Test with UKI (699 records) to verify statistical calculations
    ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request.analysisType = 'PIPELINE';
    request.primaryDimension = 'OU_NAME';
    request.primaryValue = 'UKI';
    request.timeFrame = 'CURRENT';
    request.includeStatistics = true;
    request.useBatchProcessing = false;
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response = 
        ANAgentKPIAnalysisService.analyzeKPIs(request);
    
    System.debug('✅ Statistical Functions Test Results:');
    System.debug('Success: ' + response.success);
    System.debug('Total Records: ' + response.totalRecords);
    System.debug('Total Value: $' + response.totalValue);
    System.debug('Average Value: $' + response.averageValue);
    System.debug('Max Value: $' + response.maxValue);
    System.debug('Min Value: $' + response.minValue);
    System.debug('Median Value: $' + response.medianValue);
    System.debug('Processing Mode: ' + response.processingMode);
    
    // Verify the statistics make sense
    if (response.maxValue >= response.averageValue && response.averageValue >= response.minValue) {
        System.debug('✅ Statistics Validation: PASSED - Values are logically consistent');
    } else {
        System.debug('❌ Statistics Validation: FAILED - Values are not logically consistent');
    }
    
} catch (Exception e) {
    System.debug('❌ Test 4 Error: ' + e.getMessage());
}

// Test 5: Test Different KPI Types
System.debug('\n--- TEST 5: Test Different KPI Types ---');
try {
    String[] kpiTypes = new String[]{'MEETINGS', 'PIPELINE', 'ACV', 'CALLS', 'AI_MENTIONS'};
    
    for (String kpiType : kpiTypes) {
        try {
            ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
            request.analysisType = kpiType;
            request.primaryDimension = 'WORK_LOCATION_COUNTRY';
            request.primaryValue = 'Canada'; // Smaller dataset (1,272 records)
            request.timeFrame = 'CURRENT';
            request.includeStatistics = true;
            request.useBatchProcessing = false;
            
            ANAgentKPIAnalysisService.KPIAnalysisResponse response = 
                ANAgentKPIAnalysisService.analyzeKPIs(request);
            
            System.debug('✅ ' + kpiType + ' Analysis:');
            System.debug('  Success: ' + response.success);
            System.debug('  Total Records: ' + response.totalRecords);
            System.debug('  Total Value: ' + response.totalValue);
            System.debug('  Processing Mode: ' + response.processingMode);
            
        } catch (Exception e) {
            System.debug('❌ ' + kpiType + ' Analysis Error: ' + e.getMessage());
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Test 5 Error: ' + e.getMessage());
}

System.debug('\n=== BATCH KPI PROCESSING TEST COMPLETED ===');
System.debug('Note: Batch jobs run asynchronously. Check Setup > Apex Jobs to monitor progress.'); 