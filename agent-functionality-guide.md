# 🤖 Agent Functionality Guide - Clear Scope Definitions

This guide helps the agent understand which functionality to use for different types of user requests.

## **📊 1. ANAgent Search Open Pipe V2 - Sales Data Search**

**Use for:** Sales opportunities, pipeline data, product performance, ACV analysis

**What it searches:**
- Sales opportunities and pipeline data
- Product performance and ACV (Annual Contract Value)
- Territory and segment sales data
- AE (Account Executive) performance
- Revenue and sales metrics

**Example queries:**
- "Show me top 5 products in AMER ENTR territory by ACV"
- "Which products have highest ACV in Canada?"
- "Sales opportunities in EMEA region"
- "Top performing products by revenue"

**Output:** Product summaries, ACV values, sales metrics

---

## **📚 2. ANAgent Content Search V2 - Learning Content Search**

**Use for:** Courses, training materials, learning content, educational programs (REGULAR CONTENT ONLY)

**What it searches:**
- Courses and training materials
- Learning content and curriculum
- Completion rates and learner counts
- Educational programs and training
- Course descriptions and details

**Example queries:**
- "Show me courses related to financial industries"
- "Find training materials for Tableau"
- "Search for curriculum about sales training"
- "What courses are available for data analytics?"

**Output:** Course lists, completion rates, learner counts, descriptions

---

## **📈 3. ANAgent Offering Efficacy with Fallback - Effectiveness Analysis (NEW)**

**Use for:** Effectiveness queries, performance analysis, "best" courses, APM efficacy data

**What it does:**
- **Step 1**: Tries APM efficacy data first (performance metrics, KPIs, lift, ACV impact)
- **Step 2**: If no APM data found, falls back to completion rate search
- **Result**: Comprehensive effectiveness analysis with fallback options

**Example queries:**
- "give me best course on data cloud"
- "show me most effective training programs"
- "what are the top performing courses"
- "highest quality learning programs"

**Output:** APM efficacy data OR completion rate data (with clear fallback messaging)

**Enhanced Response Handling:**
1. **APM + KPI specified**: Show APM results directly
2. **APM + NO KPI**: Ask for KPI clarification with available options
3. **APM + ineffective courses**: Show APM data + switch to completion rate
4. **NO APM data**: Switch to completion rate search automatically

**Critical Rules:**
- **NEVER show ineffective APM courses** (Lift = 0%, Effectiveness = N/A) as "best" recommendations
- **ALWAYS ask for KPI clarification** when APM data exists but KPI not specified
- **ALWAYS fall back to completion rate** when APM courses are ineffective
- **PROVIDE clear explanations** for why fallback is happening

---

## **📝 4. ANAgent APM Nomination V2 - Course Nomination Creation**

**Use for:** Creating nominations for courses to be included in the APM system

**What it does:**
- Creates APM nominations for courses
- Submits course data to external APM API
- Handles nomination validation and processing
- Provides API response status

**Example queries:**
- "Create an APM nomination for 'Tableau Fundamentals' with start date Jan 1st, 2025 and end date Mar 31st, 2025"
- "Nominate 'Sales Cloud Basics' for APM"
- "Submit 'Data Analytics Course' to APM system"

**Output:** Nomination creation status, API responses, error messages

---

## **🚫 Common Confusion Points - AVOID THESE MISTAKES:**

### **❌ WRONG: Using Content Search for Sales Data**
- User asks: "Show me top 5 products in AMER territory"
- ❌ Agent responds with: Course information
- ✅ Should use: Open Pipe Search

### **❌ WRONG: Using Open Pipe Search for Courses**
- User asks: "Show me courses related to financial industries"
- ❌ Agent responds with: Sales data
- ✅ Should use: Content Search

### **❌ WRONG: Using APM Nomination for Course Search**
- User asks: "Find courses about Tableau"
- ❌ Agent responds with: Nomination creation form
- ✅ Should use: Content Search

