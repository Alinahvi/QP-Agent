# Agent Action Configuration - SME Search V3

## Quick Reference Card

**Action Name:** Search SMEs V3  
**Handler Class:** ANAgentSMESearchHandlerV3  
**Invocable Method Label:** Search SMEs V3  
**Type:** Apex Invocable Method  
**Status:** Production Ready ✅

---

## 📝 Step-by-Step Configuration

### Step 1: Access Agent Builder
1. Navigate to **Setup** in Salesforce
2. Search for **Agents** in Quick Find
3. Click **Agents**
4. Select your agent or create a new one
5. Click **Open in Builder**

---

### Step 2: Add New Action

1. In Agent Builder, click **Actions** tab
2. Click **+ New Action** button
3. Select **Apex** as the action type
4. Find and select **"Search SMEs V3"** from the dropdown
   - If not visible, verify deployment and refresh browser

---

### Step 3: Configure Action Name & Reference Name

**Action Name (Display):**
```
SME Search V3
```

**Reference Name (API Name):**
```
ANAgent_Search_SMEs_V3
```

---

### Step 4: Input Instructions

Copy and paste this into the **Input Instructions** field:

```
Search for Subject Matter Experts (SMEs) by product expertise or name.

## Required Parameters

**searchTerm** (required): 
- The product name or person name to search for
- Examples: "Tableau", "Data Cloud", "MuleSoft", "Sales Cloud", "Einstein Analytics"
- Can also be a person's name: "John Smith"

## Optional Parameters

**searchType** (optional, default: "product"):
- "product" - Search in product fields (PRODUCT_L3__c, PRODUCT_L2__c)
- "name" - Search in AE name field (AE_NAME__c)
- "all" - Search in both product and name fields

**ouName** (optional):
- Filter by Organizational Unit for context-aware ranking
- Examples: "UKI", "AMER", "APAC", "EMEA", "LATAM"
- Leave blank for all OUs

**maxResults** (optional, default: 10):
- Maximum number of SME results to return
- Recommended range: 3-20
- Higher numbers may slow down response

**academyMembersOnly** (optional, default: false):
- Set to true to only return SMEs who are Excellence Academy members
- Useful for finding certified experts

**useEnhancedSearch** (optional, default: true):
- Enable enhanced ranking with relevance scoring
- Generally leave as true for best results

## Example Queries

User asks: "Give me 5 SMEs in UKI for Tableau"
→ Set: searchTerm="Tableau", searchType="product", ouName="UKI", maxResults=5

User asks: "Find Data Cloud academy members"
→ Set: searchTerm="Data Cloud", searchType="product", academyMembersOnly=true

User asks: "Who are the Tableau experts?"
→ Set: searchTerm="Tableau", searchType="product", maxResults=10

User asks: "Find SMEs named John in AMER"
→ Set: searchTerm="John", searchType="name", ouName="AMER"

User asks: "Search for anyone related to MuleSoft"
→ Set: searchTerm="MuleSoft", searchType="all"
```

---

### Step 5: Output Instructions

Copy and paste this into the **Output Instructions** field:

```
The response contains a comprehensive, formatted message with SME search results.

## Response Structure

The message includes the following sections:

1. **Summary** - Search parameters and result counts
2. **Insights** - Key statistics (top OU, academy member percentage)
3. **SME Details** - Individual SME information with:
   - Name and organizational unit
   - Product expertise (L2 and L3)
   - AE ranking score
   - Total ACV (Annual Contract Value)
   - Academy membership status
   - Relevance score and scoring explanation
4. **Limits & Counts** - Total matches and truncation info
5. **Data (JSON)** - Structured data for further processing

## How to Present Results

When presenting SME search results to the user:

✅ **DO:**
- Present SME names prominently
- Highlight their organizational unit
- Mention their product expertise
- Indicate if they are academy members
- Note their ranking/relevance to the query
- If results are limited, mention total count (e.g., "Found 710 SMEs, showing top 5")
- Use natural language, not technical jargon

❌ **DON'T:**
- Don't show raw JSON to users
- Don't expose technical field names (like AE_RANK__c)
- Don't show relevance scores unless user asks
- Don't show all details if user only wants names

## Example Presentation

**Good Response:**
"I found 5 Tableau SMEs in UKI for you:

1. **John Doe** (UKI) - Tableau CRM expert, Academy Member ⭐
2. **Jane Smith** (UKI) - Tableau Analytics specialist
3. **Bob Johnson** (UKI) - Tableau & Einstein expert, Academy Member ⭐
4. **Sarah Williams** (UKI) - Tableau CRM
5. **Mike Brown** (UKI) - Tableau

There are 710 total Tableau SMEs in UKI - I'm showing you the top 5 ranked by expertise and relevance. Would you like me to search for more specific criteria?"

**Note:** The search found a total of 710 matches. Would you like me to narrow down the search with additional filters?

## Handling Edge Cases

**No results found:**
- "I couldn't find any SMEs matching '[searchTerm]' [in OU if specified]. Would you like me to try a broader search or different criteria?"

**Many results (truncated):**
- "I found [total] SMEs for [searchTerm], showing you the top [maxResults] by relevance. Would you like to see more or filter by region?"

**Academy members:**
- Indicate academy status with context: "John Doe is a Salesforce Academy member, indicating certified expertise"
```

---

### Step 6: Advanced Settings (Optional)

**Timeout:** 30 seconds (default is fine)

**Error Handling:**
- Default error handling is sufficient
- Service returns formatted error messages

---

## 🖼️ Screenshot Checklist

When documenting this action, include screenshots of:

1. **Action Selection**
   - [ ] Screenshot showing "Search SMEs V3" in action dropdown

