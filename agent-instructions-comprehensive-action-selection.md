# 🎯 COMPREHENSIVE AGENT ACTION SELECTION GUIDE

## 🚨 CRITICAL ISSUES IDENTIFIED

**Issue 1: Negative Intent Queries Using Wrong Action**
- User asks: "show me AEs who don't have agentforce related opportunity in UKI"
- System calls: "ANAGENT Open Pipe Analysis V3" ❌ WRONG (direct Apex)
- Result: Exact match only, misses product families like "Agentforce Platform"

**Issue 2: Ramp Status Queries Using Wrong Action**
- User asks: "show me slow rampers in LATAM"
- System calls: "ANAGENT Open Pipe Analysis V3" ❌ WRONG
- Result: Pipeline analysis instead of ramp status analysis

### ✅ WHAT SHOULD HAPPEN:
- **Negative Intent**: "show me AEs who don't have agentforce related opportunity in UKI"
- System calls: "ANAgent Search OpenPipe" ✅ CORRECT (MCP-routed)
- Result: Enhanced product family matching excludes all Agentforce variations

- **Ramp Status**: "show me slow rampers in LATAM"
- System calls: "ANAGENT KPI Analysis V5" ✅ CORRECT
- Result: Proper ramp status analysis with AE performance data

## 🎯 ACTION SELECTION DECISION TREE

### Step 1: Analyze User Query
- **Negative Intent**: "don't have", "doesn't have", "without", "excluding", "who don't have [product]" → Use **MCP-Routed OpenPipe Search**
- **Ramp Status/Performance**: "ramp", "rampers", "onboarding", "new hire", "slow/fast/medium rampers" → Use **KPI Analysis V5**
- **Pipeline Opportunities**: "ACV", "pipe gen", "opportunities", "pipeline" → Use **OpenPipe Analysis**
- **Training/Content**: "courses", "training", "enablement", "learning" → Use **Content Search**
- **Knowledge**: "how to", "documentation", "process" → Use **Knowledge Search**

### Step 2: Choose Action
- **MCP-Routed OpenPipe Search**: For negative intent queries (product family matching)
- **KPI Analysis V5**: For ramp status, AE performance, territory analysis
- **OpenPipe Analysis**: For pipeline opportunities, ACV, pipe generation
- **Content Search**: For training materials, courses, enablement
- **Knowledge Search**: For process documentation, how-to guides

## 🔍 NEGATIVE INTENT ANALYSIS (MCP-Routed OpenPipe Search)

### For Negative Intent Queries, Use This Action:
```json
{
  "action": "ANAgent Search OpenPipe",
  "searchTerm": "show me AEs who don't have agentforce related opportunity in UKI",
  "ouName": "UKI",
  "limit": 10
}
```

### Negative Intent Parameters:
- **searchTerm**: Keep the full user query (e.g., "show me AEs who don't have agentforce related opportunity in UKI")
- **ouName**: Extract region/OU from query (e.g., "UKI", "AMER ACC")
- **limit**: Set appropriate limit (e.g., 10, 20)
- **DO NOT use**: filterCriteria, groupBy, analysisType (these are for direct Apex)

### Why Use MCP-Routed Action:
- ✅ **Enhanced Product Family Matching**: Correctly excludes "Agentforce Platform", "Agentforce Analytics", etc.
- ✅ **Natural Language Processing**: Detects negative intent patterns automatically
- ✅ **Multiple Product Support**: Handles "agentforce or tableau" exclusions
- ❌ **Direct Apex Action**: Only does exact matching (misses product families)

## 🔍 RAMP STATUS ANALYSIS (KPI Analysis V5)

### For Ramp Status Analysis, Use This Action:
```json
{
  "action": "ANAGENT KPI Analysis V5",
  "metricKey": "CALLS",
  "timeframe": "CURRENT",
  "groupBy": "AE",
  "filterCriteria": "ramp_status='Slow' AND work_location_country__c IN ('Brazil','Argentina','Chile','Mexico','Colombia')",
  "perAENormalize": true,
  "aggregationType": "AVG"
}
```

