# KPI V2 Service - Simple Flow Diagram

## 🎯 **Complete Request Flow**

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              🚀 AGENT REQUEST                                      │
│                                                                                     │
│  "Compare ACV between US and Brazil territories"                                   │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    Agent Action Configuration                               │   │
│  │  • Reference Action: ANAgentKPIAnalysisV2Handler.run                      │   │
│  │  • Assigned to Active Agent: ✅                                           │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              📥 HANDLER LAYER                                      │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │              ANAgentKPIAnalysisV2Handler                                   │   │
│  │                                                                             │   │
│  │  @InvocableMethod                                                          │   │
│  │  run(List<ANAgentKPIAnalysisV2Request> requests)                          │   │
│  │                                                                             │   │
│  │  ✅ Validates input                                                        │   │
│  │  ✅ Calls service for each request                                         │   │
│  │  ✅ Handles errors gracefully                                              │   │
│  │  ✅ Returns List<ANAgentKPIAnalysisV2Response>                             │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              🔄 SERVICE ADAPTER                                    │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │              ANAgentKPIAnalysisV2Service                                   │   │
│  │                                                                             │   │
│  │  📥 analyzeTopLevel(ANAgentKPIAnalysisV2Request)                          │   │
│  │     ├─ 🔄 Maps: Top-level DTO → Inner DTO                                 │   │
│  │     ├─ 🚀 Calls: analyze(Request)                                         │   │
│  │     └─ 🔄 Maps: Inner Response → Top-level Response                       │   │
│  │                                                                             │   │
│  │  🧠 analyze(Request) - Main Business Logic                                │   │
│  │     ├─ 📊 Determines processing mode                                      │   │
│  │     ├─ ⚙️ Builds aggregation specification                                │   │
│  │     ├─ 🔍 Executes queries & aggregation                                  │   │
│  │     └─ 💡 Generates insights & response                                   │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              ⚙️ AGGREGATION ENGINE                                │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentAggregationSpec                                  │   │
│  │                                                                             │   │
│  │  🏭 Factory Method: fromRequest()                                          │   │
│  │  • metricKey: 'ACV'                                                        │   │
│  │  • timeframe: 'CURRENT'                                                    │   │
│  │  • groupByDim: 'COUNTRY'                                                   │   │
│  │  • filter: 'country IN ("US","Brazil")'                                    │   │
│  │  • restrictInValues: ['US', 'Brazil']                                      │   │
│  │  • perAENormalize: false                                                   │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                    │                                              │
│                                    ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentSOQLBuilder                                      │   │
│  │                                                                             │   │
│  🔧 buildQuery(ANAgentAggregationSpec)                                        │   │
│  • SELECT: cq_acv__c, work_location_country__c                               │   │
│  • FROM: AGENT_OU_PIPELINE_V2__c                                             │   │
│  • WHERE: work_location_country__c IN ('US','Brazil')                        │   │
│  • GROUP BY: work_location_country__c                                         │   │
│  • ORDER BY: cq_acv__c DESC                                                   │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                    │                                              │
│                                    ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentAggregationRunner                                │   │
│  │                                                                             │   │
│  🚀 executeQuery(String soql, ANAgentAggregationSpec)                         │   │
│  • Executes SOQL query                                                        │   │
│  • Processes results                                                           │   │
│  • Calculates totals and percentages                                          │   │
│  • Generates GroupRow objects                                                 │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              🛠️ SUPPORTING SERVICES                                │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentFilterParser                                     │   │
│  │                                                                             │   │
│  🔍 parseFilter("country IN ('US','Brazil')")                                 │   │
│  → "work_location_country__c IN ('US','Brazil')"                              │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                    │                                              │
│                                    ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentMetricRegistry                                   │   │
│  │                                                                             │   │
│  📊 getMetricFields('ACV')                                                    │   │
│  → ['cq_acv__c', 'SUM', 'Currency']                                           │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                    │                                              │
│                                    ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentDimensionRegistry                                │   │
│  │                                                                             │   │
│  🎯 getDimensionFields('COUNTRY')                                             │   │
│  → ['work_location_country__c', 'String']                                      │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                    │                                              │
│                                    ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentStats                                            │   │
│  │                                                                             │   │
│  📈 calculatePercentages(List<GroupRow>)                                      │   │
│  → US: 93.36%, Brazil: 6.64%                                                  │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
                              📊 DATA LAYER                                          │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    AGENT_OU_PIPELINE_V2__c                                 │   │
