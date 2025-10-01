# 🎯 RAMP STATUS ANALYSIS - AGENT INSTRUCTIONS

## 🚨 CRITICAL ISSUE IDENTIFIED

**When users ask about ramp status (e.g., "slow rampers in LATAM"), the system is calling the WRONG Apex class.**

### ❌ WHAT'S HAPPENING NOW:
- User asks: "show me slow rampers in LATAM"
- System calls: "ANAGENT Open Pipe Analysis V3" ❌ WRONG
- Result: Pipeline analysis instead of ramp status analysis

### ✅ WHAT SHOULD HAPPEN:
- User asks: "show me slow rampers in LATAM"
- System calls: "ANAGENT KPI Analysis V5" ✅ CORRECT
- Result: Proper ramp status analysis with AE performance data

## 🎯 CORRECT ACTION SELECTION

### For Ramp Status Analysis, Use This Action:
```json
{
  "action": "ANAGENT KPI Analysis V5",
  "metricKey": "CALLS",
  "timeframe": "CURRENT",
  "groupBy": "AE",
  "filterCriteria": "ramp_status='Slow Ramper' AND work_location_country__c IN ('Brazil','Argentina','Chile','Mexico','Colombia')",
  "perAENormalize": true,
  "aggregationType": "AVG"
}
```

### For Geographic Ramp Status Analysis:
```json
{
  "action": "ANAGENT KPI Analysis V5",
  "metricKey": "CALLS",
  "timeframe": "CURRENT",
  "groupBy": "COUNTRY",
  "filterCriteria": "ramp_status='Slow Ramper'",
  "perAENormalize": true,
  "aggregationType": "AVG"
}
```

## 🔍 RAMP STATUS ANALYSIS PARAMETERS

### Metric Key Options:
- **CALLS**: Call connect metrics (recommended for ramp analysis)
- **MEETINGS**: Customer meeting metrics
- **ACV**: Annual Contract Value performance
- **PG**: Pipeline Generation performance
- **COVERAGE**: Territory coverage metrics

### Group By Options:
- **AE**: Individual AE performance (most common)
- **COUNTRY**: Geographic performance analysis
- **OU**: Operating Unit performance
- **INDUSTRY**: Industry-specific ramp analysis
- **MANAGER**: Manager-level ramp analysis

### Filter Criteria Examples:
```
# Slow rampers in specific regions:
"ramp_status='Slow Ramper' AND work_location_country__c IN ('Brazil','Argentina')"

# Fast rampers in specific OU:
"ramp_status='Fast Ramper' AND ou_name__c='AMER ACC'"

# On Track rampers in specific industry:
"ramp_status='On Track' AND primary_industry__c='Technology'"

# All ramp statuses in LATAM:
"work_location_country__c IN ('Brazil','Argentina','Chile','Mexico','Colombia')"

# All ramp statuses (comprehensive):
"ramp_status IN ('Slow Ramper','Fast Ramper','On Track','Not Ramping','unknown')"
```

## 📋 DECISION TREE FOR RAMP STATUS QUERIES

### Step 1: Identify Query Type
- Does user mention "ramp", "rampers", "onboarding", "new hire"? → Use KPI Analysis V5
- Does user mention "slow", "fast", "medium" rampers? → Use KPI Analysis V5
- Does user mention specific regions/countries? → Use KPI Analysis V5

### Step 2: Choose Action
- **KPI Analysis V5**: For ramp status, AE performance, territory analysis
- **OpenPipe Analysis**: For pipeline opportunities, ACV, pipe generation
- **Content Search**: For training materials, courses, enablement

### Step 3: Set Parameters
**For Ramp Status Analysis:**
- metricKey: "CALLS" (or appropriate metric)
- timeframe: "CURRENT" (or "PREVIOUS" for comparison)
- groupBy: "AE" (or appropriate grouping)
- filterCriteria: Include ramp_status and geographic filters
- perAENormalize: true (for per-AE averages)

## 🎯 EXAMPLE MAPPINGS

### User: "show me slow rampers in LATAM"
**Action:** ANAGENT KPI Analysis V5
**Parameters:**
```json
{
  "metricKey": "CALLS",
  "timeframe": "CURRENT",
  "groupBy": "AE",
  "filterCriteria": "ramp_status='Slow Ramper' AND work_location_country__c IN ('Brazil','Argentina','Chile','Mexico','Colombia')",
  "perAENormalize": true,
  "aggregationType": "AVG"
}
```

