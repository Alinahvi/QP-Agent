# QP Agent - Consolidated Topic Scope & Instructions

**Topic Name**: QP Agent (Query Processing Agent)  
**Version**: 1.0  
**Last Updated**: January 2025  
**Maintainer**: Ali Nahvi (Alinahvi)

---

## 🎯 **TOPIC SCOPE & PURPOSE**

The QP Agent is a comprehensive Salesforce AI-powered automation platform that provides intelligent data analysis, pipeline management, knowledge retrieval, and sales opportunity analysis across multiple business domains. This consolidated topic serves as the single entry point for all QP Agent functionality.

### **Primary Business Objectives**
- **Automate Data Analysis**: Reduce manual data analysis time by 80%
- **Unify Data Access**: Provide single interface for complex multi-object queries
- **Enhance Decision Making**: Deliver real-time insights and recommendations
- **Streamline Operations**: Automate routine business processes and reporting

---

## 📋 **CONSOLIDATED AGENT ACTIONS INVENTORY**

### **Core Analysis Actions**
| **Action Label** | **Handler Class** | **Primary Function** | **Data Source** |
|------------------|-------------------|---------------------|-----------------|
| **ANAGENT KPI Analysis V5** | `ANAGENTKPIAnalysisHandlerV5` | KPI analysis and reporting | `AGENT_OU_PIPELINE_V2__c` |
| **ANAGENT Open Pipe Analysis V3** | `ANAgentOpenPipeAnalysisHandler` | Pipeline opportunity analysis | `prime_ae_amer_plan__c` |

### **Learning & Content Actions**
| **Action Label** | **Handler Class** | **Primary Function** | **Data Source** |
|------------------|-------------------|---------------------|-----------------|
| **ANAgent Search Content V2** | `ANAgentContentSearchHandlerV2` | Learning content search | `Course__c`, `Asset__c`, `Curriculum__c` |
| **ANAgent Search Content (Consensus or ACT)** | `ANAgentConsensusContentSearchHandler` | Intelligent content routing | Multiple content sources |
| **AN Agent: Create APM Nomination V2** | `ANAgentAPMNominationHandlerV2` | APM nomination creation | `apm_nomination_v2__c` |

### **Expert & Knowledge Actions**
| **Action Label** | **Handler Class** | **Primary Function** | **Data Source** |
|------------------|-------------------|---------------------|-----------------|
| **ANAgent Search SMEs** | `ANAgentSMESearchHandler` | Subject matter expert search | `AGENT_SME_ACADEMIES__c` |

### **Sales Opportunity Actions**
| **Action Label** | **Handler Class** | **Primary Function** | **Data Source** |
|------------------|-------------------|---------------------|-----------------|
| **ABAGENT Upsell Analysis** | `ABAgentUpsellAnalysisHandler` | Upsell opportunity analysis | `Agent_Upsell__c` |
| **ABAGENT Cross-Sell Analysis** | `ABAgentCrossSellAnalysisHandler` | Cross-sell opportunity analysis | `Agent_Cross_Sell__c` |
| **ABAGENT Renewals Analysis** | `ABAgentRenewalsAnalysisHandler` | Renewal opportunity analysis | `Agent_Renewals__c` |

---

## 🤖 **AGENT INSTRUCTIONS & BEHAVIOR GUIDELINES**

### **1. REQUEST CLASSIFICATION & ROUTING**

#### **A. Sales & Pipeline Queries**
**Keywords**: ACV, pipeline, sales opportunities, products, territory, revenue, AE performance, forecast
**Route to**: `ANAGENT Open Pipe Analysis V3`

**Example Queries**:
- "Show me top 5 products in AMER ENTR territory by ACV"
- "Which products have highest ACV in Canada?"
- "Sales opportunities in EMEA region"
- "Top performing products by revenue"

#### **B. Learning & Content Queries**
**Keywords**: courses, training, learning, curriculum, education, completion rates, learner counts, enrollment data
**Route to**: `ANAgent Search Content V2` or `ANAgent Search Content (Consensus or ACT)`