### Ramp Status Parameters:
- **metricKey**: CALLS, MEETINGS, ACV, PG, COVERAGE
- **groupBy**: AE, COUNTRY, OU, INDUSTRY, MANAGER
- **filterCriteria**: Include ramp_status and geographic filters
- **perAENormalize**: true (for per-AE averages)

### Example Mappings:
| User Request | Action | Parameters |
|-------------|--------|------------|
| "slow rampers in LATAM" | KPI Analysis V5 | metricKey: "CALLS", groupBy: "AE", filterCriteria: "ramp_status='Slow' AND work_location_country__c IN ('Brazil','Argentina','Chile','Mexico','Colombia')" |
| "fast rampers in AMER" | KPI Analysis V5 | metricKey: "CALLS", groupBy: "COUNTRY", filterCriteria: "ramp_status='Fast' AND ou_name__c LIKE '%AMER%'" |
| "ramp performance comparison" | KPI Analysis V5 | metricKey: "CALLS", groupBy: "COUNTRY", filterCriteria: "ramp_status IN ('Slow','Medium','Fast')" |

## 🚀 PIPELINE ANALYSIS (OpenPipe Analysis)

### For Pipeline Opportunities, Use This Action:
```json
{
  "action": "ANAgent Search OpenPipe Multi-Forecast",
  "searchTerm": "AMER ENTR",
  "searchType": "All",
  "maxResults": 20
}
```

### Pipeline Parameters:
- **searchTerm**: Geographic/segment combinations (e.g., "AMER ENTR")
- **searchType**: "All" for combined searches, specific for single terms
- **maxResults**: 20 for proper aggregation
- **forecastType**: Only for Single action (leave blank for Multi-Forecast)

### Example Mappings:
| User Request | Action | Parameters |
|-------------|--------|------------|
| "ACV and PG in AMER ENTR" | Multi-Forecast | searchTerm: "AMER ENTR", searchType: "All", maxResults: 20 |
| "only ACV in AMER" | Single | searchTerm: "AMER", searchType: "Region", forecastType: "OpenPipe_ACV", maxResults: 20 |
| "pipe gen opportunities in ENTR" | Single | searchTerm: "ENTR", searchType: "Segment", forecastType: "PipeGen", maxResults: 20 |

## 📚 CONTENT SEARCH (Training/Enablement)

### For Training Content, Use This Action:
```json
{
  "action": "Search Content",
  "searchTerm": "Data Cloud",
  "contentType": "Course",
  "maxResults": 10
}
```

### Content Search Parameters:
- **searchTerm**: Product, technology, or skill area
- **contentType**: Course, Asset, Curriculum
- **maxResults**: 5-10 for focused results

## 🔍 KNOWLEDGE SEARCH (Process/Documentation)

### For Knowledge Articles, Use This Action:
```json
{
  "action": "Search Knowledge Articles",
  "searchQuery": "How does SME Finder work?",
  "searchType": "all",
  "maxResults": 3
}
```

### Knowledge Search Parameters:
- **searchQuery**: User's question or search term
- **searchType**: "all" (recommended), "title", "content"
- **maxResults**: 1-10 (default: 3)

## 🚫 WHAT NOT TO USE

### ❌ DON'T USE OpenPipe Analysis for Ramp Status:
```json
{
  "action": "ANAGENT Open Pipe Analysis V3",  // ❌ WRONG
  "searchTerm": "slow rampers",
  "searchType": "All"
}
```

### ❌ DON'T USE Content Search for Pipeline Data:
```json
{
  "action": "Search Content",  // ❌ WRONG
  "searchTerm": "ACV opportunities in AMER"
}
```

### ❌ DON'T USE KPI Analysis for Training Content:
```json
{
  "action": "ANAGENT KPI Analysis V5",  // ❌ WRONG
  "metricKey": "CALLS",
  "filterCriteria": "courses about data cloud"
}
```

## 🔧 FIELD MAPPING FOR RAMP STATUS

### Ramp Status Field:
- **API Field**: `ramp_status__c`
- **User-Friendly**: `ramp_status`
- **Valid Values**: 'Slow', 'Medium', 'Fast', 'Expert'

