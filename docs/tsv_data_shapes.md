# TSV Data Shapes Documentation

## Overview

This document describes the actual data structures returned by the ANAgentMemoryContext for different analysis types. These structures are used by the TSV export functionality to generate properly formatted TSV files.

## Data Structure Patterns

### Common Structure
All analysis data follows this general pattern:
```json
{
  "analysisType": "RENEWALS|OPEN_PIPE|KPIS|SME|CONTENT_ACT|CONTENT_CONSENSUS|FUTURE_PIPE",
  "sessionId": "unique-session-identifier",
  "timestamp": "2024-01-15 10:30:00",
  "analysisData": {
    // Analysis-specific data structure
  }
}
```

## Analysis Type Data Structures

### 1. RENEWALS Analysis

**Purpose**: Product performance analysis for renewals
**Key Data**: Product aggregation with values and counts

```json
{
  "analysisType": "RENEWALS",
  "sessionId": "session-123",
  "timestamp": "2024-01-15 10:30:00",
  "analysisData": {
    "product_performance": [
      {
        "product": "Data Cloud",
        "totalValue": 2500000.50,
        "opportunityCount": 15,
        "avgDealSize": 166666.70
      },
      {
        "product": "Einstein Analytics", 
        "totalValue": 1800000.00,
        "opportunityCount": 12,
        "avgDealSize": 150000.00
      }
    ]
  }
}
```

**TSV Schema**: `Product | Total_Value | Opportunity_Count | Avg_Deal_Size`

### 2. OPEN_PIPE Analysis

**Purpose**: Open pipeline opportunity analysis
**Key Data**: Individual opportunities with AE and product details

```json
{
  "analysisType": "OPEN_PIPE",
  "sessionId": "session-456",
  "timestamp": "2024-01-15 10:30:00",
  "analysisData": {
    "opportunity_data": [
      {
        "aeEmail": "john.doe@company.com",
        "learnerProfileId": "LP001",
        "product": "Data Cloud",
        "opportunityName": "Acme Corp Data Cloud Implementation",
        "stage": "03 - Validating Benefits & Value",
        "stagnationDays": 45,
        "amount": 500000.00,
        "opportunityUrl": "https://company.lightning.force.com/lightning/r/Opportunity/006123456789/view"
      }
    ]
  }
}
```

**TSV Schema**: `AE_Email | Learner_Profile_Id | Product | Opportunity_Name | Stage | Stagnation_Days | Amount | Opportunity_URL`

### 3. KPIS Analysis

**Purpose**: AE performance and KPI analysis
**Key Data**: AE performance metrics and scores

```json
{
  "analysisType": "KPIS",
  "sessionId": "session-789",
  "timestamp": "2024-01-15 10:30:00",
  "analysisData": {
    "ae_performance": [
      {
        "aeEmail": "john.doe@company.com",
        "learnerProfileId": "LP001",
        "ou": "AMER-ACC",
        "aeScore": 4.2,
        "coverage": 85.5,
        "timeframe": "Current Quarter"
      }
    ]
  }
}
```

**TSV Schema**: `AE_Email | Learner_Profile_Id | OU | AE_Score | Coverage | Timeframe`

### 4. SME Analysis

**Purpose**: Subject Matter Expert identification and analysis
**Key Data**: SME information with expertise areas

```json
{
  "analysisType": "SME",
  "sessionId": "session-101",
  "timestamp": "2024-01-15 10:30:00",
  "analysisData": {
    "sme_data": [
      {
        "smeName": "Dr. Sarah Johnson",
        "smeEmail": "sarah.johnson@company.com",
        "smeOu": "AMER-ACC",
        "productL2": "Data Cloud",
        "excellenceAcademy": "Data Cloud Expert",
        "totalAcv": 5000000.00
      }
    ]
  }
}
```

**TSV Schema**: `SME_Name | SME_Email | SME_OU | Product_L2 | Excellence_Academy | Total_ACV`

### 5. CONTENT_ACT Analysis

**Purpose**: Content performance analysis (ACT data)
**Key Data**: Training content with enrollment and completion metrics

