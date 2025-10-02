# Enhanced Open Pipe Analysis - API Reference

## Overview
This document provides comprehensive API documentation for the Enhanced Open Pipe Analysis system.

## 🏗️ Architecture

### Class Hierarchy
```
ANAgentOpenPipeAnalysisV3Handler (Entry Point)
    ↓
ANAgentOpenPipeAnalysisV3ServiceEnhanced (Business Logic)
    ↓
ANAgentNamingNormalizer (Utility)
```

### Data Flow
```
User Input → Handler → Service → Naming Normalizer → SOQL Query → Analysis → Formatted Output
```

## 📋 Main Classes

### ANAgentOpenPipeAnalysisV3Handler

#### Purpose
Entry point for invocable actions, handles parameter validation and delegates to service layer.

#### Methods

##### `analyzeOpenPipe(List<Map<String, Object>> inputs)`
**Description**: Main invocable method for Open Pipe Analysis

**Parameters**:
- `inputs` (List<Map<String, Object>>): List of input parameters

**Input Map Structure**:
```apex
Map<String, Object> input = new Map<String, Object>{
    'ou' => 'AMER ACC',                    // Operating Unit (optional)
    'country' => 'United States',          // Country filter (optional)
    'product' => 'Tableau',                // Product filter (optional)
    'segment' => 'Enterprise',             // Segment filter (optional)
    'stage' => 'Stage 2',                  // Stage filter (optional)
    'analysisType' => 'territory',         // Analysis type (required)
    'maxRecords' => 10000                  // Record limit (optional)
};
```

**Analysis Types**:
- `'territory'` - OU-level pipeline analysis
- `'product'` - Product performance analysis
- `'ae'` - AE performance analysis
- `'stage'` - Stage progression analysis

**Returns**: `List<String>` - Analysis results

**Example**:
```apex
List<Map<String, Object>> inputs = new List<Map<String, Object>>{
    new Map<String, Object>{
        'ou' => 'AMER ACC',
        'analysisType' => 'territory'
    }
};

List<String> results = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(inputs);
```

### ANAgentOpenPipeAnalysisV3ServiceEnhanced

#### Purpose
Core business logic for Open Pipe Analysis with enhanced features.

#### Methods

##### `analyzeOpenPipe(Map<String, Object> params)`
**Description**: Main analysis method with context-aware resolution

**Parameters**:
- `params` (Map<String, Object>): Analysis parameters

**Returns**: `String` - Formatted analysis result

**Features**:
- Context-aware term resolution
- Smart field selection
- Data quality assessment
- Outlier detection
- Rich message formatting

##### `queryOpenPipeData(Map<String, Object> params, String analysisType)`
**Description**: Builds and executes SOQL queries

**Parameters**:
- `params` (Map<String, Object>): Query parameters
- `analysisType` (String): Type of analysis

**Returns**: `List<Agent_Open_Pipe__c>` - Query results

**Query Optimization**:
- Dynamic field selection
- Appropriate LIMIT clauses
- Indexed field filtering

##### `detectStagnationOutliers(List<Agent_Open_Pipe__c> data)`
**Description**: Identifies unusual stagnation patterns

**Parameters**:
- `data` (List<Agent_Open_Pipe__c>): Pipeline data

**Returns**: `Map<String, Object>` - Outlier analysis results

**Statistical Methods**:
- IQR (Interquartile Range) analysis
- Z-score calculation
- Percentile-based thresholds

### ANAgentNamingNormalizer

#### Purpose
Utility class for context-aware term resolution and normalization.

#### Methods

##### `normalizeOU(String input)`
**Description**: Normalizes Operating Unit names

**Parameters**:
- `input` (String): Raw OU input

**Returns**: `String` - Normalized OU name

**Examples**:
```apex
String normalized = ANAgentNamingNormalizer.normalizeOU('amer-acc');
// Returns: 'AMER ACC'

String normalized = ANAgentNamingNormalizer.normalizeOU('AMER-ICE');
// Returns: 'AMER-ICE'
```

##### `normalizeProduct(String input)`
**Description**: Normalizes product names with context awareness

**Parameters**:
- `input` (String): Raw product input

**Returns**: `String` - Normalized product name

**Examples**:
```apex
String normalized = ANAgentNamingNormalizer.normalizeProduct('tableau');
// Returns: Context-aware resolution based on available products
```

##### `normalizeCountry(String input)`
**Description**: Normalizes country names

**Parameters**:
- `input` (String): Raw country input

**Returns**: `String` - Normalized country name

**Examples**:
```apex
String normalized = ANAgentNamingNormalizer.normalizeCountry('us');
// Returns: 'United States of America'
```

##### `normalizeSegment(String input)`
**Description**: Normalizes segment names

**Parameters**:
- `input` (String): Raw segment input

**Returns**: `String` - Normalized segment name

**Examples**:
```apex
String normalized = ANAgentNamingNormalizer.normalizeSegment('enterprise');
// Returns: 'ENTR'
```

##### `normalizeStage(String input)`
**Description**: Normalizes stage names

**Parameters**:
- `input` (String): Raw stage input

**Returns**: `String` - Normalized stage name

**Examples**:
```apex
String normalized = ANAgentNamingNormalizer.normalizeStage('stage 2');
// Returns: 'Stage 2 - Determining Problem, Impact, Ideal'
```

## 🔧 Utility Methods

### Data Quality Assessment

#### `assessDataQuality(List<Agent_Open_Pipe__c> data)`
**Description**: Assesses data quality for available fields

