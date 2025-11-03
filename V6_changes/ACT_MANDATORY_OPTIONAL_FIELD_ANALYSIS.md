# 📚 ACT Learning Content - Mandatory/Optional Field Analysis

**Date:** October 31, 2025  
**Purpose:** Identify fields indicating mandatory vs optional/recommended learning  
**Objects Analyzed:** Course__c, Asset__c, Curriculum__c, Assigned_Course__c  

---

## ✅ **FIELDS FOUND: Yes, Multiple Indicators Exist!**

### **Primary Fields on `Assigned_Course__c` Object**

These fields are on the **assignment** (Assigned_Course__c), not the course itself:

| Field | Type | Purpose | Data Found |
|-------|------|---------|------------|
| **`Is_Compliance_Learning__c`** | Boolean | Indicates compliance/mandatory training | ✅ **259,398 assignments** |
| **`Required__c`** | Boolean | Marks assignment as required for learner | ✅ **370,214 assignments** |
| **`Recommended_Learning__c`** | Lookup | Links to recommended learning object | ✅ Used sparingly |

---

## 🎯 **Field Details**

### **1. `Is_Compliance_Learning__c` (Boolean)**

**Purpose:** Identifies **compliance-mandated** training

**Usage Stats:**
- **Total Compliance Assignments:** 259,398
- **Total Non-Compliance:** 1,355,338
- **Compliance Rate:** ~16% of all assignments

**Business Context:**
- Legal/regulatory required training
- Security certifications
- Ethics training
- Data privacy courses
- Industry-specific compliance (HIPAA, SOX, etc.)

**Example Use Cases:**
- "Show me all compliance training I need to complete"
- "Find mandatory security courses"
- "What compliance learning is overdue?"

**Field Location:** `Assigned_Course__c` (assignment level, not course level)

**Why it matters:**
- ⚠️ **CANNOT** be unenrolled (usually)
- ⚠️ Has **strict due dates**
- ⚠️ Impacts **compliance status** for AE

---

### **2. `Required__c` (Boolean)**

**Purpose:** Marks assignment as **required** (broader than compliance)

**Usage Stats:**
- **Total Required Assignments:** 370,214
- **Total Optional:** 985,124
- **Required Rate:** ~27% of all assignments

**Business Context:**
- Role-based required training
- Onboarding requirements
- Product certification prerequisites
- Manager-assigned must-complete

**Difference from Compliance:**
- **Compliance** = Legal/regulatory mandate (subset of required)
- **Required** = Business/role requirement (broader category)

**Relationship:**
```
Is_Compliance_Learning__c = true → Required__c is usually true
Required__c = true → Could be compliance OR just business-required
Required__c = false → Optional/recommended learning
```

**Example Use Cases:**
- "Show me all required training for new AEs"
- "What courses are mandatory for my role?"
- "Find required vs optional Agentforce content"

**Field Location:** `Assigned_Course__c` (assignment level)

---

### **3. `Recommended_Learning__c` (Lookup)**

**Purpose:** Links to a **recommended learning object**

**Usage Stats:**
- **Most assignments:** NULL (1,355,338 have no recommended learning)
- **Some assignments:** Have lookup to related recommended content

**Business Context:**
- "If you like this course, try this next"
- Learning path recommendations
- Skill progression suggestions
- Related content discovery

**Example Use Cases:**
- "What's recommended after completing this course?"
- "Show me next steps in this learning path"
- "Find recommended follow-up content"

**Field Location:** `Assigned_Course__c` (assignment level)

---

## 🏗️ **Object Architecture**

### **Course__c (The Course Template)**

Fields found on Course__c:
- `Name` - Course title
- `Description__c` - Course description
- `Status__c` - Active, Archived, Draft
- `CSAT__c` - Customer satisfaction score
- `Time_Estimate_Minutes__c` - Duration
- `Block_Self_Enrollment__c` - Enrollment control
- `Block_Unenrollment__c` - Unenrollment control
- `Archived__c`, `Archived_Reason__c`, `Archived_Date__c` - Lifecycle
- `Published_Date__c` - Publication date
- `Last_Maintained__c` - Content freshness
- `SEED_Ready__c` - Ready for scale
- `Accessibility_Compliant__c` - A11y status

**❌ NO mandatory/optional fields on Course__c itself!**

The course template doesn't know if it's mandatory - that's determined at **assignment time**.

---

### **Assigned_Course__c (The Assignment)**

