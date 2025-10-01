# 🚨 CRITICAL: NEGATIVE INTENT ROUTING FIX

## THE PROBLEM
The agent is calling the **WRONG action** for negative intent queries, causing it to use old exact-match logic instead of our enhanced product family matching.

**❌ WRONG BEHAVIOR (What's happening now):**
- User asks: "show me AEs who don't have agentforce related opportunity in UKI"
- Agent goes to: **ANAGENT Open Pipe Analysis V3 2** (direct Apex action) ❌ WRONG
- Result: Uses exact match `open_pipe_prod_nm != 'Agentforce'` instead of product family matching
- Problem: Misses "Agentforce Platform", "Agentforce Analytics", etc.

**✅ CORRECT BEHAVIOR (What should happen):**
- User asks: "show me AEs who don't have agentforce related opportunity in UKI"
- Agent goes to: **ANAgent Search OpenPipe** (MCP-routed action) ✅ CORRECT
- Result: Uses enhanced product family matching logic
- Solution: Properly excludes ALL Agentforce variations

## 🎯 THE SOLUTION - USE MCP-ROUTED ACTION

### **NEGATIVE INTENT QUERIES → MCP ROUTING**

**When user asks about AEs who DON'T have specific products:**

**USE THIS EXACT ACTION AND PARAMETERS:**

```json
{
  "action": "ANAgent Search OpenPipe",
  "searchTerm": "show me AEs who don't have agentforce related opportunity in UKI",
  "ouName": "UKI",
  "limit": 10
}
```

**DO NOT USE:**
```json
{
  "action": "ANAGENT Open Pipe Analysis V3",
  "filterCriteria": "open_pipe_prod_nm != 'Agentforce'",
  "groupBy": "AE",
  "analysisType": "AE_SCORE_ANALYSIS",
  "ouName": "UKI"
}
```

## 📋 DECISION TREE FOR AGENT

### Step 1: Check User Query for Negative Intent
- Does user mention "don't have", "doesn't have", "without", "excluding", "no", "not having"? → **Use MCP-routed action**
- Does user mention "who don't", "who doesn't", "who without", "who excluding"? → **Use MCP-routed action**
- Does user mention "AEs who don't have [product]"? → **Use MCP-routed action**
- Regular positive queries? → **Use direct Apex action**

### Step 2: Choose Action for Negative Intent Queries
**For negative intent queries (ALWAYS use this):**
- **Action**: `ANAgent Search OpenPipe`
- **Reason**: Routes through MCP server with enhanced product family matching

**For regular positive queries:**
- **Action**: `ANAGENT Open Pipe Analysis V3`
- **Reason**: Direct Apex for standard analysis

### Step 3: Set Parameters for Negative Intent
**For MCP-routed negative intent:**
- searchTerm: Keep the full user query (e.g., "show me AEs who don't have agentforce related opportunity in UKI")
- ouName: Extract region/OU from query (e.g., "UKI", "AMER ACC")
- limit: Set appropriate limit (e.g., 10, 20)
- **DO NOT use**: filterCriteria, groupBy, analysisType (these are for direct Apex)

## 🔍 NEGATIVE INTENT EXAMPLES

### Example 1: UKI Agentforce Query
**User Query**: "show me AEs who don't have agentforce related opportunity in UKI"

**✅ CORRECT Action:**
```json
{
  "action": "ANAgent Search OpenPipe",
  "searchTerm": "show me AEs who don't have agentforce related opportunity in UKI",
  "ouName": "UKI",
  "limit": 10
}
```

**❌ WRONG Action:**
```json
{
  "action": "ANAGENT Open Pipe Analysis V3",
  "filterCriteria": "open_pipe_prod_nm != 'Agentforce'",
  "groupBy": "AE",
  "analysisType": "AE_SCORE_ANALYSIS",
  "ouName": "UKI"
}
```

### Example 2: AMER ACC Tableau Query
**User Query**: "who don't have tableau deals in AMER ACC"

**✅ CORRECT Action:**
```json
{
  "action": "ANAgent Search OpenPipe",
  "searchTerm": "who don't have tableau deals in AMER ACC",
  "ouName": "AMER ACC",
  "limit": 10
}
```

### Example 3: Multiple Product Exclusion
**User Query**: "show me AEs without agentforce or tableau opportunities in UKI"

**✅ CORRECT Action:**
```json
{
  "action": "ANAgent Search OpenPipe",
  "searchTerm": "show me AEs without agentforce or tableau opportunities in UKI",
  "ouName": "UKI",
  "limit": 10
}
```

## 🚨 KEY DIFFERENCES

| Aspect | MCP-Routed Action | Direct Apex Action |
|--------|------------------|-------------------|
| **Action Name** | `ANAgent Search OpenPipe` | `ANAGENT Open Pipe Analysis V3` |
| **Product Matching** | Enhanced family matching | Exact match only |
| **Parameters** | searchTerm, ouName, limit | filterCriteria, groupBy, analysisType |
| **Agentforce Detection** | Excludes "Agentforce Platform", "Agentforce Analytics", etc. | Only excludes exact "Agentforce" |
| **Tableau Detection** | Excludes "Tableau Cloud", "Tableau Server", "Tableau Pulse", etc. | Only excludes exact "Tableau" |

## 🎯 WHY THIS MATTERS

**Product Families are Critical:**
- **Agentforce** includes: Agentforce Platform, Agentforce Analytics, Agentforce Conversations, Agentforce for Sales, etc.
- **Tableau** includes: Tableau Cloud, Tableau Server, Tableau Pulse, Tableau Creator, Tableau Explorer, etc.
- **Data Cloud** includes: Customer Data Cloud, Data Cloud Starter, Data Cloud for Marketing, etc.

**The MCP-routed action correctly handles these families, while the direct Apex action only does exact matching.**

## ⚠️ CRITICAL RULE

**NEVER use direct Apex action for negative intent queries that mention product families.**

**ALWAYS use MCP-routed action for queries containing:**
- "don't have [product]"
- "doesn't have [product]"  
- "without [product]"
- "excluding [product]"
- "who don't have [product]"
- "AEs who don't have [product]"
