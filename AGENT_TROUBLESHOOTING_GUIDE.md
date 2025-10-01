# Agent "Invalid Config" Troubleshooting Guide

## 🎯 **Current Status: Code Works, Agent Cache Issue**

### ✅ **What We've Verified:**
1. **All permissions are correct** - Agent user can access all classes
2. **All classes are accessible** - No missing dependencies  
3. **Data access works** - Can query `AGENT_OU_PIPELINE_V2__c` and fields
4. **Code executes perfectly** - Returns proper results with insights
5. **Basic Agent framework works** - Hello Agent test passes

### ❌ **The Issue:**
The Agent Action record has **stale schema cache** from the old signature.

---

## 🔧 **Step-by-Step Fix Process**

### **Step 1: Delete the Old Agent Action**
1. Go to **Setup** → **Einstein GPT** → **Agents**
2. Find your Agent and click **Edit**
3. Go to **Actions** tab
4. **Delete** the existing "Analyze KPIs (V2)" action
5. **Save** the Agent

### **Step 2: Create a New Agent Action**
1. Click **New Action**
2. **Action Type**: Apex
3. **Reference Action**: `ANAgentKPIAnalysisV2Handler.run`
4. **API Name**: `Analyze_KPIs_V2_New` (use a new name)
5. **Label**: `Analyze KPIs (V2)`
6. **Description**: `Runs KPI aggregation via V2 service`
7. **✅ Check**: "Assigned to Active Agent"
8. **Save** the action

### **Step 3: Add Action to Agent**
1. Go back to your Agent
2. **Add** the new action to the Agent
3. **Save** the Agent

### **Step 4: Test the Agent**
1. **Deactivate** the Agent
2. **Activate** the Agent (forces fresh cache)
3. Try a test query: "Compare ACV between US and Brazil territories"

---

## 🧪 **Alternative: Test with Hello Agent First**

If you want to be extra sure, test with the minimal Hello Agent first:

### **Create Hello Agent Action:**
1. **Action Type**: Apex
2. **Reference Action**: `HelloAgentHandler.run`
3. **API Name**: `Hello_Agent_Test`
4. **✅ Check**: "Assigned to Active Agent"
5. **Add to Agent** and test

### **Expected Result:**
- Agent should load without "Invalid Config"
- Should respond to "Hello" queries

If Hello Agent works, then the issue is definitely the KPI action cache.

---

## 🔍 **Verification Checklist**

### **Before Creating New Action:**
- [ ] All classes deployed successfully
- [ ] Permission set assigned to Agent user
- [ ] KPI test runs successfully in Developer Console
- [ ] Hello Agent test runs successfully

### **After Creating New Action:**
- [ ] Agent Action shows Input Parameters section populated
- [ ] Agent Action shows Output section populated
- [ ] No "Invalid Config" error in Agent Builder
- [ ] Agent responds to KPI queries

---

## 🚨 **If Still Getting "Invalid Config"**

### **Check Agent Action Schema:**
1. Open the Agent Action record
2. Look for **Input Parameters** section
3. Should show: `question`, `metricKey`, `timeframe`, `groupByDim`, `filter`, `limitN`, `perAENormalize`, `restrictInValuesCsv`, `forceAsync`
4. Look for **Output** section
5. Should show: `success`, `message`, `metricKey`, `timeframe`, `groupByDim`, `processingMode`, `totalGroups`, `aggregateValue`, `groups`, `insights`, `batchJobId`

### **If Schema is Empty:**
- The Agent can't introspect the method
- Check that `ANAgentKPIAnalysisV2Handler.run` exists and is `global static`
- Check that DTOs are `global` and have `@InvocableVariable` annotations

### **If Schema is Populated but Still Fails:**
- Try creating the action in a different org to isolate the issue
- Check if there are any org-specific settings blocking Agent introspection

---

## 📋 **Complete Permission Set Verification**

Your permission set should include:

### **V2 KPI Classes:**
- ✅ `ANAgentKPIAnalysisV2Handler`
- ✅ `ANAgentKPIAnalysisV2Service`
- ✅ `ANAgentKPIAnalysisV2Request`
- ✅ `ANAgentKPIAnalysisV2Response`
- ✅ `ANAgentKPIAnalysisV2GroupRow`

### **Aggregation Stack:**
- ✅ `ANAgentAggregationSpec`
- ✅ `ANAgentSOQLBuilder`
- ✅ `ANAgentAggregationRunner`
- ✅ `ANAgentAggregationJob`
- ✅ `ANAgentFilterParser`
- ✅ `ANAgentMetricRegistry`
- ✅ `ANAgentDimensionRegistry`
- ✅ `ANAgentStats`
- ✅ `ANAgentErrors`
- ✅ `ANAgentLog`
- ✅ `ANAgentKPIUtils`

### **Object Permissions:**
- ✅ `AGENT_OU_PIPELINE_V2__c` - Read access
- ✅ All fields used in queries - Read access

---

## 🎯 **Expected Success Flow**

1. **Delete old Agent Action** → Clears stale cache
2. **Create new Agent Action** → Fresh schema introspection
3. **Add to Agent** → Links action to Agent
4. **Activate Agent** → Forces cache refresh
5. **Test query** → "Compare ACV between US and Brazil territories"
6. **Success** → Agent responds with insights

---

## 🚀 **Why This Will Work**

- ✅ **Code is perfect** - All tests pass
- ✅ **Permissions are correct** - Agent user has full access
- ✅ **Schema is Agent-friendly** - Global classes, top-level DTOs
- ✅ **Cache is the only issue** - Stale Agent Action record

**The "Invalid Config" error should disappear once you recreate the Agent Action!** 🎯 