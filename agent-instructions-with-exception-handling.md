# 🚨 UPDATED OPENPIPE INSTRUCTIONS WITH EXCEPTION HANDLING

## 🛡️ NEW EXCEPTION HANDLING FEATURE

**Good News!** The system now has automatic exception handling for invalid forecast types:

### What Happens When Invalid Forecast Type is Used:
- ❌ **Before**: "No opportunities found" error
- ✅ **Now**: Automatically searches ALL forecast types and returns results
- ✅ **Now**: Provides clear messaging about the invalid forecast type
- ✅ **Now**: Lists available forecast types for reference

### Example:
**User Query**: "show me top 3 pipe gen and top 3 acv products in AMER ENTR segment"

**Agent Uses Wrong Parameters** (what was happening):
```json
{
  "action": "ANAgent Search OpenPipe",
  "searchTerm": "AMER ENTR",
  "searchType": "Segment",
  "forecastType": "PipeGen_ACV",  // ❌ Invalid
  "maxResults": 3
}
```

**New Behavior**:
- System detects `"PipeGen_ACV"` is invalid
- Automatically searches ALL forecast types instead
- Returns results from both `OpenPipe_ACV` and `PipeGen`
- Message: "Found X opportunities for all forecast types (invalid forecast type 'PipeGen_ACV' was provided, available types: OpenPipe_ACV, PipeGen)"

## 🎯 CORRECT PARAMETERS (STILL PREFERRED)

### For User Query: "show me top 3 pipe gen and top 3 acv products in AMER ENTR segment"

**USE THIS EXACT ACTION AND PARAMETERS:**

```json
{
  "action": "ANAgent Search OpenPipe Multi-Forecast",
  "searchTerm": "AMER ENTR",
  "searchType": "All",
  "maxResults": 20
}
```

## 📋 DECISION TREE FOR AGENT

### Step 1: Check User Query
- Does user mention "ACV and PG" or "pipe gen and acv"? → Use Multi-Forecast action
- Does user mention "both" or "combined"? → Use Multi-Forecast action
- Does user mention only one type? → Use Single action

### Step 2: Choose Action
- **Multi-Forecast Action**: For combined ACV + PG requests
- **Single Action**: For single forecast type requests

### Step 3: Set Parameters
**For Multi-Forecast:**
- searchTerm: Keep user's search term (e.g., "AMER ENTR")
- searchType: "All" (for combined searches)
- maxResults: 20 (for top 3 aggregation)
- forecastType: (leave blank - auto-uses both)

**For Single Action:**
- searchTerm: Keep user's search term
- searchType: "All" (for combined searches) or specific type
- forecastType: "OpenPipe_ACV" OR "PipeGen" (NEVER "PipeGen_ACV")
- maxResults: 20

## 🔧 FORECAST TYPE MAPPING - NEVER CHANGE

| User Says | Use This |
|-----------|----------|
| "ACV" | `OpenPipe_ACV` |
| "pipe gen" | `PipeGen` |
| "PG" | `PipeGen` |
| "pipe generation" | `PipeGen` |

## ⚠️ AVAILABLE FORECAST TYPES

**Valid Types:**
- `OpenPipe_ACV`
- `PipeGen`

**Invalid Types (will trigger exception handling):**
- `PipeGen_ACV` ← This will automatically search all types
- `OpenPipe_PG` ← This will automatically search all types
- `ACV_PipeGen` ← This will automatically search all types

## 🔍 SEARCH TYPE RULES

| Search Term | Use This |
|-------------|----------|
| "AMER ENTR" | `"All"` |
| "Tableau Cloud AMER" | `"All"` |
| "AMER" | `"Region"` |
| "ENTR" | `"Segment"` |

## 📊 EXAMPLE MAPPINGS

### User: "ACV and PG in AMER ENTR"
**Action:** ANAgent Search OpenPipe Multi-Forecast
**Parameters:**
- searchTerm: "AMER ENTR"
- searchType: "All"
- maxResults: 20

