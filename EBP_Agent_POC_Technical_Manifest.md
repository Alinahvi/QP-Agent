# EBP Agent POC - Detailed Technical Manifest

## 🎯 **Overview**

The EBP Agent POC is a comprehensive Salesforce-based AI agent system that provides intelligent data analysis, content search, and expert identification capabilities. The system follows a consistent **Handler + Service Pattern** architecture with proper separation of concerns.

## 🏗️ **Architecture Pattern**

### **Handler Classes** (Entry Points)
- Marked with `@InvocableMethod` for Flow/Agent integration
- Handle input validation and request routing
- Convert external requests to internal service calls
- Provide standardized response formatting

### **Service Classes** (Business Logic)
- Contain all business logic and data processing
- Handle SOQL queries and data aggregation
- Implement complex algorithms and calculations
- Return formatted results for agent consumption

## 📋 **Complete Agent Actions & Apex Classes**

### 1. **ABAGENT Future Pipeline Analysis**
**Purpose**: Unified analysis for Renewals, Cross-sell, and Upsell data

#### **Handler Class**: `ABAgentFuturePipeAnalysisHandler`
```apex
@InvocableMethod(
    label='ABAGENT Future Pipeline Analysis'
    description='Unified analysis for Renewals, Cross-sell, and Upsell data'
    category='Agent Analysis'
)
public static List<Response> analyzePipeline(List<Request> requests)
```

**Key Features**:
- Supports RENEWALS, CROSS_SELL, and UPSELL analysis types
- Grouping by PRODUCT, INDUSTRY, MACRO_SEGMENT, AE, COUNTRY, MANAGER, ACCOUNT
- Advanced filtering with SOQL WHERE clause support
- Per-AE normalization capabilities
- Governor-safe limits (max 200 records)
- Intelligent aggregation type detection

**Request Parameters**:
- `analysisType` (required): RENEWALS, CROSS_SELL, UPSELL
- `ouName` (optional): Organizational Unit filter
- `workLocationCountry` (optional): Country filter
- `groupBy` (optional): Field to group by (default: PRODUCT)
- `filterCriteria` (optional): SOQL WHERE clause
- `restrictInValuesCsv` (optional): Comma-separated value restrictions
- `perAENormalize` (optional): Boolean for AE normalization
- `limitN` (optional): Record limit (default: 20, max: 200)
- `aggregationType` (optional): SUM, COUNT, AVG, MAX, MIN
- `startDate`/`endDate` (optional): Date range for Renewals

#### **Service Class**: `ABAgentFuturePipeAnalysisService`
**Core Method**: `analyzePipeline()`

**Key Features**:
- **Object Mapping**: Maps analysis types to Salesforce objects
  - RENEWALS → `Agent_Renewals__c`
  - CROSS_SELL → `Agent_Cross_Sell__c`
  - UPSELL → `Agent_Upsell__c`
- **Field Mapping**: Dynamic field mapping based on analysis type
- **Aggregate Queries**: Uses SOQL aggregation to prevent heap issues
- **Governor Safety**: Enforces limits and validates inputs
- **Field Aliases**: Comprehensive field mapping with 50+ aliases

**Data Transfer Objects**:
```apex
public class PipelineRowDTO {
    public String key;
    public Integer count;
    public Decimal amount;        // Only for Renewals
    public Decimal avgAmount;     // Only for Renewals
    public Decimal maxAmount;     // Only for Renewals
    public Decimal minAmount;     // Only for Renewals
    public Integer uniqueAccounts; // Only for Cross-sell/Upsell
    public Integer uniqueProducts; // Only for Cross-sell/Upsell
}
```

### 2. **ANAGENT KPI Analysis**
**Purpose**: Sales performance KPI analysis and reporting

#### **Handler Class**: `ANAGENTKPIAnalysisHandlerV3`
```apex
@InvocableMethod(
    label='ANAGENT KPI Analysis for Sales Performance'
    description='Search for KPI records by name, email, or OU'
)
public static List<Response> analyzeKPIs(List<Request> requests)
```

**Supported Actions**:
- `Search`: Find KPI records with filtering
- `CountFieldValues`: Count unique values for specified field
- `GetDistinctFieldValues`: Get distinct values for field
- `GetSearchableFields`: Get list of searchable fields

