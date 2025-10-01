// Direct SOQL test to see raw data and verify sorting
System.debug('🔍 Direct SOQL Test - Raw Data Analysis...');

// Test 1: Direct query to see what we're actually getting
System.debug('=== TEST 1: Direct SOQL Query ===');
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
    System.debug('Found ' + records.size() + ' AMER ICE records (ordered by Stage 1 amount DESC)');
    
    // Show top 10 records by Stage 1 amount
    for (Integer i = 0; i < Math.min(10, records.size()); i++) {
        AGENT_OU_PIPELINE_V2__c record = records[i];
        System.debug('--- Record ' + (i+1) + ' (Stage 1 Amount DESC) ---');
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
    System.debug('❌ Direct SOQL Test Failed: ' + e.getMessage());
}

// Test 2: Check if our aggregation logic is working correctly
System.debug('=== TEST 2: Manual Aggregation Check ===');
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
                   'LIMIT 50';
    
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query);
    System.debug('Found ' + records.size() + ' records for manual aggregation check');
    
    // Manual aggregation by product+family
    Map<String, Decimal> productAmounts = new Map<String, Decimal>();
    Map<String, String> productDetails = new Map<String, String>();
    
    for (AGENT_OU_PIPELINE_V2__c record : records) {
        Decimal totalRecordAmount = 0;
        String primaryProductName = '';
        String primaryProductFamily = '';
        String primaryAE = record.FULL_NAME__c;
        
        // Calculate total amount for this record across all stages
        for (Integer stage = 1; stage <= 5; stage++) {
            String stageName = (String)record.get('OPEN_PIPE_OPTY_STG_NM_' + stage + '__c');
            Decimal amount = (Decimal)record.get('OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_' + stage + '__c');
            
            if (String.isNotBlank(stageName) && amount != null && amount > 0) {
                totalRecordAmount += amount;
                
                // Store the first significant product we find
                if (String.isBlank(primaryProductName)) {
                    String productName = (String)record.get('OPEN_PIPE_PROD_NM_' + stage + '__c');
                    String productFamily = (String)record.get('OPEN_PIPE_APM_L2_' + stage + '__c');
                    primaryProductName = String.isNotBlank(productName) ? productName : 'Unnamed Product';
                    primaryProductFamily = String.isNotBlank(productFamily) ? productFamily : 'Unknown Family';
                }
            }
        }
        
        // Only add records with significant amounts
        if (totalRecordAmount > 1000) {
            String productKey = primaryProductName + '|' + primaryProductFamily;
            
            // If we already have this product, add the amounts
            Decimal existingAmount = productAmounts.get(productKey) != null ? productAmounts.get(productKey) : 0;
            productAmounts.put(productKey, existingAmount + totalRecordAmount);
            
            // Store product details
            if (!productDetails.containsKey(productKey)) {
                productDetails.put(productKey, primaryAE != null ? primaryAE : 'Unknown AE');
            }
        }
    }
    
    // Sort products by amount (descending)
    List<String> sortedProducts = new List<String>(productAmounts.keySet());
    sortedProducts.sort(new ManualProductAmountComparator(productAmounts));
    
    System.debug('=== MANUAL AGGREGATION RESULTS (Top 10) ===');
    for (Integer i = 0; i < Math.min(10, sortedProducts.size()); i++) {
        String productKey = sortedProducts[i];
        String[] parts = productKey.split('\\|');
        if (parts.size() >= 2) {
            String productName = parts[0];
            String productFamily = parts[1];
            Decimal amount = productAmounts.get(productKey);
            String aeName = productDetails.get(productKey);
            
            System.debug((i+1) + '. ' + productName + ' | ' + productFamily + ' - $' + amount + ' (AE: ' + aeName + ')');
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Manual Aggregation Check Failed: ' + e.getMessage());
}

// Manual comparator class
public class ManualProductAmountComparator implements Comparator<String> {
    private Map<String, Decimal> amounts;
    
    public ManualProductAmountComparator(Map<String, Decimal> amounts) {
        this.amounts = amounts;
    }
    
    public Integer compare(String a, String b) {
        Decimal amountA = amounts.get(a) != null ? amounts.get(a) : 0;
        Decimal amountB = amounts.get(b) != null ? amounts.get(b) : 0;
        
        // Manual comparison for descending order (highest first)
        if (amountB > amountA) return -1;
        if (amountB < amountA) return 1;
        return 0;
    }
}

System.debug('🔍 Direct SOQL Test Complete!'); 