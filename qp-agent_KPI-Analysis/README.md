# ANAGENT KPI Analysis V7

## Overview
Analyze Account Executive KPI performance (Growth Factors) across multiple time windows with memory-optimized aggregation strategy.

## Version
**V7.0** - Released 2025-11-04

## Components

### Handler Class
- **File**: `ANAgentKPIAnalysisHandlerV7.cls`
- **Label**: `ANAGENT KPI Analysis V7`
- **Type**: Invocable Method (Agent Action)
- **Purpose**: Entry point with flexible input handling

### Service Class  
- **File**: `ANAgentKPIAnalysisServiceV7.cls`
- **Type**: Business Logic Service
- **Purpose**: KPI analysis with two-tier query strategy

### Metadata Files
- `ANAgentKPIAnalysisHandlerV7.cls-meta.xml` (API Version: 64.0)
- `ANAgentKPIAnalysisServiceV7.cls-meta.xml` (API Version: 64.0)

## Critical V7 Improvements

### Memory Optimization (CRITICAL FIX)
**V6 Problem**: 18.9% tests failed with heap size errors (54 MB crash at 8,112 records)

**V7 Solution**: Two-tier query strategy
1. **Aggregation Mode** (>5,000 records OR summaryOnly=true)
   - Uses GROUP BY queries
   - Returns ~53 aggregate rows instead of 8,000+ records
   - Memory: ~6 KB (vs 54 MB in V6)
   - 99.99% memory reduction

2. **Detailed Mode** (≤5,000 records AND summaryOnly=false)
   - Full SELECT with 60 fields
   - Individual records with Learner Profile enrichment

### Other V7 Improvements
- ✅ AgentCore Constants integration
- ✅ Check count FIRST before loading data
- ✅ Pre-calculated QoQ%, YoY%, MoM% changes
- ✅ Outlier detection with Z-score method

## Key Concepts

### KPI Definitions (Growth Factors)
Each record represents ONE KPI metric for ONE AE:
- **DEFINITION__c**: KPI name (e.g., "Coverage", "Pipeline Generation")
- **DESCRIPTION__c**: What the KPI means and why it matters
- Same AE has multiple records (one per KPI tracked)

### Ramp Status Values
- **Fast Ramper**: Exceeding ramp expectations (235 records)
- **Slow Ramper**: Below ramp expectations (286 records)
- **On Track**: Meeting ramp expectations (168 records)
- **Not Ramping**: Not in ramp period (109 records)

### Time Windows
- **Current Quarter (CQ_*)**: Active quarter metrics
- **Previous Quarter (PQ_*)**: Last quarter baseline
- **Current FY (CURR_FY_*)**: Year-to-date metrics
- **Previous FY (PREV_FY_*)**: Last year comparison
- **Current Month (CURR_Y_CURR_MNTH_*)**: Monthly tracking
- **Same Month Last Year (LAST_Y_CURR_MNTH_*)**: YoY monthly

## Input Parameters

### Territory Filters (at least ONE required)
- `ouName`: Organizational Unit (supports region shortcuts: EMEA, APAC, AMER, LATAM)
- `workLocationCountry`: Country name
- `managementChainEmail`: Manager email (searches 12 hierarchy levels)

### Optional Filters
- `kpiDefinition`: Specific KPI/Growth Factor name
- `industry`: Industry filter
- `segment`: Macro segment (ENTR, CMRCL, ESMB, PubSec)
- `aeName`: Specific AE name
- `rampStatus`: Fast Ramper | Slow Ramper | On Track | Not Ramping

### Display Options
- `limitStr`: Max records (1-10,000, default: 50)
- `summaryOnlyStr`: Summary mode (default: true)
- `analysisTypeDetail`: Strategic focus for presentation
- `includeOutlierDetectionStr`: Enable outlier analysis (default: true)

## Output Structure

### Aggregation Mode (Large Datasets)
```json
{
  "ok": true,
  "data": {
    "analysisType": "KPI_ANALYSIS_V7",
    "queryStrategy": "AGGREGATION_ONLY",
    "totalRecords": 8112,
    "returnedRecords": 0,
    "omittedRecords": 8112,
    "summaryOnly": true,
    "message": "Large dataset detected. Using aggregation strategy for memory efficiency.",
    "summary": {
      "totals": {
        "total_count": 8112,
        "aggregate_rows_returned": 53,
        "memory_savings": "Returned 53 aggregate rows instead of 8112 individual records"
      },
      "by_kpi": [
        {
          "kpiDefinition": "Coverage",
          "aeCount": 1245,
          "currentQuarter": {
            "total": 45678.90,
            "average": 36.68
          },
          "previousQuarter": {
            "total": 42356.80,
            "average": 34.02
          },
          "qoq_change_pct": 7.8,
          "yoy_fy_change_pct": 12.3,
          "mom_yoy_change_pct": 5.6
        }
      ],
      "by_segment": [...],
      "by_industry": [...],
      "by_ramp_status": [...]
    }
  }
}
```

