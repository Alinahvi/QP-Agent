# 📋 Updated Agent Description for ANAgent Content Search V2

**ANAgent Content Search V2 - Learning Content & Course Search**

**IMPORTANT SCOPE CLARIFICATION:**
This action searches for **LEARNING CONTENT**, **COURSES**, **TRAINING MATERIALS**, and **CURRICULUM** in the Salesforce system. It does NOT search for sales opportunities, pipeline data, or product performance.

- ✅ **What this searches for**: Courses, training materials, learning content, curriculum, completion rates, learner counts, educational programs
- ❌ **What this does NOT search for**: Sales opportunities, pipeline data, ACV, product sales data, AE performance

**Use this when users ask about:**
- Courses and training materials
- Learning content and curriculum
- Completion rates and learner counts
- Educational programs and training
- Course descriptions and details

**Do NOT use this when users ask about:**
- Sales opportunities and pipeline
- Product performance and ACV
- Territory and segment sales data
- Revenue and sales metrics

## **Input Parameters:**
- searchTerm: The search term to look for (e.g., "FIN", "financial", "Tableau", "Sales Cloud")
- contentType: Optional content type filter ("Course", "Asset", "Curriculum")

## **Common Query Patterns:**
- "Show me courses related to [TOPIC]" → searchTerm="[TOPIC]", contentType="Course"
- "Find training materials for [SUBJECT]" → searchTerm="[SUBJECT]", contentType="Asset"
- "Search for curriculum about [AREA]" → searchTerm="[AREA]", contentType="Curriculum"
- "Top courses for [INDUSTRY]" → searchTerm="[INDUSTRY]", contentType="Course"

## **Output Structure:**
The response contains learning content records with the following information:

### **Key Response Fields:**
- id: Unique identifier for the content
- name: Name of the course/asset/curriculum
- description: Detailed description of the content
- type: Type of content (Course, Asset, Curriculum)
- status: Current status of the content
- createdDate: When the content was created
- lastModifiedDate: When the content was last modified
- learnerCount: Number of learners assigned to this content
- completionCount: Number of learners who completed this content
- completionRate: Percentage completion rate

## **Display Guidelines:**

### **For Course Search Results:**
- Sort by completion rate (highest first) or learner count (highest first)
- Format: "1. Course Name - Learner Count: X, Completion Rate: Y%"
- Include description when available
- Example: "1. Beamery for Futureforce Recruiting - Learner Count: 39, Completion Rate: 48.72%"

### **For Asset Search Results:**
- Sort by relevance or creation date
- Format: "1. Asset Name - Type: [Type], Status: [Status]"
- Include description when available

### **For Curriculum Search Results:**
- Sort by creation date or relevance
- Format: "1. Curriculum Name - Type: [Type], Status: [Status]"
- Include description when available

## **Important Rules:**
- **ALWAYS use this for learning content queries** - courses, training, education
- **NEVER use this for sales data queries** - opportunities, pipeline, ACV
- **Sort by completion rate or learner count** for course results
- **Include descriptions** when available to provide context
- **Format completion rates as percentages** with 2 decimal places
- **Report actual counts** of results found
- **Use appropriate content type filters** when specified

## **Example Responses:**

### **User asks: "Show me top 5 courses related to financial industries"**
**Correct Response:**
"Here are the top 5 courses related to financial industries:

1. **Beamery for Futureforce Recruiting**
   - Learner Count: 39
   - Completion Rate: 48.72%
   - Description: Salesforce's Talent CRM, Beamery, is a recruitment tool that empowers recruiting teams to easily find and engage their talent at scale.

2. **CIO Program Management Training, Fundamentals Course**
   - Learner Count: 58
   - Completion Rate: 34.48%
   - Description: This course offers an essential overview of Project and Program Management, covering key concepts, methodologies, and best practices.

3. **Close Strong: Reflection**
   - Learner Count: 141
   - Completion Rate: 78.72%
   - Description: The final course of Services Sales Academy: Close Strong will invite you to take time to reflect, document your progress, and start thinking about what you would like to focus on next quarter.

4. **Cloud ERP: FDM in Financial Close and Consolidation**
   - Learner Count: 1
   - Completion Rate: 100%
   - Description: This lesson is designed to provide you with an overview of FDM in Financial Close and Consolidation and an understanding of how it ensures data accuracy, regulatory compliance, and operational efficiency.

5. **Cloud ERP: Foundational Data Model (FDM) Reporting**
   - Learner Count: 1
   - Completion Rate: 100%
   - Description: This lesson provides an overview of how FDM drives reporting in Workday by utilizing Worktags and hierarchies to create effective financial reports."

### **User asks: "Find training materials for Tableau"**
**Correct Response:**
"Here are the training materials related to Tableau:

1. **Tableau Fundamentals Course**
   - Type: Course
   - Status: Active
   - Learner Count: 245
   - Completion Rate: 67.35%
   - Description: Comprehensive introduction to Tableau data visualization and analytics.

2. **Tableau Advanced Analytics**
   - Type: Asset
   - Status: Active
   - Description: Advanced techniques for data analysis and visualization in Tableau."

## **Technical Notes:**
- This searches across Course__c, Asset__c, and Curriculum__c objects
- Completion rates are calculated as (completionCount / learnerCount) * 100
- Results are sorted by relevance and completion metrics
- Content types include: Course, Asset, Curriculum
- This is specifically for learning and training content, not sales data 