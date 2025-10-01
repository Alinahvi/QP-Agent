# ANAGENT KPI Analysis V5 - Documentation

## Overview

The ANAGENT KPI Analysis V5 system processes Account Executive (AE) performance metrics and ramp status data across territories, operating units, and industries.

**System Capabilities:**
• Ramp Status Analysis for AE onboarding progress tracking
• Multi-dimensional data grouping (country, OU, industry, AE, growth factors)
• Data quality validation with outlier detection
• Field mapping system (50+ field variations)
• 25+ KPI metrics across current and previous quarters

---

## Architecture

**Handler-Service Pattern:**
```
AI Agent Request
       ↓
ANAGENTKPIAnalysisHandlerV5
• Request validation
• Parameter normalization
• Smart logic for Growth Factor detection
• Error handling & response formatting
       ↓
ANAGENTKPIAnalysisServiceV5
• Business logic execution
• SOQL query building
• Data quality validation
• KPI calculations & aggregation
• Response message formatting
       ↓
AGENT_OU_PIPELINE_V2__c
• Main data object (153 fields)
• AE performance metrics
• Pipeline and opportunity data
• Growth factors and ramp status
```

---

## ANAGENTKPIAnalysisServiceV5.cls

### Purpose
Core business logic engine for KPI analysis operations, with specialized functionality for **Ramp Status Analysis**.

### Supported Analysis Types
• **Ramp Status Analysis**: Performance analysis by onboarding status
• **New Hire Performance**: Onboarding progress and tenure analysis
• **Territory Performance**: Geographic and regional performance comparison
• **Growth Factor Analysis**: Development area identification and ranking

### Key Methods

**1. analyzeKPIs() - Main Entry Point**
```apex
public static String analyzeKPIs(
    String metricKey,           // KPI metric (CALLS, MEETINGS, ACV, etc.)
    String timeframe,           // CURRENT or PREVIOUS
    String groupBy,             // COUNTRY, OU, INDUSTRY, AE, etc.
    String filterCriteria,      // SOQL WHERE clause
    String restrictInValuesCsv, // Comma-separated restriction values
    Boolean perAENormalize,     // Average per AE vs total sum
    Integer limitN,             // Maximum results to return
    String aggregationType      // SUM, AVG, MAX, MIN, COUNT, MEDIAN
)
```

**Business Logic Flow:**
1. Validates and auto-corrects metric/timeframe mismatches
2. Gets total count for accurate reporting
3. Builds and executes SOQL query
4. Applies data quality validation and outlier filtering
5. Processes results and builds comprehensive analysis message

**2. parseFilterCriteria() - Smart Field Mapping**
Converts user-friendly filter criteria to proper SOQL syntax:

**Examples:**
• `"ramp_status='Slow'"` → `"ramp_status__c='Slow'"`
• `"country IN ('Brazil','Argentina')"` → `"work_location_country__c IN ('Brazil','Argentina')"`
• `"ou LIKE '%AMER%'"` → `"ou_name__c LIKE '%AMER%'"`

**Field Detection System:**
• Maps 50+ field variations automatically
• Handles API field names (RAMP_STATUS__C → ramp_status)
• Supports business context patterns (geographic, industry, employee, etc.)

**3. Data Quality Validation**
Built-in data quality assessment with configurable thresholds:

```apex
'CALLS' => new Map<String, Decimal>{
    'MIN_REASONABLE' => 0.0,
    'MAX_REASONABLE' => 10000.0,     // 10K calls max per quarter
    'DEFAULT_VALUE' => 0.0
}
```

### Supported Metrics (25+)
**Performance Metrics:** ACV, PG, CALLS, MEETINGS, COVERAGE, QUOTA
**Time-based Metrics:** CQ_* (Current Quarter), PQ_* (Previous Quarter)
**Specialized Metrics:** CC_ACV, DAYS_ACV, DAYS_PG, AOV
**Growth Factors:** GROWTH_FACTOR, GF (text-based analysis)

---

## ANAGENTKPIAnalysisHandlerV5.cls

### Purpose
Entry point and validation layer for AI agent integration. Implements the **InvocableMethod** pattern for Salesforce Flow and AI agents.