**Request Parameters**:
- `action` (required): Search, CountFieldValues, GetDistinctFieldValues, GetSearchableFields
- `searchTerm` (optional): Name, email, or OU to search
- `OuName` (optional): Operating Unit filter
- `WorkLocationCountry` (optional): Country filter
- `PrimaryIndustry` (optional): Industry filter
- `EmpManagerName` (optional): Manager filter
- `RampStatus` (optional): Ramp status filter
- `TimeSinceOnboarding` (optional): Tenure filter
- `ValQuota` (optional): Quota value filter
- `Coverage` (optional): Coverage ratio filter
- `AcvThreshold` (optional): ACV threshold filter
- `DaysToProductivity` (optional): Days to productivity filter
- `CqCustomerMeeting` (optional): Current quarter customer meetings
- `CqPg` (optional): Current quarter pipeline generated
- `CqAcv` (optional): Current quarter ACV
- `CqCallConnect` (optional): Current quarter call connects
- `CqCcAcv` (optional): Current quarter CC ACV
- `PqCustomerMeeting` (optional): Previous quarter customer meetings
- `PqPg` (optional): Previous quarter pipeline generated
- `PqAcv` (optional): Previous quarter ACV
- `PqCallConnect` (optional): Previous quarter call connects
- `PqCcAcv` (optional): Previous quarter CC ACV
- `Aov` (optional): Average order value
- `CallAiMention` (optional): AI mentions in calls
- `sortBy` (optional): Field to sort by
- `sortOrder` (optional): ASC or DESC
- `recordLimit` (optional): Maximum records to return
- `offset` (optional): Pagination offset

**Response Structure**:
```apex
public class Response {
    public Boolean success;
    public String message;
    public List<AN_KPIRecord> kpiRecords;
    public Integer totalRecordCount;
    public List<AN_RefineByField> refineByFields;
    public AN_KPIRecord primaryMatch;
    public Integer nextOffset;
    public Boolean hasMoreRecords;
    public String fieldValueCountsJSON;
    public List<String> fieldValues;
}
```

### 3. **ANAGENT Open Pipe Analysis V3**
**Purpose**: Analyze open pipeline data from Agent_Open_Pipe__c records

#### **Handler Class**: `ANAgentOpenPipeAnalysisV3Handler`
```apex
@InvocableMethod(
    label='ANAGENT Open Pipe Analysis V3'
    description='Analyzes open pipeline data from Agent_Open_Pipe__c records'
)
public static List<Response> analyzeOpenPipe(List<Request> requests)
```

**Request Parameters**:
- `ouName` (required): Organizational Unit filter
- `workLocationCountry` (optional): Country filter
- `groupBy` (optional): STAGE, PRODUCT, INDUSTRY, MACRO_SEGMENT, AE, COUNTRY
- `filterCriteria` (optional): SOQL WHERE clause with field aliases
- `restrictInValuesCsv` (optional): Comma-separated value restrictions
- `perAENormalize` (optional): Boolean for AE normalization
- `limitN` (optional): Record limit
- `aggregationType` (optional): SUM, AVG, MAX, MIN, COUNT, MEDIAN
- `analysisType` (optional): STAGE_COUNT, PRODUCT_PERFORMANCE, AE_SCORE_ANALYSIS, DAYS_IN_STAGE, OPPORTUNITY_DETAILS

#### **Service Class**: `ANAgentOpenPipeAnalysisV3Service`
**Core Method**: `analyzeOpenPipe()`

**Key Features**:
- **OU Alias Mapping**: 50+ OU name aliases for user-friendly input
- **Field Mapping**: 100+ field aliases for flexible filtering
- **Realistic Aggregation**: Outlier detection and filtering
- **Stage Name Mapping**: Corrects common stage name mistakes
- **Governor Safety**: Comprehensive input validation

**Analysis Types**:
1. **STAGE_COUNT**: Count opportunities by stage
2. **PRODUCT_PERFORMANCE**: Analyze product performance with ACV
3. **AE_SCORE_ANALYSIS**: Analyze AE scores by grouping
4. **DAYS_IN_STAGE**: Analyze days in stage with outlier filtering
5. **OPPORTUNITY_DETAILS**: Detailed opportunity information

