# AGENT_OU_PIPELINE_V2__c Object Field Mapping

## Object Overview
- **Object Name**: AGENT_OU_PIPELINE_V2__c
- **Total Fields**: 153
- **Label**: AGENT_OU_PIPELINE_V2
- **Plural Label**: AGENT_OU_PIPELINE_V2

## Key Fields for KPI Analysis

### 1. DIMENSION FIELDS (For Grouping/Analysis)

#### Operating Unit & Region
- **OU_NAME__c** (Operating Unit Name) - STRING
- **WORK_LOCATION_COUNTRY__c** (Work Country) - STRING

#### Industry/Segment
- **PRIMARY_INDUSTRY__c** (Primary Industry) - STRING

#### Open Pipe Sub-Sector (For Stage Filtering)
- **OPEN_PIPE_REVISED_SUB_SECTOR_1__c** (Open Pipe Revised Sub Sector 1) - STRING
- **OPEN_PIPE_REVISED_SUB_SECTOR_2__c** (Open Pipe Revised Sub Sector 2) - STRING
- **OPEN_PIPE_REVISED_SUB_SECTOR_3__c** (Open Pipe Revised Sub Sector 3) - STRING
- **OPEN_PIPE_REVISED_SUB_SECTOR_4__c** (Open Pipe Revised Sub Sector 4) - STRING
- **OPEN_PIPE_REVISED_SUB_SECTOR_5__c** (Open Pipe Revised Sub Sector 5) - STRING

#### Stage Names
- **OPEN_PIPE_OPTY_STG_NM_1__c** (Open Pipe Opty Stg Nm 1) - STRING
- **OPEN_PIPE_OPTY_STG_NM_2__c** (Open Pipe Opty Stg Nm 2) - STRING
- **OPEN_PIPE_OPTY_STG_NM_3__c** (Open Pipe Opty Stg Nm 3) - STRING
- **OPEN_PIPE_OPTY_STG_NM_4__c** (Open Pipe Opty Stg Nm 4) - STRING
- **OPEN_PIPE_OPTY_STG_NM_5__c** (Open Pipe Opty Stg Nm 5) - STRING

### 2. KPI FIELDS (Current Quarter)

#### Customer Meetings
- **CQ_CUSTOMER_MEETING__c** (Current Quarter Customer Meeting) - DOUBLE

#### Pipeline Generation
- **CQ_PG__c** (Current Quarter PG) - CURRENCY

#### ACV (Annual Contract Value)
- **CQ_ACV__c** (Current Quarter ACV) - CURRENCY
- **CQ_CC_ACV__c** (Current Quarter Cc Acv) - DOUBLE

#### Call Connections
- **CQ_CALL_CONNECT__c** (Current Quarter Call Connect) - DOUBLE

#### AI Mentions
- **CALL_AI_MENTION__c** (Call AI Mention) - DOUBLE

#### Coverage
- **COVERAGE__c** (Coverage) - DOUBLE

### 3. KPI FIELDS (Previous Quarter)

#### Customer Meetings
- **PQ_CUSTOMER_MEETING__c** (Previous Quarter Customer Meeting) - DOUBLE

#### Pipeline Generation
- **PQ_PG__c** (Previous Quarter Pg) - CURRENCY

#### ACV (Annual Contract Value)
- **PQ_ACV__c** (Previous Quarter Acv) - CURRENCY
- **PQ_CC_ACV__c** (Previous Quarter Cc Acv) - CURRENCY

#### Call Connections
- **PQ_CALL_CONNECT__c** (Previous Quarter Call Connect) - DOUBLE

### 4. OPEN PIPE FIELDS

#### Opportunity Names
- **OPEN_PIPE_OPTY_NM_1__c** (Open Pipe Opty Nm 1) - STRING
- **OPEN_PIPE_OPTY_NM_2__c** (Open Pipe Opty Nm 2) - STRING
- **OPEN_PIPE_OPTY_NM_3__c** (Open Pipe Opty Nm 3) - STRING
- **OPEN_PIPE_OPTY_NM_4__c** (Open Pipe Opty Nm 4) - STRING
- **OPEN_PIPE_OPTY_NM_5__c** (Open Pipe Opty Nm 5) - STRING

