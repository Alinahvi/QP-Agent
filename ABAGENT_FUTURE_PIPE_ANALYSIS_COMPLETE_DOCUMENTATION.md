# ABAgentFuturePipeAnalysisHandler - Complete Documentation

## Overview

The ABAgentFuturePipeAnalysisHandler is a comprehensive Salesforce Apex solution that provides unified analysis for Renewals, Cross-sell, and Upsell data across different organizational units (OUs) and countries. This system consolidates multiple pipeline analysis types into a single, intelligent service with advanced features like risk scoring, performance analysis, and market intelligence.

## Architecture

### System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           EXTERNAL AGENT/UI                                    │
│                        (Invokes @InvocableMethod)                              │
└─────────────────────┬───────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    ABAgentFuturePipeAnalysisHandler                             │
│                           (Main Handler)                                        │
├─────────────────────────────────────────────────────────────────────────────────┤
│  • @InvocableMethod: analyzePipeline()                                          │
│  • Request Validation & Parameter Normalization                                │
│  • Session Management & Interaction Logging                                     │
│  • Error Handling with Comprehensive Fallbacks                                  │
│  • Governor Limit Enforcement                                                   │
│  • AgentInteractionLogger Integration                                           │
└─────────────────────┬───────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                 ABAgentFuturePipeAnalysisService                                │
│                      (Core Service Layer)                                       │
├─────────────────────────────────────────────────────────────────────────────────┤
│  • Main Method: analyzePipeline()                                               │
│  • Aggregate Query Generation & Optimization                                    │
│  • Type-Aware Field Mapping (Renewals/Cross-sell/Upsell)                       │
│  • Smart Filter Criteria Parsing with Natural Language Support                 │
│  • Data Availability Validation with Smart Suggestions                         │
│  • Enhanced Error Messages with Actionable Guidance                            │
│  • Results Processing & Markdown Formatting                                     │
└─────────────────────┬───────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│              ABAgentFuturePipeAnalysisServiceEnhanced                           │
│                       (Intelligence Layer)                                      │
├─────────────────────────────────────────────────────────────────────────────────┤
│  • Enhanced Method: analyzePipelineEnhanced()                                   │
│  • Renewal Risk Analysis with Weighted Scoring                                  │
│  • AE Performance Analysis with Benchmarking                                    │
│  • Product-Market Fit Analysis with Efficiency Scoring                          │
│  • Pipeline Health Scoring with Composite Metrics                               │
│  • Explainability & Next Best Actions                                           │
│  • Feature Toggle Management                                                    │
└─────────────────────┬───────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│              ABAgentFuturePipeAnalysisHandlerEnhanced                           │
│                    (Enhanced Handler with Intelligence)                         │
├─────────────────────────────────────────────────────────────────────────────────┤
│  • Enhanced @InvocableMethod: analyzePipelineEnhanced()                         │
│  • Intelligence Feature Toggles (includeRenewalRisk, includeAEPerf, etc.)      │
│  • Enhanced Request/Response Objects                                            │
│  • Advanced Logging & Error Handling                                            │
│  • Graceful Degradation when Intelligence Features Fail                         │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           SALESFORCE DATA LAYER                                │
├─────────────────────────────────────────────────────────────────────────────────┤
│  Agent_Renewals__c          Agent_Cross_Sell__c         Agent_Upsell__c         │
│  • renewal_prod_nm__c       • cross_sell_next_best_     • upsell_sub_category__c│
│  • renewal_acct_nm__c         product__c               • upsell_acct_nm__c      │
│  • renewal_opty_amt__c      • cross_sell_acct_nm__c    • upsell_acct_id__c      │
│  • CloseDate__c             • cross_sell_acct_id__c    • upsell_rn__c           │
│  • AE_Score__c              • cross_sell_rn__c         • AE_Score__c            │
│  • Coverage__c              • AE_Score__c              • Coverage__c            │
│  • full_name__c             • Coverage__c              • full_name__c           │
│  • ou_name__c               • full_name__c             • ou_name__c             │
│  • work_location_country__c • ou_name__c               • work_location_country__c│
│  • emp_mgr_nm__c            • work_location_country__c • emp_mgr_nm__c          │
│  • primary_industry__c      • emp_mgr_nm__c            • primary_industry__c    │
│  • macrosgment__c           • primary_industry__c      • macrosgment__c         │
│  • learner_profile_id__c    • macrosgment__c           • learner_profile_id__c  │
│  • ramp_status__c           • learner_profile_id__c    • ramp_status__c         │
│  • time_since_onboarding__c • ramp_status__c           • time_since_onboarding__c│
│                           • time_since_onboarding__c                           │
└─────────────────────┬───────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           QUERY PROCESSING LAYER                               │
├─────────────────────────────────────────────────────────────────────────────────┤
│  • Dynamic SOQL Generation based on Analysis Type                               │
│  • Aggregate Query Optimization (COUNT, SUM, AVG, MAX, MIN)                    │
│  • Field Mapping Resolution (Analysis Type → Object Fields)                    │
│  • Filter Criteria Parsing (Natural Language → SOQL)                           │
│  • Governor Limit Compliance (Query Limits, CPU Time, Heap Size)               │
│  • Data Validation & Availability Checking                                      │
└─────────────────────┬───────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            ANALYSIS LAYER                                       │
├─────────────────────────────────────────────────────────────────────────────────┤
│  Basic Analysis (Core Service)                                                  │
│  • Grouping & Aggregation                                                       │
│  • Results Formatting & Markdown Generation                                     │
│  • Executive Summary Generation                                                 │
│  • Actionable Insights & Recommendations                                        │
│                                                                                 │
│  Intelligence Analysis (Enhanced Service)                                       │
│  • Renewal Risk Scoring (Time + AE + Amount)                                    │
│  • AE Performance Benchmarking (Percentile vs OU Average)                      │
│  • Product-Market Fit Analysis (Efficiency Scoring)                            │
│  • Pipeline Health Scoring (Composite 0-10 Score)                              │
│  • Explainability & Next Best Actions                                           │
└─────────────────────┬───────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           RESPONSE LAYER                                        │
├─────────────────────────────────────────────────────────────────────────────────┤
│  • Markdown Formatted Results                                                   │
│  • Structured Data Objects (DTOs)                                               │
│  • Error Messages with Contextual Guidance                                      │
│  • Session Logging & Interaction Tracking                                       │
│  • Performance Metrics & Debug Information                                      │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Core Components