### User: "only ACV in AMER"
**Action:** ANAgent Search OpenPipe
**Parameters:**
- searchTerm: "AMER"
- searchType: "Region"
- forecastType: "OpenPipe_ACV"
- maxResults: 20

### User: "pipe gen opportunities in ENTR"
**Action:** ANAgent Search OpenPipe
**Parameters:**
- searchTerm: "ENTR"
- searchType: "Segment"
- forecastType: "PipeGen"
- maxResults: 20

## 🛡️ ERROR PREVENTION CHECKLIST

Before executing ANY OpenPipe search:

- [ ] Is user asking for "ACV and PG"? → Use Multi-Forecast action
- [ ] Is search term multiple words? → Use searchType "All"
- [ ] Is forecast type "PipeGen_ACV"? → Change to "PipeGen" (or let exception handling fix it)
- [ ] Is maxResults less than 10? → Change to 20
- [ ] Am I using the right action for the request?

## 🎉 EXPECTED RESULTS

### For "AMER ENTR" multi-forecast search, expect:
- Success: true
- OpenPipe_ACV: Multiple opportunities found
- PipeGen: Multiple opportunities found
- Combined Top Products: Top 3 products by total value

### For invalid forecast type (exception handling):
- Success: true (instead of false)
- Results from all forecast types
- Clear message explaining what happened
- List of available forecast types

## 💡 KEY TAKEAWAYS

1. **Exception handling is now active** - invalid forecast types won't cause "no opportunities found"
2. **Still use correct parameters** when possible for best performance
3. **Multi-Forecast action is preferred** for "ACV and PG" requests
4. **Always use "All" search type** for combined terms like "AMER ENTR"
5. **Set maxResults to 20** for proper aggregation

## 🔄 FALLBACK BEHAVIOR

If you accidentally use wrong parameters:
- ❌ `forecastType: "PipeGen_ACV"` → ✅ System automatically searches all types
- ❌ `searchType: "Segment"` for "AMER ENTR" → ✅ Still works but less optimal
- ❌ `maxResults: 3` → ✅ Still works but may not get enough data for top 3

**The system is now more forgiving, but still try to use the correct parameters for best results!** 🚀 

## 🛡️ NEW EXCEPTION HANDLING FEATURE

**Good News!** The system now has automatic exception handling for invalid forecast types:

### What Happens When Invalid Forecast Type is Used:
- ❌ **Before**: "No opportunities found" error
- ✅ **Now**: Automatically searches ALL forecast types and returns results
- ✅ **Now**: Provides clear messaging about the invalid forecast type
- ✅ **Now**: Lists available forecast types for reference

### Example:
**User Query**: "show me top 3 pipe gen and top 3 acv products in AMER ENTR segment"

**Agent Uses Wrong Parameters** (what was happening):
```json
{
  "action": "ANAgent Search OpenPipe",
  "searchTerm": "AMER ENTR",
  "searchType": "Segment",
  "forecastType": "PipeGen_ACV",  // ❌ Invalid
  "maxResults": 3
}
```

**New Behavior**:
- System detects `"PipeGen_ACV"` is invalid
- Automatically searches ALL forecast types instead
- Returns results from both `OpenPipe_ACV` and `PipeGen`
- Message: "Found X opportunities for all forecast types (invalid forecast type 'PipeGen_ACV' was provided, available types: OpenPipe_ACV, PipeGen)"

## 🎯 CORRECT PARAMETERS (STILL PREFERRED)

### For User Query: "show me top 3 pipe gen and top 3 acv products in AMER ENTR segment"

**USE THIS EXACT ACTION AND PARAMETERS:**

```json
{
  "action": "ANAgent Search OpenPipe Multi-Forecast",
  "searchTerm": "AMER ENTR",
  "searchType": "All",
  "maxResults": 20
}
```

## 📋 DECISION TREE FOR AGENT

### Step 1: Check User Query
- Does user mention "ACV and PG" or "pipe gen and acv"? → Use Multi-Forecast action
- Does user mention "both" or "combined"? → Use Multi-Forecast action
- Does user mention only one type? → Use Single action