#### Product Names
- **OPEN_PIPE_PROD_NM_1__c** (Open Pipe Prod Nm 1) - STRING
- **OPEN_PIPE_PROD_NM_2__c** (Open Pipe Prod Nm 2) - STRING
- **OPEN_PIPE_PROD_NM_3__c** (Open Pipe Prod Nm 3) - STRING
- **OPEN_PIPE_PROD_NM_4__c** (Open Pipe Prod Nm 4) - STRING
- **OPEN_PIPE_PROD_NM_5__c** (Open Pipe Prod Nm 5) - STRING

#### Amounts
- **OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_1__c** (Open Pipe Original OpenPipe Alloc Amt 1) - CURRENCY
- **OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_2__c** (Open Pipe Original OpenPipe Alloc Amt 2) - CURRENCY
- **OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_3__c** (Open Pipe Original OpenPipe Alloc Amt 3) - CURRENCY
- **OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_4__c** (Open Pipe Original OpenPipe Alloc Amt 4) - CURRENCY
- **OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_5__c** (Open Pipe Original OpenPipe Alloc Amt 5) - CURRENCY

### 5. FUTURE PIPELINE FIELDS

#### Renewals
- **RENEWAL_ACCT_ID_1__c** (RENEWAL_ACCT_ID_1) - STRING
- **RENEWAL_ACCT_ID_2__c** (RENEWAL_ACCT_ID_2) - STRING
- **RENEWAL_ACCT_ID_3__c** (RENEWAL_ACCT_ID_3) - STRING
- **RENEWAL_ACCT_ID_4__c** (RENEWAL_ACCT_ID_4) - STRING
- **RENEWAL_ACCT_ID_5__c** (RENEWAL_ACCT_ID_5) - STRING
- **RENEWAL_ACCT_NM_1__c** (RENEWAL_ACCT_NM_1) - STRING
- **RENEWAL_ACCT_NM_2__c** (RENEWAL_ACCT_NM_2) - STRING
- **RENEWAL_ACCT_NM_3__c** (RENEWAL_ACCT_NM_3) - STRING
- **RENEWAL_ACCT_NM_4__c** (RENEWAL_ACCT_NM_4) - STRING
- **RENEWAL_ACCT_NM_5__c** (RENEWAL_ACCT_NM_5) - STRING
- **RENEWAL_OPTY_NM_1__c** (RENEWAL_OPTY_NM_1) - STRING
- **RENEWAL_OPTY_NM_2__c** (RENEWAL_OPTY_NM_2) - STRING
- **RENEWAL_OPTY_NM_3__c** (RENEWAL_OPTY_NM_3) - STRING
- **RENEWAL_OPTY_NM_4__c** (RENEWAL_OPTY_NM_4) - STRING
- **RENEWAL_OPTY_NM_5__c** (RENEWAL_OPTY_NM_5) - STRING
- **RENEWAL_OPTY_AMT_1__c** (RENEWAL_OPTY_AMT_1) - DOUBLE
- **RENEWAL_OPTY_AMT_2__c** (RENEWAL_OPTY_AMT_2) - DOUBLE
- **RENEWAL_OPTY_AMT_3__c** (RENEWAL_OPTY_AMT_3) - DOUBLE
- **RENEWAL_OPTY_AMT_4__c** (RENEWAL_OPTY_AMT_4) - DOUBLE
- **RENEWAL_OPTY_AMT_5__c** (RENEWAL_OPTY_AMT_5) - DOUBLE

