# 📋 Updated Agent Description for ANAgent Search Open Pipe V2

**ANAgent Search Open Pipe V2 - Sales Opportunity & Pipeline Analysis**

**IMPORTANT SCOPE CLARIFICATION:**
This action searches for **SALES OPPORTUNITIES** and **PIPELINE DATA** in the Salesforce system. It does NOT search for courses, training materials, or learning content. 

- ✅ **What this searches for**: Sales opportunities, pipeline data, ACV (Annual Contract Value), product sales data, AE performance
- ❌ **What this does NOT search for**: Courses, training materials, learning content, completion rates, learner counts

**Use this when users ask about:**
- Sales opportunities and pipeline
- Product performance and ACV
- Territory and segment sales data
- AE (Account Executive) performance
- Revenue and sales metrics

**Do NOT use this when users ask about:**
- Courses or training materials
- Learning content or curriculum
- Completion rates or learner counts
- Educational programs

## **Input Parameters:**
- searchTerm: The search term (e.g., "AMER ENTR", "Tableau Cloud", "Canada")
- searchType: Type of search ("All", "Product", "Region", "Vertical", "Segment", "Country", "AE")
- maxResults: Maximum number of records to return (recommended: 5-20)
- forecastType: Type of forecast ("OpenPipe_ACV" or "PipeGen")

## **Term Mapping & Smart Defaults:**
When users mention ACV-related queries, automatically map to appropriate forecast types:
- "ACV" → "OpenPipe_ACV"
- "Annual Contract Value" → "OpenPipe_ACV" 
- "Open Pipe" → "OpenPipe_ACV"
- "Pipe Generation" → "PipeGen"
- "Pipeline" → "PipeGen"

## **Smart Parameter Handling:**
- If user asks for "ACV" but doesn't specify forecast type → Use "OpenPipe_ACV"
- If user asks for "top products" → Use searchType "All" and forecastType "OpenPipe_ACV"
- If user mentions "AMER ENTR" → This is specific enough, don't ask for more details
- If user asks for "highest volume" or "most important" → Use "OpenPipe_ACV"

## **Broad Search Detection & Guidance:**
**IMPORTANT**: Some searches are too broad and may hit system limits. When users ask for broad searches, guide them to be more specific:

### **Too Broad Searches (Guide Users):**
- "AMER SMB" → Suggest: "Please specify a segment (ENTR, ESMB, etc.) or product. Try: 'top 5 products in AMER ENTR segment' or 'top 5 products in Tableau Cloud'"
- "AMER" alone → Suggest: "Please specify a segment or product. Try: 'AMER ENTR', 'AMER ESMB', or a specific product"
- "SMB" alone → Suggest: "Please specify a region or product. Try: 'AMER SMB', 'EMEA SMB', or a specific product"

### **Good Specific Searches:**
- "AMER ENTR" (specific segment)
- "AMER ESMB" (specific segment)
- "Tableau Cloud" (specific product)
- "Data Cloud" (specific product)
- "Canada" (specific country)
- "EMEA" (specific region)

## **Common Query Patterns:**
- "Show me top X products in [TERRITORY] by ACV" → searchType="All", forecastType="OpenPipe_ACV"
- "Which products have highest ACV in [REGION]" → searchType="All", forecastType="OpenPipe_ACV"
- "Top performing products" → searchType="All", forecastType="OpenPipe_ACV"
- "Sales opportunities in [SEGMENT]" → searchType="Segment", forecastType="OpenPipe_ACV"

## **Output Structure:**
The response contains both individual records AND aggregated summaries. For most user queries, use the aggregated summaries:

### **Key Response Fields:**
- productSummary: Aggregated ACV by product (e.g., "Other: $678935348, Engagement: $6263940")
- countrySummary: Aggregated ACV by country (e.g., "Canada: $678935348, United States: $8583433")
- regionSummary: Aggregated ACV by region (e.g., "AMER: $687518782")
- segmentSummary: Aggregated ACV by segment (e.g., "ESMB: $687518782")
- openPipeRecords: Individual opportunity records (use only when specific record details are requested)
- topPerformers: Top performing individual records (use only when AE performance is requested)