### 1. ABAgentFuturePipeAnalysisHandler

**Purpose**: Main entry point for all future pipeline analysis operations.

**Key Features**:
- Unified analysis for RENEWALS, CROSS_SELL, and UPSELL
- Request validation and parameter normalization
- Comprehensive error handling with fallback mechanisms
- Session management and interaction logging
- Governor limit enforcement

**Main Method**:
```apex
@InvocableMethod(
    label='ABAGENT Future Pipeline Analysis'
    description='Unified analysis for Renewals, Cross-sell, and Upsell data'
    category='Agent Analysis'
)
public static List<Response> analyzePipeline(List<Request> requests)
```

**Request Parameters**:
- `analysisType` (Required): RENEWALS, CROSS_SELL, or UPSELL
- `ouName` (Optional): Organizational Unit filter
- `workLocationCountry` (Optional): Country filter
- `groupBy` (Optional): Field to group results by
- `filterCriteria` (Optional): SOQL WHERE clause filters
- `aggregationType` (Optional): SUM, COUNT, AVG, MAX, MIN
- `limitN` (Optional): Maximum results (default: 20, max: 200)
- `startDate/endDate` (Optional): Date range filtering for Renewals

### 2. ABAgentFuturePipeAnalysisService

**Purpose**: Core business logic and data processing layer.

**Key Features**:
- Aggregate query optimization for large datasets
- Type-aware field mapping for different analysis types
- Smart filter criteria parsing with natural language support
- Enhanced error messages with actionable suggestions
- Data availability validation

**Supported Objects**:
- `Agent_Renewals__c` - Renewal opportunities and contracts
- `Agent_Cross_Sell__c` - Cross-sell opportunities
- `Agent_Upsell__c` - Upsell opportunities

**Field Mapping by Analysis Type**:

#### Renewals Analysis
```apex
'RENEWALS' => new Map<String, String>{
    'AE' => 'full_name__c',
    'OU' => 'ou_name__c',
    'COUNTRY' => 'work_location_country__c',
    'PRODUCT' => 'renewal_prod_nm__c',
    'INDUSTRY' => 'primary_industry__c',
    'MACRO_SEGMENT' => 'macrosgment__c',
    'MANAGER' => 'emp_mgr_nm__c',
    'ACCOUNT' => 'renewal_acct_nm__c',
    'LEARNER_PROFILE' => 'learner_profile_id__c'
}
```

#### Cross-Sell Analysis
```apex
'CROSS_SELL' => new Map<String, String>{
    'PRODUCT' => 'cross_sell_next_best_product__c',
    'INDUSTRY' => 'primary_industry__c',
    'MACRO_SEGMENT' => 'macrosgment__c',
    'AE' => 'full_name__c',
    'COUNTRY' => 'work_location_country__c',
    'MANAGER' => 'emp_mgr_nm__c',
    'ACCOUNT' => 'cross_sell_acct_nm__c',
    'LEARNER_PROFILE' => 'learner_profile_id__c'
}
```

#### Upsell Analysis
```apex
'UPSELL' => new Map<String, String>{
    'PRODUCT' => 'upsell_sub_category__c',
    'INDUSTRY' => 'primary_industry__c',
    'MACRO_SEGMENT' => 'macrosgment__c',
    'AE' => 'full_name__c',
    'COUNTRY' => 'work_location_country__c',
    'MANAGER' => 'emp_mgr_nm__c',
    'ACCOUNT' => 'upsell_acct_nm__c',
    'LEARNER_PROFILE' => 'learner_profile_id__c'
}
```

### 3. ABAgentFuturePipeAnalysisServiceEnhanced

**Purpose**: Advanced intelligence layer with AI-powered insights.

**Intelligence Features**:

#### Renewal Risk Analysis
- **Time Proximity Risk** (50% weight): Risk increases as close date approaches
- **AE Performance Risk** (30% weight): Risk based on AE score performance
- **Deal Amount Risk** (20% weight): Higher risk for larger, complex deals

```apex
// Risk Calculation Example
Decimal renewalRisk = (timeRisk * 0.5) + (aeRisk * 0.3) + (amountRisk * 0.2);
String riskTier = renewalRisk >= 0.7 ? 'HIGH' : 
                 renewalRisk >= 0.4 ? 'MEDIUM' : 'LOW';
```

#### AE Performance Analysis
- Performance percentile calculation relative to OU average
- Coaching flags and recommendations
- Performance tier classification (Top Performer, Above Average, Average, Needs Improvement)

#### Product-Market Fit Analysis
- Efficiency scoring based on coverage and opportunity density
- Market penetration analysis
- Product performance benchmarking

#### Pipeline Health Scoring
- Composite score (0-10) based on multiple factors:
  - Renewal Risk Score (30% weight)
  - AE Performance Score (25% weight)
  - PMF Score (20% weight)
  - Data Quality Score (15% weight)
  - Volume Score (10% weight)

### 4. ABAgentFuturePipeAnalysisHandlerEnhanced

**Purpose**: Enhanced handler with intelligence feature toggles.

**Additional Parameters**:
- `includeRenewalRisk`: Enable renewal risk analysis
- `includeAEPerf`: Enable AE performance analysis
- `includePMF`: Enable product-market fit analysis
- `includeHealthScore`: Enable pipeline health scoring

## Data Structures

### PipelineRowDTO
```apex
public class PipelineRowDTO {
    public String key;              // Grouping key (product, AE, etc.)
    public Integer count;           // Number of records
    public Decimal amount;          // Total amount (Renewals only)
    public Decimal avgAmount;       // Average amount (Renewals only)
    public Decimal maxAmount;       // Maximum amount (Renewals only)
    public Decimal minAmount;       // Minimum amount (Renewals only)
    public Integer uniqueAccounts;  // Unique account count (Cross-sell/Upsell)
    public Integer uniqueProducts;  // Unique product count (Cross-sell/Upsell)
}
```

### EnhancedResponse
```apex
public class EnhancedResponse {
    public Map<String, Object> aggregates;        // Basic analysis results
    public List<Map<String, Object>> renewalRisk; // Risk analysis results
    public List<Map<String, Object>> aePerformance; // AE performance data
    public List<Map<String, Object>> pmfFindings; // PMF analysis results
    public Map<String, Object> healthScore;       // Health scoring data
    public List<String> explain;                  // Explainability insights
    public List<String> nextBestActions;          // Actionable recommendations
}
```

