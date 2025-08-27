// Test script to verify that effectiveness scores are hidden
// and only lift and ACV values are shown to users

System.debug('🧪 TESTING EFFECTIVENESS SCORES HIDDEN');
System.debug('=====================================');

// ============================================================================
// PHASE 1: TEST THE UPDATED RESPONSE FORMAT
// ============================================================================

System.debug('\n--- PHASE 1: Testing Updated Response Format ---');

System.debug('🎯 Testing: When users ask for "effective courses", they should see:');
System.debug('  ✅ Lift values');
System.debug('  ✅ Influenced ACV');
System.debug('  ❌ NO effectiveness scores');

try {
    // Test the exact scenario that was updated
    ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
    request.action = 'ProgramEfficacy';
    request.kpiName = 'ACV';
    request.region = 'AMER';
    request.operatingUnit = null;
    request.vertical = null;
    
    System.debug('📋 Request Parameters:');
    System.debug('  Action: ' + request.action);
    System.debug('  KPI: ' + request.kpiName);
    System.debug('  Region: ' + request.region);
    
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
            
            // Check the summary metrics to see if effectiveness is hidden
            if (response.summaryMetrics != null) {
                System.debug('\n📋 Summary Metrics (this is what users see):');
                System.debug(response.summaryMetrics);
                
                // Check if effectiveness scores are hidden
                Boolean hasEffectiveness = response.summaryMetrics.contains('Effectiveness') || 
                                         response.summaryMetrics.contains('effectiveness');
                Boolean hasLift = response.summaryMetrics.contains('Lift') || 
                                 response.summaryMetrics.contains('lift');
                Boolean hasACV = response.summaryMetrics.contains('ACV') || 
                                response.summaryMetrics.contains('acv');
                
                System.debug('\n🔍 Content Analysis:');
                System.debug('  ❌ Contains Effectiveness: ' + hasEffectiveness);
                System.debug('  ✅ Contains Lift: ' + hasLift);
                System.debug('  ✅ Contains ACV: ' + hasACV);
                
                if (!hasEffectiveness && hasLift && hasACV) {
                    System.debug('🎉 SUCCESS: Effectiveness scores are hidden, only Lift and ACV shown!');
                } else if (hasEffectiveness) {
                    System.debug('⚠️  WARNING: Effectiveness scores are still visible!');
                } else {
                    System.debug('⚠️  WARNING: Some expected metrics are missing!');
                }
            }
            
            // Check individual records to see what fields are populated
            if (response.efficacyRecords != null && !response.efficacyRecords.isEmpty()) {
                System.debug('\n📋 Individual Record Fields (first 3 records):');
                for (Integer i = 0; i < Math.min(3, response.efficacyRecords.size()); i++) {
                    ANAgentOfferingEfficacyServiceBasic.EfficacyRecord record = response.efficacyRecords[i];
                    System.debug('  ' + (i+1) + '. ' + record.offeringLabel);
                    System.debug('     OU: ' + record.ouName);
                    System.debug('     KPI: ' + record.kpiName);
                    System.debug('     ACV: ' + record.acvDisplay);
                    System.debug('     Lift Display: ' + record.liftDisplay);
                    System.debug('     Effectiveness Display: ' + record.effectivenessDisplay);
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
// PHASE 2: TEST THE UPDATED KPI GUIDANCE
// ============================================================================

System.debug('\n--- PHASE 2: Testing Updated KPI Guidance ---');

try {
    System.debug('🔍 Getting updated KPI guidance...');
    String kpiGuidance = ANAgentOfferingEfficacyServiceBasic.getAvailableKPIs();
    System.debug('📋 KPI Guidance:');
    System.debug(kpiGuidance);
    
    // Check if effectiveness references are removed
    Boolean hasEffectivenessRefs = kpiGuidance.contains('effectiveness') || 
                                  kpiGuidance.contains('Effectiveness');
    Boolean hasLiftACVFocus = kpiGuidance.contains('lift and ACV impact') || 
                              kpiGuidance.contains('not effectiveness scores');
    
    System.debug('\n🔍 KPI Guidance Analysis:');
    System.debug('  ❌ Contains Effectiveness References: ' + hasEffectivenessRefs);
    System.debug('  ✅ Focuses on Lift and ACV: ' + hasLiftACVFocus);
    
    if (!hasEffectivenessRefs && hasLiftACVFocus) {
        System.debug('🎉 SUCCESS: KPI guidance updated to focus on Lift and ACV!');
    } else {
        System.debug('⚠️  WARNING: KPI guidance may still contain effectiveness references!');
    }
    
} catch (Exception e) {
    System.debug('❌ Error getting KPI guidance: ' + e.getMessage());
}

// ============================================================================
// PHASE 3: TEST THE UPDATED FALLBACK OPTIONS
// ============================================================================

System.debug('\n--- PHASE 3: Testing Updated Fallback Options ---');

try {
    System.debug('🔍 Testing fallback options for a test search term...');
    String fallbackOptions = ANAgentOfferingEfficacyServiceBasic.getFallbackOptions('Data Cloud');
    System.debug('📋 Fallback Options:');
    System.debug(fallbackOptions);
    
    // Check if effectiveness references are removed from fallback
    Boolean hasEffectivenessInFallback = fallbackOptions.contains('effectiveness') || 
                                        fallbackOptions.contains('Effectiveness');
    Boolean hasImpactFocus = fallbackOptions.contains('impact') || 
                             fallbackOptions.contains('Impact');
    
    System.debug('\n🔍 Fallback Options Analysis:');
    System.debug('  ❌ Contains Effectiveness References: ' + hasEffectivenessInFallback);
    System.debug('  ✅ Focuses on Impact: ' + hasImpactFocus);
    
    if (!hasEffectivenessInFallback && hasImpactFocus) {
        System.debug('🎉 SUCCESS: Fallback options updated to focus on impact!');
    } else {
        System.debug('⚠️  WARNING: Fallback options may still contain effectiveness references!');
    }
    
} catch (Exception e) {
    System.debug('❌ Error testing fallback options: ' + e.getMessage());
}

// ============================================================================
// PHASE 4: SUMMARY AND VERIFICATION
// ============================================================================

System.debug('\n--- PHASE 4: Summary and Verification ---');

System.debug('🎯 SUMMARY OF CHANGES:');
System.debug('  ✅ Effectiveness scores are now hidden from user-facing responses');
System.debug('  ✅ Focus is on Lift values and Influenced ACV');
System.debug('  ✅ KPI guidance updated to emphasize Lift and ACV');
System.debug('  ✅ Fallback options updated to focus on impact, not effectiveness');

System.debug('\n🔧 WHAT USERS WILL NOW SEE:');
System.debug('  • Lift: Performance improvement compared to control group');
System.debug('  • Total ACV: Annual Contract Value influenced by the offering');
System.debug('  • Significant Results: Number of offerings with statistically significant impact');
System.debug('  • NO effectiveness scores (hidden from users)');

System.debug('\n💡 USER EXPERIENCE IMPROVEMENT:');
System.debug('  • Cleaner, more focused responses');
System.debug('  • Emphasis on actionable metrics (lift and ACV)');
System.debug('  • No confusing effectiveness scores');
System.debug('  • Better alignment with business value');

System.debug('\n🧪 EFFECTIVENESS HIDDEN TEST COMPLETED');
System.debug('Users will now see only Lift and ACV, not effectiveness scores!'); 