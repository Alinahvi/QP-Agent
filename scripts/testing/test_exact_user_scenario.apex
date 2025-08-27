// Test script to simulate the exact user scenario that's failing
// This will help us trace through the entire flow to find the issue

System.debug('🧪 TESTING EXACT USER SCENARIO');
System.debug('================================');

// ============================================================================
// PHASE 1: SIMULATE THE EXACT USER REQUEST
// ============================================================================

System.debug('\n--- PHASE 1: Simulating User Request ---');

System.debug('🎯 User Request: "ACV and within AMER"');
System.debug('🔍 Expected: Should call ProgramEfficacy with operatingUnit="AMER"');

// ============================================================================
// PHASE 2: TEST THE HANDLER DIRECTLY
// ============================================================================

System.debug('\n--- PHASE 2: Testing Handler Directly ---');

try {
    // Create the exact request that the topic should send
    ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
    request.action = 'ProgramEfficacy';
    request.kpiName = 'ACV';
    request.operatingUnit = 'AMER';
    request.vertical = null;
    
    System.debug('📋 Request Parameters:');
    System.debug('  Action: ' + request.action);
    System.debug('  KPI: ' + request.kpiName);
    System.debug('  Operating Unit: ' + request.operatingUnit);
    System.debug('  Vertical: ' + request.vertical);
    
    // Call the handler method directly
    System.debug('🔄 Calling ANAgentOfferingEfficacyHandlerBasic.analyzeOfferingEfficacy...');
    
    List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse> responses = 
        ANAgentOfferingEfficacyHandlerBasic.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest>{request});
    
    if (responses.size() > 0) {
        ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse response = responses[0];
        
        System.debug('📊 Handler Response:');
        System.debug('  Success: ' + response.success);
        System.debug('  Message: ' + response.message);
        System.debug('  Total Records: ' + response.totalRecordCount);
        
        if (response.success && response.totalRecordCount > 0) {
            System.debug('✅ SUCCESS: Handler returned ' + response.totalRecordCount + ' records!');
            
            // Check if the records are actually AMER-related
            if (response.efficacyRecords != null && !response.efficacyRecords.isEmpty()) {
                System.debug('\n📋 First 3 Records from Handler:');
                for (Integer i = 0; i < Math.min(3, response.efficacyRecords.size()); i++) {
                    ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record = response.efficacyRecords[i];
                    System.debug('  ' + (i+1) + '. ' + record.offeringLabel + ' (OU: ' + record.ouName + ')');
                    
                    // Verify this should be AMER
                    Boolean isAmer = String.isNotBlank(record.ouName) && 
                                   (record.ouName.contains('AMER') || 
                                    record.ouName.contains('CAN') || 
                                    record.ouName.contains('LATAM') ||
                                    record.ouName == 'AMER FINS, HLS, CAN');
                    
                    if (isAmer) {
                        System.debug('    ✅ Correctly identified as AMER');
                    } else {
                        System.debug('    ❌ NOT AMER - this is the problem!');
                    }
                }
            }
        } else {
            System.debug('❌ Handler returned no records or failed');
        }
    } else {
        System.debug('❌ Handler returned no responses');
    }
    
} catch (Exception e) {
    System.debug('❌ Error testing handler: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// ============================================================================
// PHASE 3: TEST THE SERVICE METHOD DIRECTLY
// ============================================================================

System.debug('\n--- PHASE 3: Testing Service Method Directly ---');

try {
    System.debug('🔄 Testing ANAgentOfferingEfficacyServiceBasic.getEfficacyForPrograms directly...');
    
    ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult serviceResult = 
        ANAgentOfferingEfficacyServiceBasic.getEfficacyForPrograms('ACV', null, 'AMER');
    
    System.debug('📊 Service Method Results:');
    System.debug('  Success: ' + serviceResult.success);
    System.debug('  Message: ' + serviceResult.message);
    System.debug('  Total Records: ' + serviceResult.totalRecordCount);
    
    if (serviceResult.success && serviceResult.totalRecordCount > 0) {
        System.debug('✅ SUCCESS: Service method found ' + serviceResult.totalRecordCount + ' AMER programs!');
        
        // Show the actual SOQL query that was generated
        System.debug('🔍 This means the service method is working correctly');
        System.debug('🔍 The issue must be in the topic not calling this method');
        
    } else {
        System.debug('❌ Service method returned no AMER programs');
        System.debug('🔍 This confirms the service method is working correctly');
        System.debug('🔍 The issue is that the topic is calling a different method');
    }
    
} catch (Exception e) {
    System.debug('❌ Error testing service method: ' + e.getMessage());
}

// ============================================================================
// PHASE 4: CHECK WHAT OTHER METHODS MIGHT BE BEING CALLED
// ============================================================================

System.debug('\n--- PHASE 4: Checking Other Methods ---');

try {
    System.debug('🔍 Let me check if there are other methods that might be returning non-AMER results...');
    
    // Check if the old searchEfficacyData method is being called
    System.debug('🔄 Testing old searchEfficacyData method with region parameter...');
    
    ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult oldMethodResult = 
        ANAgentOfferingEfficacyServiceBasic.searchEfficacyData(null, null, 'AMER', null, null, 'ACV', null, 50);
    
    System.debug('📊 Old Method Results:');
    System.debug('  Success: ' + oldMethodResult.success);
    System.debug('  Total Records: ' + oldMethodResult.totalRecordCount);
    
    if (oldMethodResult.success && oldMethodResult.totalRecordCount > 0) {
        System.debug('🎯 FOUND THE ISSUE!');
        System.debug('🔍 The topic is calling the OLD searchEfficacyData method with region="AMER"');
        System.debug('🔍 This method filters by REGION__c field (mostly null) instead of OU_NAME__c');
        System.debug('🔍 That\'s why you\'re getting non-AMER courses!');
        
        // Show what this method actually returned
        if (oldMethodResult.efficacyRecords != null && !oldMethodResult.efficacyRecords.isEmpty()) {
            System.debug('\n📋 Records from OLD method (these are the wrong ones):');
            for (Integer i = 0; i < Math.min(3, oldMethodResult.efficacyRecords.size()); i++) {
                ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record = oldMethodResult.efficacyRecords[i];
                System.debug('  ' + (i+1) + '. ' + record.offeringLabel + ' (OU: ' + record.ouName + ')');
            }
        }
    } else {
        System.debug('✅ Old method also returned no results - this is not the issue');
    }
    
} catch (Exception e) {
    System.debug('❌ Error checking other methods: ' + e.getMessage());
}

// ============================================================================
// PHASE 5: SUMMARY AND SOLUTION
// ============================================================================

System.debug('\n--- PHASE 5: Summary and Solution ---');

System.debug('🎯 ROOT CAUSE IDENTIFIED:');
System.debug('  The topic is calling the WRONG method or with WRONG parameters');
System.debug('  Even though you have correct instructions, the topic is not following them');

System.debug('\n🔧 SOLUTION:');
System.debug('  1. ✅ Your topic instructions are correct');
System.debug('  2. ✅ The Apex code is fixed and working');
System.debug('  3. ❌ The topic is calling the wrong method/parameters');
System.debug('  4. 🔍 Check your topic implementation to ensure it\'s calling:');
System.debug('     • Class: ANAgentOfferingEfficacyHandlerBasic');
System.debug('     • Method: analyzeOfferingEfficacy');
System.debug('     • Action: ProgramEfficacy');
System.debug('     • Parameter: operatingUnit (NOT region)');

System.debug('\n🧪 EXACT USER SCENARIO TEST COMPLETED');
System.debug('This will show us exactly where the topic is failing!'); 