## Advanced Features

### 1. Smart Filter Parsing
The system supports natural language filters with automatic field mapping:

```apex
// Natural language keywords
'slow rampers' → 'ramp_status__c = \'Slow Ramper\''
'slow_rampers' → 'ramp_status__c = \'Slow Ramper\''

// Field aliases
'product' → 'renewal_prod_nm__c' (for Renewals)
'account' → 'renewal_acct_nm__c' (for Renewals)
'country' → 'work_location_country__c'
```

### 2. Data Validation & Suggestions
Comprehensive data availability validation with smart suggestions:

```apex
public static DataAvailabilityResult validateDataAvailability(
    String ouName, 
    String workLocationCountry, 
    String analysisType
) {
    // Checks data availability
    // Provides alternative suggestions
    // Returns coverage information
}
```

### 3. Enhanced Error Handling
Context-aware error messages with troubleshooting guidance:

- **NO_DATA**: Smart suggestions for alternative parameters
- **INVALID_PARAMETERS**: Detailed validation with valid options
- **GOVERNOR_LIMITS**: Optimization recommendations
- **SECURITY_ACCESS**: Permission guidance

### 4. Market Intelligence Features

#### Comparative Analysis
```apex
public static String analyzeComparativePerformance(
    String analysisType,
    String primaryOu,
    String comparisonOu,
    String groupBy,
    Integer limitN
)
```

#### Industry Benchmarking
```apex
public static String analyzeIndustryBenchmarking(
    String analysisType,
    String ouName,
    String industry,
    Integer limitN
)
```

#### Performance Ranking
```apex
public static String analyzePerformanceRanking(
    String analysisType,
    String ouName,
    String groupBy,
    Integer limitN
)
```

#### Market Penetration Analysis
```apex
public static String analyzeMarketPenetration(
    String analysisType,
    String ouName,
    String groupBy,
    Integer limitN
)
```

## Usage Examples

### Basic Renewals Analysis
```apex
List<ABAgentFuturePipeAnalysisHandler.Request> requests = new List<ABAgentFuturePipeAnalysisHandler.Request>();
ABAgentFuturePipeAnalysisHandler.Request req = new ABAgentFuturePipeAnalysisHandler.Request();
req.analysisType = 'RENEWALS';
req.ouName = 'AMER ACC';
req.groupBy = 'PRODUCT';
req.aggregationType = 'SUM';
req.limitN = 10;
requests.add(req);

List<ABAgentFuturePipeAnalysisHandler.Response> responses = 
    ABAgentFuturePipeAnalysisHandler.analyzePipeline(requests);
```

### Enhanced Analysis with Intelligence
```apex
List<ABAgentFuturePipeAnalysisHandlerEnhanced.EnhancedRequest> requests = 
    new List<ABAgentFuturePipeAnalysisHandlerEnhanced.EnhancedRequest>();
ABAgentFuturePipeAnalysisHandlerEnhanced.EnhancedRequest req = 
    new ABAgentFuturePipeAnalysisHandlerEnhanced.EnhancedRequest();
req.analysisType = 'RENEWALS';
req.ouName = 'UKI';
req.groupBy = 'AE';
req.includeRenewalRisk = true;
req.includeAEPerf = true;
req.includeHealthScore = true;
requests.add(req);

List<ABAgentFuturePipeAnalysisHandlerEnhanced.EnhancedResponse> responses = 
    ABAgentFuturePipeAnalysisHandlerEnhanced.analyzePipelineEnhanced(requests);
```

### Cross-Sell Analysis with Filtering
```apex
ABAgentFuturePipeAnalysisHandler.Request req = new ABAgentFuturePipeAnalysisHandler.Request();
req.analysisType = 'CROSS_SELL';
req.workLocationCountry = 'Canada';
req.groupBy = 'PRODUCT';
req.filterCriteria = 'slow rampers';
req.limitN = 15;
```

## Performance Optimizations

