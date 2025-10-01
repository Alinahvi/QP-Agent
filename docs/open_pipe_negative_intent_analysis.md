# Open Pipe Analysis - Negative Intent Gap Analysis

## 1) Inventory & Trace - Current State

### Entry Points
- **Primary**: `ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe()` - @InvocableMethod
- **Service**: `ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe()` - Main business logic
- **Data Source**: `Agent_Open_Pipe__c` object with flattened fields

### Current Method Signature
```apex
public static String analyzeOpenPipe(
    String ouName, String workLocationCountry, String groupBy, 
    String filterCriteria, String restrictInValuesCsv, 
    Boolean perAENormalize, Integer limitN, String aggregationType, String analysisType,
    Boolean includeClosureProb, Boolean includeStageBottlenecks, 
    Boolean includePMF, Boolean includeAEBenchmarks, Boolean includeHealthScore,
    String excludeProductListCsv, Boolean requireNoProductMatch, Boolean negativeIntent
)
```

### Current Filter Support
- ✅ **Positive Filters**: `open_pipe_prod_nm = 'ProductName'`
- ✅ **Field Mappings**: `FILTER_FIELD_MAP` with 50+ field aliases
- ✅ **OU Aliases**: `OU_ALIAS_MAP` with 50+ OU name variations
- ❌ **Negative Filters**: NOT supported (missing `handleNegativeFilters` method)
- ❌ **Anti-joins**: NOT supported
- ❌ **Product Exclusion**: NOT supported

## 2) Gap Analysis - Missing Capabilities

### Missing Methods
1. **`handleNegativeFilters()`** - Main method for negative intent processing
2. **`buildNegativeQuery()`** - SOQL builder for anti-join patterns
3. **`parseExcludeProducts()`** - Parse CSV product exclusion list
4. **`validateNegativeIntent()`** - Validate negative filter parameters

### Missing SOQL Patterns
1. **Anti-join Pattern**: AEs with open pipe MINUS AEs with specific product
2. **Conditional Aggregation**: `SUM(CASE WHEN product = 'X' THEN 1 ELSE 0 END)`
3. **NOT IN Subquery**: `WHERE AE_ID NOT IN (SELECT AE_ID WHERE product = 'X')`

### Missing Data Model Support
1. **Product Field Mapping**: Need to identify authoritative product field
2. **AE Identity Field**: Need consistent AE identifier for grouping
3. **Negative Filter Validation**: Ensure excluded products exist in data

## 3) Data Model Probe

### Product Fields Available
- **Primary**: `open_pipe_prod_nm__c` (String) - Product name
- **Alternative**: `open_pipe_apm_l2__c` (String) - APM L2 category
- **Fallback**: `open_pipe_revised_sub_sector__c` (String) - Industry sub-sector

### AE Identity Fields
- **Primary**: `emp_id__c` (String) - Employee ID
- **Email**: `emp_email_addr__c` (String) - AE email
- **Name**: `full_name__c` (String) - AE full name
- **Profile**: `learner_profile_id__c` (String) - Learner profile ID

### Sample Data Structure
```apex
Agent_Open_Pipe__c {
    emp_id__c: "12345",
    full_name__c: "John Doe",
    emp_email_addr__c: "john.doe@salesforce.com",
    ou_name__c: "UKI",
    work_location_country__c: "United Kingdom",
    open_pipe_prod_nm__c: "Agentforce",
    open_pipe_opty_nm__c: "Agentforce Deal",
    open_pipe_opty_stg_nm__c: "Prospecting",
    open_pipe_ae_score__c: 3.5,
    learner_profile_id__c: "LP12345"
}
```

## 4) Required SOQL Strategy

### Option A: Conditional Aggregation (Preferred)
```sql
SELECT emp_email_addr__c, full_name__c, learner_profile_id__c,
       COUNT(Id) totalOpps,
       SUM(CASE WHEN open_pipe_prod_nm__c = 'Agentforce' THEN 1 ELSE 0 END) hasAgentforce
FROM Agent_Open_Pipe__c
WHERE ou_name__c = 'UKI' AND IsDeleted = false
GROUP BY emp_email_addr__c, full_name__c, learner_profile_id__c
HAVING COUNT(Id) > 0 AND SUM(CASE WHEN open_pipe_prod_nm__c = 'Agentforce' THEN 1 ELSE 0 END) = 0
```

