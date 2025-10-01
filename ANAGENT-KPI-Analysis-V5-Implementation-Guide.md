# ANAGENT KPI Analysis V5 - Implementation Guide

## Overview

This document describes the implementation of an agent-safe KPI Analysis system for AGENT_OU_PIPELINE_V2__c records. The system follows FR-style best practices with a clean separation between handler (router) and service (business logic) layers.

## Architecture

### Handler Layer (`ANAGENTKPIAnalysisHandlerV5`)
- **Purpose**: Dumb router that validates inputs and delegates to service
- **Responsibility**: Input validation, parameter mapping, error handling
- **Agent Interface**: Single `@InvocableMethod` returning `List<Response>` where `Response` contains only `message:String`

### Service Layer (`ANAGENTKPIAnalysisServiceV5`)
- **Purpose**: All business logic, querying, and message composition
- **Responsibility**: SOQL building, data processing, KPI calculations, message formatting
- **Output**: Single composed message string with Markdown structure + compact JSON

## Field Constraints

### Allowed Fields (Hard Rule - No Exceptions)
**Roster Fields:**
- `emp_id__c` (Text): Unique employee ID
- `full_name__c` (Text): AE full name
- `ou_name__c` (Text): Org unit name
- `primary_industry__c` (Text): Primary industry
- `work_location_country__c` (Text): Country (ISO or label)

**KPI Fields:**
- `cq_acv__c`, `pq_acv__c` (Currency/Decimal): ACV booked
- `cq_pg__c`, `pq_pg__c` (Currency/Decimal): Pipeline generated
- `cq_customer_meeting__c`, `pq_customer_meeting__c` (Number): Customer meetings
- `cq_call_connect__c`, `pq_call_connect__c` (Number): Call connects
- `cq_cc_acv__c`, `pq_cc_acv__c` (Currency/Decimal): ACV from call connects
- `coverage__c` (Percent/Decimal 0-100): Coverage % (CURRENT only)
- `call_ai_mention__c` (Number): # calls with AI mention (CURRENT only)

## Supported Operations

### Metrics
- **ACV**: Annual Contract Value
- **PG**: Pipeline Generated
- **CALLS**: Call connections
- **MEETINGS**: Customer meetings
- **AI_MENTIONS**: AI mentions in calls (CURRENT only)
- **COVERAGE**: Coverage percentage (CURRENT only)

### Timeframes
- **CURRENT**: Current quarter data (all metrics available)
- **PREVIOUS**: Previous quarter data (AI_MENTIONS and COVERAGE not available)

### Grouping Options
- **COUNTRY**: Group by `work_location_country__c`
- **OU**: Group by `ou_name__c`
- **INDUSTRY**: Group by `primary_industry__c`
- **AE**: Group by `full_name__c`

### Filtering
- **Supported Keys**: `country`, `ou`, `industry`, `ae`
- **Examples**:
  - `country="US"`
  - `ou IN ("Amer ENT","LATAM") AND industry <> "Public Sector"`
  - `ae LIKE "Smi%"`

## Implementation Details

### Security Implementation
```apex
// Apply security stripping before field access
records = Security.stripInaccessible(AccessType.READABLE, records).getRecords();
```

### Field Mapping Constants
```apex
private static final Map<String, Map<String, String>> METRIC_FIELD_MAP = new Map<String, Map<String, String>>{
    'ACV' => new Map<String, String>{
        'CURRENT' => 'cq_acv__c',
        'PREVIOUS' => 'pq_acv__c'
    },
    // ... other mappings
};
```

### Message Structure
The composed message follows this exact structure:

1. **# KPI Analysis** (Header)
2. **## Summary** (Parameters, filters, normalization)
3. **## Insights** (Top groups, percentages, comparisons)
4. **## Limits & Counts** (Total count, limits applied, notes)
5. **## Data (JSON)** (Compact JSON with key metrics)

## Usage Examples

### Example 1: Compare ACV between US and Brazil (CURRENT)
```
metricKey: "ACV"
timeframe: "CURRENT"
groupBy: "COUNTRY"
restrictInValuesCsv: "US,Brazil"
perAENormalize: true
```

### Example 2: Top 5 OU by PG for PREVIOUS quarter
```
metricKey: "PG"
timeframe: "PREVIOUS"
groupBy: "OU"
limitN: 5
```

### Example 3: Average MEETINGS by INDUSTRY in US Tech
```
metricKey: "MEETINGS"
groupBy: "INDUSTRY"
filterCriteria: "country='US' AND industry='Tech'"
perAENormalize: true
```

## Defaults

- **metricKey**: "CALLS"
- **timeframe**: "CURRENT"
- **groupBy**: "COUNTRY"
- **perAENormalize**: false
- **limitN**: 50

## Business Logic Notes

### Distinct AE Counting
- Count distinct `emp_id__c` per group
- Fallback to `full_name__c` if `emp_id__c` missing

### Percent of Total Calculation
- `pctOfTotal = groupSum / grandTotal * 100`

### Zero/Null Handling
- Treat null KPI values as 0 for summations and averages
- Call out unavailable metrics for PREVIOUS timeframe

### Ordering
- Default: Descending by aggregate value
- With `restrictInValuesCsv`: Show exact CSV order, then extras by value

## TODOs for Full Implementation

### Service Layer TODOs
1. **Query Execution**: Replace placeholder `executeQuery()` with actual SOQL execution
2. **Filter Parsing**: Implement `parseFilterCriteria()` for user-friendly filter conversion
3. **KPI Calculations**: Implement actual aggregation logic in `buildAnalysisMessage()`
4. **Group Processing**: Add logic for handling `restrictInValuesCsv` ordering
5. **Per-AE Normalization**: Implement `perAENormalize` logic

### Advanced Features
1. **Total Count Pre-Limit**: Query total count before applying limits
2. **Percentage Calculations**: Implement group percentage of total calculations
3. **Comparison Logic**: Handle same-dimension comparisons when `restrictInValuesCsv` is provided

## Deployment Notes

### Permission Sets
- Add both classes to the Permission Set used by the Agent Integration User
- Ensure READ access to AGENT_OU_PIPELINE_V2__c object

### Agent Builder Integration
After adding/removing the action:
1. Remove → Save → Close tab
2. Add back → Save → Reopen (forces schema refresh)

## Error Handling

### Validation Errors
- Invalid metric keys
- Invalid timeframes
- Invalid grouping options
- Unavailable metric/timeframe combinations

### Runtime Errors
- SOQL query failures
- Security access violations
- Data processing errors

### Graceful Degradation
- Return informative error messages
- Include available options in error responses
- Maintain consistent message structure even for errors

## Testing Scenarios

### Basic Functionality
1. Default parameters (CALLS, CURRENT, COUNTRY)
2. All metric types with CURRENT timeframe
3. PREVIOUS timeframe with available metrics
4. Various grouping options

### Filtering
1. Simple equality filters
2. IN clause filters
3. LIKE pattern matching
4. Complex AND/OR combinations

### Normalization
1. Per-AE normalization enabled
2. Per-AE normalization disabled
3. Mixed scenarios

### Limits and Pagination
1. Default limit (50)
2. Custom limits
3. Total count vs. displayed count

## Compliance Notes

### Field Access
- Only listed fields are referenced
- No hidden or inferred fields
- Security.stripInaccessible applied

### Agent Safety
- Single message variable exposed
- No complex data structures at boundary
- Flattened output for agent consumption

### Performance
- Efficient SOQL queries
- Proper indexing considerations
- Limit enforcement to prevent runaway queries 