### Detailed Mode (Small Datasets)
```json
{
  "ok": true,
  "data": {
    "analysisType": "KPI_ANALYSIS",
    "totalRecords": 487,
    "returnedRecords": 200,
    "omittedRecords": 287,
    "summaryOnly": false,
    "summary": {
      "totals": {...},
      "by_kpi": [...],
      "outlierDetection": {
        "enabled": true,
        "threshold": 2.0,
        "mean": 45.67,
        "stdDev": 12.34,
        "outliers_found": 23,
        "positive_outliers": [
          {
            "kpiDefinition": "Coverage",
            "learnerProfileId": "a5F...",
            "kpiValue": 89.5,
            "zScore": 3.56,
            "industry": "Technology",
            "segment": "ENTR"
          }
        ],
        "negative_outliers": [...]
      }
    },
    "records": [
      {
        "id": "a0Z...",
        "analysisType": "KPI_ANALYSIS",
        "learnerProfileId": "a5F...",
        "aeName": "John Smith",
        "managerName": "Jane Doe",
        "kpiDefinition": "Coverage",
        "kpiDescription": "Ratio of pipeline to quota...",
        "ouName": "AMER ACC",
        "workLocationCountry": "United States",
        "industry": "Technology",
        "segment": "ENTR",
        "vertical": "Technology",
        "rampStatus": "On Track",
        "currentQuarter": {
          "acv": 125000,
          "pg": 98000,
          "...": "..."
        },
        "previousQuarter": {...},
        "currentFiscalYear": {...},
        "previousFiscalYear": {...},
        "currentMonth": {...},
        "sameMonthLastYear": {...}
      }
    ]
  }
}
```

## Common KPI Definitions (Growth Factors)

Top KPIs tracked:
- **Coverage**: Pipeline to quota ratio
- **Early-Stage Pipeline Percentage**: Early opportunity distribution
- **Total Sales Interactions**: Activity metrics
- **Sales Development Pipeline Generated**: SDR-generated pipeline
- **Deal Size**: Average deal value
- **Sales Play Win Percentage**: Win rate by sales play
- **Total Key Deals**: Strategic deal count
- **Pipeline Stage Stagnation Percentage**: Stagnation risk
- **Total Meeting Count**: Customer engagement
- **Create & Close ACV**: Self-sourced revenue

## Deployment Instructions

### Prerequisites
- Access to `AGENT_OU_PIPELINE_V3__c`
- Read permission on `Learner_Profile__c`
- AgentCore framework
- FRPermissionGuard utility

### Deploy Order
1. Deploy Service: `ANAgentKPIAnalysisServiceV7.cls`
2. Deploy Handler: `ANAgentKPIAnalysisHandlerV7.cls`
3. Deploy metadata files

## Dependencies
- `AgentCore_Constants`
- `AgentCore_Exception`
- `FRPermissionGuard`
- `AGENT_OU_PIPELINE_V3__c`
- `Learner_Profile__c` (with 12-level manager chain)

## Example Usage

### Analyze UKI KPIs
```json
{
  "ouName": "UKI",
  "summaryOnlyStr": "true"
}
```

### Analyze Specific Growth Factor
```json
{
  "ouName": "AMER ACC",
  "kpiDefinition": "Coverage",
  "summaryOnlyStr": "false",
  "includeOutlierDetectionStr": "true"
}
```

### Manager-based Analysis
```json
{
  "managementChainEmail": "sallen@salesforce.com",
  "rampStatus": "Slow Ramper"
}
```

## Performance Considerations
- **Small datasets** (<5,000): Detailed mode with full records
- **Large datasets** (>5,000): Auto-switches to aggregation mode
- **Extremely large** (>10,000): Forces aggregation regardless of settings
- Memory safe for datasets up to 50,000+ records

## Outlier Detection
Uses Z-score method (threshold: 2.0 standard deviations):
- **Positive outliers**: Exceptional performers
- **Negative outliers**: Underperformers
- Helps identify coaching opportunities and best practices

## Support
Contact Sales Operations Team for support.