### 1. Aggregate Query Strategy
- Uses `COUNT()`, `SUM()`, `AVG()` functions instead of loading raw records
- Prevents heap size issues with large datasets
- Optimized for governor limits

### 2. Governor Limit Management
- Automatic limit validation (max 200 results)
- Query optimization for large datasets
- Memory-efficient data processing

### 3. Caching Strategy
- Field mapping constants cached in static variables
- Reusable query templates
- Efficient data structure usage

## Security & Permissions

### Required Permissions
- **Object Access**: READ access to Agent_Renewals__c, Agent_Cross_Sell__c, Agent_Upsell__c
- **Field Access**: READ access to all referenced custom fields
- **Class Access**: Execute access to handler and service classes

### Permission Set Configuration
```xml
<classAccesses>
    <apexClass>ABAgentFuturePipeAnalysisHandler</apexClass>
    <enabled>true</enabled>
</classAccesses>
<classAccesses>
    <apexClass>ABAgentFuturePipeAnalysisService</apexClass>
    <enabled>true</enabled>
</classAccesses>
<classAccesses>
    <apexClass>ABAgentFuturePipeAnalysisServiceEnhanced</apexClass>
    <enabled>true</enabled>
</classAccesses>
<classAccesses>
    <apexClass>ABAgentFuturePipeAnalysisHandlerEnhanced</apexClass>
    <enabled>true</enabled>
</classAccesses>
```

## Error Handling & Logging

### 1. Agent Interaction Logging
Comprehensive logging of all agent interactions:

```apex
AgentInteractionLogger.LogInput li = new AgentInteractionLogger.LogInput();
li.sessionId = sessionId;
li.userId = UserInfo.getUserId();
li.detectedIntent = 'ABAgentFuturePipeAnalysis';
li.actionParameters = req;
li.responseMessage = result;
li.structuredResponse = structuredData;
li.responseStatus = 'Success';
```

### 2. Error Recovery
- Graceful degradation when intelligence features fail
- Fallback to basic analysis when enhanced features unavailable
- Comprehensive error context for troubleshooting

### 3. Debug Logging
- Detailed query execution logging
- Performance metrics tracking
- Governor limit monitoring

## Testing Strategy

### Test Classes
- `TestEnhancedFuturePipelineAnalysis` - Comprehensive test coverage
- `ABAgentFuturePipeAnalysisServiceEnhanced_Test` - Enhanced features testing

### Test Scenarios
1. **Basic Functionality**: All analysis types with various parameters
2. **Edge Cases**: Empty results, invalid parameters, governor limits
3. **Intelligence Features**: Risk scoring, performance analysis, health scoring
4. **Error Handling**: Exception scenarios and fallback behavior
5. **Performance**: Large dataset handling and governor limit compliance

## Deployment Considerations

### 1. Metadata Dependencies
- Custom objects: Agent_Renewals__c, Agent_Cross_Sell__c, Agent_Upsell__c
- Custom fields on all three objects
- Permission sets with appropriate access

### 2. Data Requirements
- Populated custom objects with realistic data
- Proper field mapping and data quality
- Test data for validation

### 3. Performance Monitoring
- Monitor query performance with large datasets
- Track governor limit usage
- Monitor heap size consumption

## Future Enhancements

### 1. Machine Learning Integration
- Predictive renewal risk scoring
- Automated opportunity scoring
- Trend analysis and forecasting

### 2. Real-time Analytics
- Live dashboard integration
- Real-time performance monitoring
- Automated alerting

### 3. Advanced Intelligence
- Natural language query processing
- Automated insight generation
- Recommendation engine integration

## Troubleshooting Guide

### Common Issues

#### 1. No Data Found
**Symptoms**: Empty results despite valid parameters
**Solutions**:
- Verify OU name exists in system
- Check country filter accuracy
- Try broader search criteria
- Use data availability validation

#### 2. Governor Limits Exceeded
**Symptoms**: "Too many SOQL queries" or "CPU time limit exceeded"
**Solutions**:
- Reduce limitN parameter
- Use more specific filters
- Consider date range filtering
- Optimize query complexity

#### 3. Permission Errors
**Symptoms**: "Insufficient privileges" errors
**Solutions**:
- Verify object and field permissions
- Check permission set assignments
- Ensure proper class access

