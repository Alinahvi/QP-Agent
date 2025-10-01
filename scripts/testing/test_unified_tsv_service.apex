// Comprehensive test script for the Unified TSV Service
System.debug('=== TESTING UNIFIED TSV SERVICE ===\n');

// Test data for each business scenario
String openPipeData = 'Here are the top 60 opportunities in UKI from Stage 3 ("Validating Benefits & Value") onward:\n\n' +
    'AE Name: Lauren Heming\n' +
    'Email: lauren.heming@company.com\n' +
    'Product: Unilever - Magnum Ice Cream Front Office IH Transformation\n' +
    'Customer Name: Unilever\n' +
    'Stage: 03 - Validating Benefits & Value\n' +
    'Amount: $2,500,000\n\n' +
    'AE Name: Ed Selby\n' +
    'Email: ed.selby@company.com\n' +
    'Product: CC-Dyson-B2C Commerce- #OSP POV-NB #pipeup\n' +
    'Customer Name: Dyson\n' +
    'Stage: 03 - Validating Benefits & Value\n' +
    'Amount: $1,800,000\n\n' +
    'AE Name: Katie Hopkinson\n' +
    'Email: katie.hopkinson@company.com\n' +
    'Product: MC- Scottish Power Retail - #MCUKBDR\n' +
    'Customer Name: Scottish Power\n' +
    'Stage: 05 - Negotiating $$ & Mutual Plan\n' +
    'Amount: $3,200,000';

String renewalsData = 'Here are the top renewal opportunities:\n\n' +
    'AE Name: John Smith\n' +
    'Email: john.smith@company.com\n' +
    'Product: Data Cloud Enterprise\n' +
    'Customer Name: TechCorp\n' +
    'Amount: $1,500,000\n' +
    'Renewal Date: 2024-06-15\n\n' +
    'AE Name: Sarah Johnson\n' +
    'Email: sarah.johnson@company.com\n' +
    'Product: Einstein Analytics Pro\n' +
    'Customer Name: DataFlow Inc\n' +
    'Amount: $2,100,000\n' +
    'Renewal Date: 2024-07-20';

String crossSellData = 'Here are the cross-sell opportunities:\n\n' +
    'AE Name: Mike Chen\n' +
    'Email: mike.chen@company.com\n' +
    'Product: Tableau Cloud\n' +
    'Customer Name: Analytics Pro\n' +
    'Amount: $800,000\n' +
    'Cross-Sell Type: Product Expansion\n\n' +
    'AE Name: Lisa Wang\n' +
    'Email: lisa.wang@company.com\n' +
    'Product: MuleSoft Platform\n' +
    'Customer Name: Integration Solutions\n' +
    'Amount: $1,200,000\n' +
    'Cross-Sell Type: New Product Line';

String upsellData = 'Here are the upsell opportunities:\n\n' +
    'AE Name: David Brown\n' +
    'Email: david.brown@company.com\n' +
    'Product: Sales Cloud Enterprise\n' +
    'Customer Name: SalesForce Pro\n' +
    'Amount: $500,000\n' +
    'Upsell Type: Feature Upgrade\n\n' +
    'AE Name: Emma Wilson\n' +
    'Email: emma.wilson@company.com\n' +
    'Product: Service Cloud Premium\n' +
    'Customer Name: Customer Care Plus\n' +
    'Amount: $750,000\n' +
    'Upsell Type: Capacity Increase';

// Test 1: Business Scenario Detection
System.debug('=== TEST 1: Business Scenario Detection ===');
System.debug('OpenPipe data starts with "AE Name:": ' + openPipeData.startsWith('AE Name:'));
System.debug('Renewals data contains "renewal": ' + renewalsData.toLowerCase().contains('renewal'));
System.debug('CrossSell data contains "cross-sell": ' + crossSellData.toLowerCase().contains('cross-sell'));
System.debug('Upsell data contains "upsell": ' + upsellData.toLowerCase().contains('upsell'));

// Test 2: Field Mapping Logic
System.debug('=== TEST 2: Field Mapping Logic ===');

// Simulate the field mapping logic
String mapFieldToStandard(String fieldName) {
    switch on fieldName.toLowerCase() {
        when 'ae name', 'ae', 'account executive', 'account executive name' {
            return 'AE Name';
        }
        when 'email', 'ae email', 'email address' {
            return 'AE Email Address';
        }
        when 'product', 'product name', 'product__c' {
            return 'Product Name';
        }
        when 'amount', 'value', 'acv', 'total_acv__c', 'total acv' {
            return 'Amount';
        }
        when 'customer', 'customer name', 'account', 'account name' {
            return 'Customer Name';
        }
        when else {
            return null;
        }
    }
}

// Test field mapping
System.debug('"AE Name" → ' + mapFieldToStandard('AE Name'));
System.debug('"Email" → ' + mapFieldToStandard('Email'));
System.debug('"Product" → ' + mapFieldToStandard('Product'));
System.debug('"Amount" → ' + mapFieldToStandard('Amount'));
System.debug('"Customer" → ' + mapFieldToStandard('Customer'));
System.debug('"Unknown Field" → ' + mapFieldToStandard('Unknown Field'));

// Test 3: Record Parsing for Each Scenario
System.debug('=== TEST 3: Record Parsing for Each Scenario ===');