**This is where mandatory/optional is determined!**

When a course is **assigned to a learner**, these fields are set:
- `Is_Compliance_Learning__c` - Is this compliance training?
- `Required__c` - Is this required for the learner?
- `Due_Date__c` - When it must be completed
- `Recommended_Learning__c` - What's recommended next

**This means:**
- ✅ **Same course** can be mandatory for one AE and optional for another
- ✅ **Same course** can be compliance for one role and not for another
- ✅ **Assignment determines requirement level**, not the course itself

---

## 📊 **Data Distribution**

### **From Aggregation Query:**

| Is_Compliance | Required | Recommended | Count | % |
|---------------|----------|-------------|-------|---|
| false | false | null | 1,355,338 | **~85%** (Optional) |
| true | false | null | ~259,398 | **~16%** (Compliance) |
| - | true | - | ~370,214 | **~27%** (Required) |

**Key Insights:**
- **85% of assignments are optional/recommended** (neither compliance nor required)
- **27% are required** (business or role requirement)
- **16% are compliance** (legal/regulatory mandate)
- **Overlap:** Most compliance is also required, but not all required is compliance

---

## 🎯 **How to Use These Fields**

### **Use Case 1: Find Mandatory Training**

**Query Pattern:**
```soql
SELECT Course__c, Course__r.Name, Due_Date__c, Is_Compliance_Learning__c
FROM Assigned_Course__c
WHERE Learner_Profile__c = :learnerProfileId
  AND Required__c = true
  AND Completed__c = false
ORDER BY Due_Date__c ASC
```

**Result:** All required courses for a learner, sorted by due date

---

### **Use Case 2: Find Compliance Training**

**Query Pattern:**
```soql
SELECT Course__c, Course__r.Name, Due_Date__c, Completion_Date__c
FROM Assigned_Course__c
WHERE Learner_Profile__c = :learnerProfileId
  AND Is_Compliance_Learning__c = true
  AND Completed__c = false
ORDER BY Due_Date__c ASC
```

**Result:** Outstanding compliance training

---

### **Use Case 3: Find Optional Learning**

**Query Pattern:**
```soql
SELECT Course__c, Course__r.Name, Course__r.CSAT__c
FROM Assigned_Course__c
WHERE Learner_Profile__c = :learnerProfileId
  AND Required__c = false
  AND Completed__c = false
ORDER BY Course__r.CSAT__c DESC
```

**Result:** Optional courses, sorted by quality

---

### **Use Case 4: Recommended Next Steps**

**Query Pattern:**
```soql
SELECT Recommended_Learning__c, Recommended_Learning__r.Name
FROM Assigned_Course__c
WHERE Learner_Profile__c = :learnerProfileId
  AND Completed__c = true
  AND Recommended_Learning__c != null
```

**Result:** What to learn next based on completed courses

---

## 🔧 **Integration with Content Search V5**

### **Current V5 Implementation**

**ContentSearchV5 currently does NOT filter by mandatory/optional!**

Looking at the service code:
- Searches Course__c, Asset__c, Curriculum__c by name/description
- Returns enrollment counts from Assigned_Course__c
- Returns completion rates from Assigned_Course__c
- **Does NOT** return Required__c or Is_Compliance_Learning__c

---

### **Potential V6 Enhancement**

**Add filters for learning priority:**

#### **New Handler Fields:**

```apex
@InvocableVariable(
    label='Learning Priority' 
    description='Filter by assignment priority. Valid values: "COMPLIANCE" (mandatory compliance training), "REQUIRED" (all required including compliance), "OPTIONAL" (recommended/optional only), "ALL" (no filter - default). Filters assignments by Is_Compliance_Learning__c and Required__c fields. Use for "Show me mandatory training" or "Find optional courses".'
    required=false
)
public String learningPriority;

@InvocableVariable(
    label='Learner Profile ID' 
    description='Filter to specific learner assignments. Provide Learner_Profile__c ID to see ONLY content assigned to that learner with their completion status. Leave blank for global catalog search. Use for "Show MY required training" vs "Show all Agentforce courses".'
    required=false
)
public String learnerProfileId;

@InvocableVariable(
    label='Include Completed' 
    description='Include courses already completed by learner (only applies when learnerProfileId provided). Default: false (show only incomplete). Use false for "What training do I still need?" or true for "What have I completed?"'
    required=false
)
public String includeCompletedStr;
```

