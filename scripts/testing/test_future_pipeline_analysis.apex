// Test script for Future Pipeline Analysis
// This script demonstrates the future-looking pipeline generation analysis functionality

System.debug('=== FUTURE PIPELINE ANALYSIS DEMONSTRATION ===');

// Test 1: Analyze all future pipeline types
System.debug('--- Test 1: All Future Pipeline Types ---');
ANAgentFuturePipelineAnalysisService.FuturePipelineRequest request1 = new ANAgentFuturePipelineAnalysisService.FuturePipelineRequest();
request1.analysisType = 'FUTURE_PIPELINE';
request1.operatingUnit = 'AMER ICE';

ANAgentFuturePipelineAnalysisService.FuturePipelineResponse response1 = 
    ANAgentFuturePipelineAnalysisService.analyzeFuturePipeline(request1);

System.debug('Success: ' + response1.success);
System.debug('Message: ' + response1.message);
System.debug('Total Records: ' + response1.totalRecords);
System.debug('Upsell Count: ' + response1.upsellCount);
System.debug('Cross-sell Count: ' + response1.crossSellCount);
System.debug('Renewal Count: ' + response1.renewalCount);

if (response1.mostImportantRenewalProduct != null) {
    System.debug('Most Important Renewal Product: ' + response1.mostImportantRenewalProduct);
    System.debug('Most Important Renewal Amount: $' + response1.mostImportantRenewalAmount);
    System.debug('Reason: ' + response1.mostImportantRenewalReason);
}

// Test 2: Analyze renewals specifically
System.debug('--- Test 2: Renewals Analysis ---');
ANAgentFuturePipelineAnalysisService.FuturePipelineRequest request2 = new ANAgentFuturePipelineAnalysisService.FuturePipelineRequest();
request2.analysisType = 'RENEWALS';
request2.operatingUnit = 'AMER ICE';

ANAgentFuturePipelineAnalysisService.FuturePipelineResponse response2 = 
    ANAgentFuturePipelineAnalysisService.analyzeFuturePipeline(request2);

System.debug('Renewal Analysis Success: ' + response2.success);
System.debug('Renewal Count: ' + response2.renewalCount);
System.debug('Most Important Product: ' + response2.mostImportantRenewalProduct);
System.debug('Most Important Amount: $' + response2.mostImportantRenewalAmount);

// Test 3: Analyze cross-sell with filtering
System.debug('--- Test 3: Cross-sell Analysis with Industry Filter ---');
ANAgentFuturePipelineAnalysisService.FuturePipelineRequest request3 = new ANAgentFuturePipelineAnalysisService.FuturePipelineRequest();
request3.analysisType = 'CROSS_SELL';
request3.industry = 'Technology';

ANAgentFuturePipelineAnalysisService.FuturePipelineResponse response3 = 
    ANAgentFuturePipelineAnalysisService.analyzeFuturePipeline(request3);

System.debug('Cross-sell Analysis Success: ' + response3.success);
System.debug('Cross-sell Count: ' + response3.crossSellCount);
System.debug('Total Records (filtered): ' + response3.totalRecords);

// Test 4: Analyze upsell with segmentation
System.debug('--- Test 4: Upsell Analysis with Segment Filter ---');
ANAgentFuturePipelineAnalysisService.FuturePipelineRequest request4 = new ANAgentFuturePipelineAnalysisService.FuturePipelineRequest();
request4.analysisType = 'UPSELL';
request4.segment = 'ICE';

ANAgentFuturePipelineAnalysisService.FuturePipelineResponse response4 = 
    ANAgentFuturePipelineAnalysisService.analyzeFuturePipeline(request4);

System.debug('Upsell Analysis Success: ' + response4.success);
System.debug('Upsell Count: ' + response4.upsellCount);
System.debug('Total Records (filtered): ' + response4.totalRecords);

// Show sample opportunities
System.debug('--- Sample Opportunities ---');
if (response1.upsellOpportunities.size() > 0) {
    System.debug('Sample Upsell: ' + response1.upsellOpportunities[0].accountName + ' - ' + response1.upsellOpportunities[0].product);
}
if (response1.crossSellOpportunities.size() > 0) {
    System.debug('Sample Cross-sell: ' + response1.crossSellOpportunities[0].accountName + ' - ' + response1.crossSellOpportunities[0].product);
}
if (response1.renewalOpportunities.size() > 0) {
    System.debug('Sample Renewal: ' + response1.renewalOpportunities[0].accountName + ' - $' + response1.renewalOpportunities[0].renewalAmount);
}

System.debug('=== DEMONSTRATION COMPLETE ==='); 