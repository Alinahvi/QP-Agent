// Debug script to investigate why amounts are so low
System.debug('🔍 Debugging Amount Aggregation - Why are amounts so low?');

// Test 1: Check individual record amounts vs aggregated amounts
System.debug('=== AMER ICE Individual Record Investigation ===');
try {
    String query = 'SELECT Id, OU_NAME__c, ' +
                   'OPEN_PIPE_PROD_NM_1__c, OPEN_PIPE_APM_L2_1__c, OPEN_PIPE_OPTY_STG_NM_1__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_1__c, ' +
                   'OPEN_PIPE_PROD_NM_2__c, OPEN_PIPE_APM_L2_2__c, OPEN_PIPE_OPTY_STG_NM_2__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_2__c, ' +
                   'OPEN_PIPE_PROD_NM_3__c, OPEN_PIPE_APM_L2_3__c, OPEN_PIPE_OPTY_STG_NM_3__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_3__c, ' +
                   'OPEN_PIPE_PROD_NM_4__c, OPEN_PIPE_APM_L2_4__c, OPEN_PIPE_OPTY_STG_NM_4__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_4__c, ' +
                   'OPEN_PIPE_PROD_NM_5__c, OPEN_PIPE_APM_L2_5__c, OPEN_PIPE_OPTY_STG_NM_5__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_5__c, ' +
                   'FULL_NAME__c ' +
                   'FROM AGENT_OU_PIPELINE_V2__c ' +
                   'WHERE OU_NAME__c = \'AMER ICE\' ' +
                   'AND (OPEN_PIPE_OPTY_STG_NM_1__c != null OR OPEN_PIPE_OPTY_STG_NM_2__c != null OR OPEN_PIPE_OPTY_STG_NM_3__c != null OR OPEN_PIPE_OPTY_STG_NM_4__c != null OR OPEN_PIPE_OPTY_STG_NM_5__c != null) ' +
                   'ORDER BY OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_1__c DESC NULLS LAST ' +
                   'LIMIT 20';
    
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query);
    System.debug('Found ' + records.size() + ' AMER ICE records');
    
    // Show top 10 records by amount
    for (Integer i = 0; i < Math.min(10, records.size()); i++) {
        AGENT_OU_PIPELINE_V2__c record = records[i];
        System.debug('--- Record ' + (i+1) + ' (Ranked by Amount) ---');
        System.debug('AE: ' + record.FULL_NAME__c);
        
        // Check each stage and show amounts
        Decimal totalRecordAmount = 0;
        for (Integer stage = 1; stage <= 5; stage++) {
            String stageName = (String)record.get('OPEN_PIPE_OPTY_STG_NM_' + stage + '__c');
            String productName = (String)record.get('OPEN_PIPE_PROD_NM_' + stage + '__c');
            String productFamily = (String)record.get('OPEN_PIPE_APM_L2_' + stage + '__c');
            Decimal amount = (Decimal)record.get('OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_' + stage + '__c');
            
            if (String.isNotBlank(stageName) && amount != null && amount > 0) {
                System.debug('Stage ' + stage + ': ' + stageName);
                System.debug('  Product: ' + productName);
                System.debug('  Family: ' + productFamily);
                System.debug('  Amount: $' + amount);
                totalRecordAmount += amount;
            }
        }
        System.debug('  TOTAL RECORD AMOUNT: $' + totalRecordAmount);
    }
} catch (Exception e) {
    System.debug('❌ AMER ICE Debug Failed: ' + e.getMessage());
}

