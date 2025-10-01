// Script to populate AGENT_OU_PIPELINE_V2__c object with CSV data
// This will create sample records with all the field definitions and sample data

System.debug('🚀 POPULATING AGENT_OU_PIPELINE_V2__c OBJECT');
System.debug('============================================');

try {
    // Check if object exists and is accessible
    Schema.SObjectType objectType = Schema.getGlobalDescribe().get('AGENT_OU_PIPELINE_V2__c');
    if (objectType == null) {
        System.debug('❌ ERROR: AGENT_OU_PIPELINE_V2__c object does not exist!');
        System.debug('Please create the custom object first.');
        return;
    }
    
    System.debug('✅ Object exists and is accessible');
    
    // Get field describe information
    Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
    System.debug('📋 Available fields: ' + fieldMap.keySet().size());
    
    // Create sample records with the CSV data structure
    List<AGENT_OU_PIPELINE_V2__c> sampleRecords = new List<AGENT_OU_PIPELINE_V2__c>();
    
    // Sample Record 1: Baker Roofing Company AE
    AGENT_OU_PIPELINE_V2__c record1 = new AGENT_OU_PIPELINE_V2__c();
    
    // Basic Employee Information
    record1.EMP_ID__c = '888674';
    record1.FULL_NAME__c = 'Camden Wentz';
    record1.EMP_EMAIL_ADDR__c = 'cwentz@salesforce.com';
    record1.WORK_LOCATION_COUNTRY__c = 'US';
    record1.OU_NAME__c = 'AMER ACC';
    record1.EMP_MGR_NM__c = 'Katie O\'Rourke';
    record1.PRIMARY_INDUSTRY__c = 'Engineering, Construction, & Real Estate';
    record1.LEARNER_PROFILE__ID__c = 'a5jHu000001XWPPIA4';
    
    // AI and Analytics
    record1.CALL_AI_MENTION__c = 3.0;
    
    // Open Pipeline Stage 1
    record1.OPEN_PIPE_APM_L2_1__c = 'Field Service';
    record1.OPEN_PIPE_PROD_NM_1__c = 'Field Service+ - Enterprise Edition';
    record1.OPEN_PIPE_OPTY_NM_1__c = 'Baker Roofing Company - +200 SFS+ Customer Community';
    record1.OPEN_PIPE_OPTY_STG_NM_1__c = 'Stage 1: Identify the Opportunity';
    record1.OPEN_PIPE_AE_SCORE_1__c = 3.18;
    record1.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_1__c = 237600.0;
    record1.OPEN_PIPE_OPTY_DAYS_IN_STAGE_1__c = 51.0;
    record1.OPEN_PIPE_REVISED_SUB_SECTOR_1__c = 'Home Services';
    
    // Open Pipeline Stage 2
    record1.OPEN_PIPE_APM_L2_2__c = 'Self Service';
    record1.OPEN_PIPE_PROD_NM_2__c = 'Customer Community Plus - Unlimited Edition - Logins (Per Month)';
    record1.OPEN_PIPE_OPTY_NM_2__c = 'Baker Roofing Company - +200 SFS+ Customer Community';
    record1.OPEN_PIPE_OPTY_STG_NM_2__c = 'Stage 2: Determining Problem and Impact';
    record1.OPEN_PIPE_AE_SCORE_2__c = 3.18;
    record1.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_2__c = 144000.0;
    record1.OPEN_PIPE_OPTY_DAYS_IN_STAGE_2__c = 51.0;
    record1.OPEN_PIPE_REVISED_SUB_SECTOR_2__c = 'Home Services';
    
    // Open Pipeline Stage 3
    record1.OPEN_PIPE_APM_L2_3__c = 'Field Service';
    record1.OPEN_PIPE_PROD_NM_3__c = 'Field Service - Field Technician - Unlimited Edition';
    record1.OPEN_PIPE_OPTY_NM_3__c = 'Baker Roofing Company - (+UE Upgrade, +Customer Community, +DE Short Code, +Feedback Mgmt, +Privacy Center)';
    record1.OPEN_PIPE_OPTY_STG_NM_3__c = 'Stage 3: Validate Benefits and Value';
    record1.OPEN_PIPE_AE_SCORE_3__c = 3.18;
    record1.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_3__c = 83585.73;
    record1.OPEN_PIPE_OPTY_DAYS_IN_STAGE_3__c = 22.0;
    record1.OPEN_PIPE_REVISED_SUB_SECTOR_3__c = 'Home Services';
    
    // Open Pipeline Stage 4
    record1.OPEN_PIPE_APM_L2_4__c = 'Field Service';
    record1.OPEN_PIPE_PROD_NM_4__c = 'Field Service+ - Unlimited Edition';
    record1.OPEN_PIPE_OPTY_NM_4__c = 'Baker Roofing Company - (+UE Upgrade, +Customer Community, +DE Short Code, +Feedback Mgmt, +Privacy Center)';
    record1.OPEN_PIPE_OPTY_STG_NM_4__c = 'Stage 4: Confirm Value with Power';
    record1.OPEN_PIPE_AE_SCORE_4__c = 3.18;
    record1.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_4__c = 74112.68;
    record1.OPEN_PIPE_OPTY_DAYS_IN_STAGE_4__c = 22.0;
    record1.OPEN_PIPE_REVISED_SUB_SECTOR_4__c = 'Home Services';
    
    // Open Pipeline Stage 5
    record1.OPEN_PIPE_APM_L2_5__c = 'Developer Services';
    record1.OPEN_PIPE_PROD_NM_5__c = 'Sandbox (Full Copy) - Fee';
    record1.OPEN_PIPE_OPTY_NM_5__c = 'Baker Roofing Company - +200 SFS+ Customer Community';
    record1.OPEN_PIPE_OPTY_STG_NM_5__c = 'Stage 5: Negotiate and Mutual Plan';
    record1.OPEN_PIPE_AE_SCORE_5__c = 3.18;
    record1.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_5__c = 71280.0;
    record1.OPEN_PIPE_OPTY_DAYS_IN_STAGE_5__c = 51.0;
    record1.OPEN_PIPE_REVISED_SUB_SECTOR_5__c = 'Home Services';
    
    // Growth Factors
    record1.DEFINITION__c = 'Early-Stage Pipeline Percentage';
    record1.DESCRIPTION__c = 'Measures the percentage of a salesperson\'s open pipeline that is currently in stages 2-3 of the sales process. Improving this can help you with reaching your quota by driving potential business towards the later stages of the sales process and increasing the likelihood of closing deals.';
    record1.ACTIONABLE__c = 'A pipe assessment and more targeted client communication could help you reduce your early-stage deals and increase your pipe quality. Sellers like you realized an increase in {} after taking the recommended course.';
    record1.RECOMMENDED_ACTION__c = 'Impactful Executive Communication';
    record1.ACTION_LINK__c = 'https://readiness.my.site.com/act/share-nav?recordId=a6JHu000000POp1&type=course';
    
    // Upsell Opportunities
    record1.UPSELL_ACCT_ID_1__c = '0013y00001focD2';
    record1.UPSELL_ACCT_NM_1__c = 'Baker Roofing Company';
    record1.UPSELL_SUB_CATEGORY_1__c = 'AppExchange';
    
    record1.UPSELL_ACCT_ID_2__c = '0010M00001QqTzb';
    record1.UPSELL_ACCT_NM_2__c = 'MONI Smart Security (Org 2)';
    record1.UPSELL_SUB_CATEGORY_2__c = 'Account Engagement';
    
    // Cross-Sell Opportunities
    record1.CS_ACCT_ID_1__c = '0010M00001Qlf7n';
    record1.CS_ACCT_NM_1__c = 'isolved Inc. - People Services';
    record1.CS_NEXT_BEST_PRODUCT_1__c = 'Sales Cloud';
    
    // Renewals
    record1.RENEWAL_ACCT_ID__c = '00130000016hQwM';
    record1.RENEWAL_ACCT_NM__c = 'The Pool Management Group Inc';
    record1.RENEWAL_OPTY_NM__c = 'The Pool Management Group Inc Renewal 28 Call Center';
    record1.RENEWAL_OPTY_AMT__c = 37728.0;
    
    // Quota and Performance
    record1.VAL_QUOTA__c = 268321.0;
    record1.CQ_CUSTOMER_MEETING__c = 10.0;
    record1.CQ_PG__c = 197778.12;
    record1.CQ_ACV__c = 1861.32;
    record1.CQ_CALL_CONNECT__c = 0.0;
    record1.CQ_CC_ACV__c = 1861.32;
    record1.CQ_DAYS_ACV__c = 0.0;
    record1.CQ_DAYS_ACV_PART__c = 0.0;
    record1.CQ_DAYS_PG_PART__c = 0.0;
    record1.CQ_DAYS_PG__c = 0.0;
    
    // Previous Quarter Performance
    record1.PQ_CUSTOMER_MEETING__c = 124.0;
    record1.PQ_PG__c = 2324625.73;
    record1.PQ_ACV__c = 391831.07;
    record1.PQ_CALL_CONNECT__c = 8.0;
    record1.PQ_CC_ACV__c = 258226.09;
    record1.PQ_DAYS_ACV__c = 0.0;
    record1.PQ_DAYS_ACV_PART__c = 143.0;
    record1.PQ_DAYS_PG_PART__c = 0.0;
    record1.PQ_DAYS_PG__c = 0.0;
    
    // Additional Metrics
    record1.AOV__c = 3.31;
    record1.COVERAGE__c = 7.37;
    record1.RAMP_STATUS__c = 'On Track';
    record1.TIME_SINCE_ONBOARDING__c = 27.86;
    record1.FULLTOTALACVQUOTAUSD__c = 1362036.41;
    record1.ACV_THRESHOLD__c = 75000.0;
    record1.DAYS_TO_PRODUCTIVITY__c = 184.0;
    
    sampleRecords.add(record1);
    
    // Sample Record 2: Different profile
    AGENT_OU_PIPELINE_V2__c record2 = new AGENT_OU_PIPELINE_V2__c();
    
    // Basic Employee Information
    record2.EMP_ID__c = '728599';
    record2.FULL_NAME__c = 'Aly Barnhart';
    record2.EMP_EMAIL_ADDR__c = 'abarnhart@salesforce.com';
    record2.WORK_LOCATION_COUNTRY__c = 'Brazil';
    record2.OU_NAME__c = 'LATAM';
    record2.EMP_MGR_NM__c = 'Seth Maybury';
    record2.PRIMARY_INDUSTRY__c = 'Travel, Transportation, & Hospitality';
    record2.LEARNER_PROFILE__ID__c = 'a5jHu000001E7G6IAK';
    
    // AI and Analytics
    record2.CALL_AI_MENTION__c = 1.0;
    
    // Open Pipeline Stage 1
    record2.OPEN_PIPE_APM_L2_1__c = 'Sales Performance Management (SPM)';
    record2.OPEN_PIPE_PROD_NM_1__c = 'Salesforce Spiff - Platform';
    record2.OPEN_PIPE_OPTY_NM_1__c = 'Concrete Pumping Holdings (+45 FSL) +45';
    record2.OPEN_PIPE_OPTY_STG_NM_1__c = 'Stage 1: Identify the Opportunity';
    record2.OPEN_PIPE_AE_SCORE_1__c = 3.09;
    record2.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_1__c = 240240.0;
    record2.OPEN_PIPE_OPTY_DAYS_IN_STAGE_1__c = 261.0;
    record2.OPEN_PIPE_REVISED_SUB_SECTOR_1__c = 'General Contractors';
    
    // Growth Factors
    record2.DEFINITION__c = 'Deal Size';
    record2.DESCRIPTION__c = 'This growth factor measures the average size of deals closed by a salesperson over the past three months. Improving this can help you with reaching your quota by focusing on closing larger deals that contribute more to your overall sales target.';
    record2.ACTIONABLE__c = 'Close larger deals to elevate your ability to generate more ACV. Sellers like you uncovered an increase in {} by joining the recommended course.';
    record2.RECOMMENDED_ACTION__c = 'Assess AE Deal Health';
    record2.ACTION_LINK__c = 'https://readiness.my.site.com/act/share-nav?recordId=a69Hu000001eOBV&type=Media&assessmentType=';
    
    // Quota and Performance
    record2.VAL_QUOTA__c = 255543.98;
    record2.CQ_CUSTOMER_MEETING__c = 6.0;
    record2.CQ_PG__c = 154950.0;
    record2.CQ_ACV__c = 0.0;
    record2.CQ_CALL_CONNECT__c = 6.0;
    record2.CQ_CC_ACV__c = 0.0;
    
    // Previous Quarter Performance
    record2.PQ_CUSTOMER_MEETING__c = 121.0;
    record2.PQ_PG__c = 918487.41;
    record2.PQ_ACV__c = 670328.24;
    record2.PQ_CALL_CONNECT__c = 0.0;
    record2.PQ_CC_ACV__c = 248706.03;
    
    // Additional Metrics
    record2.AOV__c = 2.88;
    record2.COVERAGE__c = 3.24;
    record2.RAMP_STATUS__c = 'Fast Ramper';
    record2.TIME_SINCE_ONBOARDING__c = 34.86;
    record2.FULLTOTALACVQUOTAUSD__c = 1297177.53;
    record2.ACV_THRESHOLD__c = 100000.0;
    record2.DAYS_TO_PRODUCTIVITY__c = 225.0;
    
    sampleRecords.add(record2);
    
    // Sample Record 3: Another profile
    AGENT_OU_PIPELINE_V2__c record3 = new AGENT_OU_PIPELINE_V2__c();
    
    // Basic Employee Information
    record3.EMP_ID__c = '889718';
    record3.FULL_NAME__c = 'Sean McMillan';
    record3.EMP_EMAIL_ADDR__c = 'sean.mcmillan@salesforce.com';
    record3.WORK_LOCATION_COUNTRY__c = 'Canada';
    record3.OU_NAME__c = 'AMER ICE';
    record3.EMP_MGR_NM__c = 'Loren Fraser';
    record3.PRIMARY_INDUSTRY__c = 'Technology';
    record3.LEARNER_PROFILE__ID__c = 'a5jHu000001XfoTIAS';
    
    // AI and Analytics
    record3.CALL_AI_MENTION__c = 0.0;
    
    // Open Pipeline Stage 1
    record3.OPEN_PIPE_APM_L2_1__c = 'Sales Cloud & Industries';
    record3.OPEN_PIPE_PROD_NM_1__c = 'Sales Cloud - Enterprise Edition';
    record3.OPEN_PIPE_OPTY_NM_1__c = 'ACERTUS - SPIFF';
    record3.OPEN_PIPE_OPTY_STG_NM_1__c = 'Stage 1: Identify the Opportunity';
    record3.OPEN_PIPE_AE_SCORE_1__c = 4.27;
    record3.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_1__c = 21600.0;
    record3.OPEN_PIPE_OPTY_DAYS_IN_STAGE_1__c = 292.0;
    record3.OPEN_PIPE_REVISED_SUB_SECTOR_1__c = 'Logistical Services';
    
    // Growth Factors
    record3.DEFINITION__c = 'Pipeline Stage Stagnation Percentage';
    record3.DESCRIPTION__c = 'Measures the quality of a salesperson\'s pipeline based on the number of days an opportunity has been in the same stage for more than 30 days. Improving this can help you with reaching your quota by identifying and addressing potential roadblocks in your pipeline.';
    record3.ACTIONABLE__c = 'Great job! You are outperforming your peers. Ascend to the ranks of the top 10% sellers by completing the recommended course.';
    record3.RECOMMENDED_ACTION__c = 'Strategies for Reviving a Stalled Deal with Niklas Kotman';
    record3.ACTION_LINK__c = 'https://readiness.my.site.com/act/share-nav?recordId=a69Hu000001eOBV&type=Media&assessmentType=';
    
    // Quota and Performance
    record3.VAL_QUOTA__c = 214959.0;
    record3.CQ_CUSTOMER_MEETING__c = 8.0;
    record3.CQ_PG__c = 25188.18;
    record3.CQ_ACV__c = 148.18;
    record3.CQ_CALL_CONNECT__c = 31.0;
    record3.CQ_CC_ACV__c = 148.18;
    
    // Previous Quarter Performance
    record3.PQ_CUSTOMER_MEETING__c = 119.0;
    record3.PQ_PG__c = 2848517.94;
    record3.PQ_ACV__c = 67205.39;
    record3.PQ_CALL_CONNECT__c = 22.0;
    record3.PQ_CC_ACV__c = 67205.39;
    
    // Additional Metrics
    record3.AOV__c = 9.63;
    record3.COVERAGE__c = 3.30;
    record3.RAMP_STATUS__c = 'Slow Ramper';
    record3.TIME_SINCE_ONBOARDING__c = 25.86;
    record3.FULLTOTALACVQUOTAUSD__c = 1091162.29;
    record3.ACV_THRESHOLD__c = 75000.0;
    record3.DAYS_TO_PRODUCTIVITY__c = 107.0;
    
    sampleRecords.add(record3);
    
    // Insert the records
    System.debug('📝 Inserting ' + sampleRecords.size() + ' sample records...');
    insert sampleRecords;
    
    System.debug('✅ SUCCESS: Inserted ' + sampleRecords.size() + ' sample records');
    
    // Query to verify the records were created
    List<AGENT_OU_PIPELINE_V2__c> verifyRecords = [
        SELECT Id, EMP_ID__c, FULL_NAME__c, OU_NAME__c, VAL_QUOTA__c, CQ_PG__c, CQ_ACV__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE EMP_ID__c IN ('888674', '728599', '889718')
        ORDER BY EMP_ID__c
    ];
    
    System.debug('\n📊 VERIFICATION - Sample Records Created:');
    for (AGENT_OU_PIPELINE_V2__c record : verifyRecords) {
        System.debug('  ✅ ' + record.FULL_NAME__c + ' (' + record.EMP_ID__c + ') - OU: ' + record.OU_NAME__c + ', Quota: $' + record.VAL_QUOTA__c + ', CQ PG: $' + record.CQ_PG__c + ', CQ ACV: $' + record.CQ_ACV__c);
    }
    
    System.debug('\n🎯 NEXT STEPS:');
    System.debug('  1. ✅ Object populated with sample data');
    System.debug('  2. 🔧 Ready to build Apex classes');
    System.debug('  3. 🧪 Test with real data structure');
    System.debug('  4. 🚀 Deploy AE Territory Analysis Agent');
    
} catch (Exception e) {
    System.debug('❌ Error populating object: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
} 