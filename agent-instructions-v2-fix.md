# 🎯 V2 OpenPipe Classes - Simple Instructions

## ✅ What's Fixed
- **New V2 Classes**: `ANAgent Search OpenPipe V2` (use this instead of the old one)
- **Correct Forecast Types**: Only `OpenPipe_ACV` and `PipeGen` are valid (NOT `PipeGen_ACV`)
- **Simplified Code**: Clean, simple implementation without complex governor limit handling

## 🚀 How to Use

### For Single Forecast Type Searches:
```json
{
  "action": "ANAgent Search OpenPipe V2",
  "searchTerm": "AMER ENTR",
  "searchType": "All",
  "forecastType": "PipeGen",
  "maxResults": 20
}
```

### For Combined Searches (ACV + PG):
```json
{
  "action": "ANAgent Search OpenPipe V2",
  "searchTerm": "AMER ENTR",
  "searchType": "All",
  "maxResults": 20
}
```

## 📋 Key Rules

1. **Use V2 Action**: Always use `ANAgent Search OpenPipe V2`
2. **Correct Forecast Types**: 
   - ✅ `OpenPipe_ACV` (for ACV searches)
   - ✅ `PipeGen` (for pipe generation searches)
   - ❌ `PipeGen_ACV` (does NOT exist)
3. **Search Type**: Use `"All"` for combined searches like "AMER ENTR"
4. **Max Results**: Use `20` for good aggregation results

## 🔍 Examples

| User Request | Action | Parameters |
|-------------|--------|------------|
| "top 3 pipegen products in AMER ENTR" | V2 | searchTerm: "AMER ENTR", searchType: "All", forecastType: "PipeGen", maxResults: 20 |
| "ACV opportunities in ENTR segment" | V2 | searchTerm: "ENTR", searchType: "Segment", forecastType: "OpenPipe_ACV", maxResults: 20 |
| "both ACV and PG in AMER" | V2 | searchTerm: "AMER", searchType: "All", maxResults: 20 |

## ⚠️ Important Notes

- **Don't use the old action** - it has governor limit issues
- **Don't use `PipeGen_ACV`** - it doesn't exist in the data
- **Use `searchType: "All"`** for multi-word search terms
- **Keep `maxResults` at 20** to avoid governor limits

**That's it! Use the V2 action with correct parameters.** 🚀 

## ✅ What's Fixed
- **New V2 Classes**: `ANAgent Search OpenPipe V2` (use this instead of the old one)
- **Correct Forecast Types**: Only `OpenPipe_ACV` and `PipeGen` are valid (NOT `PipeGen_ACV`)
- **Simplified Code**: Clean, simple implementation without complex governor limit handling

## 🚀 How to Use

### For Single Forecast Type Searches:
```json
{
  "action": "ANAgent Search OpenPipe V2",
  "searchTerm": "AMER ENTR",
  "searchType": "All",
  "forecastType": "PipeGen",
  "maxResults": 20
}
```

### For Combined Searches (ACV + PG):
```json
{
  "action": "ANAgent Search OpenPipe V2",
  "searchTerm": "AMER ENTR",
  "searchType": "All",
  "maxResults": 20
}
```

## 📋 Key Rules

1. **Use V2 Action**: Always use `ANAgent Search OpenPipe V2`
2. **Correct Forecast Types**: 
   - ✅ `OpenPipe_ACV` (for ACV searches)
   - ✅ `PipeGen` (for pipe generation searches)
   - ❌ `PipeGen_ACV` (does NOT exist)
3. **Search Type**: Use `"All"` for combined searches like "AMER ENTR"
4. **Max Results**: Use `20` for good aggregation results

## 🔍 Examples

| User Request | Action | Parameters |
|-------------|--------|------------|
| "top 3 pipegen products in AMER ENTR" | V2 | searchTerm: "AMER ENTR", searchType: "All", forecastType: "PipeGen", maxResults: 20 |
| "ACV opportunities in ENTR segment" | V2 | searchTerm: "ENTR", searchType: "Segment", forecastType: "OpenPipe_ACV", maxResults: 20 |
| "both ACV and PG in AMER" | V2 | searchTerm: "AMER", searchType: "All", maxResults: 20 |

## ⚠️ Important Notes

- **Don't use the old action** - it has governor limit issues
- **Don't use `PipeGen_ACV`** - it doesn't exist in the data
- **Use `searchType: "All"`** for multi-word search terms
- **Keep `maxResults` at 20** to avoid governor limits

**That's it! Use the V2 action with correct parameters.** 🚀 