2. **Configuration Screen**
   - [ ] Action name field: "SME Search V3"
   - [ ] Reference name field: "ANAgent_Search_SMEs_V3"
   - [ ] Input instructions field (full text)
   - [ ] Output instructions field (full text)

3. **Test Panel**
   - [ ] Test utterance: "Give me 5 SMEs in UKI for Tableau"
   - [ ] Successful response showing formatted SME list

4. **Agent Response**
   - [ ] Full agent response in conversation UI
   - [ ] Shows proper formatting and readability

---

## 🔐 Permission Requirements

### User Permissions Required
- Read access to `AGENT_SME_ACADEMIES__c` object
- Read access to all fields used in query:
  - `Id`, `AE_NAME__c`, `AE_RANK__c`, `OU__c`
  - `TOTAL_ACV__c`, `PRODUCT_L3__c`, `PRODUCT_L2__c`
  - `ACADEMIES_MEMBER__c`, `CreatedDate`, `LastModifiedDate`

### Agent Integration User
Ensure the Agent Integration User has:
- Execute permission on `ANAgentSMESearchHandlerV3`
- Read permission on `ANAgentSMESearchServiceV3`
- Object and field-level security (FLS) for `AGENT_SME_ACADEMIES__c`

### Add to Permission Set (if needed)
```xml
<ApexClass>
    <apexClass>ANAgentSMESearchHandlerV3</apexClass>
    <enabled>true</enabled>
</ApexClass>
<ApexClass>
    <apexClass>ANAgentSMESearchServiceV3</apexClass>
    <enabled>true</enabled>
</ApexClass>
```

---

## 🧩 Integration Patterns

### Pattern 1: Simple Product Search
```
User: "Find Tableau SMEs"
Agent uses:
  searchTerm = "Tableau"
  searchType = "product"
  maxResults = 10 (default)
```

### Pattern 2: Filtered by Region
```
User: "Give me Data Cloud experts in UKI"
Agent uses:
  searchTerm = "Data Cloud"
  searchType = "product"
  ouName = "UKI"
  maxResults = 10 (default)
```

### Pattern 3: Academy Members Focus
```
User: "Find academy members for MuleSoft"
Agent uses:
  searchTerm = "MuleSoft"
  searchType = "product"
  academyMembersOnly = true
  maxResults = 10 (default)
```

### Pattern 4: Limited Results
```
User: "Give me top 3 Sales Cloud SMEs"
Agent uses:
  searchTerm = "Sales Cloud"
  searchType = "product"
  maxResults = 3
```

### Pattern 5: Name Search
```
User: "Find SME named John Smith"
Agent uses:
  searchTerm = "John Smith"
  searchType = "name"
  maxResults = 10 (default)
```

---

## 🔄 Action Lifecycle

### When to Remove and Re-add Action

**Scenario:** After deploying code changes  
**Steps:**
1. Open Agent Builder
2. Go to Actions tab
3. Click ⋮ menu next to "SME Search V3"
4. Click **Remove**
5. Click **Save** (agent config)
6. **Close** Agent Builder tab completely
7. Reopen Agent Builder
8. Click **+ New Action**
9. Add "Search SMEs V3" again
10. Reconfigure input/output instructions
11. Click **Save**
12. Test with sample utterance

**Why?** This forces Salesforce to refresh the action schema and pick up any changes to the invocable method signature.

---

## 🎯 Testing the Action in Agent

### Test Conversation Flow

```
👤 User: "Hi, I need help finding SMEs"

🤖 Agent: "I'd be happy to help you find Subject Matter Experts. What product or expertise area are you interested in?"

👤 User: "Give me 5 SMEs in UKI for Tableau"

🤖 Agent: [Calls Search SMEs V3 action]
        "I found 5 Tableau SMEs in UKI for you:
        
        1. **John Doe** (UKI) - Tableau CRM expert, Academy Member ⭐
           - Rank: 95.5, Total ACV: $1.25M
        
        2. **Jane Smith** (UKI) - Tableau Analytics specialist
           - Rank: 89.0, Total ACV: $980K
        
        [... more SMEs ...]
        
        Note: I found 710 total Tableau SMEs in UKI. These are the top 5 by relevance and ranking. Would you like more details or want to filter further?"

👤 User: "Just show me academy members"

🤖 Agent: [Calls Search SMEs V3 action with academyMembersOnly=true]
        "Here are the Tableau academy members in UKI:
        
        [Filtered results...]"
```

---

## 📦 What to Add to Screenshot

When documenting in Salesforce or sharing with team:

### Screenshot 1: Action Configuration
**Capture:** Full action configuration screen showing:
- Action name: "SME Search V3"
- Reference name: "ANAgent_Search_SMEs_V3"
- Selected Apex class: "Search SMEs V3"
- Input instructions (visible, maybe scrolled)
- Output instructions (visible, maybe scrolled)

### Screenshot 2: Input Parameters
**Capture:** Input parameters mapping showing:
- searchTerm → Search Term
- searchType → Search Type
- ouName → OU Name
- maxResults → Max Results
- academyMembersOnly → Academy Members Only
- useEnhancedSearch → Use Enhanced Search

### Screenshot 3: Output Configuration
**Capture:** Output configuration showing:
- Single output field: "message"
- Description of what message contains

### Screenshot 4: Test Results
**Capture:** Test panel showing:
- Test utterance: "Give me 5 SMEs in UKI for Tableau"
- Successful execution
- Formatted response with SME details

### Screenshot 5: Agent Conversation
**Capture:** Actual agent conversation showing:
- User query
- Agent response using the action
- Natural language presentation of SME data

---

**Configuration Version:** 1.0  
**Last Updated:** October 8, 2025  
**Compatible With:** Agentforce (Winter '25 and later)
