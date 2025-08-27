// Debug script to investigate Open Pipe data structure and amounts
System.debug('🔍 Debugging Open Pipe Data Structure...');

// Test 1: Check AMER ICE data structure
System.debug('=== AMER ICE Data Investigation ===');
try {
    String query = 'SELECT Id, OU_NAME__c, PRIMARY_INDUSTRY__c, ' +
                   'OPEN_PIPE_PROD_NM_1__c, OPEN_PIPE_APM_L2_1__c, OPEN_PIPE_OPTY_STG_NM_1__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_1__c, ' +
                   'OPEN_PIPE_PROD_NM_2__c, OPEN_PIPE_APM_L2_2__c, OPEN_PIPE_OPTY_STG_NM_2__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_2__c, ' +
                   'OPEN_PIPE_PROD_NM_3__c, OPEN_PIPE_APM_L2_3__c, OPEN_PIPE_OPTY_STG_NM_3__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_3__c, ' +
                   'OPEN_PIPE_PROD_NM_4__c, OPEN_PIPE_APM_L2_4__c, OPEN_PIPE_OPTY_STG_NM_4__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_4__c, ' +
                   'OPEN_PIPE_PROD_NM_5__c, OPEN_PIPE_APM_L2_5__c, OPEN_PIPE_OPTY_STG_NM_5__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_5__c, ' +
                   'FULL_NAME__c ' +
                   'FROM AGENT_OU_PIPELINE_V2__c ' +
                   'WHERE OU_NAME__c = \'AMER ICE\' ' +
                   'AND (OPEN_PIPE_OPTY_STG_NM_1__c != null OR OPEN_PIPE_OPTY_STG_NM_2__c != null OR OPEN_PIPE_OPTY_STG_NM_3__c != null OR OPEN_PIPE_OPTY_STG_NM_4__c != null OR OPEN_PIPE_OPTY_STG_NM_5__c != null) ' +
                   'LIMIT 10';
    
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query);
    System.debug('Found ' + records.size() + ' AMER ICE records');
    
    for (Integer i = 0; i < Math.min(3, records.size()); i++) {
        AGENT_OU_PIPELINE_V2__c record = records[i];
        System.debug('--- Record ' + (i+1) + ' ---');
        System.debug('OU: ' + record.OU_NAME__c);
        System.debug('Industry: ' + record.PRIMARY_INDUSTRY__c);
        System.debug('AE: ' + record.FULL_NAME__c);
        
        // Check each stage
        for (Integer stage = 1; stage <= 5; stage++) {
            String stageName = (String)record.get('OPEN_PIPE_OPTY_STG_NM_' + stage + '__c');
            String productName = (String)record.get('OPEN_PIPE_PROD_NM_' + stage + '__c');
            String productFamily = (String)record.get('OPEN_PIPE_APM_L2_' + stage + '__c');
            Decimal amount = (Decimal)record.get('OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_' + stage + '__c');
            
            if (String.isNotBlank(stageName)) {
                System.debug('Stage ' + stage + ': ' + stageName);
                System.debug('  Product: ' + productName);
                System.debug('  Family: ' + productFamily);
                System.debug('  Amount: ' + amount);
                System.debug('  Amount Type: ' + (amount != null ? 'Decimal' : 'null'));
            }
        }
    }
} catch (Exception e) {
    System.debug('❌ AMER ICE Debug Failed: ' + e.getMessage());
}

// Test 2: Check UKI FINS data
System.debug('=== UKI FINS Data Investigation ===');
try {
    String query = 'SELECT Id, OU_NAME__c, PRIMARY_INDUSTRY__c, WORK_LOCATION_COUNTRY__c, ' +
                   'OPEN_PIPE_OPTY_NM_1__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_1__c, OPEN_PIPE_OPTY_STG_NM_1__c, ' +
                   'OPEN_PIPE_OPTY_NM_2__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_2__c, OPEN_PIPE_OPTY_STG_NM_2__c, ' +
                   'OPEN_PIPE_OPTY_NM_3__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_3__c, OPEN_PIPE_OPTY_STG_NM_3__c, ' +
                   'OPEN_PIPE_OPTY_NM_4__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_4__c, OPEN_PIPE_OPTY_STG_NM_4__c, ' +
                   'OPEN_PIPE_OPTY_NM_5__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_5__c, OPEN_PIPE_OPTY_STG_NM_5__c, ' +
                   'FULL_NAME__c ' +
                   'FROM AGENT_OU_PIPELINE_V2__c ' +
                   'WHERE OU_NAME__c = \'UKI\' ' +
                   'AND PRIMARY_INDUSTRY__c = \'FINS\' ' +
                   'AND WORK_LOCATION_COUNTRY__c = \'UK\' ' +
                   'AND (OPEN_PIPE_OPTY_NM_1__c != null OR OPEN_PIPE_OPTY_NM_2__c != null OR OPEN_PIPE_OPTY_NM_3__c != null OR OPEN_PIPE_OPTY_NM_4__c != null OR OPEN_PIPE_OPTY_NM_5__c != null) ' +
                   'LIMIT 10';
    
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query);
    System.debug('Found ' + records.size() + ' UKI FINS UK records');
    
    if (records.size() > 0) {
        for (Integer i = 0; i < Math.min(3, records.size()); i++) {
            AGENT_OU_PIPELINE_V2__c record = records[i];
            System.debug('--- UKI FINS Record ' + (i+1) + ' ---');
            System.debug('OU: ' + record.OU_NAME__c);
            System.debug('Industry: ' + record.PRIMARY_INDUSTRY__c);
            System.debug('Country: ' + record.WORK_LOCATION_COUNTRY__c);
            System.debug('AE: ' + record.FULL_NAME__c);
            
            // Check each stage
            for (Integer stage = 1; stage <= 5; stage++) {
                String optyName = (String)record.get('OPEN_PIPE_OPTY_NM_' + stage + '__c');
                String stageName = (String)record.get('OPEN_PIPE_OPTY_STG_NM_' + stage + '__c');
                Decimal amount = (Decimal)record.get('OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_' + stage + '__c');
                
                if (String.isNotBlank(optyName)) {
                    System.debug('Stage ' + stage + ': ' + stageName);
                    System.debug('  Opportunity: ' + optyName);
                    System.debug('  Amount: ' + amount);
                }
            }
        }
    } else {
        System.debug('⚠️ No UKI FINS UK records found');
        
        // Check if UKI exists at all
        String checkQuery = 'SELECT COUNT() FROM AGENT_OU_PIPELINE_V2__c WHERE OU_NAME__c = \'UKI\'';
        Integer ukiCount = Database.countQuery(checkQuery);
        System.debug('Total UKI records: ' + ukiCount);
        
        // Check if FINS industry exists
        String finsQuery = 'SELECT COUNT() FROM AGENT_OU_PIPELINE_V2__c WHERE PRIMARY_INDUSTRY__c = \'FINS\'';
        Integer finsCount = Database.countQuery(finsQuery);
        System.debug('Total FINS industry records: ' + finsCount);
        
        // Check if UK country exists
        String ukQuery = 'SELECT COUNT() FROM AGENT_OU_PIPELINE_V2__c WHERE WORK_LOCATION_COUNTRY__c = \'UK\'';
        Integer ukCount = Database.countQuery(ukQuery);
        System.debug('Total UK country records: ' + ukCount);
    }
} catch (Exception e) {
    System.debug('❌ UKI FINS Debug Failed: ' + e.getMessage());
}

System.debug('🔍 Open Pipe Data Investigation Complete!'); 