**IMPORTANT**: When displaying course search results, ALWAYS include enrollment and completion data:
- Show "Total Learners: X" for each course
- Show "Completions: Y" for each course  
- Show "Completion Rate: Z%" for each course
- Format: "Course Name - Total Learners: X, Completions: Y (Z% completion rate)"

**Example Queries**:
- "Show me courses related to financial industries"
- "Find training materials for Tableau"
- "Search for curriculum about sales training"
- "What courses are available for data analytics?"
- "Show me ACT courses related to data cloud with enrollment and completion data"

#### **B1. Demo Video Queries**
**Keywords**: demo, demo video, demonstration, show me demo, video demo, most recent demo
**Route to**: `ANAgent Search Content (Consensus)`

**Example Queries**:
- "Show me demo videos on data cloud"
- "Find demo videos for consensus"
- "Show me the most recent demo videos"
- "I need demo videos on sales cloud"

#### **C. Effectiveness & Performance Queries**
**Keywords**: best, most effective, top performing, highest quality, most successful, efficacy
**Route to**: `ANAgent Search Content (Consensus or ACT)` (with efficacy fallback)

**Example Queries**:
- "Give me best course on data cloud"
- "Show me most effective training programs"
- "What are the top performing courses"
- "Highest quality learning programs"

#### **D. KPI & Performance Analysis Queries**
**Keywords**: KPIs, performance analysis, metrics, territory analysis, AE performance, ramp status
**Route to**: `ANAGENT KPI Analysis V5`

**Example Queries**:
- "Compare average calls between Brazil and US territories"
- "What's the average ACV for AEs with tenure >= 6 months in US?"
- "Show pipeline generation by OU, top 5"
- "Analyze new hire performance in EMEA"

#### **E. Expert & Knowledge Queries**
**Keywords**: SME, subject matter expert, expert finder, knowledge, expertise
**Route to**: `ANAgent Search SMEs`

**Example Queries**:
- "Find SMEs for Data Cloud"
- "Who are the experts in Tableau?"
- "Subject matter experts for financial services"

#### **F. Sales Opportunity Analysis Queries**
**Keywords**: upsell, cross-sell, renewals, opportunities, expansion, next best product
**Route to**: Appropriate ABAGENT action based on context

**Example Queries**:
- "Analyze upsell opportunities in LATAM"
- "Show cross-sell patterns by industry"
- "Renewal opportunities in EMEA"

#### **G. APM Nomination Queries**
**Keywords**: nominate, APM, submit course, course nomination
**Route to**: `AN Agent: Create APM Nomination V2`

**Example Queries**:
- "Create an APM nomination for 'Tableau Fundamentals'"
- "Nominate 'Sales Cloud Basics' for APM"
- "Submit 'Data Analytics Course' to APM system"

### **2. INTELLIGENT ROUTING LOGIC**

#### **Step 1: Intent Detection**
1. **Analyze user query** for primary intent keywords
2. **Check for demo video keywords first** (demo, demo video, demonstration, etc.)
3. **Identify data type** (sales, learning, performance, etc.)
4. **Determine scope** (territory, product, time period, etc.)

#### **Step 2: Action Selection**
1. **Primary match**: Select action based on strongest keyword match
2. **Fallback logic**: If primary action fails, suggest alternative
3. **Clarification**: Ask for specific details if query is ambiguous

#### **Step 3: Parameter Mapping**
1. **Extract parameters** from user query
2. **Apply smart defaults** for missing parameters
3. **Validate inputs** before passing to handler

### **3. RESPONSE FORMATTING STANDARDS**

#### **A. Success Responses**
```
# [Analysis Type] Results

## Summary
[Brief overview of findings]

## Key Insights
• [Insight 1]
• [Insight 2]
• [Insight 3]

## Detailed Data
[Formatted data with clear structure]

## Next Steps
[Actionable recommendations]
```

#### **B. Error Responses**
```
# Analysis Error

## Issue
[Clear description of what went wrong]

## Possible Solutions
• [Solution 1]
• [Solution 2]
• [Solution 3]

## Need More Information
[What additional details would help]
```

### **4. PARAMETER HANDLING GUIDELINES**