**Field Mapping Examples**:
```apex
// OU and Location
'ou_name' => 'OU_NAME__c',
'work_location_country' => 'WORK_LOCATION_COUNTRY__c',

// Opportunity Fields
'open_pipe_opty_stg_nm' => 'OPEN_PIPE_OPTY_STG_NM__c',
'open_pipe_prod_nm' => 'OPEN_PIPE_PROD_NM__c',
'open_pipe_opty_days_in_stage' => 'OPEN_PIPE_OPTY_DAYS_IN_STAGE__c',
'open_pipe_ae_score' => 'OPEN_PIPE_AE_SCORE__c',

// Amount Fields
'open_pipe_original_openpipe_alloc_amt' => 'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c',
'amount' => 'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c'
```

### 4. **ANAgent Search Content (Consensus or ACT)**
**Purpose**: Intelligent content search across Consensus and ACT platforms

#### **Handler Class**: `ANAgentConsensusContentSearchHandler`
```apex
@InvocableMethod(
    label='ANAgent Search Content (Consensus or ACT)'
    description='Intelligently routes content searches to Consensus or ACT'
)
public static List<ContentSearchResponse> searchContent(List<ContentSearchRequest> requests)
```

**Request Parameters**:
- `userUtterance` (required): Complete user utterance to analyze

#### **Service Class**: `ANAgentUnifiedContentSearchService`
**Core Method**: `search()`

**Key Features**:
- **Intelligent Routing**: Determines search type based on keywords
- **Unified Results**: Combines Consensus and ACT results
- **Rich Formatting**: Markdown-formatted results with links
- **Date Parsing**: Extracts date ranges from user utterances
- **Duration Extraction**: Extracts duration from titles

**Search Type Detection**:
```apex
// SME Keywords (highest priority)
'sme', 'expert', 'specialist', 'advisor', 'consultant', 'rockstar'

// Consensus Keywords
'demo', 'demo video', 'demonstration', 'consensus', 'video'

// ACT Keywords
'course', 'courses', 'curriculum', 'content', 'learning', 'training'
```

**Content Types**:
- **Consensus**: Demo videos with duration, preview links, creator info
- **ACT**: Courses, Assets, Curricula with completion data

### 5. **ANAgent Search SMEs**
**Purpose**: Search for Subject Matter Experts by product, AE, or OU

#### **Service Class**: `ANAgentSMESearchService`
**Core Method**: `searchSMEs()`

**Key Features**:
- **Multi-Object Search**: Searches across products, AEs, and OUs
- **Academy Filtering**: Filter for Academy members only
- **Contact Information**: Populates email, phone, title, department
- **Product Grouping**: Groups SMEs by product for better organization
- **ACV Ranking**: Ranks SMEs by total ACV

**Search Types**:
- `Product`: Search by product name
- `AE`: Search by AE name
- `OU`: Search by organizational unit
- `All`: Search across all fields

**SME Information Structure**:
```apex
public class SMEInfo {
    public String id;
    public String name;
    public String aeName;
    public Double aeRank;
    public String organizationalUnit;
    public Double totalACV;
    public String productL3;
    public String productL2;
    public Boolean isAcademyMember;
    public String email;
    public String phone;
    public String title;
    public String department;
}
```

## 🔧 **Technical Implementation Details**

### **Data Objects**
1. **Agent_Renewals__c**: Renewal opportunity data
2. **Agent_Cross_Sell__c**: Cross-sell opportunity data
3. **Agent_Upsell__c**: Upsell opportunity data
4. **Agent_Open_Pipe__c**: Open pipeline data
5. **Agent_Consensu__c**: Consensus demo content
6. **Course__c**: ACT course data
7. **Asset__c**: ACT asset data
8. **Curriculum__c**: ACT curriculum data
9. **AGENT_SME_ACADEMIES__c**: SME expert data

