# 🚨 CRITICAL: GOVERNOR LIMIT FIX INSTRUCTIONS

## 🚨 URGENT: System.LimitException: Too many query rows: 50001

**The agent is hitting Salesforce governor limits because it's using WRONG parameters.**

### ❌ WHAT'S CAUSING THE ERROR:

The agent is using these parameters:
```json
{
  "searchTerm": "AMER ENTR",
  "searchType": "Segment",        // ❌ WRONG - "AMER" is not a segment
  "maxResults": "3",              // ❌ TOO LOW
  "forecastType": "PipeGen"       // ❌ Should use Multi-Forecast action
}
```

**Problem**: `searchType: "Segment"` with `searchTerm: "AMER ENTR"` searches for "ENTR" in segment fields, but "AMER" is a region, not a segment. This creates a very broad query that returns >50,000 records.

### ✅ EXACT SOLUTION:

**For user query: "show me top 3 pipe gen and top 3 acv products in AMER ENTR segment"**

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
  "forecastType": "PipeGen",
  "maxResults": 3
}
```

## 🔧 PARAMETER MAPPING RULES

### Search Type Rules:
| Search Term | Correct Search Type | Why |
|-------------|-------------------|-----|
| "AMER ENTR" | `"All"` | Multiple words need "All" search type |
| "AMER" | `"Region"` | Single region term |
| "ENTR" | `"Segment"` | Single segment term |
| "Tableau Cloud" | `"All"` | Multiple words need "All" search type |

### Action Selection Rules:
| User Request | Use Action | Why |
|-------------|------------|-----|
| "ACV and PG" | Multi-Forecast | Combines both forecast types |
| "pipe gen and acv" | Multi-Forecast | Combines both forecast types |
| "top 3 pipe gen and top 3 acv" | Multi-Forecast | Combines both forecast types |
| "only ACV" | Single | Single forecast type |
| "only pipe gen" | Single | Single forecast type |

### Max Results Rules:
| Request | Use Max Results | Why |
|---------|----------------|-----|
| "top 3" | `20` | Need more data to aggregate top 3 |
| "top 5" | `30` | Need more data to aggregate top 5 |
| "top 10" | `50` | Need more data to aggregate top 10 |

## 🎯 DECISION TREE

### Step 1: Analyze User Query
- Does it contain "ACV and PG" or "pipe gen and acv"? → Use Multi-Forecast
- Does it contain multiple words in search term? → Use searchType "All"
- Does it ask for "top X"? → Use maxResults = X * 7

### Step 2: Choose Action
- **Multi-Forecast**: For combined ACV + PG requests
- **Single**: For single forecast type requests

### Step 3: Set Parameters
- **searchTerm**: Keep user's exact search term
- **searchType**: "All" for multiple words, specific for single words
- **maxResults**: At least 20 for "top 3" requests
- **forecastType**: Only for Single action, leave blank for Multi-Forecast

## 📋 EXAMPLE MAPPINGS

### Example 1: "show me top 3 pipe gen and top 3 acv products in AMER ENTR segment"
```json
{
  "action": "ANAgent Search OpenPipe Multi-Forecast",
  "searchTerm": "AMER ENTR",
  "searchType": "All",
  "maxResults": 20
}
```

### Example 2: "ACV opportunities in AMER"
```json
{
  "action": "ANAgent Search OpenPipe",
  "searchTerm": "AMER",
  "searchType": "Region",
  "forecastType": "OpenPipe_ACV",
  "maxResults": 20
}
```

### Example 3: "pipe gen in ENTR segment"
```json
{
  "action": "ANAgent Search OpenPipe",
  "searchTerm": "ENTR",
  "searchType": "Segment",
  "forecastType": "PipeGen",
  "maxResults": 20
}
```

## 🛡️ ERROR PREVENTION CHECKLIST

Before executing ANY OpenPipe search:

- [ ] Is user asking for "ACV and PG"? → Use Multi-Forecast action
- [ ] Does search term contain spaces? → Use searchType "All"
- [ ] Is maxResults less than 10? → Change to 20
- [ ] Am I using the right action for the request?
- [ ] Is searchType appropriate for the search term?

## 🚨 CRITICAL WARNINGS

1. **NEVER use `searchType: "Segment"` with `searchTerm: "AMER ENTR"`** - This causes governor limit errors
2. **NEVER use `maxResults: 3`** - Too low for aggregation
3. **ALWAYS use Multi-Forecast action for "ACV and PG" requests**
4. **ALWAYS use `searchType: "All"` for combined search terms**

## 🎉 EXPECTED RESULTS

With correct parameters, expect:
- Success: true
- No governor limit errors
- Proper aggregation of top products
- Clear product summaries

## 🔄 FALLBACK BEHAVIOR

If you accidentally use wrong parameters:
- System will automatically detect and fix some issues
- But it's better to use correct parameters from the start
- Always prefer Multi-Forecast action for combined requests

**REMEMBER: The key is using the Multi-Forecast action with searchType "All" for combined searches!** 🚀 

## 🚨 URGENT: System.LimitException: Too many query rows: 50001

**The agent is hitting Salesforce governor limits because it's using WRONG parameters.**

### ❌ WHAT'S CAUSING THE ERROR:

The agent is using these parameters:
```json
{
  "searchTerm": "AMER ENTR",
  "searchType": "Segment",        // ❌ WRONG - "AMER" is not a segment
  "maxResults": "3",              // ❌ TOO LOW
  "forecastType": "PipeGen"       // ❌ Should use Multi-Forecast action
}
```

**Problem**: `searchType: "Segment"` with `searchTerm: "AMER ENTR"` searches for "ENTR" in segment fields, but "AMER" is a region, not a segment. This creates a very broad query that returns >50,000 records.

### ✅ EXACT SOLUTION:

**For user query: "show me top 3 pipe gen and top 3 acv products in AMER ENTR segment"**

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
  "forecastType": "PipeGen",
  "maxResults": 3
}
```

