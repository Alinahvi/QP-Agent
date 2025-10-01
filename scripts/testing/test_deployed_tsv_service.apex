// Test script for the deployed ANAgentUnifiedTSVService
// Testing real-world scenarios with large datasets
System.debug('=== TESTING DEPLOYED UNIFIED TSV SERVICE ===\n');

// SCENARIO 1: All opportunities stage 3, 4, 5 in UKI (300+ records)
System.debug('=== SCENARIO 1: UKI Opportunities Stages 3, 4, 5 ===');
String ukiOpportunitiesData = generateUKIOpportunitiesData(350);
System.debug('Generated UKI data with ' + countRecords(ukiOpportunitiesData) + ' records');

// SCENARIO 2: Top renewal opportunities per AE in AMER ICE (300+ records)
System.debug('=== SCENARIO 2: AMER ICE Renewal Opportunities ===');
String amerIceRenewalsData = generateAMERICERenewalsData(280);
System.debug('Generated AMER ICE data with ' + countRecords(amerIceRenewalsData) + ' records');

// Test 1: Test the actual deployed service with UKI data
System.debug('=== TEST 1: Testing Deployed Service with UKI Data ===');
try {
    // Create request for UKI opportunities
    ANAgentUnifiedTSVService.TSVRequest ukiRequest = new ANAgentUnifiedTSVService.TSVRequest();
    ukiRequest.textData = ukiOpportunitiesData;
    ukiRequest.businessScenario = 'OpenPipe';
    ukiRequest.fileName = 'UKI_Opportunities_Stages3_4_5.tsv';
    ukiRequest.description = 'All opportunities stage 3, 4, 5 in UKI with AE email, product name, and stage';
    ukiRequest.requestId = 'TEST-UKI-001';
    ukiRequest.maxRecords = null; // No limit for full dataset
    
    List<ANAgentUnifiedTSVService.TSVRequest> requests = new List<ANAgentUnifiedTSVService.TSVRequest>{ukiRequest};
    
    // Call the deployed service
    List<ANAgentUnifiedTSVService.TSVResponse> responses = ANAgentUnifiedTSVService.convertBusinessDataToTSV(requests);
    
    if (!responses.isEmpty()) {
        ANAgentUnifiedTSVService.TSVResponse response = responses[0];
        System.debug('UKI TSV Service Response:');
        System.debug('Success: ' + response.success);
        System.debug('Message: ' + response.message);
        System.debug('Record Count: ' + response.recordCount);
        System.debug('File Name: ' + response.fileName);
        
        if (response.success) {
            System.debug('✅ UKI TSV generation successful!');
            System.debug('File ID: ' + response.fileId);
            System.debug('Download URL: ' + response.fileUrl);
        } else {
            System.debug('❌ UKI TSV generation failed: ' + response.message);
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Error testing UKI scenario: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test 2: Test with AMER ICE Renewals data
System.debug('=== TEST 2: Testing Deployed Service with AMER ICE Data ===');
try {
    // Create request for AMER ICE renewals
    ANAgentUnifiedTSVService.TSVRequest amerRequest = new ANAgentUnifiedTSVService.TSVRequest();
    amerRequest.textData = amerIceRenewalsData;
    amerRequest.businessScenario = 'Renewals';
    amerRequest.fileName = 'AMER_ICE_Renewals.tsv';
    amerRequest.description = 'Top renewal opportunities per AE in AMER ICE with account name, opportunity value, product name, and AE email';
    amerRequest.requestId = 'TEST-AMER-001';
    amerRequest.maxRecords = null; // No limit for full dataset
    
    List<ANAgentUnifiedTSVService.TSVRequest> requests = new List<ANAgentUnifiedTSVService.TSVRequest>{amerRequest};
    
    // Call the deployed service
    List<ANAgentUnifiedTSVService.TSVResponse> responses = ANAgentUnifiedTSVService.convertBusinessDataToTSV(requests);
    
    if (!responses.isEmpty()) {
        ANAgentUnifiedTSVService.TSVResponse response = responses[0];
        System.debug('AMER ICE TSV Service Response:');
        System.debug('Success: ' + response.success);
        System.debug('Message: ' + response.message);
        System.debug('Record Count: ' + response.recordCount);
        System.debug('File Name: ' + response.fileName);
        
        if (response.success) {
            System.debug('✅ AMER ICE TSV generation successful!');
            System.debug('File ID: ' + response.fileId);
            System.debug('Download URL: ' + response.fileUrl);
        } else {
            System.debug('❌ AMER ICE TSV generation failed: ' + response.message);
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Error testing AMER ICE scenario: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test 3: Test record limiting functionality
System.debug('=== TEST 3: Testing Record Limiting (First 50) ===');
try {
    // Create request with record limit
    ANAgentUnifiedTSVService.TSVRequest limitedRequest = new ANAgentUnifiedTSVService.TSVRequest();
    limitedRequest.textData = ukiOpportunitiesData;
    limitedRequest.businessScenario = 'OpenPipe';
    limitedRequest.fileName = 'UKI_Opportunities_First50.tsv';
    limitedRequest.description = 'First 50 opportunities from UKI dataset';
    limitedRequest.requestId = 'TEST-LIMITED-001';
    limitedRequest.maxRecords = 50; // Limit to first 50 records
    
    List<ANAgentUnifiedTSVService.TSVRequest> requests = new List<ANAgentUnifiedTSVService.TSVRequest>{limitedRequest};
    
    // Call the deployed service
    List<ANAgentUnifiedTSVService.TSVResponse> responses = ANAgentUnifiedTSVService.convertBusinessDataToTSV(requests);
    
    if (!responses.isEmpty()) {
        ANAgentUnifiedTSVService.TSVResponse response = responses[0];
        System.debug('Limited TSV Service Response:');
        System.debug('Success: ' + response.success);
        System.debug('Message: ' + response.message);
        System.debug('Record Count: ' + response.recordCount);
        
        if (response.success && response.recordCount <= 50) {
            System.debug('✅ Record limiting successful! Generated ' + response.recordCount + ' records');
        } else {
            System.debug('❌ Record limiting failed or exceeded limit');
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Error testing record limiting: ' + e.getMessage());
}

System.debug('=== DEPLOYED SERVICE TESTING COMPLETE ===');

// Helper Methods

/**
 * Generates realistic UKI opportunities data
 */
private static String generateUKIOpportunitiesData(Integer recordCount) {
    List<String> lines = new List<String>();
    
    // Header
    lines.add('Here are the ' + recordCount + ' opportunities in UKI from Stage 3 ("Validating Benefits & Value") onward:');
    lines.add('');
    
    // Generate realistic UKI records
    for (Integer i = 1; i <= recordCount; i++) {
        lines.add('AE Name: AE_' + String.valueOf(i).leftPad(3, '0'));
        lines.add('Email: ae.' + String.valueOf(i).leftPad(3, '0') + '@company.com');
        lines.add('Product: UKI_Product_' + String.valueOf(i).leftPad(3, '0') + ' - Enterprise Solution');
        lines.add('Customer Name: UKI_Customer_' + String.valueOf(i).leftPad(3, '0'));
        lines.add('Stage: 0' + (Math.mod(i, 3) + 3) + ' - Validating Benefits & Value');
        lines.add('Amount: $' + String.valueOf((i * 100000) + 500000));
        lines.add('');
    }
    
    return String.join(lines, '\n');
}

/**
 * Generates realistic AMER ICE renewals data
 */
private static String generateAMERICERenewalsData(Integer recordCount) {
    List<String> lines = new List<String>();
    
    // Header
    lines.add('Here are the top ' + recordCount + ' renewal opportunities per AE in AMER ICE:');
    lines.add('');
    
    // Generate realistic AMER ICE renewal records
    for (Integer i = 1; i <= recordCount; i++) {
        lines.add('AE Name: AMER_AE_' + String.valueOf(i).leftPad(3, '0'));
        lines.add('Email: amer.ae.' + String.valueOf(i).leftPad(3, '0') + '@company.com');
        lines.add('Product: AMER_Product_' + String.valueOf(i).leftPad(3, '0') + ' - Renewal Package');
        lines.add('Customer Name: AMER_Customer_' + String.valueOf(i).leftPad(3, '0'));
        lines.add('Amount: $' + String.valueOf((i * 150000) + 750000));
        lines.add('Renewal Type: Annual Contract Renewal');
        lines.add('');
    }
    
    return String.join(lines, '\n');
}

/**
 * Counts records in dataset
 */
private static Integer countRecords(String data) {
    List<String> lines = data.split('\n');
    Integer count = 0;
    
    for (String line : lines) {
        if (line.startsWith('AE Name:')) {
            count++;
        }
    }
    
    return count;
}
