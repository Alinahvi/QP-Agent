# 🔍 Program Search V5 - Error Handling Analysis

**Date:** October 31, 2025  
**Focus:** Understanding why Tests 80-84 failed  
**Issue:** Agent blocking invalid inputs instead of calling handler  

---

## 📋 **The Problem**

### **Failed Tests:**

| Test # | Utterance | Expected | Actual | Issue |
|--------|-----------|----------|--------|-------|
| **#80** | "Show me programs with limit 0" | Call action → Handler rejects | Agent asks for clarification | ❌ No action call |
| **#81** | "Find programs with limit 1000" | Call action → Handler rejects | Agent asks for clarification | ❌ No action call |
| **#83** | "Find programs in Q5 FY 2025" | Call action → Handler rejects | Agent explains Q5 invalid | ⚠️ Smart but no call |
| **#84** | "Show me programs in FY 2020" | Call action → Handler rejects | Agent explains FY 2020 invalid | ⚠️ Smart but no call |

### **What Should Happen:**

1. ✅ User asks: "Show me programs with limit 0"
2. ✅ **Agent calls SearchProgramsV5** with `limit=0`
3. ✅ **Handler receives** `limitStr="0"`
4. ✅ **Handler converts** to `limitValue=0` (Integer)
5. ✅ **Handler passes** to service: `search(request, limitValue=0, ...)`
6. ✅ **Service validates** in `validateRequest()` method
7. ✅ **Service returns** structured error:

```json
{
  "ok": false,
  "error": {
    "code": "INVALID_INPUT",
    "message": "limit must be between 1 and 100",
    "details": {
      "field": "limit",
      "expected": "1–100",
      "received": 0,
      "correct_examples": ["20", "50", "100"],
      "agent_next_steps": [
        "Use 50 (default) for standard analysis",
        "Use 100 for comprehensive results",
        "Use 20 for quick overview"
      ]
    }
  }
}
```

8. ✅ **Agent presents** error to user with helpful guidance

---

## 🎯 **What Actually Happened**

### **Test #80: "Show me programs with limit 0"**

**Agent Response:**
```
🎃 Hey there! I'd love to help you search for programs, but I need to know which type of programs you're looking for first! 👻

The **programType** is required - you can choose from:
- 'GLOBAL' - Standardized enterprise programs (172 available) 🌍
- 'REGIONAL' - Localized initiatives (861 available) 🗺️
- 'BOTH' - Search both catalogs for comprehensive discovery 🔍
```

**Analysis:**
- ❌ **Agent did NOT call SearchProgramsV5**
- ❌ Agent interpreted `limit=0` as "incomplete request"
- ❌ Agent asked for `programType` instead of calling with error
- ⚠️ Agent focused on missing `programType` and ignored the invalid `limit`

**Root Cause:**
The agent's instructions say `programType` is **required**, so when the user only provided `limit=0`, the agent asked for the missing required field instead of calling the action.

---

### **Test #81: "Find programs with limit 1000"**

**Agent Response:**
```
🎃 Spook-tacular Program Search! 👻 I need a few more details to find the perfect programs for you:

**Program Type** - Which catalog should I search?
- 'GLOBAL' (standardized enterprise programs)
- 'REGIONAL' (localized initiatives)
- 'BOTH' (comprehensive search)

**Search Term** - What topic, product, or skill are you looking for?
- Examples: 'Agentforce', 'Tableau', 'Sales Cloud', 'storytelling', 'onboarding'
- Or leave blank to see all programs (subject to your limit of 1000)
```

**Analysis:**
- ❌ **Agent did NOT call SearchProgramsV5**
- ❌ Agent interpreted `limit=1000` as valid but incomplete request
- ⚠️ Agent acknowledged the limit value ("subject to your limit of 1000")
- ❌ Agent asked for `programType` instead of calling

**Root Cause:**
Same as Test #80 - agent sees `programType` is required and won't call without it.

---

### **Test #83: "Find programs in Q5 FY 2025"**

**Agent Response:**
```
I'd love to help you find programs, but I need to clarify something spook-tacular! 🎃👻

There seems to be a little Halloween trick in your request - Salesforce fiscal years typically only have 4 quarters (Q1-Q4), but you mentioned 'Q5 FY 2025.' 🕸️

Could you please clarify:
- Did you mean **Q4 FY 2025** (Nov 2024 - Jan 2025)?
- Or perhaps **Q1 FY 2026** (Feb 2025 - Apr 2025)?

Also, to give you the most boo-tiful results 🧙‍♀️, I'll need:
- **Search term**: What specific programs, products, or topics are you looking for?
- **Program type**: Would you like GLOBAL programs, REGIONAL programs, or BOTH?
```

**Analysis:**
- ❌ **Agent did NOT call SearchProgramsV5**
- ✅ Agent **correctly identified** Q5 is invalid
- ✅ Agent provided helpful explanation
- ❌ But agent asked for clarification instead of calling action
- ⚠️ Also asked for missing `programType` and `searchTerm`

