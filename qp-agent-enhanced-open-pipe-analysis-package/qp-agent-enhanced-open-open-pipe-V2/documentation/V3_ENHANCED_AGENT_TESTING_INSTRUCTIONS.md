# 🎯 V3 Enhanced - Agent Testing Instructions

## 🚀 Quick Start

### Step 1: Add Action to Agent Builder

Since Gen AI Function auto-discovery may take time, **add the action manually**:

1. Open **Agent Builder** → Your Territory Analysis Agent
2. Click **Actions** tab
3. Click **New Action**
4. Choose **Apex Action**
5. Select:
   - **Apex Class:** `ANAgentOpenPipeAnalysisHandlerV3Enhanced`
   - **Method:** `analyzeOpenPipe`
6. **Save**

---

### Step 2: Test with 10 Utterances

Copy and paste these utterances one at a time to test all functionality:

---

## ✅ Utterance 1: Basic OU Query
**Say:** _"Show me UKI opportunities in stage 2"_

**Expected Behavior:**
- Agent queries for UKI, stage "02 - Determining Problem, Impact, Ideal"
- Returns JSON with context, summary, results, limits, fieldContext
- Agent presents data with emojis in friendly format

**Expected JSON Input to Apex:**
```json
{
  "queryParamsJson": "{\"ou\":\"UKI\",\"stage\":\"2\"}"
}
```

**What to Verify:**
- ✅ Agent formats output with emojis
- ✅ Shows summary metrics (totalDeals, totalPipelineValue, avgDealSize, etc.)
- ✅ Shows results array with deal details
- ✅ Shows limits (totalFound vs showing)
- ✅ No emojis in the JSON block from service (agent adds them in presentation)

---

## ⚠️ Utterance 2: High-Level Region (Should Ask for Clarification)
**Say:** _"Show me AMER opportunities"_

**Expected Behavior:**
- Agent detects "AMER" as high-level region
- Returns clarification request with available OUs
- Agent asks: _"Which OU in AMER would you like? Here are the options: AMER ACC, AMER ICE, SMB - AMER SMB, NextGen Platform, AMER Public Sector, AMER Commercial"_

**Expected JSON Response:**
```json
{
  "needsClarification": true,
  "regionProvided": "AMER",
  "availableOUs": ["AMER ACC", "AMER ICE", "SMB - AMER SMB", ...]
}
```

**What to Verify:**
- ✅ Agent recognizes "AMER" as high-level
- ✅ Agent lists all AMER OUs
- ✅ Agent asks user to choose specific OU

---

## ✅ Utterance 3: Stagnation Query (Your Original Use Case!)
**Say:** _"Show me top products that have stagnation in stage 2 more than 40 days"_

**Expected Behavior:**
- If you DON'T specify OU → Agent should ask for OU or say "Which region?"
- If you specify "UKI" → Agent queries:
  - stage: "02 - Determining Problem, Impact, Ideal"
  - filterCriteria: "OPEN_PIPE_OPTY_DAYS_IN_STAGE__C > 40"
  - Returns products with days in stage > 40

**Expected JSON Input (after clarification):**
```json
{
  "queryParamsJson": "{\"ou\":\"UKI\",\"stage\":\"2\",\"filterCriteria\":\"OPEN_PIPE_OPTY_DAYS_IN_STAGE__C > 40\"}"
}
```

---

## ✅ Utterance 4: Product Filter
**Say:** _"Show me Agentforce deals in UKI"_

**Expected Behavior:**
- Agent queries for product containing "Agentforce" in UKI
- Returns all Agentforce opportunities

**Expected JSON Input:**
```json
{
  "queryParamsJson": "{\"ou\":\"UKI\",\"product\":\"Agentforce\"}"
}
```

---

## ✅ Utterance 5: Days in Stage Filter
**Say:** _"Show me UKI opportunities in stage 2 with days in stage greater than 30"_

**Expected Behavior:**
- Stage normalized to "02 - Determining Problem, Impact, Ideal"
- Filter applied: OPEN_PIPE_OPTY_DAYS_IN_STAGE__C > 30
- Returns matching opportunities

---

