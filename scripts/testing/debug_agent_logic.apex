// Debug script to trace exactly what the agent is doing
// This will help us find where "FY25 Solution Selling Showdown" is coming from

System.debug('🔍 DEBUGGING AGENT LOGIC - TRACING THE EXACT FLOW');
System.debug('==================================================');

// ============================================================================
// PHASE 1: TRACE THE EXACT AGENT EXECUTION
// ============================================================================

System.debug('\n--- PHASE 1: Tracing Agent Execution ---');

// Simulate the exact user request that's failing
ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
request.action = 'Search';
request.offeringLabel = 'Data Cloud';
request.maxResults = 5;

System.debug('🎯 User Request: "Show me top 5 effective courses on data cloud"');
System.debug('  Action: ' + request.action);
System.debug('  Offering Label: ' + request.offeringLabel);
System.debug('  Max Results: ' + request.maxResults);

try {
    System.debug('\n🔄 Executing Agent Logic Step by Step...');
    
    // Step 1: Call the agent
    System.debug('📞 Step 1: Calling ANAgentOfferingEfficacyHandlerBasic.analyzeOfferingEfficacy...');
    
    List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse> responses = 
        ANAgentOfferingEfficacyHandlerBasic.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest>{request});
    
    System.debug('✅ Step 1 Complete: Agent returned ' + responses.size() + ' responses');
    
    if (!responses.isEmpty()) {
        ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse response = responses[0];
        
        System.debug('\n📊 Step 2: Analyzing Agent Response...');
        System.debug('  Success: ' + response.success);
        System.debug('  Message: ' + response.message);
        System.debug('  Total Records: ' + response.totalRecordCount);
        
        if (response.success && response.totalRecordCount > 0) {
            
            // Step 3: Examine the actual records returned
            System.debug('\n🔍 Step 3: Examining Actual Records Returned...');
            
            if (response.efficacyRecords != null && !response.efficacyRecords.isEmpty()) {
                
                System.debug('📋 Raw Records from Agent:');
                for (Integer i = 0; i < response.efficacyRecords.size(); i++) {
                    ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record = response.efficacyRecords[i];
                    System.debug('  Record ' + (i + 1) + ':');
                    System.debug('    ID: ' + record.id);
                    System.debug('    Offering Label: ' + record.offeringLabel);
                    System.debug('    Program Type: ' + record.programType);
                    System.debug('    KPI: ' + record.kpiName);
                    System.debug('    Effectiveness: ' + record.effectivenessDisplay);
                    System.debug('    Lift: ' + record.liftDisplay);
                    System.debug('    ACV: ' + record.acvDisplay);
                    System.debug('    Distinct Learners: ' + record.distinctLearners);
                    System.debug('');
                }
                
                // Step 4: Check for the problematic offering
                System.debug('\n🔍 Step 4: Checking for Problematic Offering...');
                
                Boolean foundProblematicOffering = false;
                for (ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record : response.efficacyRecords) {
                    if (record.offeringLabel == 'FY25 Solution Selling Showdown') {
                        foundProblematicOffering = true;
                        System.debug('❌ FOUND PROBLEMATIC OFFERING:');
                        System.debug('    Offering: ' + record.offeringLabel);
                        System.debug('    KPI: ' + record.kpiName);
                        System.debug('    This should NOT appear for "Data Cloud" search!');
                        break;
                    }
                }
                
                if (!foundProblematicOffering) {
                    System.debug('✅ No problematic offering found in agent response');
                    System.debug('🔍 The issue might be elsewhere in the system');
                }
                
                // Step 5: Analyze the data structure
                System.debug('\n📊 Step 5: Analyzing Data Structure...');
                
                Set<String> uniqueOfferings = new Set<String>();
                Map<String, Integer> offeringCounts = new Map<String, Integer>();
                
                for (ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record : response.efficacyRecords) {
                    uniqueOfferings.add(record.offeringLabel);
                    offeringCounts.put(record.offeringLabel, offeringCounts.get(record.offeringLabel) != null ? 
                                     offeringCounts.get(record.offeringLabel) + 1 : 1);
                }
                
                System.debug('  Unique Offerings: ' + uniqueOfferings.size());
                System.debug('  Total Records: ' + response.efficacyRecords.size());
                
                for (String offering : offeringCounts.keySet()) {
                    System.debug('  • ' + offering + ' (' + offeringCounts.get(offering) + ' records)');
                }
                
            } else {
                System.debug('⚠️  No detailed records available from agent');
            }
            
        } else {
            System.debug('❌ Agent encountered an error: ' + response.message);
        }
        
    } else {
        System.debug('❌ No response from agent');
    }
    
} catch (Exception e) {
    System.debug('❌ Error executing agent logic: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// ============================================================================
// PHASE 2: TEST DIRECT SERVICE CALL
// ============================================================================

System.debug('\n--- PHASE 2: Testing Direct Service Call ---');

try {
    System.debug('🔄 Testing ANAgentOfferingEfficacyServiceBasic.searchEfficacyData directly...');
    
    ANAgentOfferingEfficacyServiceBasic.EfficacySearchResult serviceResult = 
        ANAgentOfferingEfficacyServiceBasic.searchEfficacyData('Data Cloud', null, null, null, null, null, null, 5);
    
    System.debug('📊 Direct Service Call Results:');
    System.debug('  Success: ' + serviceResult.success);
    System.debug('  Message: ' + serviceResult.message);
    System.debug('  Total Records: ' + serviceResult.totalRecordCount);
    
    if (serviceResult.success && serviceResult.efficacyRecords != null) {
        System.debug('  Records from Direct Service Call:');
        for (Integer i = 0; i < serviceResult.efficacyRecords.size(); i++) {
            ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record = serviceResult.efficacyRecords[i];
            System.debug('    ' + (i + 1) + '. ' + record.offeringLabel + ' (KPI: ' + record.kpiName + ')');
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Error in direct service call: ' + e.getMessage());
}

System.debug('\n🧪 AGENT LOGIC DEBUG COMPLETED');
System.debug('This should reveal exactly where the wrong data is coming from!'); 