### **Key Field Mappings**
- **Employee Fields**: `emp_id__c`, `full_name__c`, `emp_email_addr__c`, `emp_mgr_nm__c`
- **Location Fields**: `ou_name__c`, `work_location_country__c`, `primary_industry__c`
- **Opportunity Fields**: `open_pipe_opty_nm__c`, `open_pipe_opty_stg_nm__c`, `open_pipe_prod_nm__c`
- **Performance Fields**: `open_pipe_ae_score__c`, `open_pipe_opty_days_in_stage__c`
- **Amount Fields**: `open_pipe_original_openpipe_alloc_amt__c`, `renewal_opty_amt__c`

### **Security & Governance**
- **Security Stripping**: All queries use `Security.stripInaccessible()`
- **Governor Limits**: Comprehensive limit enforcement
- **Input Validation**: Extensive validation for all parameters
- **SOQL Injection Prevention**: Parameterized queries and input sanitization
- **Field Access Control**: Respects field-level security

### **Performance Optimizations**
- **Aggregate Queries**: Uses SOQL aggregation to prevent heap issues
- **Query Limits**: Intelligent limit application based on analysis type
- **Caching**: Field mapping and alias caching
- **Batch Processing**: Handles large datasets efficiently

### **Error Handling**
- **Comprehensive Logging**: Detailed error logging with context
- **User-Friendly Messages**: Clear error messages for users
- **Graceful Degradation**: Fallback mechanisms for failures
- **Validation Feedback**: Detailed validation error messages

## 📊 **Business Logic**

### **Analysis Capabilities**
1. **Pipeline Analysis**: Renewals, Cross-sell, Upsell with grouping and filtering
2. **KPI Analysis**: Sales performance metrics with advanced filtering
3. **Open Pipe Analysis**: Active pipeline analysis with stage and product insights
4. **Content Search**: Intelligent search across learning and demo content
5. **Expert Identification**: Find SMEs by product, performance, or expertise

### **Data Insights**
- **Trend Analysis**: Historical performance tracking
- **Comparative Analysis**: Cross-team and cross-product comparisons
- **Performance Metrics**: AE scores, completion rates, ACV analysis
- **Content Recommendations**: Relevant learning and demo content
- **Expert Matching**: Connect users with relevant SMEs

## 🚀 **Usage Examples**

### **Future Pipeline Analysis**
```apex
// Renewals analysis by product
ABAgentFuturePipeAnalysisHandler.analyzePipeline([
    new ABAgentFuturePipeAnalysisHandler.Request(
        analysisType = 'RENEWALS',
        ouName = 'AMER ACC',
        groupBy = 'PRODUCT',
        aggregationType = 'SUM',
        limitN = 10
    )
]);
```

### **Open Pipe Analysis**
```apex
// Product performance analysis
ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe([
    new ANAgentOpenPipeAnalysisV3Handler.Request(
        ouName = 'AMER ACC',
        groupBy = 'PRODUCT',
        analysisType = 'PRODUCT_PERFORMANCE',
        limitN = 5
    )
]);
```

### **Content Search**
```apex
// Search for Data Cloud content
ANAgentConsensusContentSearchHandler.searchContent([
    new ANAgentConsensusContentSearchHandler.ContentSearchRequest(
        userUtterance = 'Show me Data Cloud demos'
    )
]);
```

## 🔍 **Field Reference**

### **Common Field Aliases**
- `ou_name` → `OU_NAME__c`
- `work_location_country` → `WORK_LOCATION_COUNTRY__c`
- `primary_industry` → `PRIMARY_INDUSTRY__c`
- `macro_segment` → `MACROSGMENT__c`
- `stage` → `OPEN_PIPE_OPTY_STG_NM__c`
- `product` → `OPEN_PIPE_PROD_NM__c`
- `days_in_stage` → `OPEN_PIPE_OPTY_DAYS_IN_STAGE__c`
- `ae_score` → `OPEN_PIPE_AE_SCORE__c`
- `amount` → `OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT__c`

### **OU Name Aliases**
- `AMER SMB` → `SMB - AMER SMB`
- `EME SMB` → `SMB - EMEA SMB`
- `PubSec` → `PubSec+.Org`
- `South Asia` → `South Asia - India`
- `NextGen` → `NextGen Platform`

This comprehensive manifest provides detailed technical information about all EBP Agent POC components, their implementation, and usage patterns.
