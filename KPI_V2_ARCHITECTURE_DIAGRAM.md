# KPI V2 Service Architecture & Communication Flow

## 🏗️ High-Level Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              AGENT BUILDER UI                                      │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    Agent Action Configuration                               │   │
│  │  • Reference Action: ANAgentKPIAnalysisV2Handler.run                      │   │
│  │  • Assigned to Active Agent: ✅                                           │   │
│  │  • API Name: Analyze_KPIs_V2                                              │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              INVOCABLE HANDLER                                     │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │              ANAgentKPIAnalysisV2Handler                                   │   │
│  │                                                                             │   │
│  │  @InvocableMethod                                                          │   │
│  │  global static List<ANAgentKPIAnalysisV2Response> run(                     │   │
│  │      List<ANAgentKPIAnalysisV2Request> requests                            │   │
│  │  )                                                                         │   │
│  │                                                                             │   │
│  │  • Validates input requests                                                │   │
│  │  • Calls service.analyzeTopLevel() for each request                       │   │
│  │  • Handles errors and creates error responses                             │   │
│  │  • Returns List<ANAgentKPIAnalysisV2Response>                             │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              SERVICE ADAPTER                                      │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │              ANAgentKPIAnalysisV2Service                                   │   │
│  │                                                                             │
│  │  • analyzeTopLevel(ANAgentKPIAnalysisV2Request)                           │   │
│  │    ┌─ Maps top-level DTO → inner DTO                                       │   │
│  │    ├─ Calls analyze(Request)                                               │   │
│  │    └─ Maps inner Response → top-level Response                             │   │
│  │                                                                             │
│  │  • analyze(Request) - Main business logic                                  │   │
│  │    ┌─ Determines processing mode (SYNC/ASYNC/BATCH)                       │   │
│  │    ├─ Builds aggregation specification                                    │   │
│  │    ├─ Executes queries and aggregation                                    │   │
│  │    └─ Generates insights and responses                                    │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              AGGREGATION ENGINE                                   │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentAggregationSpec                                  │   │
│  │                                                                             │
│  │  • fromRequest() - Factory method                                          │   │
│  │  • metricKey, timeframe, groupByDim, filter, limitN                       │   │
│  │  • restrictInValues, perAENormalize                                       │   │
│  │  • Validates and builds aggregation configuration                          │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                    │                                              │
│                                    ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentSOQLBuilder                                      │   │
│  │                                                                             │
│  • buildQuery(ANAgentAggregationSpec)                                        │   │
│  • Parses filter DSL into SOQL WHERE clause                                  │   │
│  • Builds SELECT, FROM, WHERE, GROUP BY, ORDER BY, LIMIT                     │   │
│  • Handles metric-specific field selection                                   │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                    │                                              │
│                                    ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentAggregationRunner                                │   │
│  │                                                                             │
│  • executeQuery(String soql, ANAgentAggregationSpec)                         │   │
│  • Processes query results and calculates aggregations                        │   │
│  • Handles per-AE normalization                                              │   │
│  • Calculates percentages and statistics                                     │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                    │                                              │
│                                    ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentAggregationJob                                  │   │
│  │                                                                             │
│  • executeBatch(ANAgentAggregationSpec)                                      │   │
│  • Handles large datasets that exceed governor limits                         │   │
│  • Processes data in chunks                                                   │   │
│  • Returns batch job ID for tracking                                         │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              SUPPORTING SERVICES                                  │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentFilterParser                                     │   │
│  │                                                                             │
│  • parseFilter(String filterDSL)                                             │   │
│  • Converts human-readable filters to SOQL                                   │   │
│  • Examples: "country IN ('US','Brazil')" → "country__c IN ('US','Brazil')"  │   │
│  • Handles complex conditions and operators                                  │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                    │                                              │
│                                    ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentMetricRegistry                                   │   │
│  │                                                                             │
│  • getMetricFields(String metricKey)                                         │   │
│  • Defines available metrics: ACV, PG, CALLS, MEETINGS, AI_MENTIONS, COVERAGE│   │
│  • Maps metrics to database fields and aggregation functions                 │   │
│  • Provides metric-specific validation rules                                 │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                    │                                              │
│                                    ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentDimensionRegistry                                │   │
│  │                                                                             │
│  • getDimensionFields(String dimension)                                      │   │
│  • Defines grouping dimensions: COUNTRY, OU, INDUSTRY, AE, MANAGER           │   │
│  • Maps dimensions to database fields                                        │   │
│  • Provides dimension-specific validation                                     │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                    │                                              │
│                                    ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentStats                                            │   │
│  │                                                                             │
│  • calculatePercentages(List<GroupRow>)                                      │   │
│  • calculateAverages(List<GroupRow>)                                         │   │
│  • Statistical calculations and formatting                                    │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                    │                                              │
│                                    ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentErrors                                           │   │
│  │                                                                             │
│  • handleError(Exception e, String context)                                  │   │
│  • Standardized error handling and logging                                    │   │
│  • Creates user-friendly error messages                                       │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                    │                                              │
│                                    ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentLog                                              │   │
│  │                                                                             │
│  • log(String message, String level)                                         │   │
│  • Structured logging for debugging and monitoring                            │   │
│  • Performance tracking and audit trails                                      │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              DATA LAYER                                          │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    AGENT_OU_PIPELINE_V2__c                                 │   │
│  │                                                                             │
│  • Main data object for KPI analysis                                         │   │
│  • Contains: emp_id__c, full_name__c, ou_name__c, primary_industry__c        │   │
│  • Metrics: cq_pg__c, cq_acv__c, cq_customer_meeting__c, cq_call_connect__c │   │
│  • Pipeline: open_pipe_opty_nm_1__c through open_pipe_opty_nm_5__c           │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