### Key Responsibilities
• **Request Validation**: Validates all input parameters
• **Parameter Correction**: Auto-corrects common parameter mismatches
• **Growth Factor Detection**: Detection of growth factor analysis requests
• **Error Handling**: Comprehensive error handling and response formatting
• **Service Delegation**: Routes validated requests to the Service layer

### Request/Response Structure

**Request Class:**
```apex
public class Request {
    @InvocableVariable public String metricKey;        // KPI metric to analyze
    @InvocableVariable public String timeframe;        // CURRENT or PREVIOUS
    @InvocableVariable public String groupBy;          // Grouping dimension
    @InvocableVariable public String filterCriteria;   // SOQL WHERE clause
    @InvocableVariable public String restrictInValuesCsv; // Restriction values
    @InvocableVariable public Boolean perAENormalize;  // Per-AE normalization
    @InvocableVariable public Integer limitN;          // Result limit
    @InvocableVariable public String aggregationType;  // Aggregation method
}
```

**Response Class:**
```apex
public class Response {
    @InvocableVariable public String message;  // Complete analysis message
}
```

### Logic Features

**1. Growth Factor Detection**
```apex
// Detect growth factor intent
if (groupBy == 'GROWTH_FACTOR' && (metricKey == 'CALLS' || String.isBlank(req.metricKey))) {
    metricKey = 'GROWTH_FACTOR';
}

// Handle "top X growth factors" requests
if (req.limitN != null && req.limitN > 0 && groupBy == 'AE' && 
    (metricKey == 'PG' || metricKey == 'ACV' || metricKey == 'CALLS')) {
    metricKey = 'GROWTH_FACTOR';
    groupBy = 'GROWTH_FACTOR';
}
```

**2. Parameter Validation**
• **Valid Metrics**: 25+ supported metric keys
• **Valid Timeframes**: CURRENT, PREVIOUS
• **Valid Group By**: COUNTRY, OU, INDUSTRY, AE, GROWTH_FACTOR, RAMP_STATUS, etc.
• **Valid Aggregation Types**: SUM, AVG, MAX, MIN, COUNT, MEDIAN

---

## Data Model & Objects

### AGENT_OU_PIPELINE_V2__c Object
Main data object containing 153 fields for comprehensive AE performance analysis.

**Core Employee Fields:**
• **emp_id__c**: Unique employee identifier
• **full_name__c**: Employee's full display name
• **emp_email_addr__c**: Corporate email address
• **work_location_country__c**: Country of primary work location
• **ou_name__c**: Operating Unit (AMER ACC, AMER ICE, LATAM, EMEA, APAC)
• **emp_mgr_nm__c**: Direct manager's name
• **primary_industry__c**: Top-level industry classification
• **learner_profile_id__c**: SEED/Enablement Learner Profile ID

**Performance Metrics (Current Quarter):**
• **cq_customer_meeting__c**: Customer meeting count
• **cq_pg__c**: Pipeline Generation (currency)
• **cq_acv__c**: Annual Contract Value (currency)
• **cq_call_connect__c**: Call connection count
• **cq_cc_acv__c**: Create and Close ACV
• **call_ai_mention__c**: AI mention count
• **coverage__c**: Territory coverage percentage

**Performance Metrics (Previous Quarter):**
• **pq_customer_meeting__c**: Previous quarter customer meetings
• **pq_pg__c**: Previous quarter pipeline generation
• **pq_acv__c**: Previous quarter ACV
• **pq_call_connect__c**: Previous quarter call connections

**Growth & Development Fields:**
• **definition__c**: Growth Factors from performance predictor
• **description__c**: Description of each Growth Factor
• **ramp_status__c**: Ramp status (Slow, Medium, Fast, Expert)
• **time_since_onboarding__c**: Months since onboarding
• **days_to_productivity__c**: Days to reach productivity

**Pipeline Stage Fields (1-5):**
• **open_pipe_opty_nm_1__c** through **open_pipe_opty_nm_5__c**: Opportunity names
• **open_pipe_opty_stg_nm_1__c** through **open_pipe_opty_stg_nm_5__c**: Stage names
• **open_pipe_revised_sub_sector_1__c** through **open_pipe_revised_sub_sector_5__c**: Sub-sectors

---

## Field Mappings & Business Logic

