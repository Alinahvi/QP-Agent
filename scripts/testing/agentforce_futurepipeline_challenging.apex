// Challenging Future Pipeline Analysis - Big List with Comprehensive Analysis
// Use this in Agentforce for comprehensive future pipeline insights across multiple dimensions

// Comprehensive analysis across multiple OUs and industries
List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest> requests = new List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest>();

// 1. AMER ICE Technology - All Types
ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest request1 = new ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest();
request1.analysisType = 'FUTURE_PIPELINE';
request1.operatingUnit = 'AMER ICE';
request1.industry = 'Technology';
request1.maxResults = 100;
requests.add(request1);

// 2. UKI FINS - Renewals Focus
ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest request2 = new ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest();
request2.analysisType = 'RENEWALS';
request2.operatingUnit = 'UKI';
request2.industry = 'FINS';
request2.maxResults = 100;
requests.add(request2);

// 3. LATAM Manufacturing - Cross-Sell Focus
ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest request3 = new ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest();
request3.analysisType = 'CROSS_SELL';
request3.operatingUnit = 'LATAM';
request3.industry = 'Manufacturing';
request3.maxResults = 100;
requests.add(request3);

// 4. EMEA HLS - Upsell Focus
ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest request4 = new ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest();
request4.analysisType = 'UPSELL';
request4.operatingUnit = 'EMEA';
request4.industry = 'HLS';
request4.maxResults = 100;
requests.add(request4);

// Execute all analyses
List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse> responses = 
    ANAgentFuturePipelineAnalysisHandler.analyzeFuturePipeline(requests);

System.debug('=== Challenging Future Pipeline Analysis Results ===');
System.debug('Total Requests: ' + requests.size());
System.debug('Total Responses: ' + responses.size());

// Process each response with detailed analysis
for (Integer i = 0; i < responses.size(); i++) {
    ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse response = responses[i];
    ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest req = requests[i];
    
    System.debug('--- Analysis ' + (i+1) + ': ' + req.analysisType + ' (' + req.operatingUnit + ' - ' + req.industry + ') ---');
    System.debug('Success: ' + response.success);
    System.debug('Message: ' + response.message);
    System.debug('Total Records: ' + response.totalRecords);
    
    if (req.analysisType == 'FUTURE_PIPELINE') {
        System.debug('Comprehensive Results:');
        System.debug('- Renewal Count: ' + response.renewalCount);
        System.debug('- Cross-Sell Count: ' + response.crossSellCount);
        System.debug('- Upsell Count: ' + response.upsellCount);
        System.debug('- Most Important Renewal: ' + response.mostImportantRenewalProduct + ' ($' + response.mostImportantRenewalAmount + ')');
    } else if (req.analysisType == 'RENEWALS') {
        System.debug('Renewal Analysis:');
        System.debug('- Total Renewals: ' + response.renewalCount);
        System.debug('- Most Important Product: ' + response.mostImportantRenewalProduct);
        System.debug('- Most Important Amount: $' + response.mostImportantRenewalAmount);
        System.debug('- Most Important Reason: ' + response.mostImportantRenewalReason);
        System.debug('- Detailed Opportunities: ' + response.renewalOpportunities.size());
    } else if (req.analysisType == 'CROSS_SELL') {
        System.debug('Cross-Sell Analysis:');
        System.debug('- Total Cross-Sell: ' + response.crossSellCount);
        System.debug('- Detailed Opportunities: ' + response.crossSellOpportunities.size());
        if (!response.crossSellOpportunities.isEmpty()) {
            System.debug('- Sample Opportunity: ' + response.crossSellOpportunities[0]);
        }
    } else if (req.analysisType == 'UPSELL') {
        System.debug('Upsell Analysis:');
        System.debug('- Total Upsell: ' + response.upsellCount);
        System.debug('- Detailed Opportunities: ' + response.upsellOpportunities.size());
        if (!response.upsellOpportunities.isEmpty()) {
            System.debug('- Sample Opportunity: ' + response.upsellOpportunities[0]);
        }
    }
    
    System.debug('---');
} 