## 🔄 Detailed Communication Flow

### **1. Agent Action → Handler**
```
Agent Action (Analyze_KPIs_V2)
    ↓
Calls: ANAgentKPIAnalysisV2Handler.run()
    ↓
Input: List<ANAgentKPIAnalysisV2Request>
    ↓
Output: List<ANAgentKPIAnalysisV2Response>
```

### **2. Handler → Service Adapter**
```
ANAgentKPIAnalysisV2Handler.run()
    ↓
For each request:
    ↓
Calls: ANAgentKPIAnalysisV2Service.analyzeTopLevel()
    ↓
Maps: ANAgentKPIAnalysisV2Request → ANAgentKPIAnalysisV2Service.Request
```

### **3. Service Adapter → Core Logic**
```
ANAgentKPIAnalysisV2Service.analyzeTopLevel()
    ↓
Calls: ANAgentKPIAnalysisV2Service.analyze()
    ↓
Maps: ANAgentKPIAnalysisV2Service.Response → ANAgentKPIAnalysisV2Response
```

### **4. Core Logic → Aggregation Engine**
```
ANAgentKPIAnalysisV2Service.analyze()
    ↓
1. Determines processing mode (SYNC/ASYNC/BATCH)
    ↓
2. Creates: ANAgentAggregationSpec.fromRequest()
    ↓
3. Builds SOQL: ANAgentSOQLBuilder.buildQuery()
    ↓
4. Executes: ANAgentAggregationRunner.executeQuery()
    ↓
5. Generates insights and response
```

### **5. Aggregation Engine → Supporting Services**
```
ANAgentAggregationRunner.executeQuery()
    ↓
Uses: ANAgentFilterParser.parseFilter() for WHERE clause
    ↓
Uses: ANAgentMetricRegistry.getMetricFields() for SELECT fields
    ↓
Uses: ANAgentDimensionRegistry.getDimensionFields() for GROUP BY
    ↓
Uses: ANAgentStats.calculatePercentages() for insights
    ↓
Uses: ANAgentLog.log() for debugging
    ↓
Uses: ANAgentErrors.handleError() for error handling
```

## 📊 Data Flow Example

### **Request Flow:**
```
Agent: "Compare ACV between US and Brazil territories"
    ↓
Agent Action: Creates ANAgentKPIAnalysisV2Request
    ↓
Handler: Validates and calls service
    ↓
Service: Maps to inner Request object
    ↓
Aggregation: Builds spec with metricKey='ACV', groupByDim='COUNTRY'
    ↓
SOQL Builder: Creates query with filter for US/Brazil
    ↓
Runner: Executes query and calculates totals
    ↓
Stats: Calculates percentages and insights
    ↓
Response: Returns structured data with insights
```

### **Response Flow:**
```
ANAgentKPIAnalysisV2Service.Response (inner)
    ↓
Maps to ANAgentKPIAnalysisV2Response (top-level)
    ↓
Handler: Collects all responses
    ↓
Agent: Receives List<ANAgentKPIAnalysisV2Response>
    ↓
UI: Displays insights like "US: $25M (93.36%), Brazil: $1.8M (6.64%)"
```

## 🔧 Key Design Patterns

### **1. Adapter Pattern**
- **Top-level DTOs**: Agent-friendly, simple schema
- **Inner DTOs**: Rich functionality, complex logic
- **Adapter method**: `analyzeTopLevel()` bridges the gap

### **2. Builder Pattern**
- **ANAgentAggregationSpec**: Builds configuration from request
- **ANAgentSOQLBuilder**: Constructs dynamic SOQL queries
- **ANAgentFilterParser**: Parses human-readable filters

### **3. Registry Pattern**
- **ANAgentMetricRegistry**: Centralized metric definitions
- **ANAgentDimensionRegistry**: Centralized dimension definitions
- **Easy to extend**: Add new metrics/dimensions in one place

### **4. Strategy Pattern**
- **Processing modes**: SYNC, AGGREGATE, BATCH
- **Different execution strategies** based on data size and complexity
- **Fallback mechanisms** for governor limit handling

## 🎯 Benefits of This Architecture

1. **✅ Agent-Friendly**: Top-level DTOs avoid reflection issues
2. **✅ Extensible**: Easy to add new metrics and dimensions
3. **✅ Maintainable**: Clear separation of concerns
4. **✅ Testable**: Each component can be tested independently
5. **✅ Scalable**: Handles both small and large datasets
6. **✅ Error-Resilient**: Comprehensive error handling and logging

This architecture ensures that your Agent can successfully execute KPI analysis while maintaining clean, maintainable code! 🚀 