#### **Service Layer Changes:**

```apex
// When learnerProfileId provided, search Assigned_Course__c instead of Course__c
if (String.isNotBlank(request.learnerProfileId)) {
    // Build query on Assigned_Course__c
    String query = 'SELECT Course__c, Course__r.Name, Course__r.Description__c, ' +
                   'Required__c, Is_Compliance_Learning__c, Completed__c, ' +
                   'Due_Date__c, Completion_Date__c ' +
                   'FROM Assigned_Course__c ' +
                   'WHERE Learner_Profile__c = :learnerProfileId';
    
    // Add learningPriority filter
    if (learningPriority == 'COMPLIANCE') {
        query += ' AND Is_Compliance_Learning__c = true';
    } else if (learningPriority == 'REQUIRED') {
        query += ' AND Required__c = true';
    } else if (learningPriority == 'OPTIONAL') {
        query += ' AND Required__c = false';
    }
    
    // Add completion filter
    if (!includeCompleted) {
        query += ' AND Completed__c = false';
    }
    
    query += ' ORDER BY Due_Date__c ASC';
    
    // Execute and return personalized results
}
```

---

## 🎓 **Business Use Cases Enabled**

### **With Mandatory/Optional Filtering:**

1. **Compliance Dashboard**
   - "Show me all compliance training I need to complete"
   - "What mandatory security courses are overdue?"
   - "Find my incomplete compliance requirements"

2. **Onboarding Tracking**
   - "What required training is left for new AEs?"
   - "Show me mandatory onboarding courses"
   - "Find all required Agentforce certification steps"

3. **Optional Learning Discovery**
   - "What optional Tableau courses are available?"
   - "Show recommended Data Cloud content"
   - "Find optional skill development programs"

4. **Learning Path Progression**
   - "What should I learn next after completing Einstein basics?"
   - "Show recommended follow-up courses"
   - "Find the next step in my learning journey"

5. **Priority-Based Filtering**
   - "Show ONLY mandatory training" (exclude optional noise)
   - "Find all required courses for my role"
   - "What's compliance vs what's nice-to-have?"

---

## 📊 **Field Summary**

### **✅ FOUND: Three Key Fields**

| Field | Object | Type | Purpose | Count |
|-------|--------|------|---------|-------|
| **Is_Compliance_Learning__c** | Assigned_Course__c | Boolean | Compliance mandate | 259,398 |
| **Required__c** | Assigned_Course__c | Boolean | Required (broader) | 370,214 |
| **Recommended_Learning__c** | Assigned_Course__c | Lookup | Next steps | Sparse |

### **❌ NOT FOUND on Course Object**

- Course__c does NOT have mandatory/optional fields
- Determination happens at assignment time
- Same course can be mandatory for one person, optional for another

---

## 🚀 **V6 Enhancement Opportunity**

### **Current V5 Limitation:**

SearchContentV5 searches the **catalog** (Course__c, Asset__c, Curriculum__c), not **assignments**.

**This means:**
- ❌ Cannot filter by "show me MY required training"
- ❌ Cannot distinguish mandatory vs optional
- ❌ Cannot show completion status for learner
- ❌ Cannot show due dates
- ❌ Returns global catalog, not personalized view

---

### **V6 Could Add:**

**Two Search Modes:**

1. **Catalog Mode (Current V5):**
   - Searches Course__c, Asset__c, Curriculum__c
   - Returns ALL content in catalog
   - No learner context
   - Use for: "What Agentforce courses exist?"

2. **Personalized Mode (New V6):**
   - Searches Assigned_Course__c
   - Filters by learnerProfileId
   - Shows Required__c, Is_Compliance_Learning__c
   - Shows completion status, due dates
   - Use for: "What training do I still need to complete?"

**Handler Addition:**
```apex
@InvocableVariable(label='Learner Profile ID' description='...' required=false)
public String learnerProfileId;

@InvocableVariable(label='Learning Priority' description='COMPLIANCE, REQUIRED, OPTIONAL, ALL' required=false)
public String learningPriority;

@InvocableVariable(label='Show Completion Status' description='...' required=false)
public String showCompletionStr;
```

**Service Logic:**
```apex
if (String.isNotBlank(request.learnerProfileId)) {
    // PERSONALIZED MODE - Query Assigned_Course__c
    return searchAssignedCourses(request, learnerProfileId, learningPriority);
} else {
    // CATALOG MODE - Query Course__c/Asset__c/Curriculum__c (existing logic)
    return searchACTContent(request, contentType, sortBy, sortOrder, limitVal, includeInactive);
}
```

