# KPI V4 Deployment Guide

## Overview
This guide covers deploying the new KPI Analysis V4 classes that mirror the working Content Search V2 pattern for Agentforce compatibility.

## Files Added

### 1. Handler Class
- **File**: `force-app/main/default/classes/ANAgentKPIAnalysisHandlerV4.cls`
- **Purpose**: Invocable entry point for KPI search actions
- **Pattern**: Mirrors `ANAgentContentSearchHandlerV2` exactly

### 2. Service Class  
- **File**: `force-app/main/default/classes/ANAgentKPIAnalysisServiceV4.cls`
- **Purpose**: Core KPI search logic and DTOs
- **Pattern**: Mirrors `ANAgentContentSearchServiceV2` exactly

### 3. Smoke Test
- **File**: `force-app/main/default/classes/ANAgentKPIAnalysisV4_SmokeTest.cls`
- **Purpose**: Basic test coverage for the new classes

## Permission Set Updates

### Updated File
- `force-app/main/default/permissionsets/AEAE_AN_Agents_CRUD.permissionset-meta.xml`

### Changes Made
Added class access for both new classes:
```xml
<classAccesses>
    <apexClass>ANAgentKPIAnalysisHandlerV4</apexClass>
    <enabled>true</enabled>
</classAccesses>
<classAccesses>
    <apexClass>ANAgentKPIAnalysisServiceV4</apexClass>
    <enabled>true</enabled>
</classAccesses>
```

## Deployment Steps

### 1. Deploy Classes
```bash
# Deploy the new classes
sfdx force:source:deploy -p force-app/main/default/classes/ANAgentKPIAnalysisHandlerV4.cls
sfdx force:source:deploy -p force-app/main/default/classes/ANAgentKPIAnalysisServiceV4.cls
sfdx force:source:deploy -p force-app/main/default/classes/ANAgentKPIAnalysisV4_SmokeTest.cls
```

### 2. Deploy Permission Set
```bash
# Deploy the updated permission set
sfdx force:source:deploy -p force-app/main/default/permissionsets/AEAE_AN_Agents_CRUD.permissionset-meta.xml
```

### 3. Run Tests
```bash
# Run the smoke test
sfdx force:apex:test:run -n ANAgentKPIAnalysisV4_SmokeTest
```

## Verification

### 1. Anonymous Apex Test

#### Basic Test
Run the test script: `scripts/testing/test_kpi_v4_basic.apex`

Expected output:
```
=== Testing KPI V4 Basic Functionality ===
Response count: 1
Success: true
Message: Found X KPI record(s) matching "Test".
Total count: X
Results: X
=== KPI V4 Test Completed Successfully ===
```

#### Comprehensive Test (Search + Aggregation)
Run the complete test script: `scripts/testing/test_kpi_v4_complete.apex`

This tests both search and aggregation functionality with examples:
- Basic search across name/email/OU
- Single value aggregation (e.g., avg ACV in US)
- Grouped comparison (e.g., avg calls by country)
- Count with filters (e.g., AEs in Brazil ≤6 months)
- Service layer direct calls

### 2. Agentforce Setup

#### KPI Search Action
1. Create new Topic: "KPI Search (V4)"
2. Add action: `ANAgentKPIAnalysisHandlerV4.searchKPIs`
3. Configure inputs:
   - Required: `searchTerm`
   - Optional: `ouName`, `workLocationCountry`, `primaryIndustry`, `recordLimit`
4. Configure outputs: `success`, `message`, `results`

#### KPI Aggregation Action
1. Add a second action to the same Topic: `ANAgentKPIAnalysisHandlerV4.aggregateKPIs`
2. Configure inputs:
   - **Aggregator**: `AVG`, `SUM`, or `COUNT`
   - **Metric API Name**: Required for AVG/SUM (e.g., `CQ_ACV__c`, `PQ_ACV__c`, `CQ_CALL_CONNECT__c`)
   - **Group By**: Optional (e.g., `WORK_LOCATION_COUNTRY__c`, `OU_NAME__c`)
   - **Max Groups**: Optional cap on group count (default 50)
   - **Filters**: Set any of the API inputs (Country/OU/Industry/RampStatus) and Max Months Since Onboarding for tenure windows
3. Configure outputs: `success`, `message`, `rows` (with `groupKey` and `value`)

## What It Does

### Search Capabilities
- **LIKE search** across: `FULL_NAME__c`, `EMP_EMAIL_ADDR__c`, `OU_NAME__c`
- **Optional filters**: OU Name, Work Location Country, Primary Industry
- **Default limit**: 25 records (max 50)
- **Ordering**: By `FULL_NAME__c ASC`

### Aggregation Capabilities
- **Functions**: AVG, SUM, COUNT over whitelisted numeric KPIs
- **Metrics**: CQ_ACV__c, PQ_ACV__c, CQ_CALL_CONNECT__c, PQ_CALL_CONNECT__c, AOV__c, COVERAGE__c, VAL_QUOTA__c, CQ_PG__c, PQ_PG__c, CQ_CUSTOMER_MEETING__c, PQ_CUSTOMER_MEETING__c
- **Group By**: Country, OU, Industry, Ramp Status, Manager
- **Filters**: OU, Country, Industry, Ramp Status, Tenure window (months since onboarding)
- **Examples**:
  - "avg ACV of AEs who joined past 6 months in Brazil" → AVG(CQ_ACV__c), WORK_LOCATION_COUNTRY__c='Brazil', TIME_SINCE_ONBOARDING__c ≤ 6
  - "compare avg calls in Brazil vs USA" → AVG(CQ_CALL_CONNECT__c) grouped by WORK_LOCATION_COUNTRY__c

### Returned Data
- **Identity**: Id, Employee ID, Full Name, Email, OU, Country, Industry, Manager
- **Timestamps**: Created Date, Last Modified Date  
- **KPIs**: VAL_QUOTA__c, COVERAGE__c, CQ_ACV__c, PQ_ACV__c, AOV__c, RAMP_STATUS__c

## Architecture Benefits

### 1. Agentforce Compatibility
- **No custom permission checks** (avoids "Invalid Config" errors)
- **@AuraEnabled on fields only** (not on classes)
- **Simple invocable pattern** (proven working in Content V2)

### 2. Minimal Dependencies
- Only depends on `AGENT_OU_PIPELINE_V2__c` object
- No external service calls or complex logic
- Defensive schema validation

### 3. Extensible Design
- Easy to add more filters later
- Can extend to include counts/aggregates
- Maintains same I/O structure

## Troubleshooting

### Common Issues

1. **"Invalid Config" in Agentforce**
   - Ensure permission set grants access to both classes
   - Verify object and field permissions exist

2. **"Object not accessible" errors**
   - Check `AGENT_OU_PIPELINE_V2__c` object permissions
   - Verify field-level security grants

3. **No results returned**
   - Check if search term matches any records
   - Verify filters aren't too restrictive

### Debug Steps
1. Run anonymous apex test script
2. Check debug logs for detailed error messages
3. Verify permission set assignments
4. Test with simple search terms first

## Next Steps

Once V4 is stable in Agentforce:

1. **Add more filters** (e.g., date ranges, manager hierarchy)
2. **Include aggregate data** (counts, averages, trends)
3. **Add pagination** for large result sets
4. **Extend to other KPI objects** if needed

## Support

For issues or questions:
1. Check debug logs first
2. Verify permission set configuration
3. Test with minimal parameters
4. Compare behavior with working Content Search V2 