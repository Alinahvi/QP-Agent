# SearchProgramsV6

## Overview
Unified search across Product Catalog (172 global programs) and Regional Programs (861 localized programs) with usage metrics and intelligent filtering.

## Version
**V6.0** - Released 2025-11-04

## Components

### Handler Class
- **File**: `ANAgentProgramSearchHandlerV6.cls`
- **Label**: `SearchProgramsV6`
- **Type**: Invocable Method (Agent Action)
- **Purpose**: Entry point with flexible input handling and validation

### Service Class  
- **File**: `ANAgentProgramSearchServiceV6.cls`
- **Type**: Business Logic Service
- **Purpose**: Search logic, usage metrics enrichment, and sorting

### Metadata Files
- `ANAgentProgramSearchHandlerV6.cls-meta.xml` (API Version: 64.0)
- `ANAgentProgramSearchServiceV6.cls-meta.xml` (API Version: 64.0)

## Key Features

### V6 Improvements from V5
- ✅ AgentCore Constants integration
- ✅ AgentCore Exception for typed errors
- ✅ Removed Halloween theme
- ✅ Professional error messages
- ✅ Enhanced field descriptions with "Examples:" format
- ✅ searchTerm correctly marked as OPTIONAL

### Program Catalogs
1. **GLOBAL** (Product_Catalog__c)
   - 172 active programs
   - Standardized enterprise programs
   - Fields: Level, Role, Products (L1/L2/L3), Skills, Duration

2. **REGIONAL** (Regional_Programs__c)
   - 861 localized programs
   - Region-specific initiatives
   - Fields: Session Type, Business Priority, Hours

3. **BOTH** - Search both catalogs simultaneously

### Usage Metrics (from Enablement_Solutions__c)
- Usage Count (how many times scheduled)
- Total Learners (total enrollment)
- Recent Usage (last 90 days)
- Last Scheduled Date
- Avg Learners Per Instance

## Input Parameters

### Required
- `programType`: GLOBAL | REGIONAL | BOTH

### Optional Search & Filters
- `searchTerm`: Program name, topic, skill, or keyword (min 2 chars)
- `enablementType`: PRODUCT | SKILLS | INDUSTRY | DO_MY_JOB | ALL
- `targetLevel`: BEGINNER | INTERMEDIATE | ADVANCED | EXPERT | ALL (Global only)
- `targetRole`: AE | SE | BDR | SDR | SALES_MANAGER | LEADER | CSM | ALL (Global only)
- `fiscalQuarter` + `fiscalYear`: Filter by quarterly usage (Q1-Q4, FY 2024-2026)
- `globalRegion`: GLOBAL | AMER | EMEA | APAC | LATAM | JAPAN | ALL
- `sessionType`: VIRTUAL | PHYSICAL | HYBRID | ALL (Regional only)
- `businessPriority`: Strategic priority keyword
- `minHoursRequired`: Minimum duration (hours)
- `maxHoursRequired`: Maximum duration (hours)

### Optional Display
- `sortBy`: USAGE_COUNT | TOTAL_LEARNERS | RECENT_USAGE | NAME | HOURS | DEFAULT
- `sortOrder`: ASC | DESC (default: DESC)
- `limitStr`: Max results per catalog (1-100, default: 50)
- `includeUsageMetricsStr`: Include metrics (true/false, default: true)
- `includeArchivedStr`: Include archived programs (true/false, default: false)

## Output Structure

```json
{
  "ok": true,
  "data": {
    "analysisType": "PROGRAM_SEARCH_GLOBAL",
    "searchTerm": "Agentforce",
    "catalogType": "GLOBAL",
    "sortBy": "USAGE_COUNT",
    "sortOrder": "DESC",
    "includeUsageMetrics": true,
    "summary": {
      "totalPrograms": 15,
      "catalogBreakdown": {
        "global": 15,
        "regional": 0
      },
      "avgHoursRequired": 3.5,
      "totalUsageCount": 245,
      "totalLearnersAllInstances": 12450,
      "recentUsage90DaysCount": 89,
      "highUsagePrograms": 8,
      "recentlyUsedPrograms": 12
    },
    "records": [
      {
        "id": "a0X...",
        "name": "PMI-001",
        "programTitle": "Agentforce Fundamentals",
        "programType": "Global",
        "enablementType": "Product",
        "targetLevel": "Beginner",
        "targetRoles": "AE;SE;BDR",
        "description": "Introduction to Agentforce...",
        "hoursRequired": 2.0,
        "deliveryCadence": "On-Demand",
        "products": "Agentforce",
        "skills": "AI + Data + CRM",
        "businessPriority": "Priority 1: High Performance Culture",
        "status": "Active",
        "links": {
          "assetLink": "https://...",
          "programLink": "https://..."
        },
        "metrics": {
          "usageCount": 45,
          "totalLearners": 2340,
          "recentUsage90Days": 12,
          "lastScheduledDate": "2025-11-01",
          "avgLearnersPerInstance": 52
        }
      }
    ]
  }
}
```

## Deployment Instructions

### Prerequisites
- Access to `Product_Catalog__c` and `Regional_Programs__c`
- Read permission on `Enablement_Solutions__c` and `Quarterly_Planning__c`
- AgentCore framework classes
- FRPermissionGuard and FRSearchGuard utilities

### Deploy Order
1. Deploy Service: `ANAgentProgramSearchServiceV6.cls`
2. Deploy Handler: `ANAgentProgramSearchHandlerV6.cls`
3. Deploy metadata files
4. Test with sample queries

## Dependencies
- `AgentCore_Constants`
- `AgentCore_Exception`
- `FRPermissionGuard`
- `FRSearchGuard`
- `Product_Catalog__c`
- `Regional_Programs__c`
- `Enablement_Solutions__c`
- `Quarterly_Planning__c`

## Example Usage

### Find Agentforce Programs
```json
{
  "programType": "BOTH",
  "searchTerm": "Agentforce",
  "limitStr": "50"
}
```

### Find Beginner AE Programs
```json
{
  "programType": "GLOBAL",
  "targetRole": "AE",
  "targetLevel": "BEGINNER",
  "sortBy": "USAGE_COUNT"
}
```

### Find Q2 FY2025 Programs
```json
{
  "programType": "BOTH",
  "fiscalQuarter": "Q2",
  "fiscalYear": "FY 2025",
  "globalRegion": "AMER"
}
```

## Data Quality Notes
- Global: Only 172/540 programs are Active (32%)
- Global products field only 24% populated
- Regional: No status field (all non-deleted shown)
- Regional: No description field
- Session Type (Regional): 90% populated

## Support
Contact Sales Operations Team for support.

