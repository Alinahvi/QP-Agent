// Test script to verify the TSV fix works with opportunity data format
System.debug('=== TESTING TSV FIX ===\n');

// Test with the exact data format from the conversation
String opportunityData = 'Here are the top 60 opportunities in UKI from Stage 3 ("Validating Benefits & Value") onward:\n\n' +
    'AE Name: Lauren Heming\n' +
    'Email: [redacted]\n' +
    'Product: Unilever - Magnum Ice Cream Front Office IH Transformation\n' +
    'Customer Name: Unilever\n' +
    'Stage: 03 - Validating Benefits & Value\n\n' +
    'AE Name: Ed Selby\n' +
    'Email: [redacted]\n' +
    'Product: CC-Dyson-B2C Commerce- #OSP POV-NB #pipeup\n' +
    'Customer Name: Dyson\n' +
    'Stage: 03 - Validating Benefits & Value\n\n' +
    'AE Name: Katie Hopkinson\n' +
    'Email: [redacted]\n' +
    'Product: MC- Scottish Power Retail - #MCUKBDR\n' +
    'Customer Name: Scottish Power\n' +
    'Stage: 05 - Negotiating $$ & Mutual Plan\n\n' +
    'AE Name: Alex Laterza\n' +
    'Email: [redacted]\n' +
    'Product: OMG UK - Dynamics & Hubspot to Salesforce UK/EMEA\n' +
    'Customer Name: OMG UK\n' +
    'Stage: 03 - Validating Benefits & Value\n\n' +
    'AE Name: Scott Plaskett\n' +
    'Email: [redacted]\n' +
    'Product: Thames Water WFM Above Ground Field Service\n' +
    'Customer Name: Thames Water\n' +
    'Stage: 03 - Validating Benefits & Value\n\n' +
    'AE Name: Sourav Ray\n' +
    'Email: [redacted]\n' +
    'Product: Sunbelt UK - Field Service\n' +
    'Customer Name: Sunbelt UK\n' +
    'Stage: 03 - Validating Benefits & Value\n\n' +
    'AE Name: Sofya Bratus\n' +
    'Email: [redacted]\n' +
    'Product: Jensten Group - FSC Add On\n' +
    'Customer Name: Jensten Group\n' +
    'Stage: 03 - Validating Benefits & Value\n\n' +
    'AE Name: Dominic Leach\n' +
    'Email: [redacted]\n' +
    'Product: Azets - Firmwide Transformation - Sales Cloud - BR and Azets\n' +
    'Customer Name: Azets\n' +
    'Stage: 03 - Validating Benefits & Value\n\n' +
    'AE Name: Guilherme Barana\n' +
    'Email: [redacted]\n' +
    'Product: Unilever - Digital Labour Platform\n' +
    'Customer Name: Unilever\n' +
    'Stage: 03 - Validating Benefits & Value\n\n' +
    'AE Name: Michael Bell\n' +
    'Email: [redacted]\n' +
    'Product: Sage GMO Acceleration (+1500) 3800 UE - GMO Growth & Expansion\n' +
    'Customer Name: Sage\n' +
    'Stage: 04 - Confirming Value With Power\n\n' +
    '...and so on for the remaining opportunities.\n\n' +
    'If you\'d like the full list or specific details, let me know!';

// Test 1: Basic opportunity format detection
System.debug('=== TEST 1: Opportunity Format Detection ===');
Boolean isOpportunity = opportunityData.startsWith('AE Name:') || 
                       (opportunityData.contains('AE Name:') && opportunityData.contains('Customer Name:'));
System.debug('Is Opportunity Format: ' + isOpportunity);

// Test 2: Extract max records limit
System.debug('=== TEST 2: Max Records Limit Extraction ===');
String testWithLimit = opportunityData + '\n\nUser request: how about only the first 50 if 60 is big?';
Pattern p = Pattern.compile('(?:only the )?first (\\d+)|limit to (\\d+)|max (\\d+)');
Matcher m = p.matcher(testWithLimit.toLowerCase());

Integer maxRecords = null;
if (m.find()) {
    String match = m.group(1) != null ? m.group(1) : 
                  (m.group(2) != null ? m.group(2) : m.group(3));
    if (match != null) {
        maxRecords = Integer.valueOf(match);
    }
}
System.debug('Max Records Limit: ' + maxRecords);

// Test 3: Parse opportunity data manually
System.debug('=== TEST 3: Manual Opportunity Parsing ===');
List<String> lines = opportunityData.split('\n');
List<Map<String, String>> records = new List<Map<String, String>>();
Map<String, String> currentRecord = new Map<String, String>();
Set<String> allFieldNames = new Set<String>();

for (String line : lines) {
    line = line.trim();
    
    // Skip empty lines and descriptive text
    if (String.isBlank(line) || 
        line.contains('Here are the') || 
        line.contains('If you\'d like') || 
        line.contains('...and so on')) {
        continue;
    }
    
    // Check if this line starts with "AE Name:"
    if (line.startsWith('AE Name:')) {
        // Save previous record and start new one
        if (!currentRecord.isEmpty()) {
            records.add(currentRecord.clone());
            allFieldNames.addAll(currentRecord.keySet());
            
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
            currentRecord.put(fieldName, fieldValue);
        }
    }
}

// Add the last record
if (!currentRecord.isEmpty()) {
    records.add(currentRecord);
    allFieldNames.addAll(currentRecord.keySet());
}

System.debug('=== PARSED RECORDS ===');
System.debug('Total records found: ' + records.size());
System.debug('All field names: ' + allFieldNames);

for (Integer i = 0; i < Math.min(records.size(), 3); i++) {
    System.debug('Record ' + (i+1) + ': ' + records[i]);
}

// Test 4: Generate TSV
System.debug('=== TEST 4: TSV Generation ===');
if (!records.isEmpty()) {
    // Create dynamic headers
    List<String> headers = new List<String>(allFieldNames);
    headers.sort();
    
    // Ensure key fields are first
    if (headers.contains('AE Name')) {
        headers.remove(headers.indexOf('AE Name'));
        headers.add(0, 'AE Name');
    }
    if (headers.contains('Customer Name')) {
        headers.remove(headers.indexOf('Customer Name'));
        headers.add(1, 'Customer Name');
    }
    if (headers.contains('Product')) {
        headers.remove(headers.indexOf('Product'));
        headers.add(2, 'Product');
    }
    
    // Build TSV content (tab-separated)
    String tsvContent = String.join(headers, '\t') + '\n';
    
    for (Map<String, String> record : records) {
        List<String> row = new List<String>();
        for (String header : headers) {
            String value = record.get(header);
            if (value != null) {
                row.add(value);
            } else {
                row.add(''); // Empty value
            }
        }
        tsvContent += String.join(row, '\t') + '\n';
    }
    
    System.debug('=== GENERATED TSV ===');
    System.debug('Headers: ' + headers);
    System.debug('TSV Content (first 500 chars): ' + tsvContent.substring(0, Math.min(500, tsvContent.length())));
    System.debug('Total TSV length: ' + tsvContent.length());
    
} else {
    System.debug('No records found to convert to TSV');
}

System.debug('=== TEST COMPLETE ===');
