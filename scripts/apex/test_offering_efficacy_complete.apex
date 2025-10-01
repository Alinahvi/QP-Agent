// Comprehensive test script for ANAgentOfferingEfficacyHandler, Service, and Batch Service
// Run this in Developer Console or via SFDX

System.debug('=== COMPREHENSIVE OFFERING EFFICACY TEST ===');

// Test 1: Course Efficacy Action (Course Linking)
System.debug('\n--- Test 1: Course Efficacy Action ---');
ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest courseRequest = new ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest();
courseRequest.action = 'CourseEfficacy';
courseRequest.courseName = 'Einstein'; // Test with a course name that might exist

try {
    List<ANAgentOfferingEfficacyHandler.EfficacyAnalysisResponse> courseResponses = 
        ANAgentOfferingEfficacyHandler.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest>{courseRequest});
    
    if (!courseResponses.isEmpty()) {
        ANAgentOfferingEfficacyHandler.EfficacyAnalysisResponse response = courseResponses[0];
        System.debug('Course Efficacy Results:');
        System.debug('Success: ' + response.success);
        System.debug('Message: ' + response.message);
        System.debug('Total Records: ' + response.totalRecordCount);
        System.debug('Summary Metrics: ' + response.summaryMetrics);
        
        if (!response.efficacyRecords.isEmpty()) {
            System.debug('Sample Course Efficacy Record:');
            System.debug('Offering: ' + response.efficacyRecords[0].offeringLabel);
            System.debug('Effectiveness: ' + response.efficacyRecords[0].effectivenessDisplay);
            System.debug('Lift: ' + response.efficacyRecords[0].liftDisplay);
        }
    }
} catch (Exception e) {
    System.debug('Error in course efficacy test: ' + e.getMessage());
}

// Test 2: Search Action with Potential Batch Processing
System.debug('\n--- Test 2: Search Action (Potential Batch) ---');
ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest searchRequest = new ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest();
searchRequest.action = 'Search';
searchRequest.programType = 'Fast Start';
searchRequest.fiscalQuarter = '2024-Q1';
searchRequest.maxResults = 50;

try {
    List<ANAgentOfferingEfficacyHandler.EfficacyAnalysisResponse> searchResponses = 
        ANAgentOfferingEfficacyHandler.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandler.EfficacyAnalysisRequest>{searchRequest});
    
    if (!searchResponses.isEmpty()) {
        ANAgentOfferingEfficacyHandler.EfficacyAnalysisResponse response = searchResponses[0];
        System.debug('Search Results:');
        System.debug('Success: ' + response.success);
        System.debug('Message: ' + response.message);
        System.debug('Total Records: ' + response.totalRecordCount);
        
        // Check if batch processing was triggered
        if (response.message.contains('Batch processing started')) {
            System.debug('✅ Batch processing was triggered for large dataset');
            System.debug('Batch Job ID: ' + response.batchJobId);
        } else {
            System.debug('✅ Regular processing completed');
        }
    }
} catch (Exception e) {
    System.debug('Error in search test: ' + e.getMessage());
}

// Test 3: Direct Service Call for Course Efficacy
System.debug('\n--- Test 3: Direct Service Course Efficacy ---');
try {
    ANAgentOfferingEfficacyService.EfficacySearchResult serviceResult = 
        ANAgentOfferingEfficacyService.getEfficacyForCourse('Fast Start');
    
    System.debug('Direct Service Course Efficacy Results:');
    System.debug('Success: ' + serviceResult.success);
    System.debug('Message: ' + serviceResult.message);
    System.debug('Total Records: ' + serviceResult.totalRecordCount);
    
    if (!serviceResult.efficacyRecords.isEmpty()) {
        System.debug('Sample Efficacy Record:');
        ANAgentOfferingEfficacyService.EfficacyRecord record = serviceResult.efficacyRecords[0];
        System.debug('Offering: ' + record.offeringLabel);
        System.debug('Program Type: ' + record.programType);
        System.debug('Region: ' + record.region);
        System.debug('Effectiveness: ' + record.effectivenessDisplay);
    }
} catch (Exception e) {
    System.debug('Error in direct service test: ' + e.getMessage());
}

