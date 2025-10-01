/**
 * Verify Apex Fields Exist
 * Check which fields from the Apex code actually exist in AGENT_OU_PIPELINE_V2__c
 */

System.debug('=== VERIFYING APEX FIELDS EXIST ===');

// List of all fields used in Apex code
Set<String> apexFields = new Set<String>{
    // KPI Fields
    'CQ_CUSTOMER_MEETING__c', 'CQ_PG__c', 'CQ_ACV__c', 'CQ_CC_ACV__c', 'CQ_CALL_CONNECT__c', 'CALL_AI_MENTION__c',
    'PQ_CUSTOMER_MEETING__c', 'PQ_PG__c', 'PQ_ACV__c', 'PQ_CC_ACV__c', 'PQ_CALL_CONNECT__c',
    'COVERAGE__c', 'ACV_THRESHOLD__c', 'FULLTOTALACVQUOTAUSD__c', 'VAL_QUOTA__c',
    
    // Dimension Fields
    'OU_NAME__c', 'WORK_LOCATION_COUNTRY__c', 'PRIMARY_INDUSTRY__c',
    
    // Open Pipe Fields
    'OPEN_PIPE_OPTY_STG_NM_1__c', 'OPEN_PIPE_OPTY_STG_NM_2__c', 'OPEN_PIPE_OPTY_STG_NM_3__c', 'OPEN_PIPE_OPTY_STG_NM_4__c', 'OPEN_PIPE_OPTY_STG_NM_5__c',
    'OPEN_PIPE_PROD_NM_1__c', 'OPEN_PIPE_PROD_NM_2__c', 'OPEN_PIPE_PROD_NM_3__c', 'OPEN_PIPE_PROD_NM_4__c', 'OPEN_PIPE_PROD_NM_5__c',
    'OPEN_PIPE_APM_L2_1__c', 'OPEN_PIPE_APM_L2_2__c', 'OPEN_PIPE_APM_L2_3__c', 'OPEN_PIPE_APM_L2_4__c', 'OPEN_PIPE_APM_L2_5__c',
    'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_1__c', 'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_2__c', 'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_3__c', 'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_4__c', 'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_5__c',
    'OPEN_PIPE_REVISED_SUB_SECTOR_1__c', 'OPEN_PIPE_REVISED_SUB_SECTOR_2__c', 'OPEN_PIPE_REVISED_SUB_SECTOR_3__c', 'OPEN_PIPE_REVISED_SUB_SECTOR_4__c', 'OPEN_PIPE_REVISED_SUB_SECTOR_5__c',
    'OPEN_PIPE_OPTY_NM_1__c', 'OPEN_PIPE_OPTY_NM_2__c', 'OPEN_PIPE_OPTY_NM_3__c', 'OPEN_PIPE_OPTY_NM_4__c', 'OPEN_PIPE_OPTY_NM_5__c',
    'OPEN_PIPE_AE_SCORE_1__c', 'OPEN_PIPE_AE_SCORE_2__c', 'OPEN_PIPE_AE_SCORE_3__c', 'OPEN_PIPE_AE_SCORE_4__c', 'OPEN_PIPE_AE_SCORE_5__c',
    'OPEN_PIPE_OPTY_DAYS_IN_STAGE_1__c', 'OPEN_PIPE_OPTY_DAYS_IN_STAGE_2__c', 'OPEN_PIPE_OPTY_DAYS_IN_STAGE_3__c', 'OPEN_PIPE_OPTY_DAYS_IN_STAGE_4__c', 'OPEN_PIPE_OPTY_DAYS_IN_STAGE_5__c',
    
    // Future Pipeline Fields
    'RENEWAL_ACCT_ID_1__c', 'RENEWAL_ACCT_ID_2__c', 'RENEWAL_ACCT_ID_3__c', 'RENEWAL_ACCT_ID_4__c', 'RENEWAL_ACCT_ID_5__c',
    'RENEWAL_ACCT_NM_1__c', 'RENEWAL_ACCT_NM_2__c', 'RENEWAL_ACCT_NM_3__c', 'RENEWAL_ACCT_NM_4__c', 'RENEWAL_ACCT_NM_5__c',
    'RENEWAL_OPTY_NM_1__c', 'RENEWAL_OPTY_NM_2__c', 'RENEWAL_OPTY_NM_3__c', 'RENEWAL_OPTY_NM_4__c', 'RENEWAL_OPTY_NM_5__c',
    'RENEWAL_OPTY_AMT_1__c', 'RENEWAL_OPTY_AMT_2__c', 'RENEWAL_OPTY_AMT_3__c', 'RENEWAL_OPTY_AMT_4__c', 'RENEWAL_OPTY_AMT_5__c',
    'CS_ACCT_ID_1__c', 'CS_ACCT_ID_2__c', 'CS_ACCT_ID_3__c', 'CS_ACCT_ID_4__c', 'CS_ACCT_ID_5__c',
    'CS_ACCT_NM_1__c', 'CS_ACCT_NM_2__c', 'CS_ACCT_NM_3__c', 'CS_ACCT_NM_4__c', 'CS_ACCT_NM_5__c',
    'CS_NEXT_BEST_PRODUCT_1__c', 'CS_NEXT_BEST_PRODUCT_2__c', 'CS_NEXT_BEST_PRODUCT_3__c', 'CS_NEXT_BEST_PRODUCT_4__c', 'CS_NEXT_BEST_PRODUCT_5__c',
    'UPSELL_ACCT_ID_1__c', 'UPSELL_ACCT_ID_2__c', 'UPSELL_ACCT_ID_3__c', 'UPSELL_ACCT_ID_4__c', 'UPSELL_ACCT_ID_5__c',
    'UPSELL_ACCT_NM_1__c', 'UPSELL_ACCT_NM_2__c', 'UPSELL_ACCT_NM_3__c', 'UPSELL_ACCT_NM_4__c', 'UPSELL_ACCT_NM_5__c',
    'UPSELL_SUB_CATEGORY_1__c', 'UPSELL_SUB_CATEGORY_2__c', 'UPSELL_SUB_CATEGORY_3__c', 'UPSELL_SUB_CATEGORY_4__c', 'UPSELL_SUB_CATEGORY_5__c',
    
    // Employee Fields
    'EMP_EMAIL_ADDR__c', 'EMP_ID__c', 'EMP_MGR_NM__c', 'FULL_NAME__c', 'LEARNER_PROFILE_ID__c',
    
    // Additional Metrics
    'AOV__c', 'DAYS_TO_PRODUCTIVITY__c', 'TIME_SINCE_ONBOARDING__c', 'RAMP_STATUS__c',
    
    // Days Fields
    'CQ_DAYS_ACV__c', 'CQ_DAYS_ACV_PART__c', 'CQ_DAYS_PG__c', 'CQ_DAYS_PG_PART__c',
    'PQ_DAYS_ACV__c', 'PQ_DAYS_ACV_PART__c', 'PQ_DAYS_PG__c', 'PQ_DAYS_PG_PART__c',
    
    // Misc Fields
    'ACTIONABLE__c', 'ACTION_LINK__c', 'DESCRIPTION__c', 'DEFINITION__c', 'RECOMMENDED_ACTION__c'
};

