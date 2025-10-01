// Simple Future Pipeline Generation Test Runner
System.debug('🧪 Running Simple Future Pipeline Generation Tests...');

// Test 1: Incoming Pipeline - All Types (Forward-Looking Only)
System.debug('=== TEST 1: Incoming Pipeline - All Types (Forward-Looking Only) ===');
try {
    ANAgentFuturePipelineAnalysisService.FuturePipelineRequest request = new ANAgentFuturePipelineAnalysisService.FuturePipelineRequest();
    request.analysisType = 'FUTURE_PIPELINE';
    request.maxResults = 1000;
    
    List<ANAgentFuturePipelineAnalysisService.FuturePipelineResponse> responses = 
        ANAgentFuturePipelineAnalysisService.analyzeFuturePipeline(new List<ANAgentFuturePipelineAnalysisService.FuturePipelineRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentFuturePipelineAnalysisService.FuturePipelineResponse response = responses[0];
        System.debug('✅ Incoming Pipeline Analysis Results:');
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Renewal Count: ' + response.renewalCount);
        System.debug('- Cross-Sell Count: ' + response.crossSellCount);
        System.debug('- Upsell Count: ' + response.upsellCount);
        System.debug('- Success: ' + response.success);
        System.debug('- Message: ' + response.message);
    } else {
        System.debug('⚠️ No responses received');
    }
} catch (Exception e) {
    System.debug('❌ Incoming Pipeline Test Failed: ' + e.getMessage());
}

// Test 2: Renewals - Most Important Product by Amount and Why
System.debug('=== TEST 2: Renewals - Most Important Product by Amount and Why ===');
try {
    ANAgentFuturePipelineAnalysisService.FuturePipelineRequest request = new ANAgentFuturePipelineAnalysisService.FuturePipelineRequest();
    request.analysisType = 'RENEWALS';
    request.maxResults = 1000;
    
    List<ANAgentFuturePipelineAnalysisService.FuturePipelineResponse> responses = 
        ANAgentFuturePipelineAnalysisService.analyzeFuturePipeline(new List<ANAgentFuturePipelineAnalysisService.FuturePipelineRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentFuturePipelineAnalysisService.FuturePipelineResponse response = responses[0];
        System.debug('✅ Renewal Analysis Results:');
        System.debug('- Total Renewals: ' + response.renewalCount);
        System.debug('- Most Important Product: ' + response.mostImportantRenewalProduct);
        System.debug('- Most Important Amount: $' + response.mostImportantRenewalAmount);
        System.debug('- Most Important Reason: ' + response.mostImportantRenewalReason);
        System.debug('- Success: ' + response.success);
        System.debug('- Message: ' + response.message);
        
        // Verify the reason includes the amount
        if (response.mostImportantRenewalReason != null && response.mostImportantRenewalAmount != null) {
            String reason = response.mostImportantRenewalReason;
            System.debug('- Reason contains $: ' + reason.contains('$'));
            System.debug('- Reason contains amount: ' + reason.contains(String.valueOf(response.mostImportantRenewalAmount)));
            System.debug('- Reason contains "highest": ' + reason.contains('highest'));
        }
    } else {
        System.debug('⚠️ No responses received');
    }
} catch (Exception e) {
    System.debug('❌ Renewals Test Failed: ' + e.getMessage());
}

// Test 3: Cross-Sell by Account/Product with Segmentation
System.debug('=== TEST 3: Cross-Sell by Account/Product with Segmentation ===');
try {
    // Test Technology vertical
    ANAgentFuturePipelineAnalysisService.FuturePipelineRequest request1 = new ANAgentFuturePipelineAnalysisService.FuturePipelineRequest();
    request1.analysisType = 'CROSS_SELL';
    request1.industry = 'Technology';
    request1.maxResults = 1000;
    
    List<ANAgentFuturePipelineAnalysisService.FuturePipelineResponse> responses1 = 
        ANAgentFuturePipelineAnalysisService.analyzeFuturePipeline(new List<ANAgentFuturePipelineAnalysisService.FuturePipelineRequest>{request1});
    
    if (!responses1.isEmpty()) {
        ANAgentFuturePipelineAnalysisService.FuturePipelineResponse response1 = responses1[0];
        System.debug('✅ Cross-Sell Technology Results:');
        System.debug('- Total Cross-Sell: ' + response1.crossSellCount);
        System.debug('- Detailed Opportunities: ' + response1.crossSellOpportunities.size());
        System.debug('- Success: ' + response1.success);
    }
    
    // Test FINS vertical
    ANAgentFuturePipelineAnalysisService.FuturePipelineRequest request2 = new ANAgentFuturePipelineAnalysisService.FuturePipelineRequest();
    request2.analysisType = 'CROSS_SELL';
    request2.industry = 'FINS';
    request2.maxResults = 1000;
    
    List<ANAgentFuturePipelineAnalysisService.FuturePipelineResponse> responses2 = 
        ANAgentFuturePipelineAnalysisService.analyzeFuturePipeline(new List<ANAgentFuturePipelineAnalysisService.FuturePipelineRequest>{request2});
    
    if (!responses2.isEmpty()) {
        ANAgentFuturePipelineAnalysisService.FuturePipelineResponse response2 = responses2[0];
        System.debug('✅ Cross-Sell FINS Results:');
        System.debug('- Total Cross-Sell: ' + response2.crossSellCount);
        System.debug('- Detailed Opportunities: ' + response2.crossSellOpportunities.size());
        System.debug('- Success: ' + response2.success);
    }
} catch (Exception e) {
    System.debug('❌ Cross-Sell Test Failed: ' + e.getMessage());
}

