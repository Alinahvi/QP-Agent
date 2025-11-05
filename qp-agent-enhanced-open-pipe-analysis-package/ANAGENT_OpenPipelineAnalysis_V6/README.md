# ANAGENT Open Pipeline Analysis V6

## Overview
Analyzes current open sales pipeline to identify bottlenecks, stagnation, and deal band distribution with AE confidence scoring.

## Version
**V6.0** - Released 2025-11-04

## Components

### Handler Class
- **File**: `ANAgentOpenPipeAnalysisHandlerV6.cls`
- **Label**: `ANAGENT Open Pipeline Analysis V6`
- **Type**: Invocable Method (Agent Action)
- **Purpose**: Flexible input handling with validation

### Service Class  
- **File**: `ANAgentOpenPipeAnalysisServiceV6.cls`
- **Type**: Business Logic Service
- **Purpose**: Pipeline analysis with auto-optimization

### Metadata Files
- `ANAgentOpenPipeAnalysisHandlerV6.cls-meta.xml` (API Version: 64.0)
- `ANAgentOpenPipeAnalysisServiceV6.cls-meta.xml` (API Version: 64.0)

## Key Features

### V6 Improvements from V5
- ✅ AgentCore Constants integration
- ✅ Country name normalization (USA → US, UK → United Kingdom)
- ✅ Auto query limit handling (prevents >50K errors)
- ✅ Opportunity link support (includeOpportunityLinks)
- ✅ Enhanced AE Scorecard context (0-5 scale clarification)
- ✅ Deal band analysis support
- ✅ Auto-summary mode for >10,000 records

### Pipeline Insights
- **Product Performance**: Which products are underperforming
- **Stage Bottlenecks**: Where deals are stagnating
- **Stagnation Analysis**: High days in stage identification
- **Vertical/Segment Health**: Performance by market dimension
- **AE Confidence**: 0-5 scorecard with close rate correlation

### AE Scorecard (0-5 Scale)
- **0**: No score or uncertain (76.5% of deals)
- **1-2**: Low confidence, needs intervention  
- **3**: Above average, good close rate potential
- **4**: Strong confidence, excellent close rate (13% of deals)
- **5**: Exceptional confidence, highest close rate (1.7% of deals)

**Anything above 3 indicates good close rate potential**

### Deal Bands (Salesforce Terminology)
Deal size distribution for planning:
- <50k
- 50-100k
- 100-150k
- 150k-500k
- 1M+

### Product Hierarchy
- **APM_L2** (OPEN_PIPE_APM_L2__c): L2 product family, ~100 categories (e.g., "Tableau")
- **PROD_NM** (OPEN_PIPE_PROD_NM__c): L3/SKU specific items (e.g., "Tableau Desktop")

### Stage Mapping
Human names → Actual values:
- **Stage 2** → "02 - Determining Problem, Impact, Ideal"
- **Stage 3** → "03 - Validating Benefits & Value"
- **Stage 4** → "04 - Confirming Value With Power"
- **Stage 5** → "05 - Negotiating $$ & Mutual Plan"
- **Stage 6** → "06 - Finalizing Closure"
- **Stage 7** → "07 - Pending"

## Input Parameters

### Territory Filters (at least ONE required)
- `ouName`: Organizational Unit (AMER ACC, UKI, EMEA, APAC, etc.)
- `workLocationCountry`: Country name (supports aliases)
- `managerEmail`: Manager email (searches 12 hierarchy levels)

### Optional Filters
- `stageFilter`: Pipeline stage (Stage 2-7)
- `productFamily`: Product filter (fuzzy match on APM_L2)
- `aeName`: Specific AE name
- `industry`: Industry filter
- `segment`: Macro segment (ENTR, CMRCL, ESMB, PubSec)
- `startDate`: Created from date (YYYY-MM-DD)
- `endDate`: Estimated close date to (YYYY-MM-DD)

### Display Options
- `limitStr`: Max records (1-50,000, default: 50,000)
- `summaryOnlyStr`: Summary mode (default: true)
- `includeOpportunityLinksStr`: Include Salesforce opportunity links (default: false)
- `analysisTypeDetail`: Strategic focus hint

## Output Structure

