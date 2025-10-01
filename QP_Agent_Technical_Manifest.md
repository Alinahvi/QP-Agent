# QP Agent - Technical Apex Classes Manifest

**Version**: 1.0  
**Last Updated**: January 2025  
**Maintainer**: Ali Nahvi (Alinahvi)

---

## 🏗️ **ARCHITECTURE OVERVIEW**

The QP Agent system follows a **Handler-Service Pattern** architecture:

- **Handler Classes**: Entry points with `@InvocableMethod` annotations for agent integration
- **Service Classes**: Core business logic and data processing
- **DTO Classes**: Request/Response data transfer objects
- **Utility Classes**: Supporting functionality and helpers

---

## 📋 **HANDLER CLASSES**

### **1. ANAGENTKPIAnalysisHandlerV5**

**Purpose**: Main entry point for KPI analysis operations on `AGENT_OU_PIPELINE_V2__c` records.

**Key Functionality**:
- Validates KPI analysis requests
- Routes to `ANAGENTKPIAnalysisServiceV5` for business logic
- Handles ramp status analysis and performance metrics
- Supports grouping by country, OU, industry, or AE

**Core Method**:
```apex
@InvocableMethod(
    label='ANAGENT KPI Analysis V5'
    description='Analyzes KPIs from AGENT_OU_PIPELINE_V2__c records based on specified metrics, timeframes, and grouping criteria.'
)
public static List<Response> analyzeKPIs(List<Request> requests)
```

**Request Parameters**:
- `metricKey`: ACV, PG, CALLS, MEETINGS, AI_MENTIONS, COVERAGE
- `timeframe`: CURRENT, PREVIOUS
- `groupBy`: COUNTRY, OU, INDUSTRY, AE, GROWTH_FACTOR
- `filterCriteria`: SOQL WHERE clause filters
- `perAENormalize`: Boolean for per-AE averaging
- `limitN`: Record limit for results
- `aggregationType`: SUM, AVG, MAX, MIN, COUNT, MEDIAN

**Sample Code**:
```apex
// Example usage for ramp status analysis
Request req = new Request();
req.metricKey = 'CALLS';
req.timeframe = 'CURRENT';
req.groupBy = 'AE';
req.filterCriteria = 'ramp_status__c=\'Slow\' AND work_location_country__c=\'Brazil\'';
req.perAENormalize = true;
req.aggregationType = 'AVG';

List<Response> responses = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(new List<Request>{req});
```

---

### **2. ANAgentOpenPipeAnalysisV3Handler**

**Purpose**: Entry point for open pipeline analysis on `Agent_Open_Pipe__c` records.

**Key Functionality**:
- Analyzes sales pipeline opportunities
- Groups by stage, product, industry, macro segment, AE, or country
- Provides field suggestions and filter validation
- Supports multiple analysis types

**Core Method**:
```apex
@InvocableMethod(
    label='ANAGENT Open Pipe Analysis V3'
    description='Analyzes open pipeline data from Agent_Open_Pipe__c records based on specified OU, grouping criteria, and filters.'
)
public static List<Response> analyzeOpenPipe(List<Request> requests)
```

**Request Parameters**:
- `ouName`: Required OU filter
- `workLocationCountry`: Optional country filter
- `groupBy`: STAGE, PRODUCT, INDUSTRY, MACRO_SEGMENT, AE, COUNTRY
- `analysisType`: STAGE_COUNT, PRODUCT_PERFORMANCE, AE_SCORE_ANALYSIS, DAYS_IN_STAGE, OPPORTUNITY_DETAILS
- `filterCriteria`: SOQL WHERE clause filters
- `aggregationType`: SUM, AVG, MAX, MIN, COUNT, MEDIAN

**Sample Code**:
```apex
// Example usage for stage analysis
Request req = new Request();
req.ouName = 'AMER ICE';
req.groupBy = 'STAGE';
req.analysisType = 'STAGE_COUNT';
req.aggregationType = 'COUNT';

List<Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(new List<Request>{req});
```

---

### **3. ANAgentContentSearchHandlerV2**

