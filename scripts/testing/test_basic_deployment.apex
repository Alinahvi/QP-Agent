// Test script to verify the basic offering efficacy deployment
// Run this in Developer Console to test the deployed classes

System.debug('🧪 TESTING BASIC OFFERING EFFICACY DEPLOYMENT');
System.debug('============================================');

// Test 1: Basic Service Instantiation
try {
    System.debug('Testing Basic Service Instantiation...');
    ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult result = new ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult();
    System.debug('✅ Basic service instantiation successful');
} catch (Exception e) {
    System.debug('❌ Basic service instantiation failed: ' + e.getMessage());
}

// Test 2: Basic Handler Instantiation
try {
    System.debug('Testing Basic Handler Instantiation...');
    ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
    request.action = 'Search';
    System.debug('✅ Basic handler instantiation successful');
} catch (Exception e) {
    System.debug('❌ Basic handler instantiation failed: ' + e.getMessage());
}

// Test 3: Check if apm_outcome_v2__c object exists
try {
    System.debug('Testing apm_outcome_v2__c object access...');
    
    Schema.SObjectType outcomeType = Schema.getGlobalDescribe().get('apm_outcome_v2__c');
    if (outcomeType != null) {
        System.debug('✅ apm_outcome_v2__c object exists');
        
        // Check record count
        Integer recordCount = Database.countQuery('SELECT COUNT() FROM apm_outcome_v2__c WHERE IsDeleted = false');
        System.debug('📊 Total apm_outcome_v2__c records: ' + recordCount);
        
        if (recordCount > 0) {
            System.debug('✅ apm_outcome_v2__c has data');
            
            // Sample data structure
            List<apm_outcome_v2__c> sampleRecords = [
                SELECT OFFERING_LABEL__c, PROGRAM_TYPE__c, REGION__c, MEAN_EFFECTIVENESS__c
                FROM apm_outcome_v2__c 
                WHERE IsDeleted = false 
                LIMIT 3
            ];
            
            System.debug('📋 Sample data structure:');
            for (apm_outcome_v2__c record : sampleRecords) {
                System.debug('  Offering: ' + record.OFFERING_LABEL__c + 
                           ', Program: ' + record.PROGRAM_TYPE__c + 
                           ', Region: ' + record.REGION__c + 
                           ', Effectiveness: ' + record.MEAN_EFFECTIVENESS__c);
            }
        } else {
            System.debug('⚠️ apm_outcome_v2__c has no data - tests may be limited');
        }
    } else {
        System.debug('❌ apm_outcome_v2__c object does not exist');
    }
} catch (Exception e) {
    System.debug('❌ Data access test failed: ' + e.getMessage());
}

// Test 4: Test Search Action
try {
    System.debug('Testing Search Action...');
    
    ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
    request.action = 'Search';
    request.programType = 'Fast Start';
    request.maxResults = 5;
    
    List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse> responses = 
        ANAgentOfferingEfficacyHandlerBasic.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse response = responses[0];
        System.debug('✅ Search action successful');
        System.debug('  Success: ' + response.success);
        System.debug('  Message: ' + response.message);
        System.debug('  Records found: ' + response.totalRecordCount);
        
        if (response.success) {
            System.debug('🎉 BASIC SYSTEM IS WORKING!');
        } else {
            System.debug('⚠️ Search returned but with errors: ' + response.message);
        }
    } else {
        System.debug('❌ Search action returned no responses');
    }
} catch (Exception e) {
    System.debug('❌ Search action test failed: ' + e.getMessage());
}

// Test 5: Test Course Efficacy Action
try {
    System.debug('Testing Course Efficacy Action...');
    
    ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
    request.action = 'CourseEfficacy';
    request.courseName = 'Fast Start'; // Use a common term that might exist
    
    List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse> responses = 
        ANAgentOfferingEfficacyHandlerBasic.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse response = responses[0];
        System.debug('✅ Course efficacy action successful');
        System.debug('  Success: ' + response.success);
        System.debug('  Message: ' + response.message);
        System.debug('  Records found: ' + response.totalRecordCount);
    } else {
        System.debug('❌ Course efficacy action returned no responses');
    }
} catch (Exception e) {
    System.debug('❌ Course efficacy action test failed: ' + e.getMessage());
}

// Test 6: Test Error Handling
try {
    System.debug('Testing Error Handling...');
    
    ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
    request.action = 'InvalidAction';
    
    List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse> responses = 
        ANAgentOfferingEfficacyHandlerBasic.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse response = responses[0];
        if (!response.success && response.message.contains('Invalid action')) {
            System.debug('✅ Error handling for invalid action works correctly');
        } else {
            System.debug('❌ Error handling for invalid action failed');
        }
    } else {
        System.debug('❌ Error handling test returned no responses');
    }
} catch (Exception e) {
    System.debug('❌ Error handling test failed: ' + e.getMessage());
}

System.debug('\n🎯 DEPLOYMENT TEST SUMMARY:');
System.debug('If you see ✅ marks above, the basic system is working!');
System.debug('If you see ❌ marks, there are issues to resolve.');
System.debug('\nNext steps:');
System.debug('1. Review any error messages above');
System.debug('2. Check debug logs for detailed information');
System.debug('3. Test with real data if available');
System.debug('4. Deploy the full system once basic tests pass');

System.debug('\n🧪 BASIC DEPLOYMENT TEST COMPLETED'); 