## 🔧 PARAMETER MAPPING RULES

### Search Type Rules:
| Search Term | Correct Search Type | Why |
|-------------|-------------------|-----|
| "AMER ENTR" | `"All"` | Multiple words need "All" search type |
| "AMER" | `"Region"` | Single region term |
| "ENTR" | `"Segment"` | Single segment term |
| "Tableau Cloud" | `"All"` | Multiple words need "All" search type |

### Action Selection Rules:
| User Request | Use Action | Why |
|-------------|------------|-----|
| "ACV and PG" | Multi-Forecast | Combines both forecast types |
| "pipe gen and acv" | Multi-Forecast | Combines both forecast types |
| "top 3 pipe gen and top 3 acv" | Multi-Forecast | Combines both forecast types |
| "only ACV" | Single | Single forecast type |
| "only pipe gen" | Single | Single forecast type |

### Max Results Rules:
| Request | Use Max Results | Why |
|---------|----------------|-----|
| "top 3" | `20` | Need more data to aggregate top 3 |
| "top 5" | `30` | Need more data to aggregate top 5 |
| "top 10" | `50` | Need more data to aggregate top 10 |

## 🎯 DECISION TREE

### Step 1: Analyze User Query
- Does it contain "ACV and PG" or "pipe gen and acv"? → Use Multi-Forecast
- Does it contain multiple words in search term? → Use searchType "All"
- Does it ask for "top X"? → Use maxResults = X * 7

### Step 2: Choose Action
- **Multi-Forecast**: For combined ACV + PG requests
- **Single**: For single forecast type requests

### Step 3: Set Parameters
- **searchTerm**: Keep user's exact search term
- **searchType**: "All" for multiple words, specific for single words
- **maxResults**: At least 20 for "top 3" requests
- **forecastType**: Only for Single action, leave blank for Multi-Forecast

## 📋 EXAMPLE MAPPINGS

### Example 1: "show me top 3 pipe gen and top 3 acv products in AMER ENTR segment"
```json
{
  "action": "ANAgent Search OpenPipe Multi-Forecast",
  "searchTerm": "AMER ENTR",
  "searchType": "All",
  "maxResults": 20
}
```

### Example 2: "ACV opportunities in AMER"
```json
{
  "action": "ANAgent Search OpenPipe",
  "searchTerm": "AMER",
  "searchType": "Region",
  "forecastType": "OpenPipe_ACV",
  "maxResults": 20
}
```

### Example 3: "pipe gen in ENTR segment"
```json
{
  "action": "ANAgent Search OpenPipe",
  "searchTerm": "ENTR",
  "searchType": "Segment",
  "forecastType": "PipeGen",
  "maxResults": 20
}
```

## 🛡️ ERROR PREVENTION CHECKLIST

Before executing ANY OpenPipe search:

- [ ] Is user asking for "ACV and PG"? → Use Multi-Forecast action
- [ ] Does search term contain spaces? → Use searchType "All"
- [ ] Is maxResults less than 10? → Change to 20
- [ ] Am I using the right action for the request?
- [ ] Is searchType appropriate for the search term?

## 🚨 CRITICAL WARNINGS

1. **NEVER use `searchType: "Segment"` with `searchTerm: "AMER ENTR"`** - This causes governor limit errors
2. **NEVER use `maxResults: 3`** - Too low for aggregation
3. **ALWAYS use Multi-Forecast action for "ACV and PG" requests**
4. **ALWAYS use `searchType: "All"` for combined search terms**

## 🎉 EXPECTED RESULTS

With correct parameters, expect:
- Success: true
- No governor limit errors
- Proper aggregation of top products
- Clear product summaries

## 🔄 FALLBACK BEHAVIOR

If you accidentally use wrong parameters:
- System will automatically detect and fix some issues
- But it's better to use correct parameters from the start
- Always prefer Multi-Forecast action for combined requests

**REMEMBER: The key is using the Multi-Forecast action with searchType "All" for combined searches!** 🚀 