**Returns**: `Map<String, Decimal>` - Field quality percentages

#### `buildDataQualityReport(Map<String, Decimal> qualityMap)`
**Description**: Builds data quality report

**Returns**: `String` - Formatted quality report

### Smart Field Selection

#### `getSmartFieldSelection(String analysisType)`
**Description**: Returns prioritized fields for analysis type

**Parameters**:
- `analysisType` (String): Type of analysis

**Returns**: `Map<String, List<String>>` - Field priorities

### Outlier Detection

#### `calculateStagnationStatistics(List<Agent_Open_Pipe__c> data)`
**Description**: Calculates statistical measures for stagnation analysis

**Returns**: `Map<String, Decimal>` - Statistical measures

#### `identifyOutlierRecords(List<Agent_Open_Pipe__c> data, Map<String, Decimal> stats)`
**Description**: Identifies outlier records using statistical methods

**Returns**: `List<Agent_Open_Pipe__c>` - Outlier records

## 📊 Data Models

### Agent_Open_Pipe__c Object

#### Key Fields
| Field Name | Type | Description | Usage |
|------------|------|-------------|-------|
| `Id` | ID | Record ID | Primary key |
| `Name` | Text | Record name | Display name |
| `OU_NAME__C` | Text | Operating Unit | Territory analysis |
| `OPEN_PIPE_PROD_NM__C` | Text | Product Name | Product analysis |
| `OPEN_PIPE_APM_L2__C` | Text | Product Family | Product grouping |
| `WORK_LOCATION_COUNTRY__C` | Text | Customer Country | Geographic analysis |
| `MACROSGMENT__C` | Text | Customer Segment | Segment analysis |
| `PRIMARY_INDUSTRY__C` | Text | Customer Industry | Industry analysis |
| `OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__C` | Currency | Deal Amount | Financial analysis |
| `OPEN_PIPE_OPTY_STG_NM__C` | Text | Pipeline Stage | Stage analysis |
| `FULL_NAME__C` | Text | AE Name | AE analysis |
| `OPEN_PIPE_AE_SCORE__C` | Number | AE Score | Confidence analysis |
| `OPEN_PIPE_OPTY_DAYS_IN_STAGE__C` | Number | Days in Stage | Stagnation analysis |

### Response Format

#### Success Response
```json
{
  "status": "success",
  "data": {
    "executiveSummary": "🎯 **AMER ACC Territory Analysis**\n\n**Executive Summary**\n- Total Pipeline: $45.2M across 1,247 opportunities",
    "analysisSummary": "**Analysis Summary**\n- Product Diversity: High (12 product families)",
    "results": "**Results**\n- Top Products: Tableau ($12.3M), Salesforce ($8.7M)",
    "actionableInsights": "**Recommended Next Steps**\n1. Review 89 stagnant Stage 2 deals"
  },
  "metadata": {
    "recordCount": 1247,
    "dataQuality": "High",
    "outliersDetected": 23
  }
}
```

#### Error Response
```json
{
  "status": "error",
  "error": {
    "code": "NO_DATA",
    "message": "🔍 No data found for the specified criteria. Try expanding your search parameters.",
    "suggestions": [
      "Check the exact OU name",
      "Try a broader search",
      "Use country filter instead"
    ]
  }
}
```

## 🚀 Usage Examples

### Basic Territory Analysis
```apex
Map<String, Object> params = new Map<String, Object>{
    'ou' => 'AMER ACC',
    'analysisType' => 'territory'
};

String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipe(params);
System.debug(result);
```

### Product Analysis with Filtering
```apex
Map<String, Object> params = new Map<String, Object>{
    'product' => 'Tableau',
    'country' => 'United States',
    'analysisType' => 'product',
    'maxRecords' => 5000
};

String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipe(params);
```

### AE Performance Analysis
```apex
Map<String, Object> params = new Map<String, Object>{
    'ou' => 'EMEA-NORTH',
    'analysisType' => 'ae'
};

String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipe(params);
```

### Stage Analysis with Outlier Detection
```apex
Map<String, Object> params = new Map<String, Object>{
    'stage' => 'Stage 2',
    'analysisType' => 'stage'
};

String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipe(params);
```

## 🔍 Error Handling

### Common Error Codes
- `NO_DATA` - No records found for criteria
- `INVALID_PARAMS` - Invalid input parameters
- `GOVERNOR_LIMIT` - Salesforce governor limit exceeded
- `SYSTEM_ERROR` - Unexpected system error

### Error Response Format
```apex
// Error messages include:
// - Clear description of the issue
// - Troubleshooting suggestions
// - Alternative approaches
// - Contact information if needed
```

## 📈 Performance Considerations

### Query Optimization
- Uses indexed fields for filtering
- Implements dynamic LIMIT clauses
- Selects only required fields

### Memory Management
- Processes large datasets in batches
- Clears large variables when done
- Uses efficient collection types

### Governor Limits
- **SOQL Queries**: Optimized to minimize query count
- **DML Statements**: No DML operations
- **CPU Time**: Efficient algorithms and caching
- **Heap Size**: Memory-conscious processing

## 🔒 Security

### Data Access
- Respects field-level security
- Follows org sharing rules
- Runs in user's security context

### Input Validation
- Validates all input parameters
- Sanitizes user input
- Prevents injection attacks

### Output Sanitization
- Escapes special characters
- Prevents XSS attacks
- Validates output format

---

**API Version**: 3.0 Enhanced  
**Last Updated**: October 2024  
**Compatibility**: Salesforce API 58.0+
