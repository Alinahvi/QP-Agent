// Test script to query 5 programs within AMER for ACV as KPI
// This will help us understand what's actually happening with the current system

System.debug('🧪 TESTING AMER ACV PROGRAMS QUERY');
System.debug('====================================');

// ============================================================================
// PHASE 1: TEST THE EXACT SCENARIO FROM THE USER
// ============================================================================

System.debug('\n--- PHASE 1: Testing Exact User Scenario ---');

System.debug('🎯 User Request: "5 programs within AMER for ACV as KPI"');
System.debug('🔍 Expected: Should return only AMER-related programs');

try {
    // Create the exact request that the topic is sending
    ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
    request.action = 'ProgramEfficacy';
    request.kpiName = 'ACV';
    request.region = 'AMER';  // This is what the topic is actually sending
    request.operatingUnit = null;
    request.vertical = null;
    
    System.debug('📋 Request Parameters (exactly what topic sends):');
    System.debug('  Action: ' + request.action);
    System.debug('  KPI: ' + request.kpiName);
    System.debug('  Region: ' + request.region);  // This is the key!
    System.debug('  Operating Unit: ' + request.operatingUnit);
    System.debug('  Vertical: ' + request.vertical);
    
    // Call the handler method with the EXACT parameters the topic is sending
    System.debug('🔄 Calling ANAgentOfferingEfficacyHandlerBasic.analyzeOfferingEfficacy with region="AMER"...');
    
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
                        System.debug('     ❌ Should be AMER: false - THIS IS THE PROBLEM!');
                    }
                    System.debug('---');
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
// PHASE 2: CHECK WHAT THE REGION FIELD ACTUALLY CONTAINS
// ============================================================================

System.debug('\n--- PHASE 2: Checking REGION Field Values ---');

try {
    System.debug('🔍 Let me check what values actually exist in the REGION__c field...');
    
    // Check if REGION__c field has any AMER values
    String regionQuery = 'SELECT DISTINCT REGION__c, COUNT(Id) recordCount ' +
                         'FROM apm_outcome_v2__c ' +
                         'WHERE IsDeleted = false ' +
                         'AND REGION__c != null ' +
                         'GROUP BY REGION__c ' +
                         'ORDER BY recordCount DESC';
    
    List<AggregateResult> regionResults = Database.query(regionQuery);
    
    System.debug('📊 Available REGION__c Values:');
    for (AggregateResult result : regionResults) {
        String region = (String) result.get('REGION__c');
        Integer count = (Integer) result.get('recordCount');
        System.debug('  • ' + region + ': ' + count + ' records');
    }
    
    // Check specifically for AMER in REGION__c
    String amerRegionQuery = 'SELECT COUNT() FROM apm_outcome_v2__c ' +
                             'WHERE IsDeleted = false ' +
                             'AND REGION__c LIKE \'%AMER%\'';
    
    Integer amerRegionCount = Database.countQuery(amerRegionQuery);
    System.debug('🔍 Records with REGION__c containing AMER: ' + amerRegionCount);
    
    // Check for programs with ACV KPI and any region
    String acvRegionQuery = 'SELECT COUNT() FROM apm_outcome_v2__c ' +
                            'WHERE IsDeleted = false ' +
                            'AND KPI_NM__c = \'ACV\' ' +
                            'AND (PROGRAM_TYPE__c != null OR OFFERING_PROGRAM_TYPE__c != null) ' +
                            'AND REGION__c != null';
    
    Integer acvRegionCount = Database.countQuery(acvRegionQuery);
    System.debug('🔍 ACV Programs with non-null REGION__c: ' + acvRegionCount);
    
} catch (Exception e) {
    System.debug('❌ Error checking REGION field: ' + e.getMessage());
}

// ============================================================================
// PHASE 3: TEST WITH CORRECT PARAMETERS FOR COMPARISON
// ============================================================================

System.debug('\n--- PHASE 3: Testing with CORRECT Parameters for Comparison ---');

try {
    System.debug('🔄 Testing with CORRECT parameters (operatingUnit: "AMER")...');
    
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
// PHASE 4: SUMMARY AND ANALYSIS
// ============================================================================

System.debug('\n--- PHASE 4: Summary and Analysis ---');

System.debug('🎯 ANALYSIS:');
System.debug('  The topic is sending region="AMER" instead of operatingUnit="AMER"');
System.debug('  This means the REGION__c field is being filtered, not the OU_NAME__c field');
System.debug('  Since REGION__c is mostly null, this filter is ineffective');
System.debug('  That\'s why you\'re getting non-AMER courses like "[Korea] FY25 Q1 Slack Certification"');

System.debug('\n🔧 SOLUTION:');
System.debug('  The topic needs to map "within AMER" to operatingUnit="AMER"');
System.debug('  NOT to region="AMER"');
System.debug('  This will filter by OU_NAME__c field which contains actual OU values');

System.debug('\n🧪 AMER ACV PROGRAMS TEST COMPLETED');
System.debug('This shows exactly why the current system is returning wrong results!'); 