try {
    // Get the object describe
    Schema.DescribeSObjectResult objectDescribe = AGENT_OU_PIPELINE_V2__c.SObjectType.getDescribe();
    Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
    
    System.debug('Total fields in object: ' + fieldMap.size());
    System.debug('Total fields in Apex code: ' + apexFields.size());
    
    // Check which fields exist
    Set<String> existingFields = new Set<String>();
    Set<String> missingFields = new Set<String>();
    
    for (String fieldName : apexFields) {
        if (fieldMap.containsKey(fieldName)) {
            existingFields.add(fieldName);
        } else {
            missingFields.add(fieldName);
        }
    }
    
    System.debug('\n=== FIELD VALIDATION RESULTS ===');
    System.debug('✅ EXISTING FIELDS: ' + existingFields.size() + '/' + apexFields.size());
    System.debug('❌ MISSING FIELDS: ' + missingFields.size() + '/' + apexFields.size());
    
    if (!missingFields.isEmpty()) {
        System.debug('\n❌ MISSING FIELDS:');
        for (String missingField : missingFields) {
            System.debug('  ' + missingField);
        }
    }
    
    // Show some sample existing fields with their types
    System.debug('\n✅ SAMPLE EXISTING FIELDS:');
    Integer count = 0;
    for (String fieldName : existingFields) {
        if (count < 10) { // Show first 10
            Schema.SObjectField field = fieldMap.get(fieldName);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            System.debug('  ' + fieldName + ' - Type: ' + fieldDescribe.getType() + ' - Label: ' + fieldDescribe.getLabel());
            count++;
        }
    }
    
    // Calculate percentage
    Decimal percentage = (existingFields.size() / apexFields.size()) * 100;
    System.debug('\n📊 FIELD VALIDATION SUMMARY:');
    System.debug('Success Rate: ' + percentage.setScale(1) + '%');
    System.debug('Existing: ' + existingFields.size());
    System.debug('Missing: ' + missingFields.size());
    System.debug('Total Checked: ' + apexFields.size());
    
} catch (Exception e) {
    System.debug('❌ EXCEPTION: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== FIELD VERIFICATION COMPLETED ==='); 