#### 4. Intelligence Features Not Working
**Symptoms**: Basic analysis works but enhanced features fail
**Solutions**:
- Check feature toggle settings
- Verify data availability for intelligence features
- Review error logs for specific issues

### Debug Commands
```apex
// Enable debug logging
System.debug('🔍 Analysis Type: ' + analysisType);
System.debug('🔍 OU Name: ' + ouName);
System.debug('🔍 Query: ' + query);

// Check data availability
DataAvailabilityResult result = ABAgentFuturePipeAnalysisService.validateDataAvailability(ouName, country, analysisType);
System.debug('🔍 Data Available: ' + result.hasData);
System.debug('🔍 Record Count: ' + result.recordCount);
```

---

# Architecture Diagrams

## Component Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           EXTERNAL INTERFACES                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│  Agent UI/API          →  ABAgentFuturePipeAnalysisHandler                     │
│  Enhanced Agent UI     →  ABAgentFuturePipeAnalysisHandlerEnhanced             │
│  Testing Framework     →  Both Handlers + Services                             │
│  Monitoring/Logging    →  AgentInteractionLogger + AgentLog                    │
└─────────────────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            HANDLER LAYER                                        │
├─────────────────────────────────────────────────────────────────────────────────┤
│  ABAgentFuturePipeAnalysisHandler                                               │
│  ├─ Request Validation & Normalization                                          │
│  ├─ Parameter Defaults & Validation                                             │
│  ├─ Session Management & Logging                                                │
│  ├─ Error Handling & Fallbacks                                                  │
│  └─ Routes to: ABAgentFuturePipeAnalysisService                                 │
│                                                                                 │
│  ABAgentFuturePipeAnalysisHandlerEnhanced                                       │
│  ├─ Enhanced Request Processing                                                  │
│  ├─ Intelligence Feature Toggles                                                │
│  ├─ Advanced Error Handling                                                     │
│  └─ Routes to: ABAgentFuturePipeAnalysisServiceEnhanced                         │
└─────────────────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                             SERVICE LAYER                                       │
├─────────────────────────────────────────────────────────────────────────────────┤
│  ABAgentFuturePipeAnalysisService                                               │
│  ├─ Core Business Logic                                                         │
│  ├─ Data Query & Processing                                                     │
│  ├─ Results Formatting                                                          │
│  └─ Called by: ABAgentFuturePipeAnalysisServiceEnhanced                         │
│                                                                                 │
│  ABAgentFuturePipeAnalysisServiceEnhanced                                       │
│  ├─ Intelligence Feature Orchestration                                          │
│  ├─ Advanced Analytics & Scoring                                                │
│  ├─ Enhanced Results Generation                                                 │
│  └─ Extends: ABAgentFuturePipeAnalysisService                                   │
└─────────────────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            DATA ACCESS LAYER                                    │
├─────────────────────────────────────────────────────────────────────────────────┤
│  SOQL Query Engine                                                              │
│  ├─ Aggregate Query Optimization                                                │
│  ├─ Governor Limit Management                                                   │
│  ├─ Field Security & Permissions                                                │
│  └─ Data Validation & Error Handling                                            │
│                                                                                 │
│  Salesforce Objects                                                             │
│  ├─ Agent_Renewals__c                                                          │
│  ├─ Agent_Cross_Sell__c                                                        │
│  └─ Agent_Upsell__c                                                            │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Intelligence Features Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    ABAgentFuturePipeAnalysisServiceEnhanced                     │
│                           (Intelligence Orchestrator)                          │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │  Renewal Risk   │  │ AE Performance  │  │ Product-Market  │  │ Health Score │ │
│  │   Analysis      │  │   Analysis      │  │  Fit Analysis   │  │   Analysis   │ │
│  │                 │  │                 │  │                 │  │              │ │
│  │ • Time Risk     │  │ • Performance   │  │ • Efficiency    │  │ • Composite  │ │
│  │ • AE Risk       │  │   Percentile    │  │   Scoring       │  │   Scoring    │ │
│  │ • Amount Risk   │  │ • Benchmarking  │  │ • Market        │  │ • Multi-     │ │
│  │ • Weighted      │  │ • Coaching      │  │   Penetration   │  │   Factor     │ │
│  │   Scoring       │  │   Flags         │  │ • PMF Insights  │  │   Analysis   │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  └──────────────┘ │
│                                                                                 │
└─────────────────────┬───────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           Enhanced Response Builder                             │
├─────────────────────────────────────────────────────────────────────────────────┤
│  • Combines all intelligence features                                           │
│  • Generates explainability insights                                           │
│  • Creates next best actions                                                    │
│  • Formats results into markdown                                               │
│  • Handles graceful degradation                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Data Flow Sequence Diagram