```json
{
  "analysisType": "CONTENT_ACT",
  "sessionId": "session-202",
  "timestamp": "2024-01-15 10:30:00",
  "analysisData": {
    "content_data": [
      {
        "title": "Data Cloud Fundamentals",
        "url": "https://trailhead.salesforce.com/content/learn/modules/data-cloud-fundamentals",
        "productTag": "Data Cloud",
        "enrollmentCount": 1250,
        "completionRate": 78.5,
        "publishedDate": "2024-01-01"
      }
    ]
  }
}
```

**TSV Schema**: `Title | URL | ProductTag | EnrollmentCount | CompletionRate | PublishedDate`

### 6. CONTENT_CONSENSUS Analysis

**Purpose**: Content consensus and engagement analysis
**Key Data**: Content with engagement scores and consensus metrics

```json
{
  "analysisType": "CONTENT_CONSENSUS",
  "sessionId": "session-303",
  "timestamp": "2024-01-15 10:30:00",
  "analysisData": {
    "consensus_data": [
      {
        "title": "Advanced Data Cloud Techniques",
        "url": "https://trailhead.salesforce.com/content/learn/modules/advanced-data-cloud",
        "productTag": "Data Cloud",
        "engagementScore": 92.3,
        "publishedDate": "2024-01-10"
      }
    ]
  }
}
```

**TSV Schema**: `Title | URL | ProductTag | EngagementScore | PublishedDate`

### 7. FUTURE_PIPE Analysis

**Purpose**: Future pipeline analysis (renewals, upsell, cross-sell)
**Key Data**: Pipeline opportunities with generation types

```json
{
  "analysisType": "FUTURE_PIPE",
  "sessionId": "session-404",
  "timestamp": "2024-01-15 10:30:00",
  "analysisData": {
    "future_pipeline": [
      {
        "aeEmail": "john.doe@company.com",
        "learnerProfileId": "LP001",
        "product": "Data Cloud",
        "oppAmount": 750000.00,
        "pipeGenType": "Upsell"
      }
    ]
  }
}
```

**TSV Schema**: `AE_Email | Learner_Profile_Id | Product | Opp_Amount | PipeGen_Type`

## Data Extraction Patterns

### Array Detection
The TSV export looks for arrays of objects in the `analysisData` section:
- `product_performance` (RENEWALS)
- `opportunity_data` (OPEN_PIPE)
- `ae_performance` (KPIS)
- `sme_data` (SME)
- `content_data` (CONTENT_ACT)
- `consensus_data` (CONTENT_CONSENSUS)
- `future_pipeline` (FUTURE_PIPE)

### Fallback Detection
If specific arrays aren't found, the system looks for:
- Any array containing objects with Map<String, Object> structure
- Uses the first suitable array found

### Field Mapping
Each analysis type has a predefined schema that maps to specific fields:
- **String fields**: Escaped for TSV (quotes, tabs, newlines)
- **Number fields**: Formatted as plain numbers (no currency symbols)
- **Date fields**: Formatted as YYYY-MM-DD

## Error Handling

### Missing Data
- If no analysis data found: Returns error message
- If analysis type mismatch: Returns specific error with suggestion
- If data structure unrecognized: Falls back to generic key-value format

### Data Validation
- Validates that arrays contain Map<String, Object> items
- Handles null values gracefully
- Escapes special characters for TSV format

## Testing

### Unit Tests
- Test each analysis type with sample data
- Test error conditions (no data, type mismatch)
- Test TSV escaping and formatting

### UAT Scripts
- End-to-end tests for each analysis type
- MCP integration tests
- Performance tests with large datasets

## Adding New Analysis Types

1. **Add to Schema Registry**: Update `ANAgentTSVSchemaRegistry.AnalysisType` enum
2. **Define Schema**: Add column definitions in `schemaFor()` method
3. **Add Detection**: Update `detectAnalysisType()` method
4. **Add Extraction**: Create new `extract[Type]Data()` method
5. **Update Tests**: Add unit tests and UAT scripts

## Performance Considerations

- **Memory Usage**: Large datasets are processed in chunks
- **Governor Limits**: Respects Salesforce governor limits
- **Caching**: Uses Platform Cache for data storage
- **Fallback**: Static maps when Platform Cache unavailable