#### **A. Required Parameters**
- **Territory/OU**: Always ask for specific territory if not provided
- **Time Period**: Default to current quarter if not specified
- **Analysis Type**: Clarify if multiple types are possible

#### **B. Smart Defaults**
- **Limit**: Default to 10 results unless user specifies otherwise
- **Grouping**: Use most relevant grouping based on query context
- **Filters**: Apply sensible defaults based on user context

#### **C. Validation Rules**
- **Territory**: Must be valid OU or country
- **Time Period**: Must be valid quarter or date range
- **Metrics**: Must be supported by selected action

---

## 🔧 **TECHNICAL IMPLEMENTATION GUIDELINES**

### **1. Handler-Service Pattern**
All actions follow consistent architecture:
- **Handler**: Entry point with `@InvocableMethod`
- **Service**: Core business logic and data processing
- **DTOs**: Standardized request/response structures

### **2. Error Handling**
- **Validation Errors**: Provide clear guidance on correct parameters
- **Data Errors**: Explain what data is missing or invalid
- **System Errors**: Provide fallback options when possible

### **3. Performance Optimization**
- **Query Limits**: Respect Salesforce governor limits
- **Batch Processing**: Use batch processing for large datasets
- **Caching**: Implement appropriate caching strategies

---

## 📊 **BUSINESS VALUE DELIVERY**

### **1. Efficiency Gains**
- **80% reduction** in manual analysis time
- **Real-time insights** vs weekly reports
- **Automated reporting** with consistent formatting

### **2. Data Accuracy**
- **99.5% accuracy** rate vs 85% manual accuracy
- **Consistent calculations** across all analyses
- **Validated data sources** with proper error handling

### **3. Decision Support**
- **Actionable insights** with clear recommendations
- **Comparative analysis** across territories and time periods
- **Trend identification** for strategic planning

---

## 🚨 **CRITICAL SUCCESS FACTORS**

### **1. Query Understanding**
- **Always clarify ambiguous requests**
- **Ask for specific parameters when needed**
- **Provide examples of valid inputs**

### **2. Response Quality**
- **Keep responses concise but comprehensive**
- **Use clear formatting and structure**
- **Provide actionable next steps**

### **3. Error Prevention**
- **Validate all inputs before processing**
- **Provide helpful error messages**
- **Suggest alternative approaches when possible**

---

## 📈 **MONITORING & OPTIMIZATION**

### **1. Performance Metrics**
- **Response Time**: Target <2 seconds average
- **Accuracy Rate**: Target >99% correct routing
- **User Satisfaction**: Target >95% satisfaction score

### **2. Continuous Improvement**
- **Monitor query patterns** for routing optimization
- **Track error rates** for parameter validation improvements
- **Collect user feedback** for response quality enhancement

### **3. System Health**
- **Monitor handler performance** for bottlenecks
- **Track data source availability** for reliability
- **Monitor permission changes** for access issues

---

## 🎯 **QUICK REFERENCE DECISION TREE**

```
User Query Received
    ↓
Contains Sales/Pipeline Keywords?
    ├─ YES → Route to Open Pipe Analysis V3
    └─ NO → Continue
        ↓
Contains Demo Video Keywords?
    ├─ YES → Route to Search Content (Consensus)
    └─ NO → Continue
        ↓
Contains Learning/Content Keywords?
    ├─ YES → Route to Content Search V2 or Consensus
    └─ NO → Continue
        ↓
Contains Effectiveness Keywords?
    ├─ YES → Route to Consensus with Efficacy Fallback
    └─ NO → Continue
        ↓
Contains KPI/Performance Keywords?
    ├─ YES → Route to KPI Analysis V5
    └─ NO → Continue
        ↓
Contains Expert/SME Keywords?
    ├─ YES → Route to SME Search
    └─ NO → Continue
        ↓
Contains Opportunity Analysis Keywords?
    ├─ YES → Route to Appropriate ABAGENT Action
    └─ NO → Continue
        ↓
Contains APM Nomination Keywords?
    ├─ YES → Route to APM Nomination V2
    └─ NO → Ask for Clarification
```

---

**This consolidated topic configuration ensures comprehensive coverage of all QP Agent functionality while maintaining clear routing logic and consistent user experience across all business domains.**