### **❌ WRONG: Using Content Search for Nominations**
- User asks: "Create an APM nomination for 'Sales Cloud'"
- ❌ Agent responds with: Course search results
- ✅ Should use: APM Nomination

### **❌ WRONG: Using Content Search for Effectiveness Queries (NEW)**
- User asks: "give me best course on data cloud"
- ❌ Agent responds with: Direct Content Search
- ✅ Should use: Offering Efficacy with Fallback (APM first, then fallback)

---

## **🎯 Quick Decision Tree:**

1. **Does the user want to SEARCH for something?**
   - If searching for **sales data** → Use **Open Pipe Search**
   - If searching for **courses/training** → **CHECK FOR EFFECTIVENESS KEYWORDS FIRST**
   - If searching for **APM efficacy/effectiveness** → Use **Offering Efficacy with Fallback**

2. **Does the user want to CREATE something?**
   - If creating **APM nominations** → Use **APM Nomination**

3. **Does the user mention ACV, pipeline, or sales metrics?**
   - → Use **Open Pipe Search**

4. **Does the user mention effectiveness keywords?**
   - **Keywords**: "best", "most effective", "top performing", "highest performing", "most successful", "top rated", "best performing", "most impactful", "highest impact", "best results", "top results", "most valuable", "highest value", "best outcomes", "top outcomes", "most productive", "highest productivity", "best performance", "top performance", "most efficient", "highest efficiency", "best quality", "top quality"
   - → Use **Offering Efficacy with Fallback** (APM first, then fallback to completion rate)

5. **Does the user mention courses, training, or learning (without effectiveness keywords)?**
   - → Use **Content Search**

6. **Does the user mention "nominate" or "APM"?**
   - → Use **APM Nomination**

## **📋 Key Phrases to Watch For:**

### **Open Pipe Search Triggers:**
- "top products"
- "ACV"
- "sales opportunities"
- "pipeline"
- "territory"
- "segment"
- "revenue"

### **Offering Efficacy with Fallback Triggers (NEW):**
- "best courses"
- "most effective training"
- "top performing programs"
- "highest performing courses"
- "most successful learning"
- "best results"
- "most impactful training"
- "highest quality courses"

### **Content Search Triggers (Regular Learning Content):**
- "courses"
- "training materials"
- "learning content"
- "completion rates"
- "learner counts"
- "curriculum"
- "find courses about"
- "search for training"

### **APM Nomination Triggers:**
- "create nomination"
- "nominate for APM"
- "submit to APM"
- "APM nomination"

---

## **✅ Best Practices:**

1. **Always check the user's intent first** - are they searching or creating?
2. **Look for specific keywords** that indicate the type of data they want
3. **When in doubt, ask for clarification** rather than guessing
4. **Use the correct functionality** even if the user's query is ambiguous
5. **Provide clear guidance** when the user's request doesn't match any functionality

---

## **🔄 Example Corrections:**

### **User Query:** "Show me top 5 products within AMER territory within ENTR Segment for FIN related industries"

**❌ WRONG Response (Content Search):**
"Here are the top 5 courses related to financial industries..."

**✅ CORRECT Response (Open Pipe Search):**
"Here are the top 5 products in AMER ENTR territory with the highest ACV volume:
1. Tableau Cloud - $123,456,789
2. Data Cloud - $98,765,432
3. Sales Cloud & Industries - $87,654,321
4. Engagement - $76,543,210
5. Trusted Services - $65,432,109"

---

## **🆕 NEW: Effectiveness Query Examples**

### **User Query:** "give me best course on data cloud"

**❌ WRONG Response (Direct Content Search):**
"Here are some of the best courses on Data Cloud: [completion rate data only]"

**✅ CORRECT Response (Offering Efficacy with Fallback):**
"I'll search for the most effective Data Cloud courses using APM efficacy data first, then fall back to completion rates if needed. Let me analyze the performance metrics and KPIs for Data Cloud courses..."

---

**Remember:** Each functionality has a specific purpose. Use the right tool for the right job! 🎯 