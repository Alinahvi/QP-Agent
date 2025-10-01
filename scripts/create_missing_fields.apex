// Script to create all missing fields for AGENT_OU_PIPELINE_V2__c object
// This will help us identify what fields are missing and create them systematically

System.debug('🔍 ANALYZING MISSING FIELDS FOR AGENT_OU_PIPELINE_V2__c');
System.debug('========================================================');

// List of all fields from the comprehensive definition
Map<String, String> fieldDefinitions = new Map<String, String>{
    // Basic Employee Fields
    'EMP_ID__c' => 'Unique employee identifier used to join to HR/Workday and performance data',
    'FULL_NAME__c' => 'The employee\'s full display name as First Last',
    'EMP_EMAIL_ADDR__c' => 'The employee\'s corporate email address',
    'WORK_LOCATION_COUNTRY__c' => 'Country of the employee\'s primary work location',
    'OU_NAME__c' => 'Operating Unit the employee belongs to',
    'EMP_MGR_NM__c' => 'Direct manager\'s name (one level up)',
    'PRIMARY_INDUSTRY__c' => 'Top-level industry classification',
    'LEARNER_PROFILE_ID__c' => 'Internal SEED/Enablement Learner Profile ID',
    
    // Pipeline Stage Fields (1-5)
    'OPEN_PIPE_APM_L2_1__c' => 'Product family for Stage 1 open opportunity',
    'OPEN_PIPE_PROD_NM_1__c' => 'Specific product tied to Stage 1 open opportunity',
    'OPEN_PIPE_OPTY_NM_1__c' => 'CRM Opportunity name for Stage 1 open opportunity',
    'OPEN_PIPE_OPTY_STG_NM_1__c' => 'Stage 1 opportunity stage name',
    'OPEN_PIPE_AE_SCORE_1__c' => 'AE health score for Stage 1 open opportunity',
    'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_1__c' => 'Allocated dollar amount for Stage 1',
    'OPEN_PIPE_OPTY_DAYS_IN_STAGE_1__c' => 'Days in current stage for Stage 1',
    'OPEN_PIPE_REVISED_SUB_SECTOR_1__c' => 'Revised sub-sector for Stage 1',
    
    // Growth Factor Fields
    'DEFINITION__c' => 'Growth Factors from seller performance predictor',
    'DESCRIPTION__c' => 'Description of each Growth Factor',
    'ACTIONABLE__c' => 'If growth factor has action that AE can take',
    'RECOMMENDED_ACTION__c' => 'Recommended action for their Growth Factor',
    'ACTION_LINK__c' => 'Content link to help AE improve their GFs',
    
    // Upsell Fields (1-5)
    'UPSELL_ACCT_ID_1__c' => 'Upsell opportunity no 1 Account ID',
    'UPSELL_ACCT_NM_1__c' => 'Account name tied to Upsell no 1',
    'UPSELL_SUB_CATEGORY_1__c' => 'Product tied to Upsell no 1',
    
    // Cross-Sell Fields (1-5)
    'CS_ACCT_ID_1__c' => 'Cross-sell opportunity 1 Account ID',
    'CS_ACCT_NM_1__c' => 'Cross-sell opportunity 1 Account Name',
    'CS_NEXT_BEST_PRODUCT_1__c' => 'Cross-sell opportunity 1 product',
    
    // Renewal Fields
    'RENEWAL_ACCT_ID__c' => 'Renewal opportunity Account ID',
    'RENEWAL_ACCT_NM__c' => 'Renewal opportunity Account Name',
    'RENEWAL_OPTY_NM__c' => 'Renewal opportunity name',
    'RENEWAL_OPTY_AMT__c' => 'Renewal opportunity amount',
    
    // Current Quarter Fields
    'VAL_QUOTA__c' => 'Quota value for each AE',
    'CQ_CUSTOMER_MEETING__c' => 'Current quarter customer meetings',
    'CQ_PG__c' => 'Current quarter pipeline generation',
    'CQ_ACV__c' => 'Current quarter ACV',
    'CQ_CALL_CONNECT__c' => 'Current quarter call connect',
    'CQ_CC_ACV__c' => 'Current quarter Create and Close ACV',
    
    // Previous Quarter Fields
    'PQ_CUSTOMER_MEETING__c' => 'Previous quarter customer meetings',
    'PQ_PG__c' => 'Previous quarter pipeline generation',
    'PQ_ACV__c' => 'Previous quarter ACV',
    'PQ_CALL_CONNECT__c' => 'Previous quarter call connect',
    'PQ_CC_ACV__c' => 'Previous quarter Create and Close ACV',
    
    // Performance Metrics
    'COVERAGE__c' => 'Ratio of open deals to quota',
    'RAMP_STATUS__c' => 'Ramp status of the AE',
    'TIME_SINCE_ONBOARDING__c' => 'Time since AE onboarded in months',
    'FULLTOTALACVQUOTAUSD__c' => 'Total quota attained so far',
    'ACV_THRESHOLD__c' => 'ACV threshold based on peer characteristics',
    'DAYS_TO_PRODUCTIVITY__c' => 'Days to meet peer ACV attainment'
};

// Check which fields exist in the org
System.debug('\n📋 CHECKING EXISTING FIELDS:');
System.debug('============================');

Set<String> existingFields = new Set<String>();
try {
    // Get the object describe
    Schema.DescribeSObjectResult objectDesc = Schema.getGlobalDescribe().get('AGENT_OU_PIPELINE_V2__c').getDescribe();
    Map<String, Schema.SObjectField> fieldMap = objectDesc.fields.getMap();
    
    for (String fieldName : fieldMap.keySet()) {
        existingFields.add(fieldName);
    }
    
    System.debug('✅ Object exists with ' + existingFields.size() + ' fields');
    
} catch (Exception e) {
    System.debug('❌ Error accessing object: ' + e.getMessage());
    return;
}

// Identify missing fields
System.debug('\n🔍 IDENTIFYING MISSING FIELDS:');
System.debug('================================');

Set<String> missingFields = new Set<String>();
for (String fieldName : fieldDefinitions.keySet()) {
    if (!existingFields.contains(fieldName)) {
        missingFields.add(fieldName);
        System.debug('❌ MISSING: ' + fieldName + ' - ' + fieldDefinitions.get(fieldName));
    } else {
        System.debug('✅ EXISTS: ' + fieldName);
    }
}

System.debug('\n📊 SUMMARY:');
System.debug('===========');
System.debug('Total fields defined: ' + fieldDefinitions.size());
System.debug('Existing fields: ' + existingFields.size());
System.debug('Missing fields: ' + missingFields.size());

if (missingFields.size() > 0) {
    System.debug('\n🚨 CRITICAL MISSING FIELDS:');
    System.debug('============================');
    for (String missingField : missingFields) {
        System.debug('• ' + missingField + ': ' + fieldDefinitions.get(missingField));
    }
    
    System.debug('\n💡 NEXT STEPS:');
    System.debug('===============');
    System.debug('1. Create metadata files for missing fields');
    System.debug('2. Deploy field definitions');
    System.debug('3. Verify field creation');
} else {
    System.debug('\n🎉 ALL FIELDS EXIST!');
    System.debug('=====================');
    System.debug('The object is fully configured with all required fields.');
}

System.debug('\n🧪 FIELD ANALYSIS COMPLETE'); 