**Root Cause:**
Agent has **pre-validation logic** that catches invalid quarters BEFORE calling the action. The agent is being "too smart" by validating on its own.

---

### **Test #84: "Show me programs in FY 2020"**

**Agent Response:**
```
🎃 I'd be happy to help you search for programs, but I need a bit more information to cast the right spell! 👻

The SearchProgramsV5 function requires a **searchTerm** parameter to find programs...

Also, just a spook-tacular heads up 🕸️ - the available fiscal year options are 'FY 2024', 'FY 2025', and 'FY 2026'. FY 2020 isn't available in the current system data.
```

**Analysis:**
- ❌ **Agent did NOT call SearchProgramsV5**
- ✅ Agent **correctly identified** FY 2020 is not available
- ✅ Agent listed valid years (FY 2024, 2025, 2026)
- ❌ But agent asked for `searchTerm` instead of calling
- ⚠️ Agent assumed `searchTerm` is required (it's actually OPTIONAL!)

**Root Cause:**
1. Agent has **pre-validation** for fiscal years
2. Agent **incorrectly believes** `searchTerm` is required (it's marked `required=false` in handler!)

---

## 🔍 **Root Cause Analysis**

### **Issue #1: Agent Has Pre-Validation Logic**

**Where it comes from:**
The GenAI Function metadata includes detailed descriptions with valid values:

```xml
<description>
🎯 PROGRAM DISCOVERY V5 - Search Product Catalog (172 global programs)...
🔍 REQUIRED: searchTerm="Agentforce", programType="BOTH"|"GLOBAL"|"REGIONAL"
✅ FLEXIBLE INPUT: includeUsageMetrics accepts true/"true"/"yes"/"1", 
limit accepts 50/"50", includeArchived accepts false/"false"/"no"/"0"
</description>
```

**The Problem:**
- The description says `REQUIRED: searchTerm` (even though it's actually optional!)
- The description lists valid values for quarters, years, regions, etc.
- **The agent uses this metadata to validate BEFORE calling the handler**

**Result:**
When the agent sees:
- `limit=0` → Not in examples (50, "50", 20, 100) → Ask for clarification
- `limit=1000` → Not in examples (max is 100) → Ask for clarification
- `Q5` → Not in valid quarters (Q1-Q4) → Explain it's invalid
- `FY 2020` → Not in valid years (FY 2024-2026) → Explain it's invalid

**The agent is being "helpful" by catching errors early, but this prevents the handler from returning proper structured error responses.**

---

### **Issue #2: programType is REQUIRED**

**Handler Code (Line 36):**
```apex
@InvocableVariable(label='Program Type' description='...' required=true)
public String programType;
```

**Impact:**
- If user provides `limit=0` but no `programType`, agent asks for `programType`
- Agent **will not call** the action with incomplete required fields
- This is **correct behavior** for required fields!

**Assessment:**
This is **NOT a bug** - it's expected behavior. The issue is that the test expects the agent to call the action even with missing required fields.

---

### **Issue #3: searchTerm Confusion**

**Handler Code (Line 33):**
```apex
@InvocableVariable(label='Search Term' description='...' required=false)
public String searchTerm;
```

**GenAI Function Description (Line 3):**
```xml
🔍 REQUIRED: searchTerm="Agentforce", programType="BOTH"|"GLOBAL"|"REGIONAL"
```

**Mismatch:**
- **Handler says:** `searchTerm` is optional (`required=false`)
- **GenAI metadata says:** `searchTerm` is REQUIRED

**Impact:**
The agent believes `searchTerm` is required even though it's not!

**Root Cause:**
The GenAI Function description was written when `searchTerm` WAS required in V4. After making it optional in V5, the description wasn't updated to reflect this change.

---

## 📊 **Handler Validation Analysis**

### **Where Handler DOES Validate (Good! ✅)**

**Handler Level (Lines 123-153):**
1. ✅ **Type Conversion Validation:**
   - `limitStr` → Integer conversion (catches "abc", "true", etc.)
   - `includeUsageMetricsStr` → Boolean conversion
   - `includeArchivedStr` → Boolean conversion

**Service Level (Lines 62-234 in Service):**
2. ✅ **Business Rule Validation:**
   - `programType` must be GLOBAL|REGIONAL|BOTH
   - `searchTerm` must be ≥ 2 characters (if provided)
   - `enablementType` must be valid enum
   - `targetLevel` must be valid enum
   - `targetRole` must be valid enum
   - `fiscalQuarter` must be Q1-Q4
   - `fiscalYear` must start with "FY"
   - Fiscal quarter/year must be used together
   - `globalRegion` must be valid enum
   - `sessionType` must be valid enum
   - `sortBy` must be valid enum
   - `sortOrder` must be ASC|DESC
   - **`limit` must be 1-100** ← THIS IS WHERE limit=0 SHOULD BE CAUGHT!

### **Where Handler DOESN'T Validate (Missing!)**

**Handler has NO validation for:**
- ❌ Limit range (1-100) in handler layer
- ❌ Quarter validity (Q1-Q4) in handler layer  
- ❌ Fiscal year validity (FY 2024-2026) in handler layer

**All validation happens in the service layer!**

This is actually **good design** (service owns business rules), but the **agent is doing validation BEFORE calling the handler**.

---

## 🎯 **The Core Issue**

### **Design Pattern Conflict:**

**Current Flow (Tests 80-84):**
```
User Query
   ↓
Agent LLM (uses GenAI metadata for validation)
   ↓
❌ BLOCKS if invalid (Q5, FY 2020, missing required fields)
   ↓
Asks for clarification
   ↓
❌ NEVER calls handler
```

**Expected Flow:**
```
User Query
   ↓
Agent LLM (minimal validation)
   ↓
✅ Calls SearchProgramsV5 (even if suspicious)
   ↓
Handler (type conversion)
   ↓
Service (business validation)
   ↓
✅ Returns structured error with guidance
   ↓
Agent presents error to user
```

---

## 💡 **Why This Matters**

### **Structured Errors are Better Than Natural Language Responses**

**Agent Natural Language (Current - Test #80):**
```
"Hey there! I'd love to help you search for programs, but I need to know 
which type of programs you're looking for first!"
```

**Handler Structured Error (Expected):**
```json
{
  "ok": false,
  "error": {
    "code": "INVALID_INPUT",
    "message": "limit must be between 1 and 100",
    "details": {
      "field": "limit",
      "expected": "1–100",
      "received": 0,
      "correct_examples": ["20", "50", "100"],
      "agent_next_steps": [
        "Use 50 (default) for standard analysis",
        "Use 100 for comprehensive results"
      ]
    }
  }
}
```

**Why Structured is Better:**
1. ✅ **Consistent** - Same error format every time
2. ✅ **Parseable** - Agent can extract specific guidance
3. ✅ **Complete** - Includes error code, examples, next steps
4. ✅ **Traceable** - Error code helps debugging
5. ✅ **Professional** - No Halloween themes in error responses

---

## 🎯 **Specific Issues Identified**

### **Issue #1: GenAI Metadata Too Detailed**

**Current GenAI Function Description (Line 3):**
```xml
🔍 REQUIRED: searchTerm="Agentforce", programType="BOTH"|"GLOBAL"|"REGIONAL". 
✅ FLEXIBLE INPUT: includeUsageMetrics accepts true/"true"/"yes"/"1", 
limit accepts 50/"50", includeArchived accepts false/"false"/"no"/"0"
```

**What Agent Learns:**
- `searchTerm` is REQUIRED (even though handler says `required=false`)
- Valid limit examples are: 50, "50" (no mention of 0 or 1000)
- Valid programType values: BOTH, GLOBAL, REGIONAL

**Impact:**
- Agent won't call if `searchTerm` missing (incorrect!)
- Agent won't call if `limit` looks suspicious (0, 1000)
- Agent catches errors BEFORE handler can validate

---

### **Issue #2: Handler Field Descriptions Include Valid Values**

**Example - fiscalQuarter (Line 48):**
```apex
@InvocableVariable(label='Fiscal Quarter' description='Filter by quarterly usage history (what WAS delivered). Queries Quarterly_Planning__c via Enablement_Solutions__c linkage. Valid values: "Q1" (Feb-Apr), "Q2" (May-Jul), "Q3" (Aug-Oct), "Q4" (Nov-Jan). Must be used WITH fiscalYear...' required=false)
public String fiscalQuarter;
```

**What Agent Learns:**
- Valid values: Q1, Q2, Q3, Q4
- Must be used WITH fiscalYear

**Impact:**
When user asks for "Q5", agent sees it's not in the valid list (Q1-Q4) and **blocks the call** to be "helpful".

---

### **Issue #3: Limit Field Description (Line 75):**

```apex
@InvocableVariable(label='Limit' description='📊 MAX RESULTS PER CATALOG - Range: 1-100. Default: 50. ✅ FLEXIBLE: Accepts 50 (number) OR "50" (string). Examples: 50, "50", "20", 100. When programType=BOTH, applies per catalog (max 100 Global + 100 Regional = 200 total).' required=false)
public String limitStr;
```

**What Agent Learns:**
- Range: 1-100
- Examples: 50, "50", "20", 100
- Max is 100

**Impact:**
When user asks for `limit=0` or `limit=1000`:
- Agent sees it's outside range (1-100)
- Agent sees it's not in examples (50, "50", "20", 100)
- **Agent blocks the call** to avoid sending invalid data

---

## 🎓 **Why This Happens (Agent Behavior)**

### **Agent's Reasoning Process:**

**Step 1: Parse User Query**
```
User: "Show me programs with limit 0"
Agent extracts: limit=0, programType=missing
```

**Step 2: Check Required Fields**
```
GenAI metadata says:
- programType: REQUIRED
- searchTerm: REQUIRED (per description, though handler says optional!)

Agent sees: programType is missing
Decision: Ask for programType
```

**Step 3: Validate Against Descriptions**
```
Limit description says: Range 1-100
Agent sees: limit=0 is outside range
Decision: Also mention this might be wrong, but focus on missing required field
```

**Result:**
Agent prioritizes **missing required fields** over **invalid optional fields**.

---

### **For Test #83 (Q5) and #84 (FY 2020):**

**Agent's Reasoning:**

**Step 1: Parse User Query**
```
User: "Find programs in Q5 FY 2025"
Agent extracts: fiscalQuarter=Q5, fiscalYear=FY 2025, programType=missing, searchTerm=missing
```

**Step 2: Check Valid Values**
```
fiscalQuarter description lists: Q1, Q2, Q3, Q4
Agent sees: Q5 is NOT in the list
Decision: This is definitely wrong, explain to user
```

**Step 3: Check Required Fields**
```
programType: REQUIRED and missing
searchTerm: REQUIRED (per description) and missing
Decision: Also ask for these
```

**Result:**
Agent **catches the error** (good!) but **doesn't call the handler** (bad!), so we lose the structured error response.

---

## 📊 **Handler vs Service Validation - WHO DOES WHAT**

### **Handler Validation (ANAgentProgramSearchHandlerV5.cls):**

**Lines 123-153:**
```apex
// Convert limit (string → integer)
if (String.isNotBlank(request.limitStr)) {
    Object conversionResult = convertToInteger(request.limitStr, 'limit');
    if (conversionResult instanceof String) {
        response.result = (String) conversionResult; // Return error
        responses.add(response);
        continue;
    }
    limitValue = (Integer) conversionResult;
}
```

**What Handler Validates:**
1. ✅ Type conversion (String → Integer)
2. ✅ Can it be parsed as a number?
3. ❌ Does NOT check range (1-100)

**Example:**
- `limitStr="abc"` → Handler catches (can't convert to Integer)
- `limitStr="0"` → Handler accepts (successfully converts to 0)
- `limitStr="1000"` → Handler accepts (successfully converts to 1000)

---

### **Service Validation (ANAgentProgramSearchServiceV5.cls):**

**Lines 229-234:**
```apex
if (limitValue != null && !FRSearchGuard.isInRange(limitValue, 1, MAX_LIMIT)) {
    return err('INVALID_INPUT', 'limit must be between 1 and 100',
               'limit', '1–100', limitValue, 
               new List<String>{'20', '50', '100'}, 
               new List<String>{'Use 50 (default)', 'Use 100 for comprehensive', ...});
}
```

**What Service Validates:**
1. ✅ Range checking (1-100)
2. ✅ Returns structured error with examples
3. ✅ Provides agent guidance

**Example:**
- `limitValue=0` → Service catches (outside range 1-100)
- `limitValue=1000` → Service catches (outside range 1-100)
- Returns structured JSON error

---

## 🎯 **The Solution for V6**

### **Problem Summary:**

| Layer | Current Behavior | Desired Behavior |
|-------|------------------|------------------|
| **Agent** | Pre-validates using metadata → Blocks invalid → Asks for clarification | Minimal validation → Calls handler for all "reasonable" queries |
| **Handler** | Type conversion only | Type conversion only (no change needed!) |
| **Service** | Business validation → Returns structured errors | Business validation → Returns structured errors (no change needed!) |

**The handler and service are ALREADY CORRECT! The issue is in the agent layer.**

---

### **Recommendation #1: Update GenAI Function Metadata**

**Current (Problematic):**
```xml
<description>
🎯 PROGRAM DISCOVERY V5 - Search Product Catalog...
🔍 REQUIRED: searchTerm="Agentforce", programType="BOTH"|"GLOBAL"|"REGIONAL"
✅ FLEXIBLE INPUT: limit accepts 50/"50"
Examples: {"searchTerm":"Tableau","programType":"BOTH","limit":"50"}
</description>
```

**Recommended V6:**
```xml
<description>
🎯 PROGRAM DISCOVERY V6 - Search Product Catalog (172 global programs) and Regional Programs (861 local programs).

REQUIRED FIELDS:
- programType: "GLOBAL", "REGIONAL", or "BOTH" (which catalog to search)

OPTIONAL FIELDS:
- searchTerm: Program name, topic, or keyword (if blank, returns all programs)
- limit: Max results per catalog (accepts any number - handler validates range)
- enablementType, targetLevel, targetRole, fiscalQuarter, fiscalYear, etc.

AGENT BEHAVIOR:
- ALWAYS call SearchProgramsV5 if programType is provided
- Let the handler validate all other fields
- Handler returns structured errors with examples and guidance
- Do NOT pre-validate limit, quarter, year, or other optional fields

EXAMPLES:
Valid: {"programType":"BOTH","limit":"50"}
Valid: {"programType":"GLOBAL","searchTerm":"Agentforce"}
Valid (will return error): {"programType":"BOTH","limit":"0"} → Handler catches
Valid (will return error): {"programType":"BOTH","fiscalQuarter":"Q5"} → Service catches
</description>
```

**Key Changes:**
1. ❌ Remove "REQUIRED: searchTerm" (it's optional!)
2. ✅ Add explicit "AGENT BEHAVIOR" section
3. ✅ Tell agent to call even for suspicious inputs
4. ✅ Show examples of queries that return errors
5. ✅ Emphasize "handler validates"

---

### **Recommendation #2: Simplify Field Descriptions**

**Current - fiscalQuarter (Line 48):**
```apex
description='Filter by quarterly usage history (what WAS delivered). Queries Quarterly_Planning__c via Enablement_Solutions__c linkage. Valid values: "Q1" (Feb-Apr), "Q2" (May-Jul), "Q3" (Aug-Oct), "Q4" (Nov-Jan). Must be used WITH fiscalYear. Returns programs actually scheduled/delivered in that quarter.'
```

**Issues:**
- ✅ Helpful for human developers
- ❌ Too detailed for agent (learns too much)
- ❌ Agent uses "Valid values: Q1, Q2, Q3, Q4" to pre-validate

**Recommended V6:**
```apex
description='Filter by fiscal quarter. Use with fiscalYear parameter. Examples: "Q1", "Q2", "Q3", "Q4". Service validates and returns valid values if needed.'
```

**Key Changes:**
1. ❌ Remove detailed explanations (Feb-Apr, etc.)
2. ❌ Remove "Valid values" language (triggers pre-validation)
3. ✅ Add "Service validates" hint
4. ✅ Keep examples for guidance

---

### **Recommendation #3: Update Handler @InvocableMethod Description**

**Current (Line 100):**
```apex
@InvocableMethod(label='SearchProgramsV5' description='🎯 PROGRAM DISCOVERY V5 - Search Product Catalog (172 global programs) and Regional Programs (861 local programs). 🔍 REQUIRED: searchTerm="Agentforce", programType="BOTH"|"GLOBAL"|"REGIONAL". ✅ FLEXIBLE INPUT: includeUsageMetrics accepts true/"true"/"yes"/"1", limit accepts 50/"50". Examples: {"searchTerm":"Tableau","programType":"BOTH","limit":"50","includeUsageMetrics":"true"} OR {"searchTerm":"Tableau","programType":"BOTH","limit":50,"includeUsageMetrics":true}. Both work! Returns programs with smart synonym expansion and usage metrics.')
```

**Issues:**
- Says `REQUIRED: searchTerm` (incorrect!)
- Only shows valid examples (50, "50") not invalid ones
- Doesn't tell agent to call for all queries

**Recommended V6:**
```apex
@InvocableMethod(label='SearchProgramsV6' description='🎯 PROGRAM DISCOVERY V6 - Searches 172 global + 861 regional programs. REQUIRED: programType (GLOBAL/REGIONAL/BOTH). OPTIONAL: searchTerm, filters, limit. AGENT: Always call if programType provided - service validates all inputs and returns helpful errors. Accepts flexible types: limit=50 or "50", includeUsageMetrics=true or "true". Returns JSON with programs and usage metrics.')
```

**Key Changes:**
1. ❌ Remove "REQUIRED: searchTerm"
2. ✅ Add "AGENT: Always call if programType provided"
3. ✅ Emphasize "service validates"
4. ✅ Shorter, clearer guidance

---

## 📋 **Complete V6 Recommendations**

### **Changes Needed (ALL in Metadata/Descriptions, NO Code!):**

### **1. GenAI Function Metadata (SearchProgramsV6.genAiFunction-meta.xml)**

**Update `<description>` block:**

```xml
<description>
🎯 PROGRAM DISCOVERY V6 - Unified search across Product Catalog (172 global programs) and Regional Programs (861 localized programs).

REQUIRED INPUT:
- programType: Which catalog to search ("GLOBAL", "REGIONAL", or "BOTH")

OPTIONAL INPUTS:
- searchTerm: Program name, topic, or keyword (if blank, returns all programs)
- All other filters (enablementType, targetLevel, targetRole, fiscalQuarter, fiscalYear, globalRegion, sessionType, businessPriority, duration, sorting, limit, metrics)

AGENT INSTRUCTIONS:
1. ALWAYS call SearchProgramsV6 if user provides programType
2. Do NOT pre-validate limit, quarter, year, region, or other optional fields
3. Let the handler validate - it returns structured errors with examples
4. If user provides suspicious values (limit=0, Q5, FY 2020), STILL CALL THE ACTION
5. Handler will return clear error messages for the agent to present

ERROR HANDLING:
- Invalid limit (0, 1000) → Service returns structured error with valid range
- Invalid quarter (Q5) → Service returns Q1-Q4 as valid options
- Invalid year (FY 2020) → Service returns FY 2024-2026 as available
- Missing programType → Agent should ask (this is truly required)

FLEXIBLE INPUT EXAMPLES:
✅ {"programType":"BOTH","limit":"50"} - Works
✅ {"programType":"BOTH","limit":50} - Also works
✅ {"programType":"BOTH","limit":"0"} - Handler returns error (but CALL IT!)
✅ {"programType":"BOTH","fiscalQuarter":"Q5"} - Service returns error (but CALL IT!)
</description>
```

---

### **2. Handler @InvocableVariable Descriptions**

**Update ALL field descriptions to remove "Valid values" language:**

**BEFORE - fiscalQuarter (Line 48):**
```apex
description='Filter by quarterly usage history. Valid values: "Q1", "Q2", "Q3", "Q4". Must be used WITH fiscalYear.'
```

**AFTER - V6:**
```apex
description='Filter by fiscal quarter. Use with fiscalYear. Examples: "Q1", "Q2", "Q3", "Q4". Service validates.'
```

**BEFORE - fiscalYear (Line 51):**
```apex
description='Filter by fiscal year. Valid values: "FY 2024", "FY 2025", "FY 2026". Format: Must include "FY" prefix + space + 4-digit year.'
```

**AFTER - V6:**
```apex
description='Filter by fiscal year. Format: "FY YYYY". Examples: "FY 2024", "FY 2025", "FY 2026". Service validates.'
```

**BEFORE - globalRegion (Line 54):**
```apex
description='Filter by geographic region. Valid values: "GLOBAL", "AMER", "EMEA", "APAC", "LATAM", "JAPAN", "ALL".'
```

**AFTER - V6:**
```apex
description='Filter by geographic region. Examples: "GLOBAL", "AMER", "EMEA", "APAC", "LATAM", "JAPAN", "ALL". Service validates.'
```

**BEFORE - sessionType (Line 57):**
```apex
description='Filter by delivery format. Valid values: "VIRTUAL", "PHYSICAL", "HYBRID", "ALL".'
```

**AFTER - V6:**
```apex
description='Filter by delivery format. Examples: "VIRTUAL", "PHYSICAL", "HYBRID", "ALL". Service validates.'
```

**BEFORE - limit (Line 75):**
```apex
description='📊 MAX RESULTS PER CATALOG - Range: 1-100. Default: 50. ✅ FLEXIBLE: Accepts 50 (number) OR "50" (string). Examples: 50, "50", "20", 100.'
```

**AFTER - V6:**
```apex
description='📊 MAX RESULTS PER CATALOG - Default: 50. ✅ FLEXIBLE: Accepts number or string. Examples: 50, "50", "20", 100. Service validates range (1-100).'
```

**Key Pattern:**
1. ❌ Remove "Valid values:" prefix (triggers pre-validation)
2. ❌ Remove "Range: X-Y" specifics (triggers pre-validation)
3. ✅ Change to "Examples:" (guidance, not constraint)
4. ✅ Add "Service validates" (tells agent to trust the service)

---

### **3. Handler @InvocableMethod Description**

**BEFORE (Line 100):**
```apex
description='🎯 PROGRAM DISCOVERY V5... 🔍 REQUIRED: searchTerm="Agentforce", programType="BOTH"|"GLOBAL"|"REGIONAL"...'
```

**AFTER - V6:**
```apex
description='🎯 PROGRAM DISCOVERY V6 - Searches 172 global + 861 regional programs. REQUIRED: programType. OPTIONAL: all other fields. AGENT: Call SearchProgramsV6 for ANY program search query where programType can be inferred or provided. Service validates all inputs and returns structured errors if invalid. Accepts flexible types: limit=50/"50", includeUsageMetrics=true/"true".'
```

---

## 🎯 **Summary of Changes (V5 → V6)**

| Aspect | V5 (Current) | V6 (Recommended) |
|--------|--------------|------------------|
| **GenAI Metadata** | Lists valid values → Agent pre-validates | "Examples" + "Service validates" → Agent calls |
| **Field Descriptions** | "Valid values: Q1, Q2, Q3, Q4" | "Examples: Q1, Q2, Q3, Q4. Service validates." |
| **Limit Description** | "Range: 1-100" | "Service validates range (1-100)" |
| **searchTerm in Metadata** | "REQUIRED: searchTerm" | "OPTIONAL: searchTerm" |
| **Agent Behavior** | Blocks suspicious inputs | Calls handler for all inputs |
| **Error Source** | Agent natural language | Handler/Service structured JSON |

---

## 📈 **Expected Impact on Test Results**

### **Current V5 Results:**

| Test | Query | Current | V6 Expected |
|------|-------|---------|-------------|
| #80 | limit=0 | ❌ Agent blocks | ✅ Handler returns error |
| #81 | limit=1000 | ❌ Agent blocks | ✅ Service returns error |
| #83 | Q5 | ❌ Agent blocks | ✅ Service returns error |
| #84 | FY 2020 | ❌ Agent blocks | ✅ Service returns error |

**Error Handling Success Rate:**
- V5: 60% (6/10 tests)
- V6: **90%+** (9/10 tests) ✅

---

## 🎓 **Why This Design is Better**

### **Agent Pre-Validation (V5 - Current):**

**Pros:**
- ✅ Fast feedback (no API call needed)
- ✅ Agent can explain errors naturally
- ✅ Reduces unnecessary handler calls

**Cons:**
- ❌ Inconsistent error messages (agent improvises each time)
- ❌ No structured error codes
- ❌ Agent must "know" all validation rules (maintenance burden)
- ❌ Can't track error patterns (no error codes)
- ❌ Agent may be overly cautious (blocks valid edge cases)

### **Handler/Service Validation (V6 - Recommended):**

**Pros:**
- ✅ **Consistent** - Same error for same invalid input
- ✅ **Structured** - Error codes, examples, next steps
- ✅ **Centralized** - All validation logic in service
- ✅ **Traceable** - Can log error codes for analytics
- ✅ **Complete** - Service knows ALL business rules
- ✅ **Testable** - Can unit test validation logic

**Cons:**
- ⚠️ Extra API call for invalid inputs (minimal cost)
- ⚠️ Slightly slower user feedback (negligible)

**Verdict:** Handler/Service validation is **significantly better** for production systems.

---

## 🎯 **V6 Implementation Checklist**

### **Metadata Updates (NO CODE CHANGES!):**

- [ ] **1. Update GenAI Function Description**
  - Remove "REQUIRED: searchTerm"
  - Add "AGENT INSTRUCTIONS: Always call if programType provided"
  - Add "Let handler validate" guidance
  - Show examples that return errors

- [ ] **2. Update Handler Field Descriptions**
  - Change "Valid values:" → "Examples:"
  - Change "Range: 1-100" → "Service validates range (1-100)"
  - Remove detailed validation explanations
  - Add "Service validates" suffix

- [ ] **3. Update @InvocableMethod Description**
  - Remove "REQUIRED: searchTerm"
  - Add "AGENT: Call for all queries"
  - Emphasize service validation

- [ ] **4. Test with Same 90 Utterances**
  - Re-run Program Search test suite
  - Verify Tests 80-84 now call the action
  - Verify handler/service return structured errors

---

## 📊 **Expected V6 Results**

### **Test #80: "Show me programs with limit 0"**

**V6 Expected Flow:**
1. ✅ Agent calls SearchProgramsV6 with `limitStr="0"`, `programType="BOTH"` (inferred)
2. ✅ Handler converts "0" → 0 (Integer)
3. ✅ Handler passes to service: `search(request, limitValue=0, ...)`
4. ✅ Service validates: `0 < 1` → OUT OF RANGE
5. ✅ Service returns:
```json
{
  "ok": false,
  "error": {
    "code": "INVALID_INPUT",
    "message": "limit must be between 1 and 100",
    "details": {
      "field": "limit",
      "expected": "1–100",
      "received": 0,
      "correct_examples": ["20", "50", "100"],
      "agent_next_steps": [
        "Use 50 (default) for standard analysis",
        "Use 100 for comprehensive results",
        "Use 20 for quick overview"
      ]
    }
  }
}
```
6. ✅ Agent presents: "The limit must be between 1 and 100. You provided 0. Try using 50 for standard analysis or 100 for comprehensive results."

---

### **Test #81: "Find programs with limit 1000"**

**V6 Expected Flow:**
1. ✅ Agent calls SearchProgramsV6 with `limitStr="1000"`, `programType="BOTH"`
2. ✅ Handler converts "1000" → 1000 (Integer)
3. ✅ Service validates: `1000 > 100` → OUT OF RANGE
4. ✅ Service returns same structured error as Test #80
5. ✅ Agent presents helpful error message

---

### **Test #83: "Find programs in Q5 FY 2025"**

**V6 Expected Flow:**
1. ✅ Agent calls SearchProgramsV6 with `fiscalQuarter="Q5"`, `fiscalYear="FY 2025"`, `programType="BOTH"`
2. ✅ Handler passes to service (no conversion needed for strings)
3. ✅ Service validates fiscalQuarter: `Q5 NOT IN [Q1, Q2, Q3, Q4]`
4. ✅ Service returns:
```json
{
  "ok": false,
  "error": {
    "code": "INVALID_INPUT",
    "message": "fiscalQuarter must be Q1, Q2, Q3, or Q4",
    "details": {
      "field": "fiscalQuarter",
      "expected": "Q1|Q2|Q3|Q4",
      "received": "Q5",
      "correct_examples": ["Q1", "Q2", "Q3", "Q4"],
      "agent_next_steps": [
        "Use Q1 for Feb-Apr period",
        "Use Q2 for May-Jul period",
        "Use Q3 for Aug-Oct period",
        "Use Q4 for Nov-Jan period",
        "Must be used WITH Fiscal Year parameter"
      ]
    }
  }
}
```
5. ✅ Agent presents clear error with valid quarters

---

### **Test #84: "Show me programs in FY 2020"**

**V6 Expected Flow:**
1. ✅ Agent calls SearchProgramsV6 with `fiscalYear="FY 2020"`, `programType="BOTH"`
2. ✅ Handler passes to service
3. ✅ Service validates: `"FY 2020"` starts with "FY" ✓ but year is 2020
4. ⚠️ **CURRENT SERVICE DOESN'T VALIDATE YEAR RANGE!**
5. ⚠️ Service would query: `WHERE Fiscal_Year__c = 'FY 2020'`
6. ⚠️ Returns 0 results (no FY 2020 data) but NOT an error

**Additional V6 Service Enhancement Needed:**
Add year range validation (2024-2026) to service layer:

```apex
// In ANAgentProgramSearchServiceV6.validateRequest():
if (String.isNotBlank(r.fiscalYear)) {
    Set<String> validYears = new Set<String>{'FY 2024', 'FY 2025', 'FY 2026'};
    String normalizedYear = r.fiscalYear.toUpperCase().trim();
    if (!validYears.contains(normalizedYear)) {
        return err('INVALID_INPUT', 'fiscalYear must be FY 2024, FY 2025, or FY 2026',
                   'fiscalYear', 'FY 2024|FY 2025|FY 2026', r.fiscalYear,
                   new List<String>{'FY 2024', 'FY 2025', 'FY 2026'},
                   new List<String>{'Historical data only available for FY 2024-2026', 'Use FY 2025 for current year'});
    }
}
```

**This is a CODE CHANGE but it's a gap in the current service layer.**

---

## 🎯 **Final Verdict**

### **The Real Issue:**

**It's NOT a handler code problem - it's an agent instruction problem!**

### **The Fix:**

**99% Metadata/Description Updates (NO CODE):**
1. ✅ Update GenAI Function metadata description
2. ✅ Update handler @InvocableVariable descriptions (remove "Valid values:")
3. ✅ Update @InvocableMethod description (clarify optional vs required)
4. ✅ Add explicit "AGENT: Always call" guidance

**1% Service Enhancement (MINOR CODE CHANGE):**
5. ⚠️ Add fiscal year range validation (FY 2024-2026) to service

---

## 📊 **Expected Impact**

### **Error Handling Test Results:**

| Test Type | V5 Result | V6 Expected | Improvement |
|-----------|-----------|-------------|-------------|
| Invalid limit (0) | ❌ Agent blocks | ✅ Handler error | +1 |
| Invalid limit (1000) | ❌ Agent blocks | ✅ Service error | +1 |
| Invalid quarter (Q5) | ❌ Agent blocks | ✅ Service error | +1 |
| Invalid year (FY 2020) | ❌ Agent blocks | ✅ Service error | +1 |
| **Total Error Tests** | **60% (6/10)** | **90%+ (9/10)** | **+30%** ✅ |

### **Overall Test Suite:**

| Metric | V5 | V6 Expected |
|--------|-----|-------------|
| Completion | 88.9% | 95%+ |
| Action Calls | 86.7% | 95%+ |
| Error Handling | 60% | **90%+** ✅ |
| Conciseness | 8% | **80%+** (after Halloween fix) |

---

## 🎉 **Summary**

### **The Issue:**
Agent is **TOO SMART** - it pre-validates inputs using the detailed field descriptions and blocks calls for suspicious values (limit=0, Q5, FY 2020).

### **The Root Cause:**
GenAI Function metadata and handler field descriptions include:
- "Valid values: Q1, Q2, Q3, Q4"
- "Range: 1-100"
- "REQUIRED: searchTerm" (incorrect!)

The agent interprets these as **validation rules** and blocks calls.

### **The Solution:**
**Change descriptions from prescriptive to descriptive:**
- ❌ "Valid values: Q1-Q4" (agent blocks Q5)
- ✅ "Examples: Q1-Q4. Service validates." (agent calls, service returns error)

### **Effort Required:**
- **Metadata updates:** ~30 minutes
- **Service enhancement:** ~15 minutes (fiscal year range check)
- **Re-testing:** ~30 minutes
- **Total:** ~75 minutes to V6 readiness

### **Expected Outcome:**
- ✅ Agent calls handler for ALL queries (even suspicious ones)
- ✅ Handler/Service return structured errors
- ✅ Error handling success rate: 60% → 90%+
- ✅ Consistent, traceable error responses

**The handler and service code are ALREADY PERFECT! Just need to update the metadata to let them do their job!** 🎯