### Geographic & Organizational Mapping
**Operating Units:**
• AMER ACC → Americas Account
• AMER ICE → Americas ICE
• LATAM → Latin America
• EMEA → Europe, Middle East, Africa
• APAC → Asia Pacific

**Countries (LATAM Examples):**
• Brazil, Argentina, Chile, Mexico, Colombia, Peru, Venezuela

**Industries:**
• Engineering, Construction, & Real Estate
• Financial Services
• Healthcare & Life Sciences
• Manufacturing
• Technology

### Ramp Status Categories
• **Slow**: AEs requiring additional support and development
• **Medium**: AEs progressing normally through onboarding
• **Fast**: High-performing AEs exceeding expectations
• **Expert**: Fully ramped AEs with mastery-level performance

### Metric Field Mapping
```apex
'ACV' => new Map<String, String>{
    'CURRENT' => 'cq_acv__c',
    'PREVIOUS' => 'pq_acv__c'
},
'CALLS' => new Map<String, String>{
    'CURRENT' => 'cq_call_connect__c',
    'PREVIOUS' => 'pq_call_connect__c'
},
'MEETINGS' => new Map<String, String>{
    'CURRENT' => 'cq_customer_meeting__c',
    'PREVIOUS' => 'pq_customer_meeting__c'
}
```

---

## Class Relationships

### Handler → Service Relationship
```
ANAGENTKPIAnalysisHandlerV5
    │
    │ 1. Validates request parameters
    │ 2. Applies smart logic corrections
    │ 3. Handles errors gracefully
    │
    ▼
ANAGENTKPIAnalysisServiceV5.analyzeKPIs()
    │
    │ 1. Builds SOQL queries
    │ 2. Executes data operations
    │ 3. Performs KPI calculations
    │ 4. Formats response message
    │
    ▼
AGENT_OU_PIPELINE_V2__c records
```

### Data Flow
1. **AI Agent** sends request to Handler
2. **Handler** validates and normalizes parameters
3. **Handler** calls Service with validated parameters
4. **Service** queries AGENT_OU_PIPELINE_V2__c records
5. **Service** processes data and builds analysis message
6. **Handler** returns formatted response to AI Agent

### Dependencies
• **Handler** depends on **Service** for business logic
• **Service** depends on **AGENT_OU_PIPELINE_V2__c** object
• Both classes use Salesforce's **Security.stripInaccessible()** for data security

---

## Business Use Cases

### 1. Ramp Status Analysis
**Use Case:** Analysis of slow rampers in LATAM region

**Handler Processing:**
• Validates metricKey = "CALLS"
• Validates timeframe = "CURRENT"
• Validates groupBy = "AE"
• Validates filterCriteria = "ramp_status='Slow' AND country IN ('Brazil','Argentina','Chile','Mexico','Colombia')"

**Service Processing:**
• Parses filter criteria to SOQL
• Queries AGENT_OU_PIPELINE_V2__c records
• Groups by individual AEs
• Calculates average calls per AE
• Builds analysis message

**Output:** Analysis showing slow rampers with call performance metrics, geographic breakdown, and performance data.

### 2. Growth Factor Analysis
**Use Case:** Top 5 growth factors in AMER region

**Handler Processing:**
• Detects growth factor intent
• Sets metricKey = "GROWTH_FACTOR"
• Sets groupBy = "GROWTH_FACTOR"
• Sets limitN = 5
• Validates filterCriteria = "ou LIKE '%AMER%'"

**Service Processing:**
• Queries records with definition__c not null
• Groups by growth factor definition
• Counts frequency of each growth factor
• Sorts by count (descending)
• Returns top 5 with descriptions

**Output:** Ranked list of most common growth factors with descriptions and occurrence counts.

### 3. Territory Performance Comparison
**Use Case:** Call performance comparison across regions

**Handler Processing:**
• Validates metricKey = "CALLS"
• Validates timeframe = "CURRENT"
• Validates groupBy = "COUNTRY"
• Sets perAENormalize = true

**Service Processing:**
• Queries all records with call data
• Groups by country
• Calculates average calls per AE by country
• Applies data quality filtering
• Builds comparative analysis

**Output:** Country-by-country performance comparison with performance data and metrics.

---

## API Reference

