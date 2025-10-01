# OpenPipe Opportunity Search - Enhanced Agent Instructions

## 🚨 CRITICAL FORECAST TYPE FIX

### The Problem:
The agent was using `PipeGen_ACV` which does not exist, causing "no opportunities found" errors.

### The Solution:
Use the correct forecast type names:
- ✅ **OpenPipe_ACV** (for ACV opportunities)
- ✅ **PipeGen** (for pipe generation opportunities)
- ❌ **PipeGen_ACV** (DOES NOT EXIST - causes errors)

## 📋 Updated Agent Instructions

### For OpenPipe Opportunity Search:

#### When Users Ask For:
- "ACV opportunities" → Use `OpenPipe_ACV` forecast type
- "Pipe generation opportunities" → Use `PipeGen` forecast type  
- "ACV and PG volume" → Use **Multi-Forecast action**
- "both forecast types" → Use **Multi-Forecast action**
- "pipe gen and acv" → Use **Multi-Forecast action**
- "top 3 pipe gen and top 3 acv" → Use **Multi-Forecast action**

#### Recommended Actions:

**1. For Single Forecast Type Searches:**
Use "ANAgent Search OpenPipe" action with:
- searchTerm: "AMER ENTR" (for combined searches)
- searchType: "All" (for combined searches)
- forecastType: "OpenPipe_ACV" OR "PipeGen" (NOT "PipeGen_ACV")
- maxResults: 20 (for top 3 product aggregation)

**2. For Multi-Forecast Type Searches (RECOMMENDED):**
Use "ANAgent Search OpenPipe Multi-Forecast" action with:
- searchTerm: "AMER ENTR" (for combined searches)
- searchType: "All" (for combined searches)
- maxResults: 20 (for top 3 product aggregation)

#### Why Use Multi-Forecast Action:
- ✅ Automatically uses correct forecast types
- ✅ Prevents "PipeGen_ACV" errors
- ✅ Combines results from both types
- ✅ Provides top 3 products across both forecast types
- ✅ Handles complex queries like "show me top 3 pipe gen and top 3 acv products"

#### Combined Search Examples:
- "AMER ENTR" → Searches for both ENTR segment AND AMER region
- "Tableau Cloud AMER" → Searches for both product AND region
- "FINS ENTR" → Searches for both vertical AND segment

#### Expected Results:
For "AMER ENTR" multi-forecast search, you should get:
- **OpenPipe_ACV**: Multiple opportunities with products like Tableau Cloud, Analytics - Success Plans, Other
- **PipeGen**: Multiple opportunities with products like Developer Services, Revenue Cloud, Sales - Success Plans
- **Combined Top Products**: Top 3 products by total value across both forecast types

## 🎯 Key Points for Agent:

1. **NEVER use "PipeGen_ACV"** - this forecast type does not exist
2. **Use "PipeGen"** for pipe generation opportunities
3. **Use "OpenPipe_ACV"** for ACV opportunities
4. **Use Multi-Forecast action** for combined ACV and PG requests
5. **Use "All" search type** for combined searches like "AMER ENTR"
6. **Set maxResults to 20** to ensure enough data for top 3 aggregation

## 📊 Example Response Format:

When using Multi-Forecast action for "AMER ENTR":
```
Multi-forecast search results for "AMER ENTR":
OpenPipe_ACV: 10 opportunities, Product breakdown: Tableau Cloud: $1,018M, Other: $436M, Analytics - Success Plans: $424M
PipeGen: 10 opportunities, Product breakdown: Developer Services: $36M, Revenue Cloud: $31M, Sales - Success Plans: $31M

Combined Top Products: Tableau Cloud: $1,018,265,228, Other: $436,147,928, Analytics - Success Plans: $423,945,761
```

This will give users exactly what they asked for: top 3 products based on both ACV and PG volume in the AMER ENTR segment. 

## 🚨 CRITICAL FORECAST TYPE FIX

### The Problem:
The agent was using `PipeGen_ACV` which does not exist, causing "no opportunities found" errors.

### The Solution:
Use the correct forecast type names:
- ✅ **OpenPipe_ACV** (for ACV opportunities)
- ✅ **PipeGen** (for pipe generation opportunities)
- ❌ **PipeGen_ACV** (DOES NOT EXIST - causes errors)

## 📋 Updated Agent Instructions

### For OpenPipe Opportunity Search:

#### When Users Ask For:
- "ACV opportunities" → Use `OpenPipe_ACV` forecast type
- "Pipe generation opportunities" → Use `PipeGen` forecast type  
- "ACV and PG volume" → Use **Multi-Forecast action**
- "both forecast types" → Use **Multi-Forecast action**
- "pipe gen and acv" → Use **Multi-Forecast action**
- "top 3 pipe gen and top 3 acv" → Use **Multi-Forecast action**

#### Recommended Actions:

**1. For Single Forecast Type Searches:**
Use "ANAgent Search OpenPipe" action with:
- searchTerm: "AMER ENTR" (for combined searches)
- searchType: "All" (for combined searches)
- forecastType: "OpenPipe_ACV" OR "PipeGen" (NOT "PipeGen_ACV")
- maxResults: 20 (for top 3 product aggregation)

**2. For Multi-Forecast Type Searches (RECOMMENDED):**
Use "ANAgent Search OpenPipe Multi-Forecast" action with:
- searchTerm: "AMER ENTR" (for combined searches)
- searchType: "All" (for combined searches)
- maxResults: 20 (for top 3 product aggregation)

#### Why Use Multi-Forecast Action:
- ✅ Automatically uses correct forecast types
- ✅ Prevents "PipeGen_ACV" errors
- ✅ Combines results from both types
- ✅ Provides top 3 products across both forecast types
- ✅ Handles complex queries like "show me top 3 pipe gen and top 3 acv products"

#### Combined Search Examples:
- "AMER ENTR" → Searches for both ENTR segment AND AMER region
- "Tableau Cloud AMER" → Searches for both product AND region
- "FINS ENTR" → Searches for both vertical AND segment

#### Expected Results:
For "AMER ENTR" multi-forecast search, you should get:
- **OpenPipe_ACV**: Multiple opportunities with products like Tableau Cloud, Analytics - Success Plans, Other
- **PipeGen**: Multiple opportunities with products like Developer Services, Revenue Cloud, Sales - Success Plans
- **Combined Top Products**: Top 3 products by total value across both forecast types

## 🎯 Key Points for Agent:

1. **NEVER use "PipeGen_ACV"** - this forecast type does not exist
2. **Use "PipeGen"** for pipe generation opportunities
3. **Use "OpenPipe_ACV"** for ACV opportunities
4. **Use Multi-Forecast action** for combined ACV and PG requests
5. **Use "All" search type** for combined searches like "AMER ENTR"
6. **Set maxResults to 20** to ensure enough data for top 3 aggregation

## 📊 Example Response Format:

When using Multi-Forecast action for "AMER ENTR":
```
Multi-forecast search results for "AMER ENTR":
OpenPipe_ACV: 10 opportunities, Product breakdown: Tableau Cloud: $1,018M, Other: $436M, Analytics - Success Plans: $424M
PipeGen: 10 opportunities, Product breakdown: Developer Services: $36M, Revenue Cloud: $31M, Sales - Success Plans: $31M

Combined Top Products: Tableau Cloud: $1,018,265,228, Other: $436,147,928, Analytics - Success Plans: $423,945,761
```

This will give users exactly what they asked for: top 3 products based on both ACV and PG volume in the AMER ENTR segment. 