// Test 2: Check if we're missing opportunity-level amounts
System.debug('=== Check for Opportunity-Level Amounts ===');
try {
    // Look for fields that might contain the full opportunity amount
    String describeQuery = 'SELECT QualifiedApiName, Label, DataType FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = \'AGENT_OU_PIPELINE_V2__c\' AND QualifiedApiName LIKE \'%AMOUNT%\' ORDER BY QualifiedApiName';
    
    // Since we can't run describe in anonymous apex, let's check for common opportunity amount fields
    String checkQuery = 'SELECT Id, OU_NAME__c, ' +
                        'OPEN_PIPE_OPTY_NM_1__c, OPEN_PIPE_OPTY_NM_2__c, OPEN_PIPE_OPTY_NM_3__c, OPEN_PIPE_OPTY_NM_4__c, OPEN_PIPE_OPTY_NM_5__c, ' +
                        'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_1__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_2__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_3__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_4__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_5__c ' +
                        'FROM AGENT_OU_PIPELINE_V2__c ' +
                        'WHERE OU_NAME__c = \'AMER ICE\' ' +
                        'AND (OPEN_PIPE_OPTY_NM_1__c != null OR OPEN_PIPE_OPTY_NM_2__c != null OR OPEN_PIPE_OPTY_NM_3__c != null OR OPEN_PIPE_OPTY_NM_4__c != null OR OPEN_PIPE_OPTY_NM_5__c != null) ' +
                        'LIMIT 5';
    
    List<AGENT_OU_PIPELINE_V2__c> checkRecords = Database.query(checkQuery);
    System.debug('Found ' + checkRecords.size() + ' records to check opportunity names');
    
    for (Integer i = 0; i < Math.min(3, checkRecords.size()); i++) {
        AGENT_OU_PIPELINE_V2__c record = checkRecords[i];
        System.debug('--- Opportunity Check Record ' + (i+1) + ' ---');
        
        for (Integer stage = 1; stage <= 5; stage++) {
            String optyName = (String)record.get('OPEN_PIPE_OPTY_NM_' + stage + '__c');
            Decimal amount = (Decimal)record.get('OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_' + stage + '__c');
            
            if (String.isNotBlank(optyName)) {
                System.debug('Stage ' + stage + ' Opportunity: ' + optyName);
                System.debug('  Amount: $' + amount);
            }
        }
    }
} catch (Exception e) {
    System.debug('❌ Opportunity Check Failed: ' + e.getMessage());
}

// Test 3: Check if we need to aggregate by opportunity instead of product
System.debug('=== Check if we should aggregate by opportunity ===');
try {
    // Look for opportunities with multiple products to see if we're double-counting
    String optyQuery = 'SELECT Id, OU_NAME__c, ' +
                       'OPEN_PIPE_OPTY_NM_1__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_1__c, ' +
                       'OPEN_PIPE_OPTY_NM_2__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_2__c, ' +
                       'OPEN_PIPE_OPTY_NM_3__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_3__c, ' +
                       'OPEN_PIPE_OPTY_NM_4__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_4__c, ' +
                       'OPEN_PIPE_OPTY_NM_5__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_5__c, ' +
                       'FULL_NAME__c ' +
                       'FROM AGENT_OU_PIPELINE_V2__c ' +
                       'WHERE OU_NAME__c = \'AMER ICE\' ' +
                       'AND OPEN_PIPE_OPTY_NM_1__c != null ' +
                       'ORDER BY OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_1__c DESC NULLS LAST ' +
                       'LIMIT 10';
    
    List<AGENT_OU_PIPELINE_V2__c> optyRecords = Database.query(optyQuery);
    System.debug('Found ' + optyRecords.size() + ' opportunities to analyze');
    
    for (Integer i = 0; i < Math.min(5, optyRecords.size()); i++) {
        AGENT_OU_PIPELINE_V2__c record = optyRecords[i];
        System.debug('--- Opportunity Analysis ' + (i+1) + ' ---');
        System.debug('AE: ' + record.FULL_NAME__c);
        
        Decimal totalOptyAmount = 0;
        for (Integer stage = 1; stage <= 5; stage++) {
            String optyName = (String)record.get('OPEN_PIPE_OPTY_NM_' + stage + '__c');
            Decimal amount = (Decimal)record.get('OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_' + stage + '__c');
            
            if (String.isNotBlank(optyName) && amount != null && amount > 0) {
                System.debug('Stage ' + stage + ': ' + optyName + ' - $' + amount);
                totalOptyAmount += amount;
            }
        }
        System.debug('  TOTAL OPPORTUNITY AMOUNT: $' + totalOptyAmount);
    }
} catch (Exception e) {
    System.debug('❌ Opportunity Analysis Failed: ' + e.getMessage());
}

System.debug('🔍 Amount Aggregation Investigation Complete!'); 