### Option B: Anti-join Pattern
```sql
-- Step 1: Get all AEs with open pipe
Set<Id> aeWithOpen = new Map<Id,AggregateResult>([
  SELECT emp_id__c u, COUNT(Id) c
  FROM Agent_Open_Pipe__c
  WHERE ou_name__c = 'UKI' AND IsDeleted = false
  GROUP BY emp_id__c
]).keySet();

-- Step 2: Get AEs with target product
Set<Id> aeWithTarget = new Map<Id,AggregateResult>([
  SELECT emp_id__c u
  FROM Agent_Open_Pipe__c
  WHERE ou_name__c = 'UKI' AND IsDeleted = false 
  AND open_pipe_prod_nm__c = 'Agentforce'
  GROUP BY emp_id__c
]).keySet();

-- Step 3: AEs without target product
aeWithOpen.removeAll(aeWithTarget);
```

## 5) Implementation Plan

### Phase 1: Core Negative Filter Method
1. Implement `handleNegativeFilters()` method
2. Add product exclusion parsing
3. Implement conditional aggregation SOQL
4. Add validation and error handling

### Phase 2: MCP Integration
1. Update MCP router to detect negative intent
2. Add NL parsing for "without", "don't have", "excluding"
3. Map utterances to negative filter parameters

### Phase 3: Testing & UAT
1. Create comprehensive test data
2. Test all negative filter scenarios
3. Validate performance and governor limits
4. Create UAT scripts for 100+ utterances

## 6) Expected Output Format

### Negative Query Response
```json
{
  "analysisType": "NEGATIVE_FILTER_ANALYSIS",
  "ouName": "UKI",
  "excludedProducts": ["Agentforce"],
  "totalAEsAnalyzed": 150,
  "aesWithoutProducts": [
    {
      "aeEmail": "john.doe@salesforce.com",
      "aeName": "John Doe",
      "learnerProfileId": "LP12345",
      "totalOpenOpps": 5,
      "topProductInPipeline": "Sales Cloud",
      "ouName": "UKI",
      "country": "United Kingdom"
    }
  ]
}
```

## 7) Performance Considerations

### Governor Limits
- **Query Rows**: Max 50,000 per query
- **Heap Size**: Use aggregate queries to minimize memory
- **CPU Time**: Anti-join patterns may be CPU intensive
- **SOQL Queries**: Limit to 2-3 queries per request

### Optimization Strategies
1. **Aggregate First**: Use GROUP BY to reduce data volume
2. **Filter Early**: Apply OU/country filters before grouping
3. **Limit Results**: Use LIMIT clause for large datasets
4. **Batch Processing**: Consider batch processing for very large OUs

## 8) Test Scenarios

### Basic Negative Filters
1. "AEs who don't have Agentforce in open pipe in UKI"
2. "Open pipe excluding Data Cloud in AMER ACC"
3. "UKI AEs without Slack opportunities"

### Complex Negative Filters
1. "AEs without Agentforce or Data Cloud in EMEA"
2. "LATAM AEs excluding multiple products"
3. "SMB AEs without any cloud products"

### Edge Cases
1. Empty exclusion list
2. Non-existent products
3. AEs with no open pipe
4. Invalid OU names
5. Governor limit scenarios

## 9) Success Criteria

### Functional Requirements
- ✅ Support "without", "don't have", "excluding" language
- ✅ Handle single and multiple product exclusions
- ✅ Work across all OUs and countries
- ✅ Maintain backward compatibility
- ✅ Provide accurate AE counts

### Performance Requirements
- ✅ Response time < 5 seconds
- ✅ Handle up to 10,000 AEs per OU
- ✅ Stay within governor limits
- ✅ Memory usage < 6MB per request

### Quality Requirements
- ✅ 95%+ test coverage
- ✅ 100+ UAT scenarios
- ✅ Zero breaking changes
- ✅ Comprehensive error handling