// Test OpenPipe parsing
System.debug('--- OpenPipe Parsing ---');
List<Map<String, String>> openPipeRecords = parseScenarioData(openPipeData, 2); // Limit to 2 records
System.debug('OpenPipe records found: ' + openPipeRecords.size());
for (Integer i = 0; i < openPipeRecords.size(); i++) {
    System.debug('Record ' + (i+1) + ': ' + openPipeRecords[i]);
}

// Test Renewals parsing
System.debug('--- Renewals Parsing ---');
List<Map<String, String>> renewalsRecords = parseScenarioData(renewalsData, null); // No limit
System.debug('Renewals records found: ' + renewalsRecords.size());
for (Integer i = 0; i < renewalsRecords.size(); i++) {
    System.debug('Record ' + (i+1) + ': ' + renewalsRecords[i]);
}

// Test CrossSell parsing
System.debug('--- CrossSell Parsing ---');
List<Map<String, String>> crossSellRecords = parseScenarioData(crossSellData, null);
System.debug('CrossSell records found: ' + crossSellRecords.size());

// Test Upsell parsing
System.debug('--- Upsell Parsing ---');
List<Map<String, String>> upsellRecords = parseScenarioData(upsellData, null);
System.debug('Upsell records found: ' + upsellRecords.size());

// Test 4: Standardized TSV Generation
System.debug('=== TEST 4: Standardized TSV Generation ===');

// Required fields in standard order
List<String> requiredFields = new List<String>{
    'AE Email Address', 'AE Name', 'Product Name', 'Amount', 'Customer Name'
};

// Generate TSV for OpenPipe data
String openPipeTSV = generateStandardizedTSV(openPipeRecords, requiredFields);
System.debug('--- OpenPipe TSV ---');
System.debug('Headers: ' + requiredFields);
System.debug('TSV Content (first 300 chars): ' + openPipeTSV.substring(0, Math.min(300, openPipeTSV.length())));
System.debug('Total TSV length: ' + openPipeTSV.length());

// Test 5: Record Limiting
System.debug('=== TEST 5: Record Limiting ===');
System.debug('Testing with limit of 1 record:');
List<Map<String, String>> limitedRecords = parseScenarioData(openPipeData, 1);
System.debug('Limited records: ' + limitedRecords.size());
System.debug('First record: ' + limitedRecords[0]);

System.debug('=== TEST COMPLETE ===');

// Helper method to simulate the parsing logic
private static List<Map<String, String>> parseScenarioData(String textData, Integer maxRecords) {
    List<String> lines = textData.split('\n');
    List<Map<String, String>> records = new List<Map<String, String>>();
    Map<String, String> currentRecord = new Map<String, String>();
    
    for (String line : lines) {
        line = line.trim();
        
        // Skip empty lines and descriptive text
        if (String.isBlank(line) || 
            line.contains('Here are the') || 
            line.contains('If you\'d like') || 
            line.contains('...and so on')) {
            continue;
        }
        
        // Check if this is a new record (starts with "AE Name:")
        if (line.startsWith('AE Name:')) {
            // Save previous record and start new one
            if (!currentRecord.isEmpty()) {
                records.add(currentRecord.clone());
                
                // Check if we've reached the limit
                if (maxRecords != null && records.size() >= maxRecords) {
                    System.debug('Reached record limit of ' + maxRecords + ', stopping processing');
                    break;
                }
            }
            currentRecord = new Map<String, String>();
            
            // Extract the AE Name
            String aeName = line.substringAfter(':').trim();
            currentRecord.put('AE Name', aeName);
            
        } else if (line.contains(':')) {
            // This is a field with a value
            String[] parts = line.split(':', 2);
            if (parts.size() == 2) {
                String fieldName = parts[0].trim();
                String fieldValue = parts[1].trim();
                
                // Map field names to standardized names
                String standardizedField = mapFieldToStandard(fieldName);
                if (standardizedField != null) {
                    currentRecord.put(standardizedField, fieldValue);
                }
            }
        }
    }
    
    // Add the last record
    if (!currentRecord.isEmpty()) {
        records.add(currentRecord);
    }
    
    return records;
}

// Helper method to simulate the field mapping
private static String mapFieldToStandard(String fieldName) {
    switch on fieldName.toLowerCase() {
        when 'ae name', 'ae', 'account executive', 'account executive name' {
            return 'AE Name';
        }
        when 'email', 'ae email', 'email address' {
            return 'AE Email Address';
        }
        when 'product', 'product name', 'product__c' {
            return 'Product Name';
        }
        when 'amount', 'value', 'acv', 'total_acv__c', 'total acv' {
            return 'Amount';
        }
        when 'customer', 'customer name', 'account', 'account name' {
            return 'Customer Name';
        }
        when else {
            return null;
        }
    }
}

// Helper method to generate standardized TSV
private static String generateStandardizedTSV(List<Map<String, String>> records, List<String> requiredFields) {
    // Build TSV content with required fields in standard order
    String tsvContent = String.join(requiredFields, '\t') + '\n';
    
    for (Map<String, String> record : records) {
        List<String> row = new List<String>();
        for (String field : requiredFields) {
            String value = record.get(field);
            if (value != null) {
                row.add(value);
            } else {
                row.add(''); // Empty value for missing fields
            }
        }
        tsvContent += String.join(row, '\t') + '\n';
    }
    
    return tsvContent;
}