#### Cross-Sell
- **CS_ACCT_ID_1__c** (Cross-Sell Acct Id 1) - STRING
- **CS_ACCT_ID_2__c** (CS_ACCT_ID_2) - STRING
- **CS_ACCT_ID_3__c** (CS_ACCT_ID_3) - STRING
- **CS_ACCT_ID_4__c** (CS_ACCT_ID_4) - STRING
- **CS_ACCT_ID_5__c** (CS_ACCT_ID_5) - STRING
- **CS_ACCT_NM_1__c** (Cross-Sell Acct Nm 1) - STRING
- **CS_ACCT_NM_2__c** (CS_ACCT_NM_2) - STRING
- **CS_ACCT_NM_3__c** (CS_ACCT_NM_3) - STRING
- **CS_ACCT_NM_4__c** (CS_ACCT_NM_4) - STRING
- **CS_ACCT_NM_5__c** (CS_ACCT_NM_5) - STRING
- **CS_NEXT_BEST_PRODUCT_1__c** (CS Next Best Product 1) - STRING
- **CS_NEXT_BEST_PRODUCT_2__c** (CS_NEXT_BEST_PRODUCT_2) - STRING
- **CS_NEXT_BEST_PRODUCT_3__c** (CS_NEXT_BEST_PRODUCT_3) - STRING
- **CS_NEXT_BEST_PRODUCT_4__c** (CS_NEXT_BEST_PRODUCT_4) - STRING
- **CS_NEXT_BEST_PRODUCT_5__c** (CS_NEXT_BEST_PRODUCT_5) - STRING

#### Upsell (Used for Off-Sell)
- **UPSELL_ACCT_ID_1__c** (Upsell Acct Id 1) - STRING
- **UPSELL_ACCT_ID_2__c** (UPSELL_ACCT_ID_2) - STRING
- **UPSELL_ACCT_ID_3__c** (UPSELL_ACCT_ID_3) - STRING
- **UPSELL_ACCT_ID_4__c** (UPSELL_ACCT_ID_4) - STRING
- **UPSELL_ACCT_ID_5__c** (UPSELL_ACCT_ID_5) - STRING
- **UPSELL_ACCT_NM_1__c** (Upsell Acct Nm 1) - STRING
- **UPSELL_ACCT_NM_2__c** (UPSELL_ACCT_NM_2) - STRING
- **UPSELL_ACCT_NM_3__c** (UPSELL_ACCT_NM_3) - STRING
- **UPSELL_ACCT_NM_4__c** (UPSELL_ACCT_NM_4) - STRING
- **UPSELL_ACCT_NM_5__c** (UPSELL_ACCT_NM_5) - STRING
- **UPSELL_SUB_CATEGORY_1__c** (Upsell Sub Category 1) - STRING
- **UPSELL_SUB_CATEGORY_2__c** (UPSELL_SUB_CATEGORY_2) - STRING
- **UPSELL_SUB_CATEGORY_3__c** (UPSELL_SUB_CATEGORY_3) - STRING
- **UPSELL_SUB_CATEGORY_4__c** (UPSELL_SUB_CATEGORY_4) - STRING
- **UPSELL_SUB_CATEGORY_5__c** (UPSELL_SUB_CATEGORY_5) - STRING

## Field Mapping Issues Found

### ❌ INCORRECT FIELD NAMES USED IN CODE
- **SEGMENT__c** - This field does NOT exist
- **REGION__c** - This field does NOT exist

### ✅ CORRECT FIELD NAMES TO USE
- **PRIMARY_INDUSTRY__c** - For industry/segment filtering
- **OU_NAME__c** - For operating unit filtering
- **WORK_LOCATION_COUNTRY__c** - For country/region filtering

## Recommendations for Fixes

1. **Replace all instances of `SEGMENT__c` with `PRIMARY_INDUSTRY__c`**
2. **Replace all instances of `REGION__c` with `WORK_LOCATION_COUNTRY__c`**
3. **Update field references in all services and handlers**
4. **Verify field accessibility and permissions**
5. **Test with actual data to ensure correct filtering**

## Data Types Summary

- **STRING**: 89 fields (mostly names, IDs, descriptions)
- **DOUBLE**: 35 fields (KPI metrics, scores, amounts)
- **CURRENCY**: 15 fields (ACV, pipeline, quotas)
- **DATETIME**: 5 fields (timestamps)
- **DATE**: 1 field (last activity)
- **BOOLEAN**: 3 fields (flags)
- **REFERENCE**: 3 fields (lookups)
- **ID**: 1 field (record ID)
- **TEXTAREA**: 2 fields (long text)
- **URL**: 1 field (action link) 