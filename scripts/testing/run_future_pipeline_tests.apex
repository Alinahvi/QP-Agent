// Run Future Pipeline Generation Tests
System.debug('🧪 Running Future Pipeline Generation Tests...');

// Test 1: Incoming Pipeline - All Types (Forward-Looking Only)
System.debug('=== TEST 1: Incoming Pipeline - All Types (Forward-Looking Only) ===');
try {
    ANAgentFuturePipelineGenerationTest.test_IncomingPipeline_AllTypes_ForwardLookingOnly();
    System.debug('✅ Incoming Pipeline Test PASSED');
} catch (Exception e) {
    System.debug('❌ Incoming Pipeline Test FAILED: ' + e.getMessage());
}

// Test 2: Renewals - Most Important Product by Amount and Why
System.debug('=== TEST 2: Renewals - Most Important Product by Amount and Why ===');
try {
    ANAgentFuturePipelineGenerationTest.test_Renewals_MostImportantProduct_WhyByAmount();
    System.debug('✅ Renewals Test PASSED');
} catch (Exception e) {
    System.debug('❌ Renewals Test FAILED: ' + e.getMessage());
}

// Test 3: Cross-Sell by Account/Product with Segmentation
System.debug('=== TEST 3: Cross-Sell by Account/Product with Segmentation ===');
try {
    ANAgentFuturePipelineGenerationTest.test_CrossSell_ByAccountProduct_WithSegmentation();
    System.debug('✅ Cross-Sell Test PASSED');
} catch (Exception e) {
    System.debug('❌ Cross-Sell Test FAILED: ' + e.getMessage());
}

// Test 4: Off-Sell by Account/Product with Segmentation
System.debug('=== TEST 4: Off-Sell by Account/Product with Segmentation ===');
try {
    ANAgentFuturePipelineGenerationTest.test_OffSell_ByAccountProduct_WithSegmentation();
    System.debug('✅ Off-Sell Test PASSED');
} catch (Exception e) {
    System.debug('❌ Off-Sell Test FAILED: ' + e.getMessage());
}

// Test 5: Forward-Looking Only (Not Current Pipeline)
System.debug('=== TEST 5: Forward-Looking Only (Not Current Pipeline) ===');
try {
    ANAgentFuturePipelineGenerationTest.test_ForwardLookingOnly_NotCurrentPipeline();
    System.debug('✅ Forward-Looking Only Test PASSED');
} catch (Exception e) {
    System.debug('❌ Forward-Looking Only Test FAILED: ' + e.getMessage());
}

System.debug('🎯 All Future Pipeline Generation Tests Completed!'); 