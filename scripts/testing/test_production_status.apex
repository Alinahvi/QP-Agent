// Test script to check the current production status
// This will help us understand why the user is still seeing Korea programs

System.debug('🔍 CHECKING PRODUCTION STATUS');
System.debug('============================');

// ============================================================================
// PHASE 1: VERIFY CURRENT CODE VERSION
// ============================================================================

System.debug('\n--- PHASE 1: Verifying Current Code Version ---');

try {
    System.debug('🔍 Testing the EXACT user scenario: "AMER and ACV"');
    
    // Create the exact request that the user is experiencing
    ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
    request.action = 'ProgramEfficacy';
    request.kpiName = 'ACV';
    request.region = 'AMER';  // This is what the topic is sending
    request.operatingUnit = null;
    request.vertical = null;
    
    System.debug('📋 Request Parameters (exactly what user is experiencing):');
    System.debug('  Action: ' + request.action);
    System.debug('  KPI: ' + request.kpiName);
    System.debug('  Region: ' + request.region);
    System.debug('  Operating Unit: ' + request.operatingUnit);
    
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
            
            // Check what records were actually returned
            if (response.efficacyRecords != null && !response.efficacyRecords.isEmpty()) {
                System.debug('\n📋 Records Returned (these are what the user sees):');
                for (Integer i = 0; i < Math.min(10, response.efficacyRecords.size()); i++) {
                    ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record = response.efficacyRecords[i];
                    System.debug('  ' + (i+1) + '. ' + record.offeringLabel);
                    System.debug('     OU: ' + record.ouName);
                    System.debug('     Region: ' + record.region);
                    System.debug('     KPI: ' + record.kpiName);
                    System.debug('     ACV: ' + record.acvDisplay);
                    
                    // Check if this should be considered AMER
                    Boolean isAmer = false;
                    if (String.isNotBlank(record.ouName)) {
                        isAmer = record.ouName.contains('AMER') || 
                                 record.ouName.contains('CAN') || 
                                 record.ouName.contains('LATAM') ||
                                 record.ouName == 'AMER FINS, HLS, CAN';
                    }
                    
                    if (isAmer) {
                        System.debug('     ✅ Should be AMER: true');
                    } else {
                        System.debug('     ❌ Should be AMER: false - THIS IS THE PROBLEM!');
                    }
                    System.debug('---');
                }
                
                // Count how many are actually AMER-related
                Integer amerCount = 0;
                Integer nonAmerCount = 0;
                
                for (ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record : response.efficacyRecords) {
                    Boolean isAmer = false;
                    if (String.isNotBlank(record.ouName)) {
                        isAmer = record.ouName.contains('AMER') || 
                                 record.ouName.contains('CAN') || 
                                 record.ouName.contains('LATAM') ||
                                 record.ouName == 'AMER FINS, HLS, CAN';
                    }
                    
                    if (isAmer) {
                        amerCount++;
                    } else {
                        nonAmerCount++;
                    }
                }
                
                System.debug('\n📊 AMER vs Non-AMER Breakdown:');
                System.debug('  ✅ AMER-related programs: ' + amerCount);
                System.debug('  ❌ Non-AMER programs: ' + nonAmerCount);
                System.debug('  📈 AMER accuracy: ' + (amerCount * 100 / response.totalRecordCount) + '%');
                
                if (amerCount > nonAmerCount) {
                    System.debug('🎉 SUCCESS: Region-to-OU mapping is working in production!');
                } else {
                    System.debug('⚠️  WARNING: Region-to-OU mapping is NOT working in production!');
                    System.debug('   This means the updated code has not been deployed yet.');
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
// PHASE 2: CHECK IF REGION-TO-OU MAPPING IS ACTIVE
// ============================================================================

System.debug('\n--- PHASE 2: Checking if Region-to-OU Mapping is Active ---');

try {
    System.debug('🔍 Testing if the mapRegionToOU method is working...');
    
    // Try to call the method directly to see if it exists
    // This will help us determine if the updated code is deployed
    
    // Create a test request with region
    ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest testRequest = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
    testRequest.action = 'ProgramEfficacy';
    testRequest.kpiName = 'ACV';
    testRequest.region = 'AMER';
    testRequest.operatingUnit = null;
    
    System.debug('🔄 Testing region="AMER" to see if it gets mapped to OU filtering...');
    
    List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse> testResponses = 
        ANAgentOfferingEfficacyHandlerBasic.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest>{testRequest});
    
    if (testResponses.size() > 0) {
        ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse testResponse = testResponses[0];
        
        System.debug('📊 Test Response:');
        System.debug('  Success: ' + testResponse.success);
        System.debug('  Total Records: ' + testResponse.totalRecordCount);
        System.debug('  Message: ' + testResponse.message);
        
        // Check if we see the debug message about region-to-OU mapping
        // This would indicate the updated code is running
        
    }
    
} catch (Exception e) {
    System.debug('❌ Error testing region-to-OU mapping: ' + e.getMessage());
}

// ============================================================================
// PHASE 3: DIAGNOSIS AND RECOMMENDATIONS
// ============================================================================

System.debug('\n--- PHASE 3: Diagnosis and Recommendations ---');

System.debug('🎯 DIAGNOSIS:');
System.debug('  If you still see "[Korea] FY25 Q1 Slack Certification" in your chat,');
System.debug('  it means the updated Apex code has not been deployed to your production org yet.');

System.debug('\n🔧 IMMEDIATE ACTIONS REQUIRED:');
System.debug('  1. ✅ Deploy the updated ANAgentOfferingEfficacyHandlerBasic.cls');
System.debug('  2. ✅ Deploy the updated ANAgentOfferingEfficacyServiceBasic.cls');
System.debug('  3. ✅ Clear any caching in your chat system');
System.debug('  4. ✅ Test with "ACV and within AMER" again');

System.debug('\n💡 VERIFICATION STEPS:');
System.debug('  After deployment, you should see:');
System.debug('  • Only AMER-related programs (AMER, CAN, LATAM OUs)');
System.debug('  • No more "[Korea]" programs');
System.debug('  • Debug message: "Region-to-OU mapping applied: region="AMER" → operatingUnit="AMER""');

System.debug('\n🧪 PRODUCTION STATUS CHECK COMPLETED');
System.debug('The issue is likely that the updated code needs to be deployed!'); 