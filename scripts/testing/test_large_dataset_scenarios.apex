// Test script for large dataset scenarios (300+ records)
// Simulating the unified TSV service behavior with your real-world scenarios
System.debug('=== TESTING LARGE DATASET SCENARIOS (300+ RECORDS) ===\n');

// SCENARIO 1: All opportunities stage 3, 4, 5 in UKI
System.debug('=== SCENARIO 1: UKI Opportunities Stages 3, 4, 5 ===');
String ukiOpportunitiesData = generateLargeDataset('UKI_Opportunities', 350, 'Stage 3, 4, 5');
System.debug('Generated UKI data with ' + countRecords(ukiOpportunitiesData) + ' records');

// SCENARIO 2: Top renewal opportunities per AE in AMER ICE
System.debug('=== SCENARIO 2: AMER ICE Renewal Opportunities ===');
String amerIceRenewalsData = generateLargeDataset('AMER_ICE_Renewals', 280, 'Renewal');
System.debug('Generated AMER ICE data with ' + countRecords(amerIceRenewalsData) + ' records');

// Test 1: Performance with Large Datasets
System.debug('=== TEST 1: Performance with Large Datasets ===');
Long startTime = System.currentTimeMillis();

// Simulate parsing large UKI dataset
List<Map<String, String>> ukiRecords = parseLargeDataset(ukiOpportunitiesData, null); // No limit
Long ukiParseTime = System.currentTimeMillis() - startTime;

System.debug('UKI dataset parsing: ' + ukiRecords.size() + ' records in ' + ukiParseTime + 'ms');
System.debug('Average time per record: ' + (ukiParseTime / ukiRecords.size()) + 'ms');

// Test 2: Record Limiting Performance
System.debug('=== TEST 2: Record Limiting Performance ===');
startTime = System.currentTimeMillis();

// Test with limit of 50 records
List<Map<String, String>> limitedRecords = parseLargeDataset(ukiOpportunitiesData, 50);
Long limitParseTime = System.currentTimeMillis() - startTime;

System.debug('Limited dataset parsing: ' + limitedRecords.size() + ' records in ' + limitParseTime + 'ms');
System.debug('Performance improvement: ' + (ukiParseTime - limitParseTime) + 'ms faster');

// Test 3: Memory Usage Analysis
System.debug('=== TEST 3: Memory Usage Analysis ===');
System.debug('UKI dataset size: ' + ukiOpportunitiesData.length() + ' characters');
System.debug('UKI records count: ' + ukiRecords.size());
System.debug('Average characters per record: ' + (ukiOpportunitiesData.length() / ukiRecords.size()));

// Test 4: TSV Generation Performance
System.debug('=== TEST 4: TSV Generation Performance ===');
startTime = System.currentTimeMillis();

String ukiTSV = generateLargeTSV(ukiRecords);
Long tsvGenTime = System.currentTimeMillis() - startTime;

System.debug('TSV generation: ' + ukiTSV.length() + ' characters in ' + tsvGenTime + 'ms');
System.debug('TSV generation rate: ' + (ukiTSV.length() / tsvGenTime) + ' chars/ms');

// Test 5: Field Mapping Performance
System.debug('=== TEST 5: Field Mapping Performance ===');
startTime = System.currentTimeMillis();

Integer mappedFields = 0;
for (Map<String, String> record : ukiRecords) {
    for (String fieldName : record.keySet()) {
        String standardizedField = mapFieldToStandard(fieldName);
        if (standardizedField != null) {
            mappedFields++;
        }
    }
}
Long mappingTime = System.currentTimeMillis() - startTime;

System.debug('Field mapping: ' + mappedFields + ' fields mapped in ' + mappingTime + 'ms');
System.debug('Average mapping time per field: ' + (mappingTime / mappedFields) + 'ms');

// Test 6: Business Scenario Detection
System.debug('=== TEST 6: Business Scenario Detection ===');
System.debug('UKI data scenario: ' + detectBusinessScenario(ukiOpportunitiesData));
System.debug('AMER ICE data scenario: ' + detectBusinessScenario(amerIceRenewalsData));

// Test 7: Error Handling with Large Data
System.debug('=== TEST 7: Error Handling with Large Data ===');
String malformedData = generateMalformedDataset(400);
List<Map<String, String>> malformedRecords = parseLargeDataset(malformedData, null);

