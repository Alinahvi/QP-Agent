// Test script for the updated ANAgentUnifiedTSVService with pre-formatted TSV data
System.debug('=== TESTING UPDATED SERVICE WITH PRE-FORMATTED TSV DATA ===\n');

// Test data from your conversation - already in TSV format
String preFormattedData = 'Email\tName\tProduct\tAmount\tCustomer\n' +
    'cwhittington@salesforce.com\tCasey Whittington\tAdjustment - Unallocated\t1000000\tTyson - Transformation Budget - Upside - E1 (+1500), CPQ (+1,000), CPF (+2,000)\n' +
    'cjowers@salesforce.com\tCecily Jowers\tAdjustment - Unallocated\t2136000\tVizio Hardware - Service A1E Upgrade\n' +
    'nate.justice@salesforce.com\tNate Justice\tAdjustment - Unallocated\t116000\tSouthland Transportation-Auto Cloud Upgrade (+25) | Mulesoft Starter\n' +
    'vkillmer@salesforce.com\tTori Killmer\tAdjustment - Unallocated\t422896\tPenske IT: Employee Case Mgmt (Phase 1 FootPrints Replacement) - #getontheboard\n' +
    'cwhittington@salesforce.com\tCasey Whittington\tConsumer Goods Cloud - Trade Promotion Management - UE\t500000\tTyson Foods CRM Transformation E1 (+1,000), CPF (+1,000)\n' +
    'julia.donahue@salesforce.com\tJulia Donahue\tConsumer Goods Cloud - Trade Promotion Management - UE\t409600\tCGC - Kellanova - LAND - TPM\n' +
    'apiwonski@salesforce.com\tAdrian Piwonski\tSlack Enterprise Plus\t675000\tEQT - (+2250) Slack Enterprise+\n' +
    'bill.miller@salesforce.com\tBill Miller\tSlack Enterprise Plus\t229440\t(Child*) Thales (SLK Enterprise+ Expansion +4800)\n' +
    'cstiglic@salesforce.com\tColby Stiglic\tConsumer Goods Cloud - Trade Promotion Management - Enterprise Edition\t489999.96\tHometown Food Company- CG Cloud (TPM + TPO)\n' +
    'ivette.johnson@salesforce.com\tIvette Johnson\tField Service+ - Enterprise Edition\t1320\tGolden State Window and Door (+10) 10 Field Service + VRA + Agentforce #getontheboard\n' +
    'jennifer.vega@salesforce.com\tJennifer Vega\tField Service+ - Enterprise Edition\t714345.62\tOpex Corporation - (+150) FSL & (+950) Technicians RFP\n' +
    'kmccurdy@salesforce.com\tKendall McCurdy\tField Service+ - Enterprise Edition\t63360\tGreenrise Technologies - (+60) 60 SFS + (+113) 113 Technicians + Agentforce\n' +
    'mnorris@salesforce.com\tMadison Norris\tField Service+ - Enterprise Edition\t60720\tOasis Group of PA - (+42) 39 FSL+ + 3 DE #getontheboard';

System.debug('Input data format: Pre-formatted TSV with ' + countRecords(preFormattedData) + ' records');
System.debug('First few lines:');
List<String> lines = preFormattedData.split('\n');
for (Integer i = 0; i < Math.min(3, lines.size()); i++) {
    System.debug('Line ' + (i+1) + ': ' + lines[i]);
}

// Test the updated service
System.debug('=== TESTING UPDATED SERVICE ===');
try {
    // Create request
    ANAgentUnifiedTSVService.TSVRequest request = new ANAgentUnifiedTSVService.TSVRequest();
    request.textData = preFormattedData;
    request.businessScenario = 'OpenPipe'; // Any scenario will work now
    request.fileName = 'AE_Opportunities_Export.tsv';
    request.description = 'AE opportunities export with email, name, product, amount, and customer';
    request.requestId = 'TEST-PREFORMATTED-001';
    request.maxRecords = null; // No limit
    
    List<ANAgentUnifiedTSVService.TSVRequest> requests = new List<ANAgentUnifiedTSVService.TSVRequest>{request};
    
    // Call the updated service
    List<ANAgentUnifiedTSVService.TSVResponse> responses = ANAgentUnifiedTSVService.convertBusinessDataToTSV(requests);
    
    if (!responses.isEmpty()) {
        ANAgentUnifiedTSVService.TSVResponse response = responses[0];
        System.debug('Service Response:');
        System.debug('Success: ' + response.success);
        System.debug('Message: ' + response.message);
        System.debug('Record Count: ' + response.recordCount);
        System.debug('File Name: ' + response.fileName);
        
        if (response.success) {
            System.debug('✅ TSV generation successful!');
            System.debug('File ID: ' + response.fileId);
            System.debug('Download URL: ' + response.fileUrl);
            System.debug('Records processed: ' + response.recordCount);
        } else {
            System.debug('❌ TSV generation failed: ' + response.message);
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Error testing pre-formatted TSV: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test with record limiting
System.debug('=== TESTING RECORD LIMITING (First 5) ===');
try {
    ANAgentUnifiedTSVService.TSVRequest limitedRequest = new ANAgentUnifiedTSVService.TSVRequest();
    limitedRequest.textData = preFormattedData;
    limitedRequest.businessScenario = 'OpenPipe';
    limitedRequest.fileName = 'AE_Opportunities_First5.tsv';
    limitedRequest.description = 'First 5 AE opportunities';
    limitedRequest.requestId = 'TEST-LIMITED-002';
    limitedRequest.maxRecords = 5; // Limit to first 5
    
    List<ANAgentUnifiedTSVService.TSVRequest> requests = new List<ANAgentUnifiedTSVService.TSVRequest>{limitedRequest};
    
    List<ANAgentUnifiedTSVService.TSVResponse> responses = ANAgentUnifiedTSVService.convertBusinessDataToTSV(requests);
    
    if (!responses.isEmpty()) {
        ANAgentUnifiedTSVService.TSVResponse response = responses[0];
        System.debug('Limited Response:');
        System.debug('Success: ' + response.success);
        System.debug('Record Count: ' + response.recordCount);
        
        if (response.success && response.recordCount <= 5) {
            System.debug('✅ Record limiting successful! Generated ' + response.recordCount + ' records');
        } else {
            System.debug('❌ Record limiting failed or exceeded limit');
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Error testing record limiting: ' + e.getMessage());
}

System.debug('=== TESTING COMPLETE ===');

// Helper method to count records
private static Integer countRecords(String data) {
    List<String> lines = data.split('\n');
    return lines.size() - 1; // Subtract header row
}