```
External Agent/UI
       │
       │ 1. Invoke @InvocableMethod
       ▼
┌─────────────────────────────────────┐
│ ABAgentFuturePipeAnalysisHandler    │
│                                     │
│ • Validate Request                  │
│ • Set Defaults                      │
│ • Normalize Parameters              │
│ • Log Session                       │
└─────────────────┬───────────────────┘
                  │
                  │ 2. Call Service
                  ▼
┌─────────────────────────────────────┐
│ ABAgentFuturePipeAnalysisService    │
│                                     │
│ • Build SOQL Query                  │
│ • Execute Aggregate Query           │
│ • Process Results                   │
│ • Format Markdown                   │
└─────────────────┬───────────────────┘
                  │
                  │ 3. Return Results
                  ▼
┌─────────────────────────────────────┐
│ ABAgentFuturePipeAnalysisHandler    │
│                                     │
│ • Log Interaction                   │
│ • Handle Errors                     │
│ • Return Response                   │
└─────────────────┬───────────────────┘
                  │
                  │ 4. Formatted Results
                  ▼
            External Agent/UI
```

## Enhanced Flow Sequence Diagram

```
External Agent/UI (Enhanced)
       │
       │ 1. Invoke Enhanced @InvocableMethod
       ▼
┌─────────────────────────────────────┐
│ ABAgentFuturePipeAnalysisHandler    │
│ Enhanced                            │
│                                     │
│ • Validate Enhanced Request         │
│ • Check Feature Toggles             │
│ • Set Intelligence Flags            │
│ • Log Enhanced Session              │
└─────────────────┬───────────────────┘
                  │
                  │ 2. Call Enhanced Service
                  ▼
┌─────────────────────────────────────┐
│ ABAgentFuturePipeAnalysisService    │
│ Enhanced                            │
│                                     │
│ • Call Core Service                 │
│ • Add Renewal Risk Analysis         │
│ • Add AE Performance Analysis       │
│ • Add PMF Analysis                  │
│ • Add Health Score Analysis         │
│ • Generate Enhanced Response        │
└─────────────────┬───────────────────┘
                  │
                  │ 3. Call Core Service
                  ▼
┌─────────────────────────────────────┐
│ ABAgentFuturePipeAnalysisService    │
│                                     │
│ • Build & Execute SOQL              │
│ • Process Basic Results             │
│ • Return to Enhanced Service        │
└─────────────────┬───────────────────┘
                  │
                  │ 4. Enhanced Results
                  ▼
┌─────────────────────────────────────┐
│ ABAgentFuturePipeAnalysisHandler    │
│ Enhanced                            │
│                                     │
│ • Log Enhanced Interaction          │
│ • Handle Intelligence Errors        │
│ • Return Enhanced Response          │
└─────────────────┬───────────────────┘
                  │
                  │ 5. Enhanced Formatted Results
                  ▼
            External Agent/UI (Enhanced)
```

## Error Handling Flow