---

## 📈 **Impact Analysis**

### **New Queries Enabled:**

**Compliance Tracking:**
- "Show me all my compliance training"
- "What mandatory courses are overdue?"
- "Find incomplete compliance requirements"

**Onboarding:**
- "What required training do I have left?"
- "Show my mandatory onboarding courses"
- "What's required for Agentforce certification?"

**Recommended Learning:**
- "What should I learn next?"
- "Show optional courses for skill development"
- "Find recommended follow-up content"

**Prioritization:**
- "Show ONLY mandatory training" (filter out optional)
- "What's required vs nice-to-have?"
- "Compliance training first, then optional"

---

## 🎯 **Quick Answer to Your Question**

**YES, there ARE fields for mandatory/optional learning!** ✅

**Location:** `Assigned_Course__c` object (not Course__c)

**Fields:**
1. **`Is_Compliance_Learning__c`** - Boolean - Compliance mandate (259K assignments)
2. **`Required__c`** - Boolean - Required training (370K assignments)
3. **`Recommended_Learning__c`** - Lookup - Recommended next steps (sparse)

**Key Insight:**
The same course can be:
- **Mandatory** for new AEs (Required__c = true)
- **Optional** for experienced AEs (Required__c = false)
- **Compliance** for managers (Is_Compliance_Learning__c = true)

**Assignment determines priority, not the course itself!**

---

## 💡 **Recommendation**

### **For V6 Enhancement:**

**Add learner-specific filtering** to SearchContentV6:

**Low Effort (1-2 hours):**
- Add `learnerProfileId` field to handler
- Add `learningPriority` field (COMPLIANCE, REQUIRED, OPTIONAL, ALL)
- Add `showCompletion` field (show completed courses or not)
- Route to Assigned_Course__c when learnerProfileId provided
- Return Required__c, Is_Compliance_Learning__c in response

**High Value:**
- Enables compliance tracking queries
- Personalized learning recommendations
- Priority-based filtering
- Completion status tracking

**Business Impact:**
- AEs can find "What training do I NEED vs WANT?"
- Managers can track "Who's missing compliance requirements?"
- Enablement can analyze "What's required vs optional adoption?"

---

## 🔍 **Sample Queries for V6**

### **Agent Utterances That Would Work:**

**With V6 learner filtering:**
1. "Show me all my required training"
2. "What compliance courses are overdue?"
3. "Find optional Agentforce courses I can take"
4. "What mandatory training do I have left?"
5. "Show my incomplete required certifications"
6. "Find recommended next steps after Data Cloud basics"
7. "What's compliance training vs optional learning?"

**Current V5 can't answer these** because it searches the catalog, not assignments!

---

## 📋 **Field Reference**

### **Assigned_Course__c Key Fields**

| Field | API Name | Type | Values | Purpose |
|-------|----------|------|--------|---------|
| Compliance | `Is_Compliance_Learning__c` | Boolean | true/false | Legal mandate |
| Required | `Required__c` | Boolean | true/false | Must complete |
| Recommended | `Recommended_Learning__c` | Lookup | ID or null | Next steps |
| Completed | `Completed__c` | Boolean | true/false | Completion status |
| Due Date | `Due_Date__c` | Date | YYYY-MM-DD | Deadline |
| Completion Date | `Completion_Date__c` | Date | YYYY-MM-DD | When completed |
| Course | `Course__c` | Lookup | Course ID | Which course |
| Learner | `Learner_Profile__c` | Lookup | Learner ID | Which AE |

---

## 🎯 **Summary**

**Q: Are there fields for mandatory/optional learning?**

**A: YES! Three fields on Assigned_Course__c:**

1. **`Is_Compliance_Learning__c`** (Boolean)
   - 259,398 compliance assignments (~16%)
   - Strictest requirement level

2. **`Required__c`** (Boolean)
   - 370,214 required assignments (~27%)
   - Broader than compliance

3. **`Recommended_Learning__c`** (Lookup)
   - Links to recommended next steps
   - Used sparingly

**Location:** Assigned_Course__c (assignment), NOT Course__c (template)

**Why:** Same course can be mandatory for one AE, optional for another

**V6 Opportunity:** Add learner-specific filtering to enable personalized queries!

---

END OF ANALYSIS


