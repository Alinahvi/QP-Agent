# APEX FIELD USAGE INVENTORY

## Overview
This document lists ALL field names used in the Apex code across all services and handlers. Please validate each field exists in the `AGENT_OU_PIPELINE_V2__c` object and provide detailed descriptions.

## 1. KPI ANALYSIS SERVICE FIELDS

### Primary KPI Fields (Current Quarter)
- **CQ_CUSTOMER_MEETING__c** - Current Quarter Customer Meeting
- **CQ_PG__c** - Current Quarter Pipeline Generation  
- **CQ_ACV__c** - Current Quarter Annual Contract Value
- **CQ_CC_ACV__c** - Current Quarter CC ACV
- **CQ_CALL_CONNECT__c** - Current Quarter Call Connect
- **CALL_AI_MENTION__c** - Call AI Mention

### Primary KPI Fields (Previous Quarter)
- **PQ_CUSTOMER_MEETING__c** - Previous Quarter Customer Meeting
- **PQ_PG__c** - Previous Quarter Pipeline Generation
- **PQ_ACV__c** - Previous Quarter Annual Contract Value
- **PQ_CC_ACV__c** - Previous Quarter CC ACV
- **PQ_CALL_CONNECT__c** - Previous Quarter Call Connect

### Additional KPI Fields
- **COVERAGE__c** - Coverage
- **ACV_THRESHOLD__c** - ACV Threshold
- **FULLTOTALACVQUOTAUSD__c** - Full Total ACV Quota USD
- **VAL_QUOTA__c** - Current Quarter Quota

## 2. DIMENSION FIELDS (For Grouping/Analysis)

### Operating Unit & Region
- **OU_NAME__c** - Operating Unit Name
- **WORK_LOCATION_COUNTRY__c** - Work Country

### Industry/Segment
- **PRIMARY_INDUSTRY__c** - Primary Industry

## 3. OPEN PIPE ANALYSIS SERVICE FIELDS

### Stage Names
- **OPEN_PIPE_OPTY_STG_NM_1__c** - Open Pipe Opportunity Stage Name 1
- **OPEN_PIPE_OPTY_STG_NM_2__c** - Open Pipe Opportunity Stage Name 2
- **OPEN_PIPE_OPTY_STG_NM_3__c** - Open Pipe Opportunity Stage Name 3
- **OPEN_PIPE_OPTY_STG_NM_4__c** - Open Pipe Opportunity Stage Name 4
- **OPEN_PIPE_OPTY_STG_NM_5__c** - Open Pipe Opportunity Stage Name 5

### Product Names
- **OPEN_PIPE_PROD_NM_1__c** - Open Pipe Product Name 1
- **OPEN_PIPE_PROD_NM_2__c** - Open Pipe Product Name 2
- **OPEN_PIPE_PROD_NM_3__c** - Open Pipe Product Name 3
- **OPEN_PIPE_PROD_NM_4__c** - Open Pipe Product Name 4
- **OPEN_PIPE_PROD_NM_5__c** - Open Pipe Product Name 5

### Product Families
- **OPEN_PIPE_APM_L2_1__c** - Open Pipe APM L2 1
- **OPEN_PIPE_APM_L2_2__c** - Open Pipe APM L2 2
- **OPEN_PIPE_APM_L2_3__c** - Open Pipe APM L2 3
- **OPEN_PIPE_APM_L2_4__c** - Open Pipe APM L2 4
- **OPEN_PIPE_APM_L2_5__c** - Open Pipe APM L2 5

### Amounts
- **OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_1__c** - Open Pipe Original OpenPipe Alloc Amt 1
- **OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_2__c** - Open Pipe Original OpenPipe Alloc Amt 2
- **OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_3__c** - Open Pipe Original OpenPipe Alloc Amt 3
- **OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_4__c** - Open Pipe Original OpenPipe Alloc Amt 4
- **OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_5__c** - Open Pipe Original OpenPipe Alloc Amt 5

### Sub-Sector/Industry
- **OPEN_PIPE_REVISED_SUB_SECTOR_1__c** - Open Pipe Revised Sub Sector 1
- **OPEN_PIPE_REVISED_SUB_SECTOR_2__c** - Open Pipe Revised Sub Sector 2
- **OPEN_PIPE_REVISED_SUB_SECTOR_3__c** - Open Pipe Revised Sub Sector 3
- **OPEN_PIPE_REVISED_SUB_SECTOR_4__c** - Open Pipe Revised Sub Sector 4
- **OPEN_PIPE_REVISED_SUB_SECTOR_5__c** - Open Pipe Revised Sub Sector 5