### Step 2: Choose Action
- **Multi-Forecast Action**: For combined ACV + PG requests
- **Single Action**: For single forecast type requests

### Step 3: Set Parameters
**For Multi-Forecast:**
- searchTerm: Keep user's search term (e.g., "AMER ENTR")
- searchType: "All" (for combined searches)
- maxResults: 20 (for top 3 aggregation)
- forecastType: (leave blank - auto-uses both)

**For Single Action:**
- searchTerm: Keep user's search term
- searchType: "All" (for combined searches) or specific type
- forecastType: "OpenPipe_ACV" OR "PipeGen" (NEVER "PipeGen_ACV")
- maxResults: 20

## 🔧 FORECAST TYPE MAPPING - NEVER CHANGE

| User Says | Use This |
|-----------|----------|
| "ACV" | `OpenPipe_ACV` |
| "pipe gen" | `PipeGen` |
| "PG" | `PipeGen` |
| "pipe generation" | `PipeGen` |

## ⚠️ AVAILABLE FORECAST TYPES

**Valid Types:**
- `OpenPipe_ACV`
- `PipeGen`

**Invalid Types (will trigger exception handling):**
- `PipeGen_ACV` ← This will automatically search all types
- `OpenPipe_PG` ← This will automatically search all types
- `ACV_PipeGen` ← This will automatically search all types

## 🔍 SEARCH TYPE RULES

| Search Term | Use This |
|-------------|----------|
| "AMER ENTR" | `"All"` |
| "Tableau Cloud AMER" | `"All"` |
| "AMER" | `"Region"` |
| "ENTR" | `"Segment"` |

## 📊 EXAMPLE MAPPINGS

### User: "ACV and PG in AMER ENTR"
**Action:** ANAgent Search OpenPipe Multi-Forecast
**Parameters:**
- searchTerm: "AMER ENTR"
- searchType: "All"
- maxResults: 20

### User: "only ACV in AMER"
**Action:** ANAgent Search OpenPipe
**Parameters:**
- searchTerm: "AMER"
- searchType: "Region"
- forecastType: "OpenPipe_ACV"
- maxResults: 20

### User: "pipe gen opportunities in ENTR"
**Action:** ANAgent Search OpenPipe
**Parameters:**
- searchTerm: "ENTR"
- searchType: "Segment"
- forecastType: "PipeGen"
- maxResults: 20

## 🛡️ ERROR PREVENTION CHECKLIST

Before executing ANY OpenPipe search:

- [ ] Is user asking for "ACV and PG"? → Use Multi-Forecast action
- [ ] Is search term multiple words? → Use searchType "All"
- [ ] Is forecast type "PipeGen_ACV"? → Change to "PipeGen" (or let exception handling fix it)
- [ ] Is maxResults less than 10? → Change to 20
- [ ] Am I using the right action for the request?

## 🎉 EXPECTED RESULTS

### For "AMER ENTR" multi-forecast search, expect:
- Success: true
- OpenPipe_ACV: Multiple opportunities found
- PipeGen: Multiple opportunities found
- Combined Top Products: Top 3 products by total value

### For invalid forecast type (exception handling):
- Success: true (instead of false)
- Results from all forecast types
- Clear message explaining what happened
- List of available forecast types

## 💡 KEY TAKEAWAYS

1. **Exception handling is now active** - invalid forecast types won't cause "no opportunities found"
2. **Still use correct parameters** when possible for best performance
3. **Multi-Forecast action is preferred** for "ACV and PG" requests
4. **Always use "All" search type** for combined terms like "AMER ENTR"
5. **Set maxResults to 20** for proper aggregation

## 🔄 FALLBACK BEHAVIOR

If you accidentally use wrong parameters:
- ❌ `forecastType: "PipeGen_ACV"` → ✅ System automatically searches all types
- ❌ `searchType: "Segment"` for "AMER ENTR" → ✅ Still works but less optimal
- ❌ `maxResults: 3` → ✅ Still works but may not get enough data for top 3

**The system is now more forgiving, but still try to use the correct parameters for best results!** 🚀 