// Test 4: Off-Sell by Account/Product with Segmentation
System.debug('=== TEST 4: Off-Sell by Account/Product with Segmentation ===');
try {
    // Test AMER ICE operating unit
    ANAgentFuturePipelineAnalysisService.FuturePipelineRequest request1 = new ANAgentFuturePipelineAnalysisService.FuturePipelineRequest();
    request1.analysisType = 'UPSELL'; // Using upsell for off-sell analysis
    request1.operatingUnit = 'AMER ICE';
    request1.maxResults = 1000;
    
    List<ANAgentFuturePipelineAnalysisService.FuturePipelineResponse> responses1 = 
        ANAgentFuturePipelineAnalysisService.analyzeFuturePipeline(new List<ANAgentFuturePipelineAnalysisService.FuturePipelineRequest>{request1});
    
    if (!responses1.isEmpty()) {
        ANAgentFuturePipelineAnalysisService.FuturePipelineResponse response1 = responses1[0];
        System.debug('✅ Off-Sell AMER ICE Results:');
        System.debug('- Total Upsell (Off-Sell): ' + response1.upsellCount);
        System.debug('- Detailed Opportunities: ' + response1.upsellOpportunities.size());
        System.debug('- Success: ' + response1.success);
    }
    
    // Test UKI operating unit
    ANAgentFuturePipelineAnalysisService.FuturePipelineRequest request2 = new ANAgentFuturePipelineAnalysisService.FuturePipelineRequest();
    request2.analysisType = 'UPSELL'; // Using upsell for off-sell analysis
    request2.operatingUnit = 'UKI';
    request2.maxResults = 1000;
    
    List<ANAgentFuturePipelineAnalysisService.FuturePipelineResponse> responses2 = 
        ANAgentFuturePipelineAnalysisService.analyzeFuturePipeline(new List<ANAgentFuturePipelineAnalysisService.FuturePipelineRequest>{request2});
    
    if (!responses2.isEmpty()) {
        ANAgentFuturePipelineAnalysisService.FuturePipelineResponse response2 = responses2[0];
        System.debug('✅ Off-Sell UKI Results:');
        System.debug('- Total Upsell (Off-Sell): ' + response2.upsellCount);
        System.debug('- Detailed Opportunities: ' + response2.upsellOpportunities.size());
        System.debug('- Success: ' + response2.success);
    }
} catch (Exception e) {
    System.debug('❌ Off-Sell Test Failed: ' + e.getMessage());
}

// Test 5: Verify Forward-Looking Data Separation
System.debug('=== TEST 5: Forward-Looking Data Separation ===');
try {
    // Query records to verify separation between current and future pipeline
    List<AGENT_OU_PIPELINE_V2__c> records = [
        SELECT cq_pg__c, cq_acv__c, renewal_opty_amt_1__c, cs_next_best_product_1__c, upsell_sub_category_1__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE renewal_opty_amt_1__c != null 
        OR cs_next_best_product_1__c != null 
        OR upsell_sub_category_1__c != null
        LIMIT 5
    ];
    
    if (!records.isEmpty()) {
        System.debug('✅ Forward-Looking Data Verification:');
        System.debug('- Records with future data: ' + records.size());
        
        for (Integer i = 0; i < records.size(); i++) {
            AGENT_OU_PIPELINE_V2__c record = records[i];
            System.debug('- Record ' + (i+1) + ':');
            System.debug('  * Current Pipeline (CQ_PG): $' + record.cq_pg__c);
            System.debug('  * Current ACV (CQ_ACV): $' + record.cq_acv__c);
            System.debug('  * Future Renewal Amount: $' + record.renewal_opty_amt_1__c);
            System.debug('  * Future Cross-Sell Product: ' + record.cs_next_best_product_1__c);
            System.debug('  * Future Off-Sell Product: ' + record.upsell_sub_category_1__c);
        }
    } else {
        System.debug('⚠️ No records with future pipeline data found');
    }
} catch (Exception e) {
    System.debug('❌ Forward-Looking Data Verification Failed: ' + e.getMessage());
}

System.debug('🎯 All Simple Future Pipeline Generation Tests Completed!'); 