System.debug('Malformed dataset parsing: ' + malformedRecords.size() + ' records parsed');
System.debug('Data quality: ' + calculateDataQuality(malformedRecords) + '% valid records');

System.debug('=== LARGE DATASET TESTING COMPLETE ===');

// Helper Methods

/**
 * Generates large dataset for testing
 */
private static String generateLargeDataset(String scenario, Integer recordCount, String description) {
    List<String> lines = new List<String>();
    
    // Header
    lines.add('Here are the ' + recordCount + ' ' + description + ' opportunities:');
    lines.add('');
    
    // Generate records
    for (Integer i = 1; i <= recordCount; i++) {
        lines.add('AE Name: AE_' + String.valueOf(i).leftPad(3, '0'));
        lines.add('Email: ae.' + String.valueOf(i).leftPad(3, '0') + '@company.com');
        lines.add('Product: Product_' + String.valueOf(i).leftPad(3, '0') + ' - ' + description);
        lines.add('Customer Name: Customer_' + String.valueOf(i).leftPad(3, '0'));
        lines.add('Stage: 0' + (Math.mod(i, 3) + 3) + ' - Stage Description');
        lines.add('Amount: $' + String.valueOf((i * 100000) + 500000));
        lines.add('');
    }
    
    return String.join(lines, '\n');
}

/**
 * Generates malformed dataset for error testing
 */
private static String generateMalformedDataset(Integer recordCount) {
    List<String> lines = new List<String>();
    
    lines.add('Here are the ' + recordCount + ' opportunities:');
    lines.add('');
    
    for (Integer i = 1; i <= recordCount; i++) {
        if (Math.mod(i, 10) == 0) {
            // Every 10th record is malformed
            lines.add('Malformed Record ' + i);
            lines.add('Missing: AE Name');
            lines.add('Email: ae.' + String.valueOf(i).leftPad(3, '0') + '@company.com');
        } else {
            lines.add('AE Name: AE_' + String.valueOf(i).leftPad(3, '0'));
            lines.add('Email: ae.' + String.valueOf(i).leftPad(3, '0') + '@company.com');
            lines.add('Product: Product_' + String.valueOf(i).leftPad(3, '0'));
            lines.add('Customer Name: Customer_' + String.valueOf(i).leftPad(3, '0'));
            lines.add('Stage: 0' + (Math.mod(i, 3) + 3));
            lines.add('Amount: $' + String.valueOf((i * 100000) + 500000));
        }
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

/**
 * Parses large dataset with optional record limit
 */
private static List<Map<String, String>> parseLargeDataset(String textData, Integer maxRecords) {
    List<String> lines = textData.split('\n');
    List<Map<String, String>> records = new List<Map<String, String>>();
    Map<String, String> currentRecord = new Map<String, String>();
    
    for (String line : lines) {
        line = line.trim();
        
        // Skip empty lines and headers
        if (String.isBlank(line) || line.contains('Here are the')) {
            continue;
        }
        
        // Check if this is a new record
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

/**
 * Generates large TSV
 */
private static String generateLargeTSV(List<Map<String, String>> records) {
    // Required fields in standard order
    List<String> requiredFields = new List<String>{
        'AE Email Address', 'AE Name', 'Product Name', 'Amount', 'Customer Name'
    };
    
    // Build TSV content
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

/**
 * Maps field names to standardized names
 */
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

/**
 * Detects business scenario from data
 */
private static String detectBusinessScenario(String data) {
    if (data.contains('UKI') && data.contains('Stage')) {
        return 'OpenPipe';
    } else if (data.contains('AMER') && data.contains('Renewal')) {
        return 'Renewals';
    } else if (data.contains('Cross-Sell')) {
        return 'CrossSell';
    } else if (data.contains('Upsell')) {
        return 'Upsell';
    }
    return 'Unknown';
}

/**
 * Calculates data quality percentage
 */
private static Integer calculateDataQuality(List<Map<String, String>> records) {
    if (records.isEmpty()) return 0;
    
    Integer validRecords = 0;
    for (Map<String, String> record : records) {
        if (record.containsKey('AE Name') && record.containsKey('Email')) {
            validRecords++;
        }
    }
    
    return (validRecords * 100) / records.size();
}
