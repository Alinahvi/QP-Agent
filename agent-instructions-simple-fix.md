# 🎯 SIMPLE FIX: Use Multi-Forecast Action

## The Problem
The agent is using the wrong action and getting governor limit errors.

## The Solution
**Use the Multi-Forecast action for combined requests.**

### For User Query: "show me top 5 pipegen products with highest volume in AMER ENTR segment"

**❌ DON'T USE THIS (causes governor limit errors):**
```json
{
  "action": "ANAgent Search OpenPipe",
  "searchTerm": "AMER ENTR",
  "searchType": "Segment",
  "forecastType": "PipeGen",
  "maxResults": 5
}
```

**✅ USE THIS INSTEAD:**
```json
{
  "action": "ANAgent Search OpenPipe Multi-Forecast",
  "searchTerm": "AMER ENTR",
  "searchType": "All",
  "maxResults": 20
}
```

## Simple Rules

1. **If user asks for "pipegen" or "ACV" or both** → Use Multi-Forecast action
2. **If search term has multiple words** → Use searchType "All"
3. **For "top X" requests** → Use maxResults = 20 (not X)

## Examples

| User Request | Use Action | Parameters |
|-------------|------------|------------|
| "top 5 pipegen products in AMER ENTR" | Multi-Forecast | searchTerm: "AMER ENTR", searchType: "All", maxResults: 20 |
| "ACV and PG in AMER" | Multi-Forecast | searchTerm: "AMER", searchType: "All", maxResults: 20 |
| "only ACV in ENTR" | Single | searchTerm: "ENTR", searchType: "Segment", forecastType: "OpenPipe_ACV", maxResults: 20 |

## Key Points

- **Multi-Forecast action** handles both ACV and PG automatically
- **searchType "All"** works better for combined search terms
- **maxResults 20** gives enough data for aggregation
- **Don't specify forecastType** in Multi-Forecast action

**That's it! Use Multi-Forecast action for combined requests.** 🚀 

## The Problem
The agent is using the wrong action and getting governor limit errors.

## The Solution
**Use the Multi-Forecast action for combined requests.**

### For User Query: "show me top 5 pipegen products with highest volume in AMER ENTR segment"

**❌ DON'T USE THIS (causes governor limit errors):**
```json
{
  "action": "ANAgent Search OpenPipe",
  "searchTerm": "AMER ENTR",
  "searchType": "Segment",
  "forecastType": "PipeGen",
  "maxResults": 5
}
```

**✅ USE THIS INSTEAD:**
```json
{
  "action": "ANAgent Search OpenPipe Multi-Forecast",
  "searchTerm": "AMER ENTR",
  "searchType": "All",
  "maxResults": 20
}
```

## Simple Rules

1. **If user asks for "pipegen" or "ACV" or both** → Use Multi-Forecast action
2. **If search term has multiple words** → Use searchType "All"
3. **For "top X" requests** → Use maxResults = 20 (not X)

## Examples

| User Request | Use Action | Parameters |
|-------------|------------|------------|
| "top 5 pipegen products in AMER ENTR" | Multi-Forecast | searchTerm: "AMER ENTR", searchType: "All", maxResults: 20 |
| "ACV and PG in AMER" | Multi-Forecast | searchTerm: "AMER", searchType: "All", maxResults: 20 |
| "only ACV in ENTR" | Single | searchTerm: "ENTR", searchType: "Segment", forecastType: "OpenPipe_ACV", maxResults: 20 |

## Key Points

- **Multi-Forecast action** handles both ACV and PG automatically
- **searchType "All"** works better for combined search terms
- **maxResults 20** gives enough data for aggregation
- **Don't specify forecastType** in Multi-Forecast action

**That's it! Use Multi-Forecast action for combined requests.** 🚀 