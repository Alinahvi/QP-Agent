# ANAGENT KPI Analysis V5 - Comprehensive Documentation

## Table of Contents
1. [Overview](#overview)
2. [Architecture & Design Pattern](#architecture--design-pattern)
3. [ANAGENTKPIAnalysisServiceV5.cls](#anagentkpianalysisservicev5cls)
4. [ANAGENTKPIAnalysisHandlerV5.cls](#anagentkpianalysishandlerv5cls)
5. [Data Model & Objects](#data-model--objects)
6. [Field Mappings & Business Logic](#field-mappings--business-logic)
7. [Class Relationships](#class-relationships)
8. [Business Use Cases](#business-use-cases)
9. [API Reference](#api-reference)
10. [Error Handling & Data Quality](#error-handling--data-quality)
11. [Performance Considerations](#performance-considerations)

---

## Overview

The ANAGENT KPI Analysis V5 system is a comprehensive Salesforce solution designed for analyzing Account Executive (AE) performance metrics and ramp status across different territories, operating units, and industries. This system follows a **Handler-Service pattern** where the Handler validates requests and the Service performs the actual business logic and data operations.

### Key Features
- **Ramp Status Analysis**: Specialized for analyzing AE performance by onboarding status
- **Multi-dimensional Grouping**: Group by country, operating unit, industry, AE, or growth factors
- **Data Quality Validation**: Built-in outlier detection and data quality assessment
- **Smart Field Mapping**: Automatic conversion of user-friendly field names to SOQL
- **Comprehensive Metrics**: Support for 25+ KPI metrics across current and previous quarters

---

## Architecture & Design Pattern

### Handler-Service Pattern
```
┌─────────────────────────────────────────────────────────────────┐
│                    AI Agent Request                            │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│              ANAGENTKPIAnalysisHandlerV5                       │
│  • Request validation                                          │
│  • Parameter normalization                                     │
│  • Smart logic for Growth Factor detection                    │
│  • Error handling & response formatting                       │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│              ANAGENTKPIAnalysisServiceV5                       │
│  • Business logic execution                                    │
│  • SOQL query building                                         │
│  • Data quality validation                                     │
│  • KPI calculations & aggregation                              │
│  • Response message formatting                                 │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                AGENT_OU_PIPELINE_V2__c                         │
│  • Main data object (153 fields)                              │
│  • AE performance metrics                                      │
│  • Pipeline and opportunity data                               │
│  • Growth factors and ramp status                              │
└─────────────────────────────────────────────────────────────────┘
```

---

## ANAGENTKPIAnalysisServiceV5.cls

### Purpose & Business Intent
The Service class is the **core business logic engine** for KPI analysis operations. It's specifically designed for **Ramp Status Analysis** - analyzing AE performance by onboarding progress, territory performance, and growth factors.

### Primary Use Cases
1. **Ramp Status Analysis**: "slow rampers in LATAM", "fast rampers in AMER"
2. **New Hire Performance**: "new hire performance analysis", "onboarding progress"
3. **Territory Performance**: "AE performance by country", "regional comparison"
4. **Growth Factor Analysis**: "top growth factors", "development areas"

### Key Methods

#### 1. `analyzeKPIs()` - Main Entry Point
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

#### 2. `parseFilterCriteria()` - Smart Field Mapping
Converts user-friendly filter criteria to proper SOQL syntax:

**Examples:**
- `"ramp_status='Slow'"` → `"ramp_status__c='Slow'"`
- `"country IN ('Brazil','Argentina')"` → `"work_location_country__c IN ('Brazil','Argentina')"`
- `"ou LIKE '%AMER%'"` → `"ou_name__c LIKE '%AMER%'"`

**Smart Field Detection:**
- Automatically maps 50+ field variations
- Handles API field names (RAMP_STATUS__C → ramp_status)
- Supports business context patterns (geographic, industry, employee, etc.)

#### 3. Data Quality Validation
Built-in data quality assessment with configurable thresholds:

```apex
private static final Map<String, Map<String, Decimal>> METRIC_QUALITY_THRESHOLDS = new Map<String, Map<String, Decimal>>{
    'COVERAGE' => new Map<String, Decimal>{
        'MIN_REASONABLE' => -100.0,
        'MAX_REASONABLE' => 1000.0,
        'DEFAULT_VALUE' => 0.0
    },
    'ACV' => new Map<String, Decimal>{
        'MIN_REASONABLE' => -1000000.0,  // Allow negative ACV for returns
        'MAX_REASONABLE' => 100000000.0, // 100M max reasonable ACV
        'DEFAULT_VALUE' => 0.0
    }
    // ... more metrics
};
```

### Supported Metrics (25+)
- **Performance Metrics**: ACV, PG, CALLS, MEETINGS, COVERAGE, QUOTA
- **Time-based Metrics**: CQ_* (Current Quarter), PQ_* (Previous Quarter)
- **Specialized Metrics**: CC_ACV, DAYS_ACV, DAYS_PG, AOV
- **Growth Factors**: GROWTH_FACTOR, GF (text-based analysis)

### Field Mapping System
The service uses three comprehensive mapping systems:

1. **Metric Field Mapping**: Maps metric keys to actual database fields
2. **Group Field Mapping**: Maps grouping dimensions to database fields  
3. **Filter Field Mapping**: Maps user-friendly names to database fields

---

## ANAGENTKPIAnalysisHandlerV5.cls

### Purpose & Business Intent
The Handler class serves as the **entry point and validation layer** for the AI agent. It implements the **InvocableMethod** pattern, making it accessible to Salesforce Flow and AI agents.

### Key Responsibilities
1. **Request Validation**: Validates all input parameters
2. **Smart Parameter Correction**: Auto-corrects common parameter mismatches
3. **Growth Factor Detection**: Intelligent detection of growth factor analysis requests
4. **Error Handling**: Comprehensive error handling and user-friendly messages
5. **Service Delegation**: Routes validated requests to the Service layer

### Request/Response Structure

#### Request Class
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

#### Response Class
```apex
public class Response {
    @InvocableVariable public String message;  // Complete analysis message
}
```

### Smart Logic Features

#### 1. Growth Factor Detection
The handler includes sophisticated logic to detect when users want growth factor analysis:

```apex
// Auto-detect growth factor intent
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

#### 2. Parameter Validation
Comprehensive validation for all input parameters:

- **Valid Metrics**: 25+ supported metric keys
- **Valid Timeframes**: CURRENT, PREVIOUS
- **Valid Group By**: COUNTRY, OU, INDUSTRY, AE, GROWTH_FACTOR, RAMP_STATUS, etc.
- **Valid Aggregation Types**: SUM, AVG, MAX, MIN, COUNT, MEDIAN

---

## Data Model & Objects

### AGENT_OU_PIPELINE_V2__c Object
The main data object containing 153 fields for comprehensive AE performance analysis.

#### Core Employee Fields
- **emp_id__c**: Unique employee identifier
- **full_name__c**: Employee's full display name
- **emp_email_addr__c**: Corporate email address
- **work_location_country__c**: Country of primary work location
- **ou_name__c**: Operating Unit (AMER ACC, AMER ICE, LATAM, EMEA, APAC)
- **emp_mgr_nm__c**: Direct manager's name
- **primary_industry__c**: Top-level industry classification
- **learner_profile_id__c**: SEED/Enablement Learner Profile ID

#### Performance Metrics (Current Quarter)
- **cq_customer_meeting__c**: Customer meeting count
- **cq_pg__c**: Pipeline Generation (currency)
- **cq_acv__c**: Annual Contract Value (currency)
- **cq_call_connect__c**: Call connection count
- **cq_cc_acv__c**: Create and Close ACV
- **call_ai_mention__c**: AI mention count
- **coverage__c**: Territory coverage percentage

#### Performance Metrics (Previous Quarter)
- **pq_customer_meeting__c**: Previous quarter customer meetings
- **pq_pg__c**: Previous quarter pipeline generation
- **pq_acv__c**: Previous quarter ACV
- **pq_call_connect__c**: Previous quarter call connections

#### Growth & Development Fields
- **definition__c**: Growth Factors from performance predictor
- **description__c**: Description of each Growth Factor
- **ramp_status__c**: Ramp status (Slow, Medium, Fast, Expert)
- **time_since_onboarding__c**: Months since onboarding
- **days_to_productivity__c**: Days to reach productivity

#### Pipeline Stage Fields (1-5)
- **open_pipe_opty_nm_1__c** through **open_pipe_opty_nm_5__c**: Opportunity names
- **open_pipe_opty_stg_nm_1__c** through **open_pipe_opty_stg_nm_5__c**: Stage names
- **open_pipe_revised_sub_sector_1__c** through **open_pipe_revised_sub_sector_5__c**: Sub-sectors

---

## Field Mappings & Business Logic

### Geographic & Organizational Mapping
```apex
// Operating Units
'AMER ACC' → Americas Account
'AMER ICE' → Americas ICE
'LATAM' → Latin America
'EMEA' → Europe, Middle East, Africa
'APAC' → Asia Pacific

// Countries (LATAM Examples)
'Brazil', 'Argentina', 'Chile', 'Mexico', 'Colombia', 'Peru', 'Venezuela'

// Industries
'Engineering, Construction, & Real Estate'
'Financial Services'
'Healthcare & Life Sciences'
'Manufacturing'
'Technology'
```

### Ramp Status Categories
- **Slow**: AEs requiring additional support and development
- **Medium**: AEs progressing normally through onboarding
- **Fast**: High-performing AEs exceeding expectations
- **Expert**: Fully ramped AEs with mastery-level performance

### Metric Field Mapping
```apex
private static final Map<String, Map<String, String>> METRIC_FIELD_MAP = new Map<String, Map<String, String>>{
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
    // ... 20+ more metrics
};
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
- **Handler** depends on **Service** for business logic
- **Service** depends on **AGENT_OU_PIPELINE_V2__c** object
- Both classes use Salesforce's **Security.stripInaccessible()** for data security

---

## Business Use Cases

### 1. Ramp Status Analysis
**Use Case**: "Show me slow rampers in LATAM"

**Handler Processing**:
- Validates metricKey = "CALLS"
- Validates timeframe = "CURRENT"
- Validates groupBy = "AE"
- Validates filterCriteria = "ramp_status='Slow' AND country IN ('Brazil','Argentina','Chile','Mexico','Colombia')"

**Service Processing**:
- Parses filter criteria to SOQL
- Queries AGENT_OU_PIPELINE_V2__c records
- Groups by individual AEs
- Calculates average calls per AE
- Builds comprehensive analysis message

**Output**: Detailed analysis showing slow rampers with call performance metrics, geographic breakdown, and improvement recommendations.

### 2. Growth Factor Analysis
**Use Case**: "What are the top 5 growth factors in AMER?"

**Handler Processing**:
- Detects growth factor intent
- Sets metricKey = "GROWTH_FACTOR"
- Sets groupBy = "GROWTH_FACTOR"
- Sets limitN = 5
- Validates filterCriteria = "ou LIKE '%AMER%'"

**Service Processing**:
- Queries records with definition__c not null
- Groups by growth factor definition
- Counts frequency of each growth factor
- Sorts by count (descending)
- Returns top 5 with descriptions

**Output**: Ranked list of most common growth factors with descriptions and occurrence counts.

### 3. Territory Performance Comparison
**Use Case**: "Compare call performance across regions"

**Handler Processing**:
- Validates metricKey = "CALLS"
- Validates timeframe = "CURRENT"
- Validates groupBy = "COUNTRY"
- Sets perAENormalize = true

**Service Processing**:
- Queries all records with call data
- Groups by country
- Calculates average calls per AE by country
- Applies data quality filtering
- Builds comparative analysis

**Output**: Country-by-country performance comparison with insights and recommendations.

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
- **ACV**: Annual Contract Value
- **PG**: Pipeline Generation
- **CALLS**: Call Connections
- **MEETINGS**: Customer Meetings
- **COVERAGE**: Territory Coverage
- **QUOTA**: Quota Attainment
- **GROWTH_FACTOR**: Growth Factor Analysis
- **CC_ACV**: Create and Close ACV
- **DAYS_ACV**: Days to ACV
- **AOV**: Average Order Value
- And 15+ more specialized metrics

---

## Error Handling & Data Quality

### Data Quality Validation
The system includes comprehensive data quality assessment:

```apex
// Quality thresholds for each metric
'CALLS' => new Map<String, Decimal>{
    'MIN_REASONABLE' => 0.0,
    'MAX_REASONABLE' => 10000.0,     // 10K calls max per quarter
    'DEFAULT_VALUE' => 0.0
}
```

### Outlier Detection
- Automatically identifies extreme values outside reasonable ranges
- Filters outliers from analysis while reporting their presence
- Provides data quality warnings in response messages

### Error Handling Strategy
1. **Input Validation**: Comprehensive parameter validation
2. **Query Safety**: SOQL injection prevention
3. **Data Security**: Uses Security.stripInaccessible()
4. **Graceful Degradation**: Continues processing with available data
5. **User-Friendly Messages**: Clear error messages for troubleshooting

### Data Quality Reporting
```
## Data Quality Assessment
⚠️ **Data Quality Warning**: 3 records (2.1%) have extreme values outside reasonable range (0 to 10000).
Examples: John Smith: 15000, Jane Doe: 12000.

**Quality Details:**
- **Outlier Records**: 3 (2.1%)
- **Null Records**: 5 (3.5%)
- **Valid Records**: 137
- **Value Range**: 0 to 15000
```

---

## Performance Considerations

### Query Optimization
- **Selective Field Queries**: Only queries required fields
- **Efficient Filtering**: Applies filters at database level
- **Indexed Fields**: Uses indexed fields for grouping and filtering
- **Limit Application**: Applies limits after total count calculation

### Memory Management
- **Batch Processing**: Processes records in manageable batches
- **Data Quality Filtering**: Removes outliers before processing
- **Efficient Grouping**: Uses Map-based grouping for performance

### Scalability Features
- **Configurable Limits**: Supports result limiting for large datasets
- **Data Quality Thresholds**: Configurable quality thresholds
- **Smart Field Detection**: Efficient field mapping system
- **Caching Opportunities**: Field mappings are static and cacheable

### Security Considerations
- **Field-Level Security**: Respects Salesforce field-level security
- **Data Stripping**: Uses Security.stripInaccessible()
- **Input Sanitization**: Prevents SOQL injection
- **Access Control**: Follows Salesforce sharing rules

---

## Conclusion

The ANAGENT KPI Analysis V5 system provides a robust, scalable solution for analyzing AE performance metrics and ramp status. The Handler-Service pattern ensures clean separation of concerns, while the comprehensive field mapping and data quality systems provide reliable, accurate analysis results.

The system is specifically optimized for **Ramp Status Analysis** use cases, making it ideal for:
- Sales management and coaching
- Territory performance analysis
- Growth factor identification
- Onboarding progress tracking
- Regional performance comparison

With 25+ supported metrics, comprehensive data quality validation, and intelligent parameter correction, this system provides the foundation for data-driven sales performance management.
