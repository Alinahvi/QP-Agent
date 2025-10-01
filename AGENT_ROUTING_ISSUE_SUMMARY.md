# 🚨 CRITICAL: Agent Routing Issue - Wrong Action for Negative Intent

## **The Problem**
The agent is using the **WRONG action** for negative intent queries, causing incorrect results.

### **❌ What's Happening Now:**
- User asks: "how many AEs didn't have agentforce in their deals?"
- Agent calls: **Direct Apex Action** (wrong)
- Result: **1,664 AEs don't have Agentforce** ✅ Correct

- User asks: "and how many have [Agentforce]?"
- Agent calls: **Same Direct Apex Action** (wrong) 
- Result: **"No AEs have Agentforce"** ❌ WRONG - This contradicts the first answer!

### **✅ What Should Happen:**
- User asks: "how many AEs didn't have agentforce in their deals?"
- Agent calls: **ANAgent Search OpenPipe** (MCP-routed action) ✅ CORRECT
- Result: **3,769 AEs don't have Agentforce** (with proper product family matching)

- User asks: "and how many have [Agentforce]?"
- Agent calls: **ANAgent Search OpenPipe** (MCP-routed action) ✅ CORRECT  
- Result: **Some number of AEs DO have Agentforce** (consistent with first answer)

## **The Root Cause**
The agent is using **direct Apex actions** instead of **MCP-routed actions** for negative intent queries.

### **Direct Apex Action Problems:**
1. **No Product Family Matching**: Uses exact match `!= 'Agentforce'` instead of partial matching
2. **Inconsistent Results**: Different queries return contradictory answers
3. **Missing Enhanced Logic**: Doesn't use our improved negative intent detection

### **MCP-Routed Action Benefits:**
1. **Product Family Matching**: Correctly excludes "Agentforce Platform", "Agentforce Analytics", etc.
2. **Consistent Results**: All queries use the same enhanced logic
3. **Natural Language Processing**: Better intent detection and parameter extraction

## **The Solution**
Update agent instructions to use **ANAgent Search OpenPipe** for all negative intent queries.

### **For Negative Intent Queries, Use:**
```json
{
  "action": "ANAgent Search OpenPipe",
  "searchTerm": "show me AEs who don't have agentforce deals in AMER ACC",
  "ouName": "AMER ACC",
  "limit": 10
}
```

### **DO NOT Use:**
```json
{
  "action": "ANAGENT Open Pipe Analysis V3",
  "filterCriteria": "open_pipe_prod_nm != 'Agentforce'",
  "ouName": "AMER ACC"
}
```

## **Verification**
Our enhanced handler works correctly:
- **Test Result**: 3,769 AEs in AMER ACC don't have Agentforce-related opportunities
- **Product Family Matching**: Properly excludes all Agentforce variations
- **Consistent Logic**: Same enhanced processing for all negative intent queries

## **Next Steps**
1. Update agent instructions to use MCP-routed action for negative intent
2. Test with the corrected routing
3. Verify consistent results across all negative intent queries