### Geographic Fields:
- **Country**: `work_location_country__c` → `country`
- **Operating Unit**: `ou_name__c` → `ou`
- **Region**: Derived from country (LATAM, AMER, EMEA, APAC)

### Performance Fields:
- **Calls**: `cq_call_connect__c` (current quarter)
- **Meetings**: `cq_customer_meeting__c` (current quarter)
- **ACV**: `cq_acv__c` (current quarter)
- **Pipeline**: `cq_pg__c` (current quarter)

## 📊 EXPECTED RESULTS BY ACTION TYPE

### KPI Analysis V5 (Ramp Status):
- **Total Records**: X AEs found
- **Performance Metrics**: Average calls, meetings, ACV per AE
- **Geographic Breakdown**: Performance by country/region
- **Ramp Insights**: Days to productivity, coverage metrics

### OpenPipe Analysis (Pipeline):
- **Product Summary**: Top products by ACV/PG
- **Geographic Summary**: Performance by country/region
- **Opportunity Records**: Individual opportunity details
- **Top Performers**: Best performing AEs/products

### Content Search (Training):
- **Course List**: Available training materials
- **Learner Counts**: Total learners and completion rates
- **Content Types**: Courses, assets, curricula
- **Relevance Scores**: How well content matches query

### Knowledge Search (Process):
- **Article Content**: Step-by-step instructions
- **Process Details**: How-to guides and documentation
- **Related Articles**: Additional relevant information
- **Metadata**: Article titles, categories, last updated

## 🛡️ ERROR PREVENTION CHECKLIST

Before executing any action:

- [ ] Is user asking about ramp status/performance? → Use KPI Analysis V5
- [ ] Is user asking about pipeline opportunities? → Use OpenPipe Analysis
- [ ] Is user asking about training content? → Use Content Search
- [ ] Is user asking about process documentation? → Use Knowledge Search
- [ ] Am I using the correct action for the request?
- [ ] Are my parameters properly formatted?
- [ ] Am I grouping by the right dimension?

## 🎉 SUCCESS INDICATORS

### For Ramp Status Analysis:
- ✅ Success: Proper ramp status analysis
- ✅ Results: AE performance data by ramp status
- ✅ Insights: Performance trends and recommendations
- ✅ No errors: Correct Apex class called

### For Pipeline Analysis:
- ✅ Success: Pipeline opportunity data
- ✅ Results: Product and geographic summaries
- ✅ Insights: Top performing products/regions
- ✅ No errors: Proper forecast types used

### For Content Search:
- ✅ Success: Relevant training materials found
- ✅ Results: Course listings with learner data
- ✅ Insights: Completion rates and popularity
- ✅ No errors: Proper content types returned

### For Knowledge Search:
- ✅ Success: Relevant articles found
- ✅ Results: Process documentation and guides
- ✅ Insights: Step-by-step instructions
- ✅ No errors: Proper knowledge base access

## 🔄 FALLBACK BEHAVIOR

If you accidentally use wrong parameters:
- System will validate and provide helpful error messages
- But it's better to use correct parameters from the start
- Always prefer the correct action for the user's intent

## 📋 QUICK REFERENCE CHART

| User Intent | Use Action | Key Parameters |
|-------------|------------|----------------|
| Ramp status, AE performance | KPI Analysis V5 | metricKey, groupBy, filterCriteria |
| Pipeline opportunities, ACV/PG | OpenPipe Analysis | searchTerm, searchType, maxResults |
| Training materials, courses | Content Search | searchTerm, contentType, maxResults |
| Process documentation, how-to | Knowledge Search | searchQuery, searchType, maxResults |

**REMEMBER: Choose the right action based on user intent, not just keywords!** 🚀

## 🎯 FINAL CHECKLIST

Before responding to any user query:

1. **Identify the user's intent** (ramp status, pipeline, training, knowledge)
2. **Choose the correct action** based on intent
3. **Set appropriate parameters** for the chosen action
4. **Validate the configuration** using the error prevention checklist
5. **Execute the action** with confidence

**This will ensure users get the right analysis every time!** 🎉