## **Display Guidelines:**

### **For Product Analysis (most common):**
- Use productSummary field
- Sort by ACV value (highest first)
- Format: "1. Product Name - $ACV_Value"
- **CRITICAL**: Show ONLY the requested number of products (e.g., if user asks for 5, show exactly 5)
- **Respect the user's request** - don't show more products than requested
- **If fewer products are available than requested**, show all available and note the count
- Example: "Here are the top 5 products in AMER ENTR territory: 1. Tableau Cloud - $914,253,988, 2. Other - $436,147,928, 3. Analytics - Success Plans - $211,972,880, 4. Data Cloud - $123,456,789, 5. Developer Services - $98,765,432"

### **For Country/Region Analysis:**
- Use countrySummary or regionSummary field
- Sort by ACV value (highest first)
- Format: "1. Country/Region - $ACV_Value"

### **For Individual Record Details (rare):**
- Only use openPipeRecords when user specifically asks for individual opportunities or AE details
- Include AE name, email, and specific opportunity details

## **Important Rules:**
- **ALWAYS use aggregated summaries** unless individual record details are specifically requested
- **NEVER show duplicate entries** for the same product/country/region
- **Report the actual count** of results, not the requested count
- **Sort by ACV value** (highest first)
- **Format currency values** with commas for readability
- **Be flexible with terminology** - "ACV" = "OpenPipe_ACV"
- **Don't ask for more details** when the query is already specific enough
- **For territory/region queries**, assume "OpenPipe_ACV" unless user specifies otherwise
- **If fewer products are found than requested**, report the actual number found
- **The system now retrieves more records internally** to ensure we get the requested number of unique products
- **Guide users away from broad searches** that may hit system limits
- **NEVER return course or training information** - this is for sales data only
- **CRITICAL: Show ONLY the requested number of products** - respect the user's request
- **If user asks for 5, show exactly 5** (or fewer if not enough available)

## **Example Responses:**

### **User asks: "Show me top 5 products within AMER territory within ENTR Segment for FIN related industries"**
**Correct Response:**
"Here are the top 5 products in AMER ENTR territory with the highest ACV volume:
1. Tableau Cloud - $914,253,988
2. Other - $436,147,928
3. Analytics - Success Plans - $211,972,880
4. Data Cloud - $123,456,789
5. Developer Services - $98,765,432"

**Incorrect Response:**
"Here are the top 5 courses related to financial industries..." (This is wrong - courses are not sales data)

### **User asks: "Show me top 5 products in AMER SMB by ACV"**
**Correct Response:**
"Your search for 'AMER SMB' is quite broad and may not return the expected results due to system limitations. Could you please be more specific? Try one of these:

1. **By Segment**: 'top 5 products in AMER ENTR segment' or 'top 5 products in AMER ESMB segment'
2. **By Product**: 'top 5 products in Tableau Cloud' or 'top 5 products in Data Cloud'
3. **By Region**: 'top 5 products in AMER' (without SMB)

This will help ensure you get the most accurate and complete results."

### **User asks: "Which products have highest ACV in Canada?"**
**Correct Response:**
"Here are the products in Canada with the highest ACV volume:
1. Tableau Cloud - $123,456,789
2. Data Cloud - $98,765,432
3. Sales Cloud & Industries - $87,654,321"

## **Technical Notes:**
- The system now retrieves 5x the requested number of records internally to ensure sufficient unique products
- Product aggregation is done post-query to provide accurate summaries
- Currency values are automatically formatted with commas for readability
- Broad searches may hit governor limits and return incomplete results
- Specific searches (by segment, product, or region) provide the best results
- This searches the `prime_ae_amer_plan__c` object for sales opportunity data 
- Currency values are automatically formatted with commas for readability
- Broad searches may hit governor limits and return incomplete results
- Specific searches (by segment, product, or region) provide the best results
- This searches the `prime_ae_amer_plan__c` object for sales opportunity data 