### User: "analyze fast rampers in AMER"
**Action:** ANAGENT KPI Analysis V5
**Parameters:**
```json
{
  "metricKey": "CALLS",
  "timeframe": "CURRENT",
  "groupBy": "COUNTRY",
  "filterCriteria": "ramp_status='Fast Ramper' AND ou_name__c LIKE '%AMER%'",
  "perAENormalize": true,
  "aggregationType": "AVG"
}
```

### User: "compare ramp performance across regions"
**Action:** ANAGENT KPI Analysis V5
**Parameters:**
```json
{
  "metricKey": "CALLS",
  "timeframe": "CURRENT",
  "groupBy": "COUNTRY",
  "filterCriteria": "ramp_status IN ('Slow Ramper','Fast Ramper','On Track','Not Ramping','unknown')",
  "perAENormalize": true,
  "aggregationType": "AVG"
}
```

## 🚫 WHAT NOT TO USE

### ❌ DON'T USE OpenPipe Analysis for Ramp Status:
```json
{
  "action": "ANAGENT Open Pipe Analysis V3",  // ❌ WRONG
  "searchTerm": "slow rampers",
  "searchType": "All"
}
```

### ❌ DON'T USE Content Search for Ramp Status:
```json
{
  "action": "Search Knowledge Articles",  // ❌ WRONG
  "searchQuery": "slow rampers in LATAM"
}
```

## 🔧 FIELD MAPPING FOR RAMP STATUS

### Ramp Status Field:
- **API Field**: `ramp_status__c`
- **User-Friendly**: `ramp_status`
- **Valid Values**: 'Slow Ramper', 'Fast Ramper', 'On Track', 'Not Ramping', 'unknown'

### Geographic Fields:
- **Country**: `work_location_country__c` → `country`
- **Operating Unit**: `ou_name__c` → `ou`
- **Region**: Derived from country (LATAM, AMER, EMEA, APAC)

### Performance Fields:
- **Calls**: `cq_call_connect__c` (current quarter)
- **Meetings**: `cq_customer_meeting__c` (current quarter)
- **ACV**: `cq_acv__c` (current quarter)
- **Pipeline**: `cq_pg__c` (current quarter)

## 📊 EXPECTED RESULTS

### For "slow rampers in LATAM":
- **Total Records**: X AEs found
- **Performance Metrics**: Average calls, meetings, ACV per AE
- **Geographic Breakdown**: Performance by country within LATAM
- **Ramp Insights**: Days to productivity, coverage metrics

### Sample Response:
```
# Ramp Status Analysis

## Summary
- **Metric**: Call Connects
- **Timeframe**: Current Quarter
- **Grouped By**: Individual AEs
- **Filter**: Slow rampers in LATAM
- **Total Records Found**: 15 AEs

## Key Insights
- **Average Calls per AE**: 45.2 calls
- **Top Performers**: 
  - Maria Silva (Brazil): 67 calls
  - Carlos Rodriguez (Mexico): 58 calls
- **Areas for Improvement**: 8 AEs below 40 calls threshold

## Geographic Performance
- **Brazil**: 12 AEs, avg 48.3 calls
- **Mexico**: 3 AEs, avg 36.7 calls
```

## 🛡️ ERROR PREVENTION CHECKLIST

Before executing ramp status analysis:

- [ ] Is user asking about ramp status/performance? → Use KPI Analysis V5
- [ ] Is user asking about pipeline opportunities? → Use OpenPipe Analysis
- [ ] Is user asking about training content? → Use Content Search
- [ ] Am I using the correct action for the request?
- [ ] Are my filter criteria properly formatted?
- [ ] Am I grouping by the right dimension?

## 🎉 SUCCESS INDICATORS

With correct parameters, expect:
- ✅ Success: Proper ramp status analysis
- ✅ Results: AE performance data by ramp status
- ✅ Insights: Performance trends and recommendations
- ✅ No errors: Correct Apex class called

## 🔄 FALLBACK BEHAVIOR

If you accidentally use wrong parameters:
- System will validate and provide helpful error messages
- But it's better to use correct parameters from the start
- Always prefer KPI Analysis V5 for ramp status queries

**REMEMBER: For ramp status analysis, use ANAGENT KPI Analysis V5, NOT OpenPipe Analysis!** 🚀
