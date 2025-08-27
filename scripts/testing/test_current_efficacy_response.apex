// Test script to verify current efficacy response format
// This will show us if effectiveness scores are still visible

System.debug('🧪 TESTING CURRENT EFFICACY RESPONSE FORMAT');
System.debug('==========================================');

try {
    // Test the exact scenario: "Data Cloud" efficacy search
    ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest request = new ANAgentOfferingEfficacyHandlerBasic.EfficacyAnalysisRequest();
    request.action = 'Search';
    request.offeringLabel = 'Data Cloud';
    request.kpiName = null;
    request.region = null;
    request.operatingUnit = null;
    request.vertical = null;
    
    System.debug('📋 Request Parameters:');
    System.debug('  Action: ' + request.action);
    System.debug('  Offering Label: ' + request.offeringLabel);
    System.debug('  KPI: ' + request.kpiName);
    
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
                    System.debug('🔧 This means the updated code is not being used by the agent.');
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

System.debug('\n🎯 DIAGNOSIS:');
System.debug('If effectiveness scores are still visible, it means:');
System.debug('  1. The agent is using an old version of the service class');
System.debug('  2. There might be a caching issue');
System.debug('  3. The deployment might not have taken effect');
System.debug('  4. The agent might be calling a different method');

System.debug('\n🔧 NEXT STEPS:');
System.debug('  1. Verify the deployment was successful');
System.debug('  2. Check if the agent is using the correct service class');
System.debug('  3. Clear any caches if necessary');
System.debug('  4. Test with a fresh agent session'); 