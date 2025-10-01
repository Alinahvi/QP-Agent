# 🚨 CRITICAL NEGATIVE FILTER ROUTING - AGENT MUST FOLLOW THESE RULES

## THE PROBLEM
The agent is NOT detecting negative intent and routing to the MCP adapter for "don't have" queries.

**❌ WRONG BEHAVIOR (What's happening now):**
- User asks: "List AEs in UKI who don't have agentforce deals"
- Agent uses: **ANAGENT Open Pipe Analysis V3** directly ❌
- Result: Uses `filterCriteria: "open_pipe_opty_stg_nm IS NULL"` instead of negative filters
- Result: Returns "no records found" instead of proper negative analysis

**✅ CORRECT BEHAVIOR (What should happen):**
- User asks: "List AEs in UKI who don't have agentforce deals"
- Agent routes to: **MCP Adapter with negative parameters** ✅
- Result: Uses `excludeProducts: "Agentforce"` and `negativeIntent: true`
- Result: Returns proper negative filter analysis with 810 AEs

## 🎯 THE SOLUTION - NEGATIVE FILTER DETECTION

### **NEGATIVE INTENT KEYWORDS**
When user query contains these phrases, use MCP adapter with negative parameters:

**Negative Keywords:**
- "don't have"
- "without"
- "excluding"
- "lack"
- "no [product]"
- "missing"
- "not having"

**Examples:**
- "AEs who don't have Agentforce deals" → Negative filter
- "Show me AEs without Data Cloud" → Negative filter
- "List AEs excluding Slack products" → Negative filter
- "AEs who lack MuleSoft opportunities" → Negative filter

## 📋 DECISION TREE FOR AGENT

### Step 1: Check User Query for Negative Intent
- Does user mention "don't have", "without", "excluding", "lack", "no [product]"? → **Use MCP Adapter with Negative Parameters**
- Does user mention regular pipeline analysis? → **Use Standard Open Pipe Analysis**

### Step 2: Choose Action for Negative Queries
**For negative filter queries (ALWAYS use this):**
- **Action**: `AN_OpenPipeV3_FromMCP` (MCP Adapter)
- **Reason**: This routes to the MCP adapter with negative filter support

**For regular pipeline queries:**
- **Action**: `ANAGENT Open Pipe Analysis V3`
- **Reason**: Direct pipeline analysis without negative filters

### Step 3: Set MCP Parameters for Negative Queries
**For MCP Adapter with Negative Filters:**
```json
{
  "ouName": "UKI",
  "excludeProducts": "Agentforce",
  "negativeIntent": true,
  "limit": "10"
}
```

**DO NOT USE:**
```json
{
  "action": "ANAGENT Open Pipe Analysis V3",
  "filterCriteria": "open_pipe_opty_stg_nm IS NULL"
}
```

## 🔍 NEGATIVE FILTER EXAMPLES

### Example 1: "List AEs in UKI who don't have agentforce deals"
**CORRECT MCP Parameters:**
```json
{
  "ouName": "UKI",
  "excludeProducts": "Agentforce",
  "negativeIntent": true,
  "limit": "10"
}
```

### Example 2: "Find AEs in AMER SMB without Data Cloud opportunities, limit to 20"
**CORRECT MCP Parameters:**
```json
{
  "ouName": "AMER SMB",
  "excludeProducts": "Data Cloud",
  "negativeIntent": true,
  "limit": "20"
}
```

### Example 3: "Show me AEs in PubSec+ who don't have Slack deals, top 15"
**CORRECT MCP Parameters:**
```json
{
  "ouName": "PubSec+.Org",
  "excludeProducts": "Slack",
  "negativeIntent": true,
  "limit": "15"
}
```

## 🚨 CRITICAL ROUTING RULES

### Rule 1: Always Check for Negative Keywords First
- Scan user query for negative intent keywords
- If found, route to MCP adapter with negative parameters
- If not found, use standard Open Pipe Analysis

### Rule 2: Extract Product Names for Exclusion
- Look for product names after negative keywords
- Map to `excludeProducts` parameter
- Set `negativeIntent: true`

### Rule 3: Preserve OU and Other Filters
- Keep original OU name from user query
- Preserve any other filters (country, stage, etc.)
- Add negative filter parameters

## 📊 EXPECTED RESULTS

### For "List AEs in UKI who don't have agentforce deals":
- **Expected Count**: 810 AEs (verified by UAT)
- **Expected Response**: Detailed analysis with AE list
- **Expected Message**: "Negative Filter Analysis" with proper formatting

### For Regular Pipeline Queries:
- **Expected Response**: Standard pipeline analysis
- **Expected Message**: Regular analysis format

## 🔧 TROUBLESHOOTING

### If Agent Still Uses Wrong Action:
1. Check if negative keywords are detected
2. Verify MCP adapter is being called
3. Confirm negative parameters are set
4. Check if `negativeIntent: true` is included

### If No Results Returned:
1. Verify `excludeProducts` parameter is correct
2. Check if OU name is properly mapped
3. Confirm negative filter logic is working
4. Test with UAT script to verify data

## 🎯 QUICK REFERENCE

| User Query Pattern | Action | Parameters |
|-------------------|--------|------------|
| "don't have [product]" | MCP Adapter | excludeProducts, negativeIntent: true |
| "without [product]" | MCP Adapter | excludeProducts, negativeIntent: true |
| "excluding [product]" | MCP Adapter | excludeProducts, negativeIntent: true |
| "lack [product]" | MCP Adapter | excludeProducts, negativeIntent: true |
| "no [product]" | MCP Adapter | excludeProducts, negativeIntent: true |
| Regular pipeline query | Open Pipe Analysis V3 | Standard parameters |

## 🚨 REMEMBER
- **ALWAYS** check for negative keywords first
- **ALWAYS** use MCP adapter for negative queries
- **NEVER** use standard Open Pipe Analysis for negative queries
- **ALWAYS** set `negativeIntent: true` for negative queries