## ⚠️ Utterance 6: EMEA Clarification
**Say:** _"Show me EMEA pipeline in stage 3"_

**Expected Behavior:**
- Agent detects "EMEA" as high-level region
- Asks: _"Which OU in EMEA? Options: EMEA ACC, EMEA ICE, SMB - EMEA SMB, UKI, DACH, France, Southern Europe, Northern Europe, Middle East, Africa"_

---

## ✅ Utterance 7: Country-Based Query
**Say:** _"Show me Tableau deals in Japan in stage 3"_

**Expected Behavior:**
- Uses country filter instead of OU
- Stage normalized to "03 - Validating Benefits & Value"
- Product filter: Tableau

**Expected JSON Input:**
```json
{
  "queryParamsJson": "{\"country\":\"Japan\",\"product\":\"Tableau\",\"stage\":\"3\"}"
}
```

---

## ✅ Utterance 8: With Limit
**Say:** _"Show me top 10 deals in AMER ACC by value"_

**Expected Behavior:**
- Applies limit of 10
- Orders by value descending
- Shows "totalFound: X, showing: 10, limitApplied: true"

**Expected JSON Input:**
```json
{
  "queryParamsJson": "{\"ou\":\"AMER ACC\",\"limitN\":10}"
}
```

---

## ⚠️ Utterance 9: APAC Clarification
**Say:** _"Show me APAC stage 4 opportunities"_

**Expected Behavior:**
- Agent detects "APAC" as high-level region
- Asks: _"Which OU in APAC? Options: APAC ACC, APAC ICE, SMB - APAC SMB, Japan, Australia, India, ASEAN, Greater China"_

---

## ✅ Utterance 10: Complex Multi-Filter
**Say:** _"Show me UKI Sales Cloud deals in stage 2 that have been there for more than 45 days, limit to top 20"_

**Expected Behavior:**
- OU: UKI
- Product: Sales Cloud
- Stage: "02 - Determining Problem, Impact, Ideal"
- Filter: days in stage > 45
- Limit: 20
- Returns top 20 matching deals

**Expected JSON Input:**
```json
{
  "queryParamsJson": "{\"ou\":\"UKI\",\"product\":\"Sales Cloud\",\"stage\":\"2\",\"filterCriteria\":\"OPEN_PIPE_OPTY_DAYS_IN_STAGE__C > 45\",\"limitN\":20}"
}
```

---

## 📋 Validation Checklist

For each utterance, check:

- [ ] Agent understands natural language ("stage 2" not "02 - Determining...")
- [ ] Agent detects high-level regions and asks for clarification
- [ ] Agent adds emojis and friendly formatting (not in raw Apex output)
- [ ] JSON structure includes: context, summary, results, limits, fieldContext
- [ ] Limits are deterministic (shows totalFound vs showing)
- [ ] Field context helps agent explain the data
- [ ] No errors in query execution
- [ ] Agent presents data in conversational format

---

## 🎯 Success Criteria

**✅ PASS if:**
1. All 10 utterances execute without errors
2. Region clarification works for AMER, EMEA, APAC
3. Stage normalization works for "stage 2", "2", "stage2"
4. Agent adds emojis and formatting (not service)
5. Agent understands field context and can explain the data
6. Limits are shown correctly (totalFound vs showing)
7. Agent handles "no data found" gracefully

**❌ FAIL if:**
1. Agent asks YOU for query parameters (means action not configured)
2. Agent doesn't understand "stage 2" (should auto-convert)
3. Agent doesn't ask for clarification when you say "AMER"
4. Service output contains emojis (should be clean JSON)
5. Errors occur during query execution

---

## 📞 Support

**If you encounter issues:**

1. Check **Setup** → **Apex Jobs** for any errors
2. Check **Setup** → **Debug Logs** for detailed error messages
3. Verify action is added in Agent Builder
4. Try simpler queries first (e.g., "Show me UKI opportunities")

**Known Limitations:**
- Test environment may have limited data (empty results are okay)
- Some test methods fail due to no test data (expected)
- Gen AI Function may not auto-discover immediately (add action manually)

---

**Start Testing!** 🎬 Report back with results from all 10 utterances!