```
Request Processing
       │
       ▼
┌─────────────────────────────────────┐
│ Request Validation                  │
│                                     │
│ • Check Required Parameters         │
│ • Validate Analysis Type            │
│ • Verify Field Mappings             │
└─────────────────┬───────────────────┘
                  │
                  │ Valid?
                  ▼
            ┌─────────┐
            │   Yes   │
            └─────┬───┘
                  │
                  ▼
┌─────────────────────────────────────┐
│ Data Availability Check             │
│                                     │
│ • Query Data Existence              │
│ • Check Governor Limits             │
│ • Validate Permissions              │
└─────────────────┬───────────────────┘
                  │
                  │ Data Available?
                  ▼
            ┌─────────┐
            │   Yes   │
            └─────┬───┘
                  │
                  ▼
┌─────────────────────────────────────┐
│ Execute Analysis                    │
│                                     │
│ • Build SOQL Query                  │
│ • Execute with Error Handling       │
│ • Process Results                   │
└─────────────────┬───────────────────┘
                  │
                  │ Success?
                  ▼
            ┌─────────┐
            │   Yes   │
            └─────┬───┘
                  │
                  ▼
┌─────────────────────────────────────┐
│ Log Success & Return Results        │
└─────────────────────────────────────┘

Error Handling Paths:
       │
       ▼
┌─────────────────────────────────────┐
│ Enhanced Error Messages             │
│                                     │
│ • Contextual Error Information      │
│ • Smart Suggestions                 │
│ • Troubleshooting Guidance          │
│ • Alternative Recommendations       │
└─────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│ Graceful Degradation                │
│                                     │
│ • Fallback to Basic Analysis        │
│ • Partial Results When Possible     │
│ • Error Logging & Monitoring        │
└─────────────────────────────────────┘
```

## Field Mapping Architecture

```
Analysis Type Input
       │
       ▼
┌─────────────────────────────────────┐
│ Field Mapping Resolution            │
│                                     │
│ • Determine Analysis Type           │
│ • Select Object Schema              │
│ • Map GroupBy to Field Name         │
│ • Resolve Filter Criteria           │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│ Type-Specific Field Maps            │
│                                     │
│ RENEWALS:                           │
│ • PRODUCT → renewal_prod_nm__c      │
│ • ACCOUNT → renewal_acct_nm__c      │
│ • AMOUNT → renewal_opty_amt__c      │
│                                     │
│ CROSS_SELL:                         │
│ • PRODUCT → cross_sell_next_best_   │
│             product__c              │
│ • ACCOUNT → cross_sell_acct_nm__c   │
│                                     │
│ UPSELL:                             │
│ • PRODUCT → upsell_sub_category__c  │
│ • ACCOUNT → upsell_acct_nm__c       │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│ Natural Language Processing         │
│                                     │
│ • Parse Filter Criteria             │
│ • Expand Keywords                   │
│ • Convert to SOQL WHERE             │
│ • Handle Field Aliases              │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│ Final SOQL Query                    │
│                                     │
│ • Aggregate Functions               │
│ • Proper Field References           │
│ • Optimized WHERE Clauses           │
│ • Governor-Safe Limits              │
└─────────────────────────────────────┘
```

## Intelligence Scoring Architecture

```
Raw Data Input
       │
       ▼
┌─────────────────────────────────────┐
│ Data Collection & Validation        │
│                                     │
│ • Query Relevant Records            │
│ • Validate Data Quality             │
│ • Check Field Availability          │
│ • Handle Missing Data               │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│ Multi-Factor Analysis               │
│                                     │
│ ┌─────────────┐ ┌─────────────┐ ┌──┐ │
│ │Time-Based   │ │Performance  │ │Am│ │
│ │Risk         │ │Risk         │ │ou│ │
│ │• Days to    │ │• AE Score   │ │nt│ │
│ │  Close      │ │• Coverage   │ │R │ │
│ │• Urgency    │ │• Benchmark  │ │is│ │
│ └─────────────┘ └─────────────┘ │k │ │
│                                 └──┘ │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│ Weighted Scoring Algorithm          │
│                                     │
│ • Apply Weights (50%, 30%, 20%)     │
│ • Calculate Composite Score         │
│ • Normalize to 0-1 Range            │
│ • Determine Risk Tier               │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│ Intelligence Insights               │
│                                     │
│ • Risk Tier Classification          │
│ • Contributing Factors              │
│ • Next Best Actions                 │
│ • Explainability Reasoning          │
└─────────────────────────────────────┘
```

## Conclusion

The ABAgentFuturePipeAnalysisHandler represents a comprehensive, enterprise-grade solution for pipeline analysis with advanced intelligence capabilities. Its modular architecture, robust error handling, and extensive feature set make it suitable for complex sales analytics requirements while maintaining performance and scalability.

The system successfully consolidates multiple analysis types into a unified interface while providing deep insights through AI-powered intelligence features. Its governor-safe design and comprehensive logging make it production-ready for large-scale Salesforce deployments.

This consolidated documentation ensures that all aspects of the system are preserved and accessible in a single, comprehensive reference document.