**Purpose**: Entry point for learning content search across multiple objects.

**Key Functionality**:
- Searches Course__c, Asset__c, and Curriculum__c objects
- Provides unified content results with learner statistics
- Supports content type filtering
- Returns completion rates and learner counts

**Core Method**:
```apex
@InvocableMethod(
    label='ANAgent Search Content V2'
    description='Searches for content across Course, Asset, and Curriculum objects. Returns unified results with learner statistics.'
)
public static List<ContentSearchResponse> searchContent(List<ContentSearchRequest> requests)
```

**Request Parameters**:
- `searchTerm`: Required search term
- `contentType`: Optional filter (Course, Asset, Curriculum)

**Sample Code**:
```apex
// Example usage for course search
ContentSearchRequest req = new ContentSearchRequest();
req.searchTerm = 'Data Cloud';
req.contentType = 'Course';

List<ContentSearchResponse> responses = ANAgentContentSearchHandlerV2.searchContent(new List<ContentSearchRequest>{req});
```

---

### **4. ANAgentConsensusContentSearchHandler**

**Purpose**: Entry point for consensus-based content search and intelligent routing.

**Key Functionality**:
- Intelligently routes between different content search methods
- Provides consensus-based recommendations
- Handles ACT (Accelerated Customer Training) content
- Supports unified learning content discovery

**Core Method**:
```apex
@InvocableMethod(
    label='ANAgent Search Content (Consensus or ACT)'
    description='Intelligently routes content search requests and provides consensus-based recommendations.'
)
public static List<Response> searchConsensusContent(List<Request> requests)
```

---

### **5. ANAgentSMESearchHandler**

**Purpose**: Entry point for Subject Matter Expert identification and search.

**Key Functionality**:
- Searches `AGENT_SME_ACADEMIES__c` records
- Identifies experts by skills and expertise areas
- Provides contact information and availability
- Supports collaboration facilitation

**Core Method**:
```apex
@InvocableMethod(
    label='ANAgent Search SMEs'
    description='Searches for Subject Matter Experts based on skills, expertise, and availability.'
)
public static List<Response> searchSMEs(List<Request> requests)
```

---

### **6. ANAgentAPMNominationHandlerV2**

**Purpose**: Entry point for APM nomination creation and management.

**Key Functionality**:
- Creates nominations in `apm_nomination_v2__c`
- Integrates with external APM APIs
- Handles duplicate detection and validation
- Provides status tracking and progress monitoring

**Core Method**:
```apex
@InvocableMethod(
    label='AN Agent: Create APM Nomination V2'
    description='Creates APM nominations and integrates with external APM system.'
)
public static List<Response> createAPMNomination(List<Request> requests)
```

---

### **7. ABAgentUpsellAnalysisHandler**

**Purpose**: Entry point for upsell opportunity analysis.

**Key Functionality**:
- Analyzes `Agent_Upsell__c` records
- Provides upsell pattern analysis
- Supports grouping by product, industry, macro segment, AE, country, manager, or account
- Handles expansion opportunity identification

**Core Method**:
```apex
@InvocableMethod(
    label='ABAGENT Upsell Analysis'
    description='Analyzes upsell data from Agent_Upsell__c records based on specified OU, grouping criteria, and filters.'
)
public static List<Response> analyzeUpsell(List<Request> requests)
```

---

### **8. ABAgentCrossSellAnalysisHandler**

**Purpose**: Entry point for cross-sell opportunity analysis.

**Key Functionality**:
- Analyzes `Agent_Cross_Sell__c` records
- Provides next best product recommendations
- Supports cross-sell pattern identification
- Handles revenue opportunity analysis

**Core Method**:
```apex
@InvocableMethod(
    label='ABAGENT Cross-Sell Analysis'
    description='Analyzes cross-sell data from Agent_Cross_Sell__c records based on specified OU, grouping criteria, and filters.'
)
public static List<Response> analyzeCrossSell(List<Request> requests)
```

---

### **9. ABAgentRenewalsAnalysisHandler**

**Purpose**: Entry point for renewal opportunity analysis.

