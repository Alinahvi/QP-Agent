// Test script for Enhanced Future Pipeline Analysis Features
// Tests the four new features: PMF Analysis, Actionable Insights, Rich Formatting, and Executive Summaries

System.debug('=== ENHANCED FUTURE PIPELINE ANALYSIS FEATURES TEST ===');

// Test 1: Renewals Analysis with Enhanced Features
System.debug('--- Test 1: Renewals Analysis with Enhanced Features ---');
ABAgentFuturePipeAnalysisHandler.Request request1 = new ABAgentFuturePipeAnalysisHandler.Request();
request1.analysisType = 'RENEWALS';
request1.ouName = 'AMER ICE';
request1.groupBy = 'PRODUCT';
request1.limitN = 10;

List<ABAgentFuturePipeAnalysisHandler.Response> responses1 = 
    ABAgentFuturePipeAnalysisHandler.analyzePipeline(new List<ABAgentFuturePipeAnalysisHandler.Request>{request1});

System.debug('✅ Renewals Analysis Response:');
System.debug(responses1[0].message);

// Test 2: Cross-Sell Analysis with Enhanced Features
System.debug('\n--- Test 2: Cross-Sell Analysis with Enhanced Features ---');
ABAgentFuturePipeAnalysisHandler.Request request2 = new ABAgentFuturePipeAnalysisHandler.Request();
request2.analysisType = 'CROSS_SELL';
request2.workLocationCountry = 'Canada';
request2.groupBy = 'AE';
request2.limitN = 8;

List<ABAgentFuturePipeAnalysisHandler.Response> responses2 = 
    ABAgentFuturePipeAnalysisHandler.analyzePipeline(new List<ABAgentFuturePipeAnalysisHandler.Request>{request2});

System.debug('✅ Cross-Sell Analysis Response:');
System.debug(responses2[0].message);

// Test 3: Upsell Analysis with Enhanced Features
System.debug('\n--- Test 3: Upsell Analysis with Enhanced Features ---');
ABAgentFuturePipeAnalysisHandler.Request request3 = new ABAgentFuturePipeAnalysisHandler.Request();
request3.analysisType = 'UPSELL';
request3.ouName = 'LATAM';
request3.groupBy = 'INDUSTRY';
request3.limitN = 12;

List<ABAgentFuturePipeAnalysisHandler.Response> responses3 = 
    ABAgentFuturePipeAnalysisHandler.analyzePipeline(new List<ABAgentFuturePipeAnalysisHandler.Request>{request3});

System.debug('✅ Upsell Analysis Response:');
System.debug(responses3[0].message);

// Test 4: Feature Validation
System.debug('\n=== FEATURE VALIDATION ===');

// Check for Executive Summary
if (responses1[0].message.contains('🎯 Executive Summary')) {
    System.debug('✅ Executive Summary: PRESENT');
} else {
    System.debug('❌ Executive Summary: MISSING');
}

// Check for Rich Formatting (Emojis)
if (responses1[0].message.contains('🔄') || responses1[0].message.contains('📊') || responses1[0].message.contains('💰')) {
    System.debug('✅ Rich Formatting (Emojis): PRESENT');
} else {
    System.debug('❌ Rich Formatting (Emojis): MISSING');
}

// Check for PMF Analysis
if (responses1[0].message.contains('🎯 Product-Market Fit Analysis')) {
    System.debug('✅ PMF Analysis: PRESENT');
} else {
    System.debug('❌ PMF Analysis: MISSING');
}

// Check for Actionable Insights
if (responses1[0].message.contains('💡 Actionable Insights')) {
    System.debug('✅ Actionable Insights: PRESENT');
} else {
    System.debug('❌ Actionable Insights: MISSING');
}

// Test 5: Cross-Sell Feature Validation
System.debug('\n--- Cross-Sell Feature Validation ---');
if (responses2[0].message.contains('🎯') && responses2[0].message.contains('Cross-Sell')) {
    System.debug('✅ Cross-Sell Analysis with Emojis: PRESENT');
} else {
    System.debug('❌ Cross-Sell Analysis with Emojis: MISSING');
}

// Test 6: Upsell Feature Validation
System.debug('\n--- Upsell Feature Validation ---');
if (responses3[0].message.contains('📈') && responses3[0].message.contains('Upsell')) {
    System.debug('✅ Upsell Analysis with Emojis: PRESENT');
} else {
    System.debug('❌ Upsell Analysis with Emojis: MISSING');
}

System.debug('\n=== ENHANCED FEATURES TEST COMPLETE ===');
