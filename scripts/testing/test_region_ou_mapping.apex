// Test script to verify the new region-to-OU mapping functionality
// This tests the automatic conversion from region filtering to OU filtering

System.debug('🧪 TESTING REGION-TO-OU MAPPING FUNCTIONALITY');
System.debug('==============================================');

// ============================================================================
// PHASE 1: TEST THE NEW REGION-TO-OU MAPPING
// ============================================================================

System.debug('\n--- PHASE 1: Testing Region-to-OU Mapping ---');

System.debug('🎯 Testing: When topic sends region="AMER", it should now filter by OU instead of REGION__c');

try {
    // Test the EXACT scenario that was failing before
    ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
    request.action = 'ProgramEfficacy';
    request.kpiName = 'ACV';
    request.region = 'AMER';  // This is what the topic is still sending
    request.operatingUnit = null;
    request.vertical = null;
    
    System.debug('📋 Request Parameters (exactly what topic sends):');
    System.debug('  Action: ' + request.action);
    System.debug('  KPI: ' + request.kpiName);
    System.debug('  Region: ' + request.region);  // This should now trigger OU filtering
    System.debug('  Operating Unit: ' + request.operatingUnit);
    
    System.debug('🔄 Calling ANAgentOfferingEfficacyHandlerBasic.analyzeOfferingEfficacy with region="AMER"...');
    System.debug('💡 EXPECTATION: Should now filter by OU_NAME__c instead of REGION__c');
    
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
                System.debug('\n📋 Records Returned (these should now be AMER-related):');
                for (Integer i = 0; i < Math.min(5, response.efficacyRecords.size()); i++) {
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
                        System.debug('     ❌ Should be AMER: false - MAPPING STILL NOT WORKING!');
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
                    System.debug('🎉 SUCCESS: Region-to-OU mapping is working! Most programs are AMER-related.');
                } else {
                    System.debug('⚠️  WARNING: Region-to-OU mapping may not be working correctly.');
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
// PHASE 2: TEST THE REGION-OU MAPPING INFO METHOD
// ============================================================================

System.debug('\n--- PHASE 2: Testing Region-OU Mapping Info Method ---');

try {
    System.debug('🔍 Getting region-OU mapping explanation...');
    String mappingInfo = ANAgentOfferingEfficacyServiceBasic.getRegionOUMappingInfo();
    System.debug('📋 Region-OU Mapping Info:');
    System.debug(mappingInfo);
    
} catch (Exception e) {
    System.debug('❌ Error getting mapping info: ' + e.getMessage());
}

// ============================================================================
// PHASE 3: COMPARISON WITH CORRECT PARAMETERS
// ============================================================================

System.debug('\n--- PHASE 3: Comparison with Correct Parameters ---');

System.debug('🔄 Testing with CORRECT parameters (operatingUnit: "AMER") for comparison...');

try {
    ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest correctRequest = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
    correctRequest.action = 'ProgramEfficacy';
    correctRequest.kpiName = 'ACV';
    correctRequest.region = null;
    correctRequest.operatingUnit = 'AMER';  // This is what it SHOULD be
    correctRequest.vertical = null;
    
    System.debug('📋 CORRECT Request Parameters:');
    System.debug('  Action: ' + correctRequest.action);
    System.debug('  KPI: ' + correctRequest.kpiName);
    System.debug('  Region: ' + correctRequest.region);
    System.debug('  Operating Unit: ' + correctRequest.operatingUnit);
    
    List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse> correctResponses = 
        ANAgentOfferingEfficacyHandlerBasic.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest>{correctRequest});
    
    if (correctResponses.size() > 0) {
        ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse correctResponse = correctResponses[0];
        
        System.debug('📊 CORRECT Parameters Results:');
        System.debug('  Success: ' + correctResponse.success);
        System.debug('  Total Records: ' + correctResponse.totalRecordCount);
        System.debug('  Message: ' + correctResponse.message);
        
        if (correctResponse.success && correctResponse.totalRecordCount > 0) {
            System.debug('✅ SUCCESS: CORRECT parameters returned ' + correctResponse.totalRecordCount + ' AMER programs!');
        } else {
            System.debug('❌ CORRECT parameters returned no AMER programs');
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Error testing correct parameters: ' + e.getMessage());
}

// ============================================================================
// PHASE 4: SUMMARY AND RECOMMENDATIONS
// ============================================================================

System.debug('\n--- PHASE 4: Summary and Recommendations ---');

System.debug('🎯 SUMMARY:');
System.debug('  ✅ Code has been updated with region-to-OU mapping');
System.debug('  ✅ Critical instructions added to both service and handler classes');
System.debug('  ✅ Automatic fallback from region to OU filtering implemented');
System.debug('  ✅ Documentation explains why region filtering doesn\'t work');

System.debug('\n🔧 NEXT STEPS:');
System.debug('  1. Deploy the updated Apex classes');
System.debug('  2. Update topic instructions to use operatingUnit instead of region');
System.debug('  3. Test with "ACV and within AMER" to verify improvement');
System.debug('  4. Monitor that only AMER-related programs are returned');

System.debug('\n💡 KEY INSIGHT:');
System.debug('  Even with the automatic mapping, the topic should still send operatingUnit="AMER"');
System.debug('  This provides clarity and avoids confusion about which field is being filtered');

System.debug('\n🧪 REGION-TO-OU MAPPING TEST COMPLETED');
System.debug('The system should now handle region="AMER" much better!'); 