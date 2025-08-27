// Test script to verify the enhanced search with intelligent broadening
// This tests if the agent can now find more variety in offerings

System.debug('🧪 TESTING ENHANCED SEARCH WITH INTELLIGENT BROADENING');
System.debug('========================================================');

// ============================================================================
// PHASE 1: TEST THE EXACT USER SCENARIO WITH ENHANCED LOGIC
// ============================================================================

System.debug('\n--- PHASE 1: Testing Enhanced "Data Cloud" Search ---');

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
    System.debug('\n🔄 Executing Enhanced Agent Logic...');
    
    List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse> responses = 
        ANAgentOfferingEfficacyHandlerBasic.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse response = responses[0];
        
        System.debug('✅ Enhanced Agent Response Received:');
        System.debug('  Success: ' + response.success);
        System.debug('  Message: ' + response.message);
        System.debug('  Total Records: ' + response.totalRecordCount);
        
        if (response.success && response.totalRecordCount > 0) {
            
            // ============================================================================
            // PHASE 2: ANALYZE THE ENHANCED RESULTS
            // ============================================================================
            
            System.debug('\n--- PHASE 2: Analyzing Enhanced Results ---');
            
            if (response.efficacyRecords != null && !response.efficacyRecords.isEmpty()) {
                
                // Check for variety in offerings
                Set<String> uniqueOfferings = new Set<String>();
                Map<String, List<ANAgentOfferingEfficacyServiceBasic.EfficacyRecord>> offeringsByLabel = new Map<String, List<ANAgentOfferingEfficacyServiceBasic.EfficacyRecord>>();
                
                for (ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record : response.efficacyRecords) {
                    uniqueOfferings.add(record.offeringLabel);
                    
                    if (!offeringsByLabel.containsKey(record.offeringLabel)) {
                        offeringsByLabel.put(record.offeringLabel, new List<ANAgentOfferingEfficacyServiceBasic.EfficacyRecord>());
                    }
                    offeringsByLabel.get(record.offeringLabel).add(record);
                }
                
                System.debug('📊 Enhanced Search Analysis:');
                System.debug('  Total Records: ' + response.efficacyRecords.size());
                System.debug('  Unique Offerings: ' + uniqueOfferings.size());
                System.debug('  Duplicate Records: ' + (response.efficacyRecords.size() - uniqueOfferings.size()));
                
                // Show breakdown by offering
                System.debug('\n🔍 Breakdown by Offering:');
                for (String offeringLabel : offeringsByLabel.keySet()) {
                    List<ANAgentOfferingEfficacyServiceBasic.EfficacyRecord> records = offeringsByLabel.get(offeringLabel);
                    System.debug('  • ' + offeringLabel + ' (' + records.size() + ' records)');
                    
                    // Show segments for this offering
                    Set<String> segments = new Set<String>();
                    Set<String> regions = new Set<String>();
                    Decimal totalAcv = 0;
                    
                    for (ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record : records) {
                        if (record.macroSegment != null) segments.add(record.macroSegment);
                        if (record.region != null) regions.add(record.region);
                        if (record.totalInfluencedAcv != null) totalAcv += record.totalInfluencedAcv;
                    }
                    
                    System.debug('    Segments: ' + String.join(new List<String>(segments), ', '));
                    System.debug('    Regions: ' + String.join(new List<String>(regions), ', '));
                    System.debug('    Total ACV: ' + formatCurrency(totalAcv));
                }
                
                // ============================================================================
                // PHASE 3: COMPARE WITH PREVIOUS RESULTS
                // ============================================================================
                
                System.debug('\n--- PHASE 3: Comparison with Previous Results ---');
                
                System.debug('🔄 BEFORE (Limited Search):');
                System.debug('  • Found: 2 unique offerings');
                System.debug('  • Data Cloud Foundations (5 records)');
                System.debug('  • Learning Circle EMEA Data Cloud Day Copenhagen May-17 (40 records)');
                
                System.debug('\n✅ AFTER (Enhanced Search):');
                System.debug('  • Found: ' + uniqueOfferings.size() + ' unique offerings');
                
                if (uniqueOfferings.size() > 2) {
                    System.debug('  🎉 SUCCESS: Enhanced search found more variety!');
                    System.debug('  🎯 Intelligent broadening is working');
                } else if (uniqueOfferings.size() == 2) {
                    System.debug('  ⚠️  SAME: Enhanced search found same variety');
                    System.debug('  🎯 Data may be limited for this specific search term');
                } else {
                    System.debug('  ❌ ISSUE: Enhanced search found less variety');
                    System.debug('  🎯 Something may be wrong with the enhancement');
                }
                
                // Show the actual response the user would see
                System.debug('\n🤖 ACTUAL ENHANCED AGENT RESPONSE TO USER:');
                System.debug('I found ' + response.totalRecordCount + ' efficacy records for Data Cloud. Here are the top offerings:');
                
                Integer displayCount = Math.min(5, response.efficacyRecords.size());
                for (Integer i = 0; i < displayCount; i++) {
                    ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record = response.efficacyRecords[i];
                    System.debug((i + 1) + '. ' + record.offeringLabel);
                    System.debug('   Program Type: ' + record.programType);
                    System.debug('   Segment: ' + record.macroSegment);
                    System.debug('   Region: ' + record.region);
                    System.debug('   Effectiveness: ' + record.effectivenessDisplay);
                    System.debug('   Lift: ' + record.liftDisplay);
                    System.debug('   ACV: ' + record.acvDisplay);
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
    System.debug('❌ Error executing enhanced agent logic: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// ============================================================================
// PHASE 4: TEST BROADER SEARCH TERMS
// ============================================================================

System.debug('\n--- PHASE 4: Testing Broader Search Terms ---');

System.debug('🔍 Testing broader search terms to find more variety:');
System.debug('  • "Data" (broader than "Data Cloud")');
System.debug('  • "Analytics" (related to data)');
System.debug('  • "Cloud" (broader cloud offerings)');

// Test broader search directly
try {
    System.debug('\n🔄 Testing "Data" search term...');
    
    ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest broaderRequest = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
    broaderRequest.action = 'Search';
    broaderRequest.offeringLabel = 'Data';
    broaderRequest.maxResults = 10;
    
    List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse> broaderResponses = 
        ANAgentOfferingEfficacyHandlerBasic.analyzeOfferingEfficacy(new List<ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest>{broaderRequest});
    
    if (!broaderResponses.isEmpty()) {
        ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisResponse broaderResponse = broaderResponses[0];
        
        if (broaderResponse.success && broaderResponse.totalRecordCount > 0) {
            Set<String> broaderUniqueOfferings = new Set<String>();
            for (ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record : broaderResponse.efficacyRecords) {
                broaderUniqueOfferings.add(record.offeringLabel);
            }
            
            System.debug('📊 Broader "Data" Search Results:');
            System.debug('  Total Records: ' + broaderResponse.totalRecordCount);
            System.debug('  Unique Offerings: ' + broaderUniqueOfferings.size());
            
            if (broaderUniqueOfferings.size() > 5) {
                System.debug('  ✅ SUCCESS: Broader search found ' + broaderUniqueOfferings.size() + ' offerings!');
                System.debug('  🎯 This confirms the data has variety, just needs broader search terms');
            }
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Error in broader search test: ' + e.getMessage());
}

System.debug('\n🧪 ENHANCED SEARCH TEST COMPLETED');
System.debug('Check the results above to verify the enhancement is working!');

// Helper method for currency formatting
private static String formatCurrency(Decimal value) {
    if (value == null) return 'N/A';
    if (value >= 1000000) {
        return '$' + (value / 1000000).setScale(1) + 'M';
    } else if (value >= 1000) {
        return '$' + (value / 1000).setScale(1) + 'K';
    } else {
        return '$' + value.setScale(0);
    }
} 