// Debug script to check the actual field names for future pipeline analysis
System.debug('🔍 Debugging Future Pipeline Field Names...');

// ========================================
// CHECK 1: Verify field names exist
// ========================================

System.debug('=== CHECK 1: Verify Field Names Exist ===');
try {
    // Test a simple query with the fields used in the service
    String query = 'SELECT Id, emp_id__c, full_name__c, ou_name__c, primary_industry__c, work_location_country__c ' +
                   'FROM AGENT_OU_PIPELINE_V2__c LIMIT 1';
    
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query);
    System.debug('✅ Basic fields query: SUCCESS - Found ' + records.size() + ' records');
} catch (Exception e) {
    System.debug('❌ Basic fields query: FAILED - ' + e.getMessage());
}

// ========================================
// CHECK 2: Verify upsell fields
// ========================================

System.debug('=== CHECK 2: Verify Upsell Fields ===');
try {
    String query = 'SELECT Id, upsell_acct_id_1__c, upsell_acct_nm_1__c, upsell_sub_category_1__c ' +
                   'FROM AGENT_OU_PIPELINE_V2__c LIMIT 1';
    
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query);
    System.debug('✅ Upsell fields query: SUCCESS - Found ' + records.size() + ' records');
} catch (Exception e) {
    System.debug('❌ Upsell fields query: FAILED - ' + e.getMessage());
}

// ========================================
// CHECK 3: Verify cross-sell fields
// ========================================

System.debug('=== CHECK 3: Verify Cross-Sell Fields ===');
try {
    String query = 'SELECT Id, cs_acct_id_1__c, cs_acct_nm_1__c, cs_next_best_product_1__c ' +
                   'FROM AGENT_OU_PIPELINE_V2__c LIMIT 1';
    
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query);
    System.debug('✅ Cross-sell fields query: SUCCESS - Found ' + records.size() + ' records');
} catch (Exception e) {
    System.debug('❌ Cross-sell fields query: FAILED - ' + e.getMessage());
}

// ========================================
// CHECK 4: Verify renewal fields
// ========================================

System.debug('=== CHECK 4: Verify Renewal Fields ===');
try {
    String query = 'SELECT Id, renewal_acct_id_1__c, renewal_acct_nm_1__c, renewal_opty_nm_1__c, renewal_opty_amt_1__c ' +
                   'FROM AGENT_OU_PIPELINE_V2__c LIMIT 1';
    
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query);
    System.debug('✅ Renewal fields query: SUCCESS - Found ' + records.size() + ' records');
} catch (Exception e) {
    System.debug('❌ Renewal fields query: FAILED - ' + e.getMessage());
}

// ========================================
// CHECK 5: Test the exact query from the service
// ========================================

System.debug('=== CHECK 5: Test Exact Service Query ===');
try {
    // Build the exact query that the service builds
    String baseQuery = 'SELECT Id, emp_id__c, full_name__c, ou_name__c, primary_industry__c, ' +
                       'work_location_country__c, ' +
                       // Upsell fields (5 opportunities)
                       'upsell_acct_id_1__c, upsell_acct_nm_1__c, upsell_sub_category_1__c, ' +
                       'upsell_acct_id_2__c, upsell_acct_nm_2__c, upsell_sub_category_2__c, ' +
                       'upsell_acct_id_3__c, upsell_acct_nm_3__c, upsell_sub_category_3__c, ' +
                       'upsell_acct_id_4__c, upsell_acct_nm_4__c, upsell_sub_category_4__c, ' +
                       'upsell_acct_id_5__c, upsell_acct_nm_5__c, upsell_sub_category_5__c, ' +
                       // Cross-sell fields (5 opportunities)
                       'cs_acct_id_1__c, cs_acct_nm_1__c, cs_next_best_product_1__c, ' +
                       'cs_acct_id_2__c, cs_acct_nm_2__c, cs_next_best_product_2__c, ' +
                       'cs_acct_id_3__c, cs_acct_nm_3__c, cs_next_best_product_3__c, ' +
                       'cs_acct_id_4__c, cs_acct_nm_4__c, cs_next_best_product_4__c, ' +
                       'cs_acct_id_5__c, cs_acct_nm_5__c, cs_next_best_product_5__c, ' +
                       // Renewal fields (5 opportunities)
                       'renewal_acct_id_1__c, renewal_acct_nm_1__c, renewal_opty_nm_1__c, renewal_opty_amt_1__c, ' +
                       'renewal_acct_id_2__c, renewal_acct_nm_2__c, renewal_opty_nm_2__c, renewal_opty_amt_2__c, ' +
                       'renewal_acct_id_3__c, renewal_acct_nm_3__c, renewal_opty_nm_3__c, renewal_opty_amt_3__c, ' +
                       'renewal_acct_id_4__c, renewal_acct_nm_4__c, renewal_opty_nm_4__c, renewal_opty_amt_4__c, ' +
                       'renewal_acct_id_5__c, renewal_acct_nm_5__c, renewal_opty_nm_5__c, renewal_opty_amt_5__c ' +
                       'FROM AGENT_OU_PIPELINE_V2__c WHERE 1=1 LIMIT 1';
    
    System.debug('🔍 Generated Query: ' + baseQuery);
    
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(baseQuery);
    System.debug('✅ Exact service query: SUCCESS - Found ' + records.size() + ' records');
} catch (Exception e) {
    System.debug('❌ Exact service query: FAILED - ' + e.getMessage());
    System.debug('🔍 Stack Trace: ' + e.getStackTraceString());
}

System.debug('🎯 Future Pipeline Field Debug Complete!');
System.debug('📊 This should reveal any field name issues!'); 