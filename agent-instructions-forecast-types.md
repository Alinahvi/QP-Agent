# 🚨 CRITICAL FORECAST TYPE INSTRUCTIONS

## FORECAST TYPE MAPPING - NEVER CHANGE THESE

### When User Says → Use This Forecast Type:
- "ACV" → `OpenPipe_ACV`
- "annual contract value" → `OpenPipe_ACV`
- "open pipe" → `OpenPipe_ACV`
- "pipe gen" → `PipeGen`
- "pipe generation" → `PipeGen`
- "PG" → `PipeGen`

### ❌ NEVER USE THESE (They Don't Exist):
- `PipeGen_ACV` ← This causes "no opportunities found" errors
- `OpenPipe_PG` ← This doesn't exist
- `ACV_PipeGen` ← This doesn't exist

## ACTION SELECTION RULES

### Use "ANAgent Search OpenPipe Multi-Forecast" When User Says:
- "ACV and PG"
- "pipe gen and acv"
- "both forecast types"
- "top 3 pipe gen and top 3 acv"
- "ACV and pipe generation"
- "show me both"
- "combined results"

### Use "ANAgent Search OpenPipe" When User Says:
- "only ACV"
- "only pipe gen"
- "just ACV"
- "just pipe generation"
- "ACV only"
- "pipe gen only"

## SEARCH TYPE RULES

### Use `"All"` When Search Term Contains:
- Multiple words (e.g., "AMER ENTR", "Tableau Cloud AMER")
- Region + Segment combinations
- Product + Region combinations
- Any combined criteria

### Use Specific Search Types When:
- Single word searches (e.g., "AMER", "ENTR", "Tableau")
- Clear single dimension searches

## EXAMPLE MAPPINGS

### User Query: "show me top 3 pipe gen and top 3 acv products in AMER ENTR segment"
**CORRECT PARAMETERS:**
```json
{
  "action": "ANAgent Search OpenPipe Multi-Forecast",
  "searchTerm": "AMER ENTR",
  "searchType": "All",
  "maxResults": 20
}
```

**WRONG PARAMETERS (What agent is currently using):**
```json
{
  "action": "ANAgent Search OpenPipe",
  "searchTerm": "AMER ENTR",
  "searchType": "Segment",
  "forecastType": "PipeGen_ACV",
  "maxResults": 3
}
```

### User Query: "ACV opportunities in AMER"
**CORRECT PARAMETERS:**
```json
{
  "action": "ANAgent Search OpenPipe",
  "searchTerm": "AMER",
  "searchType": "Region",
  "forecastType": "OpenPipe_ACV",
  "maxResults": 20
}
```

## QUICK REFERENCE CHART

| User Request | Action | Search Term | Search Type | Forecast Type | Max Results |
|-------------|--------|-------------|-------------|---------------|-------------|
| "ACV and PG in AMER ENTR" | Multi-Forecast | "AMER ENTR" | "All" | (auto) | 20 |
| "only ACV in AMER" | Single | "AMER" | "Region" | "OpenPipe_ACV" | 20 |
| "only pipe gen in ENTR" | Single | "ENTR" | "Segment" | "PipeGen" | 20 |
| "both types in Tableau Cloud" | Multi-Forecast | "Tableau Cloud" | "All" | (auto) | 20 |

## ERROR PREVENTION CHECKLIST

Before executing any OpenPipe search, verify:
- [ ] NOT using `PipeGen_ACV` (use `PipeGen` instead)
- [ ] Using `"All"` search type for combined terms
- [ ] Using Multi-Forecast action for "ACV and PG" requests
- [ ] Setting maxResults to 20 for top 3 aggregation
- [ ] Using correct forecast type mapping from the table above 

## FORECAST TYPE MAPPING - NEVER CHANGE THESE

### When User Says → Use This Forecast Type:
- "ACV" → `OpenPipe_ACV`
- "annual contract value" → `OpenPipe_ACV`
- "open pipe" → `OpenPipe_ACV`
- "pipe gen" → `PipeGen`
- "pipe generation" → `PipeGen`
- "PG" → `PipeGen`

### ❌ NEVER USE THESE (They Don't Exist):
- `PipeGen_ACV` ← This causes "no opportunities found" errors
- `OpenPipe_PG` ← This doesn't exist
- `ACV_PipeGen` ← This doesn't exist

## ACTION SELECTION RULES

### Use "ANAgent Search OpenPipe Multi-Forecast" When User Says:
- "ACV and PG"
- "pipe gen and acv"
- "both forecast types"
- "top 3 pipe gen and top 3 acv"
- "ACV and pipe generation"
- "show me both"
- "combined results"

### Use "ANAgent Search OpenPipe" When User Says:
- "only ACV"
- "only pipe gen"
- "just ACV"
- "just pipe generation"
- "ACV only"
- "pipe gen only"

## SEARCH TYPE RULES

### Use `"All"` When Search Term Contains:
- Multiple words (e.g., "AMER ENTR", "Tableau Cloud AMER")
- Region + Segment combinations
- Product + Region combinations
- Any combined criteria

### Use Specific Search Types When:
- Single word searches (e.g., "AMER", "ENTR", "Tableau")
- Clear single dimension searches

## EXAMPLE MAPPINGS

### User Query: "show me top 3 pipe gen and top 3 acv products in AMER ENTR segment"
**CORRECT PARAMETERS:**
```json
{
  "action": "ANAgent Search OpenPipe Multi-Forecast",
  "searchTerm": "AMER ENTR",
  "searchType": "All",
  "maxResults": 20
}
```

**WRONG PARAMETERS (What agent is currently using):**
```json
{
  "action": "ANAgent Search OpenPipe",
  "searchTerm": "AMER ENTR",
  "searchType": "Segment",
  "forecastType": "PipeGen_ACV",
  "maxResults": 3
}
```

### User Query: "ACV opportunities in AMER"
**CORRECT PARAMETERS:**
```json
{
  "action": "ANAgent Search OpenPipe",
  "searchTerm": "AMER",
  "searchType": "Region",
  "forecastType": "OpenPipe_ACV",
  "maxResults": 20
}
```

## QUICK REFERENCE CHART

| User Request | Action | Search Term | Search Type | Forecast Type | Max Results |
|-------------|--------|-------------|-------------|---------------|-------------|
| "ACV and PG in AMER ENTR" | Multi-Forecast | "AMER ENTR" | "All" | (auto) | 20 |
| "only ACV in AMER" | Single | "AMER" | "Region" | "OpenPipe_ACV" | 20 |
| "only pipe gen in ENTR" | Single | "ENTR" | "Segment" | "PipeGen" | 20 |
| "both types in Tableau Cloud" | Multi-Forecast | "Tableau Cloud" | "All" | (auto) | 20 |

## ERROR PREVENTION CHECKLIST

Before executing any OpenPipe search, verify:
- [ ] NOT using `PipeGen_ACV` (use `PipeGen` instead)
- [ ] Using `"All"` search type for combined terms
- [ ] Using Multi-Forecast action for "ACV and PG" requests
- [ ] Setting maxResults to 20 for top 3 aggregation
- [ ] Using correct forecast type mapping from the table above 