**Key Functionality**:
- Analyzes `Agent_Renewals__c` records
- Provides contract renewal tracking
- Supports revenue retention analysis
- Handles renewal risk assessment

**Core Method**:
```apex
@InvocableMethod(
    label='ABAGENT Renewals Analysis'
    description='Analyzes renewal data from Agent_Renewals__c records based on specified OU, grouping criteria, and filters.'
)
public static List<Response> analyzeRenewals(List<Request> requests)
```

---

## 🔧 **SERVICE CLASSES**

### **1. ANAGENTKPIAnalysisServiceV5**

**Purpose**: Core business logic for KPI analysis operations.

**Key Functionality**:
- Computes KPIs across AE rosters
- Handles grouping, filtering, and aggregation
- Provides ramp status analysis
- Builds comprehensive analysis messages

**Core Methods**:
```apex
public static String analyzeKPIs(String metricKey, String timeframe, String groupBy, 
                                String filterCriteria, String restrictInValuesCsv, 
                                Boolean perAENormalize, Integer limitN, String aggregationType)

public static String parseFilterCriteria(String filterCriteria)

public static String buildAnalysisMessage(Map<String, Object> analysisData)
```

**Sample Code**:
```apex
// Example KPI analysis
String result = ANAGENTKPIAnalysisServiceV5.analyzeKPIs(
    'CALLS',           // metricKey
    'CURRENT',         // timeframe
    'COUNTRY',         // groupBy
    'country=\'US\'',  // filterCriteria
    'US,Brazil',       // restrictInValuesCsv
    true,              // perAENormalize
    10,                // limitN
    'AVG'              // aggregationType
);
```

---

### **2. ANAgentContentSearchServiceV2**

**Purpose**: Core business logic for content search operations.

**Key Functionality**:
- Searches across multiple content objects
- Provides unified content results
- Calculates learner statistics
- Handles content type filtering

**Core Methods**:
```apex
public static ContentSearchResult search(String searchTerm, String contentType)

public static List<UnifiedContent> searchObject(String objectName, String searchTerm)

public static String getObjectNameForType(String contentType)
```

**Sample Code**:
```apex
// Example content search
ContentSearchResult result = ANAgentContentSearchServiceV2.search('Data Cloud', 'Course');

if (result.success) {
    for (UnifiedContent content : result.records) {
        System.debug('Found: ' + content.name + ' - ' + content.type);
        System.debug('Learners: ' + content.learnerCount + ', Completions: ' + content.completionCount);
    }
}
```

---

### **3. ANAgentOpenPipeAnalysisV3Service**

**Purpose**: Core business logic for open pipeline analysis.

**Key Functionality**:
- Analyzes pipeline opportunities
- Handles stage, product, and AE analysis
- Provides field suggestions and validation
- Builds comprehensive pipeline insights

**Core Methods**:
```apex
public static String analyzeOpenPipe(String ouName, String workLocationCountry, 
                                   String groupBy, String filterCriteria, 
                                   String restrictInValuesCsv, Boolean perAENormalize, 
                                   Integer limitN, String aggregationType, String analysisType)

public static String getFieldSuggestions(String filterCriteria)

public static String validateFilterCriteria(String filterCriteria)
```

---

## 🛠️ **UTILITY CLASSES**

### **1. ANAgentDateUtils**

**Purpose**: Date manipulation and calculation utilities.

**Key Functionality**:
- Quarter calculations
- Date range processing
- Time period analysis
- Business day calculations

**Core Methods**:
```apex
public static String getCurrentQuarter()
public static String getPreviousQuarter()
public static Date getQuarterStartDate(String quarter)
public static Date getQuarterEndDate(String quarter)
```

### **2. ANAgentEmailService**

**Purpose**: Email functionality and notifications.

**Key Functionality**:
- Sends analysis results via email
- Handles email templates
- Manages recipient lists
- Provides delivery confirmation

**Core Methods**:
```apex
public static void sendAnalysisEmail(String recipient, String subject, String body)
public static String buildEmailTemplate(String analysisType, String results)
```

