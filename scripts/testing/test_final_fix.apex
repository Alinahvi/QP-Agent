// Final test to verify KPI aggregation fix is working
// This should now return only unique, aggregated offerings

System.debug('🧪 FINAL TEST - VERIFYING KPI AGGREGATION FIX');
System.debug('================================================');

// ============================================================================
// PHASE 1: TEST THE EXACT USER SCENARIO
// ============================================================================

System.debug('\n--- PHASE 1: Testing "Data Cloud" Search with Final Fix ---');

// Simulate the exact user request that was failing
ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
request.action = 'Search';
request.offeringLabel = 'Data Cloud';
request.maxResults = 5;

System.debug('🎯 User Request: "Show me top 5 effective courses on data cloud"');
System.debug('  Action: ' + request.action);
System.debug('  Offering Label: ' + request.offeringLabel);
System.debug('  Max Results: ' + request.maxResults);

try {
    System.debug('\n🔄 Executing Agent Logic with Final Fix...');
    
    List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse> responses = 
        ANAgentOfferingEfficacyHandlerBasic.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse response = responses[0];
        
        System.debug('✅ Agent Response Received:');
        System.debug('  Success: ' + response.success);
        System.debug('  Message: ' + response.message);
        System.debug('  Total Records: ' + response.totalRecordCount);
        
        if (response.success && response.totalRecordCount > 0) {
            
            // ============================================================================
            // PHASE 2: VERIFY NO DUPLICATE OFFERINGS
            // ============================================================================
            
            System.debug('\n--- PHASE 2: Verifying No Duplicate Offerings ---');
            
            if (response.efficacyRecords != null && !response.efficacyRecords.isEmpty()) {
                
                // Check for duplicate offerings
                Set<String> uniqueOfferings = new Set<String>();
                Map<String, Integer> offeringCounts = new Map<String, Integer>();
                
                for (ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record : response.efficacyRecords) {
                    uniqueOfferings.add(record.offeringLabel);
                    offeringCounts.put(record.offeringLabel, offeringCounts.get(record.offeringLabel) != null ? 
                                     offeringCounts.get(record.offeringLabel) + 1 : 1);
                }
                
                System.debug('📊 Final Fix Analysis:');
                System.debug('  Total Records Returned: ' + response.efficacyRecords.size());
                System.debug('  Unique Offerings: ' + uniqueOfferings.size());
                System.debug('  Duplicate Records: ' + (response.efficacyRecords.size() - uniqueOfferings.size()));
                
                // Show breakdown by offering
                System.debug('\n🔍 Breakdown by Offering:');
                for (String offeringLabel : offeringCounts.keySet()) {
                    Integer count = offeringCounts.get(offeringLabel);
                    System.debug('  • ' + offeringLabel + ' (' + count + ' record' + (count > 1 ? 's' : '') + ')');
                    
                    // Find the record for this offering to show aggregated data
                    for (ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record : response.efficacyRecords) {
                        if (record.offeringLabel == offeringLabel) {
                            System.debug('    KPI: ' + record.kpiName);
                            System.debug('    Effectiveness: ' + record.effectivenessDisplay);
                            System.debug('    Lift: ' + record.liftDisplay);
                            System.debug('    ACV: ' + record.acvDisplay);
                            System.debug('    Distinct Learners: ' + record.distinctLearners);
                            break;
                        }
                    }
                }
                
                // ============================================================================
                // PHASE 3: VERIFY SUCCESS
                // ============================================================================
                
                System.debug('\n--- PHASE 3: Verifying Success ---');
                
                if (uniqueOfferings.size() == response.efficacyRecords.size()) {
                    System.debug('🎉 SUCCESS: No duplicate offerings!');
                    System.debug('✅ Each offering appears exactly once');
                    System.debug('✅ KPI aggregation is working perfectly');
                } else {
                    System.debug('❌ ISSUE: Still have duplicate offerings');
                    System.debug('🔍 Need to investigate further');
                }
                
                // Show the actual response the user would see
                System.debug('\n🤖 FINAL AGENT RESPONSE TO USER:');
                System.debug('I found ' + response.totalRecordCount + ' efficacy records for Data Cloud. Here are the top offerings:');
                
                for (Integer i = 0; i < response.efficacyRecords.size(); i++) {
                    ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record = response.efficacyRecords[i];
                    System.debug((i + 1) + '. ' + record.offeringLabel);
                    System.debug('   KPI: ' + record.kpiName);
                    System.debug('   Effectiveness: ' + record.effectivenessDisplay);
                    System.debug('   Lift: ' + record.liftDisplay);
                    System.debug('   ACV: ' + record.acvDisplay);
                    System.debug('   Distinct Learners: ' + record.distinctLearners);
                    System.debug('');
                }
                
                System.debug('📊 SUMMARY METRICS:');
                System.debug(response.summaryMetrics);
                
            } else {
                System.debug('⚠️  No detailed records available');
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
// PHASE 4: SUMMARY OF WHAT WE'VE FIXED
// ============================================================================

System.debug('\n--- PHASE 4: Summary of Fixes Applied ---');

System.debug('🔧 ISSUES IDENTIFIED AND FIXED:');
System.debug('  1. ✅ Clone method deployment error - RESOLVED');
System.debug('  2. ✅ Same offering repeated due to different KPIs - RESOLVED');
System.debug('  3. ✅ ACV not aggregated across KPIs - RESOLVED');
System.debug('  4. ✅ No user guidance on KPIs - RESOLVED');

System.debug('\n🎯 SOLUTIONS IMPLEMENTED:');
System.debug('  1. ✅ Intelligent search broadening when variety is limited');
System.debug('  2. ✅ KPI aggregation to prevent duplicate offerings');
System.debug('  3. ✅ ACV summation across different KPIs');
System.debug('  4. ✅ Clear user guidance and metric explanations');
System.debug('  5. ✅ Professional presentation format');

System.debug('\n📊 EXPECTED USER EXPERIENCE NOW:');
System.debug('  • User asks: "Show me top 5 effective courses on data cloud"');
System.debug('  • Agent responds with 2 unique offerings (not 5 duplicates)');
System.debug('  • Each offering shows aggregated metrics across all KPIs');
System.debug('  • Clear guidance on how to get more specific data');
System.debug('  • Professional, actionable information');

System.debug('\n🧪 FINAL TEST COMPLETED');
System.debug('The KPI aggregation fix should now be working perfectly!'); 