```json
{
  "ok": true,
  "data": {
    "analysisType": "OPEN_PIPE",
    "totalRecords": 3456,
    "returnedRecords": 200,
    "omittedRecords": 3256,
    "summaryOnly": true,
    "summary": {
      "totals": {
        "total_amount": 45678900.50,
        "total_count": 3456,
        "average_amount": 13215.62,
        "total_stagnation_days": 89234,
        "average_stagnation_days": 25.8,
        "average_ae_score": 2.9
      },
      "by_product": [
        {
          "product": "sales cloud",
          "count": 456,
          "sum_amount": 12345678.90,
          "avg_stagnation": 28.5,
          "avg_ae_score": 3.1
        }
      ],
      "by_segment": [...],
      "by_industry": [...],
      "by_stage": [
        {
          "stage": "03 - validating benefits & value",
          "stage_human": "Stage 3",
          "count": 234,
          "sum_amount": 5678900.00,
          "avg_stagnation": 32.4,
          "avg_ae_score": 2.8
        }
      ]
    },
    "records": [
      {
        "id": "a0W...",
        "pipeType": "OPEN_PIPE",
        "learnerProfileId": "a5F...",
        "amount": 125000.00,
        "product": {
          "family": "Sales Cloud",
          "name": "Sales Cloud Enterprise"
        },
        "industry": "Technology",
        "segment": "ENTR",
        "vertical": "Technology",
        "stage": "03 - Validating Benefits & Value",
        "stageHuman": "Stage 3",
        "stagnationDays": 45,
        "aeScore": 3.5,
        "opportunityLink": "https://salesforce.com/..." (if includeOpportunityLinks=true)
      }
    ]
  }
}
```

## Auto-Optimization

### Auto-Summary Mode
Automatically enabled when:
- Dataset > 10,000 records
- Prevents memory errors
- Returns summary aggregations only

### Query Limit Protection
- Hard stop at 50,000 records
- Returns error with suggestions to narrow query

## Deployment Instructions

### Prerequisites
- Access to `Agent_Open_Pipe__c`
- Read permission on `Learner_Profile__c`
- AgentCore framework
- FRPermissionGuard and FRSearchGuard utilities

### Deploy Order
1. Deploy Service: `ANAgentOpenPipeAnalysisServiceV6.cls`
2. Deploy Handler: `ANAgentOpenPipeAnalysisHandlerV6.cls`
3. Deploy metadata files

## Dependencies
- `AgentCore_Constants`
- `AgentCore_Exception`
- `FRPermissionGuard`
- `FRSearchGuard`
- `Agent_Open_Pipe__c`
- `Learner_Profile__c`

## Example Usage

### Find Stage Bottlenecks
```json
{
  "ouName": "AMER ACC",
  "summaryOnlyStr": "true"
}
```

### Analyze Product Performance
```json
{
  "workLocationCountry": "United States",
  "productFamily": "Sales Cloud",
  "summaryOnlyStr": "true"
}
```

### Find Stagnating Deals
```json
{
  "ouName": "UKI",
  "stageFilter": "Stage 3",
  "includeOpportunityLinksStr": "true"
}
```

### Manager Pipeline Analysis
```json
{
  "managerEmail": "sallen@salesforce.com",
  "segment": "ENTR"
}
```

## Field Mapping

### Amount Field
Uses `OPEN_PIPE_OPENPIPE_ALLOC_AMT__c` (not ORIGINAL amount)

### Date Field
`OPEN_PIPE_CLOSED_DATE__c` = Estimated close date (critical for Q1-Q4 planning)

### Stagnation
`OPEN_PIPE_OPTY_DAYS_IN_STAGE__c` = Days stuck in current stage

## Common Analysis Types
- pipeline stagnation
- product strategy
- Q4 closing strategy
- stage bottlenecks
- deal band analysis
- opportunity distribution by stage
- amount concentration by stage
- vertical performance
- segment pipeline health
- at-risk opportunities

## Performance Thresholds
- Auto-summary threshold: 10,000 records
- Max detailed rows: 200 records
- Query limit: 50,000 records
- Response size cap: ~1 MB

## Support
Contact Sales Operations Team for support.