### **3. ANAgentCSVService**

**Purpose**: CSV generation and data export functionality.

**Key Functionality**:
- Generates CSV files from analysis results
- Handles data formatting and export
- Manages file downloads
- Provides data aggregation

**Core Methods**:
```apex
public static String generateCSV(List<Object> data, List<String> headers)
public static String buildDownloadURL(String csvContent, String fileName)
```

---

## 📊 **DATA TRANSFER OBJECTS (DTOs)**

### **1. Request Classes**

All handlers include standardized request classes with:
- `@InvocableVariable` annotations
- Validation attributes
- Description and label metadata
- Required/optional field specifications

### **2. Response Classes**

All handlers include standardized response classes with:
- `@InvocableVariable` annotations
- Success/failure indicators
- Message fields for agent consumption
- Error handling capabilities

### **3. UnifiedContent Class**

**Purpose**: Unified content representation across different object types.

**Properties**:
```apex
public String id { get; set; }
public String name { get; set; }
public String description { get; set; }
public String type { get; set; }
public String status { get; set; }
public Datetime createdDate { get; set; }
public Datetime lastModifiedDate { get; set; }
public Integer learnerCount { get; set; }
public Integer completionCount { get; set; }
public Double completionRate { get; set; }
```

---

## 🔒 **SECURITY & COMPLIANCE**

### **Field-Level Security**
All classes implement `with sharing` and use `Security.stripInaccessible()`:
```apex
records = Security.stripInaccessible(AccessType.READABLE, records).getRecords();
```

### **Input Validation**
Comprehensive validation for all inputs:
```apex
private static Boolean isValidMetric(String metric) {
    Set<String> validMetrics = new Set<String>{
        'ACV', 'PG', 'CALLS', 'MEETINGS', 'COVERAGE', 'GROWTH_FACTOR'
    };
    return validMetrics.contains(metric);
}
```

### **Error Handling**
Consistent error handling across all classes:
```apex
try {
    // Business logic
} catch (Exception e) {
    res.message = 'An error occurred: ' + e.getMessage();
    System.debug(LoggingLevel.ERROR, 'Handler Error: ' + e.getStackTraceString());
}
```

---

## 🚀 **PERFORMANCE OPTIMIZATION**

### **Query Optimization**
- Efficient SOQL queries with proper indexing
- Governor limit awareness
- Batch processing for large datasets
- Proper field selection

### **Caching Strategy**
- Static variables for frequently accessed data
- Session-based caching for user context
- Result caching for repeated queries

### **Memory Management**
- Proper object instantiation
- Garbage collection optimization
- Efficient data structures

---

## 📈 **MONITORING & DEBUGGING**

### **Logging**
Comprehensive logging throughout all classes:
```apex
System.debug(LoggingLevel.ERROR, 'Handler Error: ' + e.getStackTraceString());
System.debug('Processing request: ' + JSON.serialize(request));
```

### **Performance Metrics**
- Query execution time tracking
- Memory usage monitoring
- Governor limit tracking
- Error rate monitoring

---

## 🔄 **INTEGRATION PATTERNS**

### **Handler-Service Pattern**
```apex
// Handler validates and delegates
public static List<Response> processRequest(List<Request> requests) {
    // Validation
    // Service call
    res.message = ServiceClass.processBusinessLogic(parameters);
    // Response formatting
}
```

### **Factory Pattern**
```apex
// Factory for handler selection
public static IHandler getHandler(String actionType) {
    switch on actionType {
        when 'KPI_ANALYSIS' return new KPIHandler();
        when 'CONTENT_SEARCH' return new ContentHandler();
    }
}
```

### **Builder Pattern**
```apex
// Builder for complex queries
public class QueryBuilder {
    public QueryBuilder addFilter(String field, String value) { /* */ }
    public QueryBuilder addGroupBy(String field) { /* */ }
    public String build() { /* */ }
}
```

---

**This technical manifest provides comprehensive documentation of all Apex classes in the QP Agent system, including their purposes, core functionalities, sample code, and integration patterns.**