### InvocableMethod: analyzeKPIs
```apex
@InvocableMethod(
    label='ANAGENT KPI Analysis V5'
    description='Analyzes KPIs from AGENT_OU_PIPELINE_V2__c records based on specified metrics, timeframes, and grouping criteria.'
)
public static List<Response> analyzeKPIs(List<Request> requests)
```

### Request Parameters
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| metricKey | String | No | KPI metric to analyze | "CALLS", "ACV", "GROWTH_FACTOR" |
| timeframe | String | No | Time period | "CURRENT", "PREVIOUS" |
| groupBy | String | No | Grouping dimension | "COUNTRY", "AE", "GROWTH_FACTOR" |
| filterCriteria | String | No | SOQL WHERE clause | "ramp_status='Slow'" |
| restrictInValuesCsv | String | No | Restriction values | "US,Brazil" |
| perAENormalize | Boolean | No | Per-AE normalization | true, false |
| limitN | Integer | No | Result limit | 5, 10, 25 |
| aggregationType | String | No | Aggregation method | "SUM", "AVG", "COUNT" |

### Response Format
```json
{
  "message": "# KPI Analysis\n\n## Summary\n- **Metric**: CALLS\n- **Timeframe**: CURRENT\n..."
}
```

### Supported Metrics
• **ACV**: Annual Contract Value
• **PG**: Pipeline Generation
• **CALLS**: Call Connections
• **MEETINGS**: Customer Meetings
• **COVERAGE**: Territory Coverage
• **QUOTA**: Quota Attainment
• **GROWTH_FACTOR**: Growth Factor Analysis
• **CC_ACV**: Create and Close ACV
• **DAYS_ACV**: Days to ACV
• **AOV**: Average Order Value
• And 15+ more specialized metrics

---

## Error Handling & Data Quality

### Data Quality Validation
The system includes comprehensive data quality assessment with configurable thresholds for each metric.

### Outlier Detection
• Automatically identifies extreme values outside reasonable ranges
• Filters outliers from analysis while reporting their presence
• Provides data quality warnings in response messages

### Error Handling Strategy
1. **Input Validation**: Comprehensive parameter validation
2. **Query Safety**: SOQL injection prevention
3. **Data Security**: Uses Security.stripInaccessible()
4. **Graceful Degradation**: Continues processing with available data
5. **User-Friendly Messages**: Clear error messages for troubleshooting

### Data Quality Reporting Example
```
## Data Quality Assessment
⚠️ **Data Quality Warning**: 3 records (2.1%) have extreme values outside reasonable range (0 to 10000).
Examples: John Smith: 15000, Jane Doe: 12000.

**Quality Details:**
• **Outlier Records**: 3 (2.1%)
• **Null Records**: 5 (3.5%)
• **Valid Records**: 137
• **Value Range**: 0 to 15000
```

---

## Performance Considerations

### Query Optimization
• **Selective Field Queries**: Only queries required fields
• **Efficient Filtering**: Applies filters at database level
• **Indexed Fields**: Uses indexed fields for grouping and filtering
• **Limit Application**: Applies limits after total count calculation

### Memory Management
• **Batch Processing**: Processes records in manageable batches
• **Data Quality Filtering**: Removes outliers before processing
• **Efficient Grouping**: Uses Map-based grouping for performance

### Scalability Features
• **Configurable Limits**: Supports result limiting for large datasets
• **Data Quality Thresholds**: Configurable quality thresholds
• **Smart Field Detection**: Efficient field mapping system
• **Caching Opportunities**: Field mappings are static and cacheable

### Security Considerations
• **Field-Level Security**: Respects Salesforce field-level security
• **Data Stripping**: Uses Security.stripInaccessible()
• **Input Sanitization**: Prevents SOQL injection
• **Access Control**: Follows Salesforce sharing rules

---

## Summary

The ANAGENT KPI Analysis V5 system provides a scalable solution for processing AE performance metrics and ramp status data. The Handler-Service pattern ensures separation of concerns, while the field mapping and data quality systems provide analysis results.

**System Applications:**
• Sales management and coaching
• Territory performance analysis
• Growth factor identification
• Onboarding progress tracking
• Regional performance comparison

**Technical Capabilities:**
• 25+ supported metrics
• Data quality validation
• Parameter correction
• Field mapping system
• Performance data processing foundation