// Test 4: Batch Service Execution
System.debug('\n--- Test 4: Batch Service Execution ---');
try {
    // Start a batch job for analysis
    Id batchJobId = ANAgentOfferingEfficacyBatchService.executeBatchAnalysis(
        'Einstein', 'Fast Start', 'ANZ', 'ESMB', '2024-Q1', 'PIPE_QUALITY', 'ALL', 'analyze'
    );
    
    System.debug('✅ Batch job started successfully');
    System.debug('Batch Job ID: ' + batchJobId);
    
    // Check batch job status
    AsyncApexJob batchJob = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors 
                            FROM AsyncApexJob WHERE Id = :batchJobId];
    
    System.debug('Batch Job Status: ' + batchJob.Status);
    System.debug('Job Items Processed: ' + batchJob.JobItemsProcessed);
    System.debug('Total Job Items: ' + batchJob.TotalJobItems);
    System.debug('Number of Errors: ' + batchJob.NumberOfErrors);
    
} catch (Exception e) {
    System.debug('Error in batch service test: ' + e.getMessage());
}

// Test 5: Object Linking Verification
System.debug('\n--- Test 5: Object Linking Verification ---');
try {
    // Check if we can find courses that might match offering labels
    List<Course__c> sampleCourses = [
        SELECT Id, Name, Description__c, Status__c 
        FROM Course__c 
        WHERE Status__c = 'Active'
        LIMIT 5
    ];
    
    System.debug('Sample Courses Found: ' + sampleCourses.size());
    for (Course__c course : sampleCourses) {
        System.debug('Course: ' + course.Name + ' (ID: ' + course.Id + ')');
        
        // Try to find matching offering outcomes
        List<apm_outcome_v2__c> matchingOutcomes = [
            SELECT OFFERING_LABEL__c, MEAN_EFFECTIVENESS__c, CALCULATED_LIFT__c
            FROM apm_outcome_v2__c 
            WHERE OFFERING_LABEL__c LIKE '%' + course.Name + '%'
            LIMIT 3
        ];
        
        System.debug('  Matching Outcomes: ' + matchingOutcomes.size());
        for (apm_outcome_v2__c outcome : matchingOutcomes) {
            System.debug('    Offering: ' + outcome.OFFERING_LABEL__c);
            System.debug('    Effectiveness: ' + outcome.MEAN_EFFECTIVENESS__c);
        }
    }
    
} catch (Exception e) {
    System.debug('Error in object linking test: ' + e.getMessage());
}

// Test 6: Batch Processing Decision Logic
System.debug('\n--- Test 6: Batch Processing Decision Logic ---');
try {
    // Test different scenarios that should trigger batch processing
    
    // Scenario 1: No filters (broad search)
    Boolean shouldBatch1 = ANAgentOfferingEfficacyService.shouldUseBatchProcessing(
        null, null, null, null, null, null, null
    );
    System.debug('No filters - Should use batch: ' + shouldBatch1);
    
    // Scenario 2: Specific filters (narrow search)
    Boolean shouldBatch2 = ANAgentOfferingEfficacyService.shouldUseBatchProcessing(
        'Einstein', 'Fast Start', 'ANZ', 'ESMB', '2024-Q1', 'PIPE_QUALITY', 'ALL'
    );
    System.debug('Specific filters - Should use batch: ' + shouldBatch2);
    
    // Scenario 3: Check record count for specific filters
    String countQuery = 'SELECT COUNT() FROM apm_outcome_v2__c WHERE IsDeleted = false';
    Integer totalRecords = Database.countQuery(countQuery);
    System.debug('Total records in apm_outcome_v2__c: ' + totalRecords);
    
    if (totalRecords > 10000) {
        System.debug('✅ Large dataset detected - batch processing recommended');
    } else {
        System.debug('✅ Dataset size manageable - regular processing sufficient');
    }
    
} catch (Exception e) {
    System.debug('Error in batch decision logic test: ' + e.getMessage());
}

// Test 7: Keyword Extraction for Course Names
System.debug('\n--- Test 7: Keyword Extraction Test ---');
try {
    // Test the keyword extraction method
    List<String> keywords1 = ANAgentOfferingEfficacyService.extractKeywordsFromCourseName('Einstein AI Training Course');
    System.debug('Keywords from "Einstein AI Training Course": ' + keywords1);
    
    List<String> keywords2 = ANAgentOfferingEfficacyService.extractKeywordsFromCourseName('Fast Start - RKO - Einstein 1');
    System.debug('Keywords from "Fast Start - RKO - Einstein 1": ' + keywords2);
    
    List<String> keywords3 = ANAgentOfferingEfficacyService.extractKeywordsFromCourseName('Sales Methodology Workshop');
    System.debug('Keywords from "Sales Methodology Workshop": ' + keywords3);
    
} catch (Exception e) {
    System.debug('Error in keyword extraction test: ' + e.getMessage());
}

System.debug('\n=== COMPREHENSIVE TESTING COMPLETED ===');
System.debug('Check the debug logs for detailed results and any errors.');
System.debug('For batch jobs, monitor progress in Setup > Apex Jobs.'); 