### Opportunity Names
- **OPEN_PIPE_OPTY_NM_1__c** - Open Pipe Opportunity Name 1
- **OPEN_PIPE_OPTY_NM_2__c** - Open Pipe Opportunity Name 2
- **OPEN_PIPE_OPTY_NM_3__c** - Open Pipe Opportunity Name 3
- **OPEN_PIPE_OPTY_NM_4__c** - Open Pipe Opportunity Name 4
- **OPEN_PIPE_OPTY_NM_5__c** - Open Pipe Opportunity Name 5

### AE Scores
- **OPEN_PIPE_AE_SCORE_1__c** - Open Pipe AE Score 1
- **OPEN_PIPE_AE_SCORE_2__c** - Open Pipe AE Score 2
- **OPEN_PIPE_AE_SCORE_3__c** - Open Pipe AE Score 3
- **OPEN_PIPE_AE_SCORE_4__c** - Open Pipe AE Score 4
- **OPEN_PIPE_AE_SCORE_5__c** - Open Pipe AE Score 5

### Days in Stage
- **OPEN_PIPE_OPTY_DAYS_IN_STAGE_1__c** - Open Pipe Opportunity Days In Stage 1
- **OPEN_PIPE_OPTY_DAYS_IN_STAGE_2__c** - Open Pipe Opportunity Days In Stage 2
- **OPEN_PIPE_OPTY_DAYS_IN_STAGE_3__c** - Open Pipe Opportunity Days In Stage 3
- **OPEN_PIPE_OPTY_DAYS_IN_STAGE_4__c** - Open Pipe Opportunity Days In Stage 4
- **OPEN_PIPE_OPTY_DAYS_IN_STAGE_5__c** - Open Pipe Opportunity Days In Stage 5

## 4. FUTURE PIPELINE ANALYSIS SERVICE FIELDS

### Renewals
- **RENEWAL_ACCT_ID_1__c** - Renewal Account ID 1
- **RENEWAL_ACCT_ID_2__c** - Renewal Account ID 2
- **RENEWAL_ACCT_ID_3__c** - Renewal Account ID 3
- **RENEWAL_ACCT_ID_4__c** - Renewal Account ID 4
- **RENEWAL_ACCT_ID_5__c** - Renewal Account ID 5
- **RENEWAL_ACCT_NM_1__c** - Renewal Account Name 1
- **RENEWAL_ACCT_NM_2__c** - Renewal Account Name 2
- **RENEWAL_ACCT_NM_3__c** - Renewal Account Name 3
- **RENEWAL_ACCT_NM_4__c** - Renewal Account Name 4
- **RENEWAL_ACCT_NM_5__c** - Renewal Account Name 5
- **RENEWAL_OPTY_NM_1__c** - Renewal Opportunity Name 1
- **RENEWAL_OPTY_NM_2__c** - Renewal Opportunity Name 2
- **RENEWAL_OPTY_NM_3__c** - Renewal Opportunity Name 3
- **RENEWAL_OPTY_NM_4__c** - Renewal Opportunity Name 4
- **RENEWAL_OPTY_NM_5__c** - Renewal Opportunity Name 5
- **RENEWAL_OPTY_AMT_1__c** - Renewal Opportunity Amount 1
- **RENEWAL_OPTY_AMT_2__c** - Renewal Opportunity Amount 2
- **RENEWAL_OPTY_AMT_3__c** - Renewal Opportunity Amount 3
- **RENEWAL_OPTY_AMT_4__c** - Renewal Opportunity Amount 4
- **RENEWAL_OPTY_AMT_5__c** - Renewal Opportunity Amount 5

### Cross-Sell
- **CS_ACCT_ID_1__c** - Cross-Sell Account ID 1
- **CS_ACCT_ID_2__c** - Cross-Sell Account ID 2
- **CS_ACCT_ID_3__c** - Cross-Sell Account ID 3
- **CS_ACCT_ID_4__c** - Cross-Sell Account ID 4
- **CS_ACCT_ID_5__c** - Cross-Sell Account ID 5
- **CS_ACCT_NM_1__c** - Cross-Sell Account Name 1
- **CS_ACCT_NM_2__c** - Cross-Sell Account Name 2
- **CS_ACCT_NM_3__c** - Cross-Sell Account Name 3
- **CS_ACCT_NM_4__c** - Cross-Sell Account Name 4
- **CS_ACCT_NM_5__c** - Cross-Sell Account Name 5
- **CS_NEXT_BEST_PRODUCT_1__c** - Cross-Sell Next Best Product 1
- **CS_NEXT_BEST_PRODUCT_2__c** - Cross-Sell Next Best Product 2
- **CS_NEXT_BEST_PRODUCT_3__c** - Cross-Sell Next Best Product 3
- **CS_NEXT_BEST_PRODUCT_4__c** - Cross-Sell Next Best Product 4
- **CS_NEXT_BEST_PRODUCT_5__c** - Cross-Sell Next Best Product 5

