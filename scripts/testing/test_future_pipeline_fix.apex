// Test script to verify the Future Pipeline Analysis fix
System.debug('🧪 Testing Future Pipeline Analysis Fix...');

// ========================================
// TEST 1: Basic Future Pipeline Analysis
// ========================================

System.debug('=== TEST 1: Basic Future Pipeline Analysis ===');
try {
    ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest request = new ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest();
    request.analysisType = 'FUTURE_PIPELINE';
    request.operatingUnit = 'AMER ICE';
    
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse> responses = 
        ANAgentFuturePipelineAnalysisHandler.analyzeFuturePipeline(new List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse response = responses[0];
        System.debug('✅ Future Pipeline Results: ' + response.totalRecords + ' records');
        System.debug('📊 Summary: ' + response.message);
        System.debug('🔄 Renewal Count: ' + response.renewalCount);
        System.debug('🔄 Cross-Sell Count: ' + response.crossSellCount);
        System.debug('🔄 Upsell Count: ' + response.upsellCount);
        
        if (response.success) {
            System.debug('🎉 SUCCESS: Future Pipeline Analysis now working!');
            if (response.detailedResults != null) {
                System.debug('📋 Detailed Results: ' + response.detailedResults);
            }
        } else {
            System.debug('⚠️ Response indicates failure: ' + response.message);
        }
    }
} catch (Exception e) {
    System.debug('❌ Future Pipeline Test Failed: ' + e.getMessage());
    System.debug('🔍 Stack Trace: ' + e.getStackTraceString());
}

// ========================================
// TEST 2: Renewals Analysis
// ========================================

System.debug('=== TEST 2: Renewals Analysis ===');
try {
    ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest request = new ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest();
    request.analysisType = 'RENEWALS';
    request.operatingUnit = 'UKI';
    
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse> responses = 
        ANAgentFuturePipelineAnalysisHandler.analyzeFuturePipeline(new List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse response = responses[0];
        System.debug('✅ Renewals Results: ' + response.totalRecords + ' records');
        System.debug('📊 Summary: ' + response.message);
        System.debug('🔄 Renewal Count: ' + response.renewalCount);
        System.debug('💰 Most Important Renewal Amount: ' + response.mostImportantRenewalAmount);
        System.debug('🏷️ Most Important Renewal Product: ' + response.mostImportantRenewalProduct);
        System.debug('💡 Most Important Renewal Reason: ' + response.mostImportantRenewalReason);
        
        if (response.success) {
            System.debug('🎉 SUCCESS: Renewals Analysis now working!');
        } else {
            System.debug('⚠️ Response indicates failure: ' + response.message);
        }
    }
} catch (Exception e) {
    System.debug('❌ Renewals Test Failed: ' + e.getMessage());
    System.debug('🔍 Stack Trace: ' + e.getStackTraceString());
}

// ========================================
// TEST 3: Cross-Sell Analysis
// ========================================

System.debug('=== TEST 3: Cross-Sell Analysis ===');
try {
    ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest request = new ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest();
    request.analysisType = 'CROSS_SELL';
    request.operatingUnit = 'AMER REG';
    
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse> responses = 
        ANAgentFuturePipelineAnalysisHandler.analyzeFuturePipeline(new List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse response = responses[0];
        System.debug('✅ Cross-Sell Results: ' + response.totalRecords + ' records');
        System.debug('📊 Summary: ' + response.message);
        System.debug('🔄 Cross-Sell Count: ' + response.crossSellCount);
        
        if (response.success) {
            System.debug('🎉 SUCCESS: Cross-Sell Analysis now working!');
        } else {
            System.debug('⚠️ Response indicates failure: ' + response.message);
        }
    }
} catch (Exception e) {
    System.debug('❌ Cross-Sell Test Failed: ' + e.getMessage());
    System.debug('🔍 Stack Trace: ' + e.getStackTraceString());
}

// ========================================
// TEST 4: Upsell Analysis
// ========================================

System.debug('=== TEST 4: Upsell Analysis ===');
try {
    ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest request = new ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest();
    request.analysisType = 'UPSELL';
    request.operatingUnit = 'EMEA Central';
    
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse> responses = 
        ANAgentFuturePipelineAnalysisHandler.analyzeFuturePipeline(new List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse response = responses[0];
        System.debug('✅ Upsell Results: ' + response.totalRecords + ' records');
        System.debug('📊 Summary: ' + response.message);
        System.debug('🔄 Upsell Count: ' + response.upsellCount);
        
        if (response.success) {
            System.debug('🎉 SUCCESS: Upsell Analysis now working!');
        } else {
            System.debug('⚠️ Response indicates failure: ' + response.message);
        }
    }
} catch (Exception e) {
    System.debug('❌ Upsell Test Failed: ' + e.getMessage());
    System.debug('🔍 Stack Trace: ' + e.getStackTraceString());
}

System.debug('🎯 Future Pipeline Analysis Fix Test Complete!');
System.debug('📊 The "unexpected token: \'1\'" error should now be resolved!'); 