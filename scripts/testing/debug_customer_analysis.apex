// Debug script for Customer Analysis
System.debug('🔍 DEBUGGING CUSTOMER ANALYSIS');

// Test the customer analysis service directly
try {
    System.debug('🧪 Testing Customer Analysis Service...');
    
    ANAgentOpenPipeAnalysisService.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisService.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS_BY_OPENPIPE';
    request.operatingUnit = 'AMER ICE';
    
    ANAgentOpenPipeAnalysisService.OpenPipeAnalysisResponse response = 
        ANAgentOpenPipeAnalysisService.analyzeOpenPipe(request);
    
    System.debug('Service Response:');
    System.debug('Success: ' + response.success);
    System.debug('Message: ' + response.message);
    System.debug('Analysis Type: ' + response.analysisType);
    System.debug('Total Records: ' + response.totalRecords);
    System.debug('Summary: ' + response.summary);
    
    if (response.detailedResults != null && response.detailedResults.size() > 0) {
        System.debug('Top Customers Found: ' + response.detailedResults.size());
        
        // Check the ranking
        for (Integer i = 0; i < response.detailedResults.size(); i++) {
            ANAgentOpenPipeAnalysisService.OpenPipeAnalysisResult result = response.detailedResults[i];
            System.debug('Customer ' + (i+1) + ': ' + result.customerName + ' - $' + result.amount + ' - AE: ' + result.aeName);
        }
        
        // Verify ranking manually
        if (response.detailedResults.size() > 1) {
            System.debug('=== RANKING VERIFICATION ===');
            for (Integer i = 1; i < response.detailedResults.size(); i++) {
                Decimal previousAmount = response.detailedResults[i-1].amount;
                Decimal currentAmount = response.detailedResults[i].amount;
                System.debug('Customer ' + i + ' vs ' + (i+1) + ': $' + previousAmount + ' vs $' + currentAmount + ' - ' + (previousAmount >= currentAmount ? '✅ Correct' : '❌ Wrong Order'));
            }
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Error testing customer analysis: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('🔍 CUSTOMER ANALYSIS DEBUG COMPLETE'); 