### Upsell (Used for Off-Sell)
- **UPSELL_ACCT_ID_1__c** - Upsell Account ID 1
- **UPSELL_ACCT_ID_2__c** - Upsell Account ID 2
- **UPSELL_ACCT_ID_3__c** - Upsell Account ID 3
- **UPSELL_ACCT_ID_4__c** - Upsell Account ID 4
- **UPSELL_ACCT_ID_5__c** - Upsell Account ID 5
- **UPSELL_ACCT_NM_1__c** - Upsell Account Name 1
- **UPSELL_ACCT_NM_2__c** - Upsell Account Name 2
- **UPSELL_ACCT_NM_3__c** - Upsell Account Name 3
- **UPSELL_ACCT_NM_4__c** - Upsell Account Name 4
- **UPSELL_ACCT_NM_5__c** - Upsell Account Name 5
- **UPSELL_SUB_CATEGORY_1__c** - Upsell Sub Category 1
- **UPSELL_SUB_CATEGORY_2__c** - Upsell Sub Category 2
- **UPSELL_SUB_CATEGORY_3__c** - Upsell Sub Category 3
- **UPSELL_SUB_CATEGORY_4__c** - Upsell Sub Category 4
- **UPSELL_SUB_CATEGORY_5__c** - Upsell Sub Category 5

## 5. STANDARD FIELDS

### System Fields
- **Id** - Record ID
- **IsDeleted** - Deleted flag
- **CreatedDate** - Created Date
- **LastModifiedDate** - Last Modified Date

## 6. EMPLOYEE/AGENT FIELDS

### Employee Information
- **EMP_EMAIL_ADDR__c** - Employee Email
- **EMP_ID__c** - Employee ID
- **EMP_MGR_NM__c** - Employee Manager Name
- **FULL_NAME__c** - Full Name
- **LEARNER_PROFILE_ID__c** - Learner Profile ID

## 7. ADDITIONAL METRICS

### Performance Metrics
- **AOV__c** - Average Order Value
- **DAYS_TO_PRODUCTIVITY__c** - Days To Productivity
- **TIME_SINCE_ONBOARDING__c** - Time Since Onboarding
- **RAMP_STATUS__c** - Ramp Status

### Quota and Threshold Fields
- **ACV_THRESHOLD__c** - ACV Threshold
- **VAL_QUOTA__c** - Current Quarter Quota
- **FULLTOTALACVQUOTAUSD__c** - Full Total ACV Quota USD

## 8. DAYS FIELDS

### Current Quarter Days
- **CQ_DAYS_ACV__c** - Current Quarter Days ACV
- **CQ_DAYS_ACV_PART__c** - Current Quarter Days ACV Part
- **CQ_DAYS_PG__c** - Current Quarter Days PG
- **CQ_DAYS_PG_PART__c** - Current Quarter Days PG Part

### Previous Quarter Days
- **PQ_DAYS_ACV__c** - Previous Quarter Days ACV
- **PQ_DAYS_ACV_PART__c** - Previous Quarter Days ACV Part
- **PQ_DAYS_PG__c** - Previous Quarter Days PG
- **PQ_DAYS_PG_PART__c** - Previous Quarter Days PG Part

## 9. MISC FIELDS

### Action and Description
- **ACTIONABLE__c** - Actionable
- **ACTION_LINK__c** - Action Link
- **DESCRIPTION__c** - Description
- **DEFINITION__c** - Definition
- **RECOMMENDED_ACTION__c** - Recommended Action

## SUMMARY

**Total Fields Listed**: 108 fields
**Categories**: 9 main categories
**Most Critical**: KPI fields, Dimension fields, Open Pipe fields, Future Pipeline fields

## VALIDATION REQUEST

Please:
1. ✅ **Confirm each field exists** in the `AGENT_OU_PIPELINE_V2__c` object
2. 📝 **Provide detailed descriptions** for each field
3. 🔧 **Identify any missing fields** that should be added
4. 📚 **Suggest field groupings** for agent topic instructions
5. ⚠️ **Flag any deprecated fields** that should not be used

This will ensure the Apex code is using the correct, current field names and the agent instructions are accurate. 