│  │                                                                             │   │
│  📋 Sample Records:                                                            │   │
│  • US: 336 people, $25,090,104.32 ACV                                         │   │
│  • Brazil: 25 people, $1,784,680.39 ACV                                       │   │
│  • Total: 361 people, $26,874,784.71 ACV                                      │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              📤 RESPONSE FLOW                                      │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentKPIAnalysisV2Response                            │   │
│  │                                                                             │   │
│  📊 Response Data:                                                             │   │
│  • success: true                                                               │   │
│  • metricKey: 'ACV'                                                            │   │
│  • timeframe: 'CURRENT'                                                        │   │
│  • groupByDim: 'COUNTRY'                                                       │   │
│  • processingMode: 'AGGREGATE'                                                 │   │
│  • totalGroups: 2                                                              │   │
│  • insights: "SUM ACV (CURRENT) — US: 25090104.32, Brazil: 1784680.39 (Diff: 1305.86%)" │
│  • groups: [US: $25M (93.36%), Brazil: $1.8M (6.64%)]                         │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                    │                                              │
│                                    ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │              ANAgentKPIAnalysisV2Handler                                   │   │
│  │                                                                             │   │
│  🔄 Collects all responses                                                    │   │
│  📦 Returns: List<ANAgentKPIAnalysisV2Response>                               │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                    │                                              │
│                                    ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                              🎯 AGENT UI                                     │   │
│  │                                                                             │   │
│  💬 "US territories generated $25M in ACV (93.36% of total), while Brazil   │   │
│     generated $1.8M (6.64%). The US outperformed Brazil by 1,305.86%."       │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

## 🔄 **Key Class Interactions**

### **Handler ↔ Service Communication:**
```
Handler.run() 
    ↓
    Calls: Service.analyzeTopLevel()
    ↓
    Returns: ANAgentKPIAnalysisV2Response
```

### **Service ↔ Aggregation Engine:**
```
Service.analyze()
    ↓
    Creates: ANAgentAggregationSpec.fromRequest()
    ↓
    Calls: ANAgentSOQLBuilder.buildQuery()
    ↓
    Calls: ANAgentAggregationRunner.executeQuery()
    ↓
    Returns: Response with insights
```

### **Aggregation Engine ↔ Supporting Services:**
```
ANAgentAggregationRunner
    ↓
    Uses: ANAgentFilterParser.parseFilter()
    Uses: ANAgentMetricRegistry.getMetricFields()
    Uses: ANAgentDimensionRegistry.getDimensionFields()
    Uses: ANAgentStats.calculatePercentages()
    Uses: ANAgentLog.log()
    Uses: ANAgentErrors.handleError()
```

## 🎯 **Why This Architecture Works**

1. **🔄 Clean Separation**: Each class has a single responsibility
2. **🔌 Loose Coupling**: Classes communicate through well-defined interfaces
3. **📈 Scalability**: Easy to add new metrics, dimensions, and processing modes
4. **🧪 Testability**: Each component can be tested independently
5. **🤖 Agent-Friendly**: Top-level DTOs avoid reflection issues
6. **🚀 Performance**: Efficient query building and execution
7. **🛡️ Error Handling**: Comprehensive error handling at each layer

## 💡 **Key Benefits for Your Agent**

- **✅ No More "Invalid Config"**: Clean, global schema
- **✅ Rich KPI Analysis**: Multiple metrics, dimensions, and filters
- **✅ Human-Readable Insights**: Natural language responses
- **✅ Flexible Processing**: Handles small and large datasets
- **✅ Easy Extension**: Add new capabilities without breaking existing code

This architecture ensures your Agent can successfully execute complex KPI analysis while maintaining clean, maintainable code! 🚀 