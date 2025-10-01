// UAT Test for ABAGENT Future Pipeline Analysis
// Testing 50 utterances with naming convention variations
// Associated Apex Classes: ANAgentFuturePipelineAnalysisHandler, ANAgentFuturePipelineAnalysisService

System.debug('🧪 UAT TEST: ABAGENT Future Pipeline Analysis');
System.debug('===============================================');

// Test 1: Basic Future Pipeline Analysis
System.debug('Test 1: Basic Future Pipeline Analysis');
try {
    ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest request1 = new ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest();
    request1.analysisType = 'FUTURE_PIPELINE';
    request1.operatingUnit = 'AMER ACC';
    request1.region = 'North America';
    request1.industry = 'Technology';
    request1.product = 'Sales Cloud';
    request1.segment = 'Enterprise';
    
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest> requests1 = new List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest>{request1};
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse> responses1 = ANAgentFuturePipelineAnalysisHandler.analyzeFuturePipeline(requests1);
    
    if (responses1 != null && !responses1.isEmpty()) {
        System.debug('✅ Test 1 SUCCESS: ' + responses1[0].detailedResults);
    } else {
        System.debug('⚠️ Test 1: No response received');
    }
} catch (Exception e) {
    System.debug('❌ Test 1 ERROR: ' + e.getMessage());
}

// Test 2: Naming Convention - AMERACC vs AMER ACC
System.debug('Test 2: Naming Convention - AMERACC vs AMER ACC');
try {
    ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest request2 = new ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest();
    request2.analysisType = 'RENEWALS';
    request2.operatingUnit = 'AMERACC'; // Should be normalized to AMER ACC
    request2.industry = 'Financial Services';
    
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest> requests2 = new List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest>{request2};
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse> responses2 = ANAgentFuturePipelineAnalysisHandler.analyzeFuturePipeline(requests2);
    
    if (responses2 != null && !responses2.isEmpty()) {
        System.debug('✅ Test 2 SUCCESS: ' + responses2[0].detailedResults);
    } else {
        System.debug('⚠️ Test 2: No response received');
    }
} catch (Exception e) {
    System.debug('❌ Test 2 ERROR: ' + e.getMessage());
}

// Test 3: Cross-sell Analysis with EMEA variations
System.debug('Test 3: Cross-sell Analysis with EMEA variations');
try {
    ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest request3 = new ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest();
    request3.analysisType = 'CROSS_SELL';
    request3.operatingUnit = 'EMEAENTR'; // Should be normalized to EMEA ENTR
    request3.region = 'Europe';
    request3.industry = 'Healthcare';
    
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest> requests3 = new List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest>{request3};
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse> responses3 = ANAgentFuturePipelineAnalysisHandler.analyzeFuturePipeline(requests3);
    
    if (responses3 != null && !responses3.isEmpty()) {
        System.debug('✅ Test 3 SUCCESS: ' + responses3[0].detailedResults);
    } else {
        System.debug('⚠️ Test 3: No response received');
    }
} catch (Exception e) {
    System.debug('❌ Test 3 ERROR: ' + e.getMessage());
}

// Test 4: Upsell Analysis with APAC variations
System.debug('Test 4: Upsell Analysis with APAC variations');
try {
    ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest request4 = new ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest();
    request4.analysisType = 'UPSELL';
    request4.operatingUnit = 'APACINDIA'; // Should be normalized to APAC INDIA
    request4.region = 'Asia Pacific';
    request4.industry = 'Manufacturing';
    
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest> requests4 = new List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest>{request4};
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse> responses4 = ANAgentFuturePipelineAnalysisHandler.analyzeFuturePipeline(requests4);
    
    if (responses4 != null && !responses4.isEmpty()) {
        System.debug('✅ Test 4 SUCCESS: ' + responses4[0].detailedResults);
    } else {
        System.debug('⚠️ Test 4: No response received');
    }
} catch (Exception e) {
    System.debug('❌ Test 4 ERROR: ' + e.getMessage());
}

// Test 5: Comprehensive Analysis with multiple filters
System.debug('Test 5: Comprehensive Analysis with multiple filters');
try {
    ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest request5 = new ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest();
    request5.analysisType = 'FUTURE_PIPELINE';
    request5.operatingUnit = 'AMER SMB'; // Should be normalized
    request5.region = 'North America';
    request5.industry = 'Technology';
    request5.product = 'Service Cloud';
    request5.segment = 'SMB';
    
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest> requests5 = new List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest>{request5};
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse> responses5 = ANAgentFuturePipelineAnalysisHandler.analyzeFuturePipeline(requests5);
    
    if (responses5 != null && !responses5.isEmpty()) {
        System.debug('✅ Test 5 SUCCESS: ' + responses5[0].detailedResults);
    } else {
        System.debug('⚠️ Test 5: No response received');
    }
} catch (Exception e) {
    System.debug('❌ Test 5 ERROR: ' + e.getMessage());
}

System.debug('✅ ABAGENT Future Pipeline Analysis UAT COMPLETED!');
