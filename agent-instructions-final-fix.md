# 🚨 FINAL OPENPIPE FIX - AGENT MUST FOLLOW THESE RULES

## THE PROBLEM
The agent is using WRONG parameters:
- ❌ `forecastType: "PipeGen_ACV"` (doesn't exist)
- ❌ `searchType: "Segment"` (should be "All" for combined searches)
- ❌ `maxResults: 3` (too low for aggregation)
- ❌ Wrong action (using single instead of multi-forecast)

## THE SOLUTION - EXACT PARAMETERS TO USE

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

**DO NOT USE:**
```json
{
  "action": "ANAgent Search OpenPipe",
  "searchTerm": "AMER ENTR", 
  "searchType": "Segment",
  "forecastType": "PipeGen_ACV",
  "maxResults": 3
}
```

## DECISION TREE FOR AGENT

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

## FORECAST TYPE MAPPING - NEVER CHANGE

| User Says | Use This |
|-----------|----------|
| "ACV" | `OpenPipe_ACV` |
| "pipe gen" | `PipeGen` |
| "PG" | `PipeGen` |
| "pipe generation" | `PipeGen` |

## SEARCH TYPE RULES

| Search Term | Use This |
|-------------|----------|
| "AMER ENTR" | `"All"` |
| "Tableau Cloud AMER" | `"All"` |
| "AMER" | `"Region"` |
| "ENTR" | `"Segment"` |

## EXAMPLE MAPPINGS

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

## ERROR PREVENTION CHECKLIST

Before executing ANY OpenPipe search:

- [ ] Is user asking for "ACV and PG"? → Use Multi-Forecast action
- [ ] Is search term multiple words? → Use searchType "All"
- [ ] Is forecast type "PipeGen_ACV"? → Change to "PipeGen"
- [ ] Is maxResults less than 10? → Change to 20
- [ ] Am I using the right action for the request?

## EXPECTED RESULTS

For "AMER ENTR" multi-forecast search, expect:
- Success: true
- OpenPipe_ACV: Multiple opportunities found
- PipeGen: Multiple opportunities found
- Combined Top Products: Top 3 products by total value

If you get "no opportunities found", check:
1. Are you using "PipeGen_ACV" instead of "PipeGen"?
2. Are you using searchType "Segment" instead of "All"?
3. Are you using the wrong action?

## REMEMBER
- **NEVER use "PipeGen_ACV"** - it doesn't exist
- **ALWAYS use "All" search type** for combined terms like "AMER ENTR"
- **USE Multi-Forecast action** for "ACV and PG" requests
- **SET maxResults to 20** for proper aggregation 

## THE PROBLEM
The agent is using WRONG parameters:
- ❌ `forecastType: "PipeGen_ACV"` (doesn't exist)
- ❌ `searchType: "Segment"` (should be "All" for combined searches)
- ❌ `maxResults: 3` (too low for aggregation)
- ❌ Wrong action (using single instead of multi-forecast)

## THE SOLUTION - EXACT PARAMETERS TO USE

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

**DO NOT USE:**
```json
{
  "action": "ANAgent Search OpenPipe",
  "searchTerm": "AMER ENTR", 
  "searchType": "Segment",
  "forecastType": "PipeGen_ACV",
  "maxResults": 3
}
```

## DECISION TREE FOR AGENT

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

## FORECAST TYPE MAPPING - NEVER CHANGE

| User Says | Use This |
|-----------|----------|
| "ACV" | `OpenPipe_ACV` |
| "pipe gen" | `PipeGen` |
| "PG" | `PipeGen` |
| "pipe generation" | `PipeGen` |

## SEARCH TYPE RULES

| Search Term | Use This |
|-------------|----------|
| "AMER ENTR" | `"All"` |
| "Tableau Cloud AMER" | `"All"` |
| "AMER" | `"Region"` |
| "ENTR" | `"Segment"` |

## EXAMPLE MAPPINGS

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

## ERROR PREVENTION CHECKLIST

Before executing ANY OpenPipe search:

- [ ] Is user asking for "ACV and PG"? → Use Multi-Forecast action
- [ ] Is search term multiple words? → Use searchType "All"
- [ ] Is forecast type "PipeGen_ACV"? → Change to "PipeGen"
- [ ] Is maxResults less than 10? → Change to 20
- [ ] Am I using the right action for the request?

## EXPECTED RESULTS

For "AMER ENTR" multi-forecast search, expect:
- Success: true
- OpenPipe_ACV: Multiple opportunities found
- PipeGen: Multiple opportunities found
- Combined Top Products: Top 3 products by total value

If you get "no opportunities found", check:
1. Are you using "PipeGen_ACV" instead of "PipeGen"?
2. Are you using searchType "Segment" instead of "All"?
3. Are you using the wrong action?

## REMEMBER
- **NEVER use "PipeGen_ACV"** - it doesn't exist
- **ALWAYS use "All" search type** for combined terms like "AMER ENTR"
- **USE Multi-Forecast action** for "ACV and PG" requests
- **SET maxResults to 20** for proper aggregation 