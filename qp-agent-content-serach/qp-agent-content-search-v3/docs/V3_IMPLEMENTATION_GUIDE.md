# V3 Implementation Guide

## 🎯 Architecture Overview

### **Design Principles**
ANAgent Search Content V3 follows **FR-style best practices** for Salesforce agent actions:

1. **Single Responsibility**: Handler routes, Service executes
2. **Agent Boundary**: One variable only (`message:String`)
3. **Flattened Data**: No complex structures at boundary
4. **Stable Format**: Predictable message structure
5. **Security First**: FLS enforced with stripInaccessible

---

## 🏗️ Component Architecture

```
┌─────────────────────────────────────────────┐
│         Agent (Einstein AI)                 │
│  Reads ONLY: message:String                 │
└──────────────┬──────────────────────────────┘
               │
               ↓
┌──────────────────────────────────────────────┐
│  ANAgentContentSearchHandlerV3              │
│  (Dumb Router - 63 lines)                   │
│                                              │
│  • Maps input → service → output            │
│  • NO business logic                        │
│  • NO formatting                            │
│  • NO routing decisions                     │
└──────────────┬───────────────────────────────┘
               │
               ↓
┌──────────────────────────────────────────────┐
│  ANAgentContentSearchServiceV3              │
│  (Smart Service - All Logic)                │
│                                              │
│  • Routing Logic                            │
│  • SOQL Queries                             │
│  • Data Aggregation                         │
│  • Lifecycle Analysis                       │
│  • DTO Composition (String message)         │
│  • Security (stripInaccessible)             │
└──────────────┬───────────────────────────────┘
               │
               ↓
┌──────────────────────────────────────────────┐
│  Data Layer                                  │
│  • Course__c, Asset__c, Curriculum__c       │
│  • Assigned_Course__c (enrollments)         │
│  • Agent_Consensu__c (demos)                │
└──────────────────────────────────────────────┘
```

---

## 📦 Handler Implementation (ANAgentContentSearchHandlerV3)

### **Design Pattern: Dumb Router**
```apex
public with sharing class ANAgentContentSearchHandlerV3 {
    
    // INPUT DTO
    public class ContentSearchRequest {
        @InvocableVariable(required=true)
        public String searchTerm;
        
        @InvocableVariable
        public String contentType;
        
        @InvocableVariable
        public String searchMode;
        
        @InvocableVariable
        public String userUtterance;
    }

    // OUTPUT DTO - SINGLE VARIABLE ONLY
    public class ContentSearchResponse {
        @InvocableVariable
        public String message;  // ← ONLY ONE FIELD
    }

    // INVOCABLE METHOD - JUST ROUTES
    @InvocableMethod(label='ANAgent Search Content V3')
    public static List<ContentSearchResponse> searchContent(
        List<ContentSearchRequest> requests
    ) {
        List<ContentSearchResponse> responses = new List<ContentSearchResponse>();

        for (ContentSearchRequest request : requests) {
            ContentSearchResponse response = new ContentSearchResponse();
            
            // DUMB ROUTER: Just call service
            response.message = ANAgentContentSearchServiceV3.search(
                request.searchTerm,
                request.contentType,
                request.searchMode,
                request.userUtterance
            );

            responses.add(response);
        }

        return responses;
    }
}
```

### **Key Characteristics**
- ✅ **63 lines total** (target: <100)
- ✅ **Zero business logic**
- ✅ **Single @InvocableMethod**
- ✅ **One output variable**
- ✅ **Clean, readable, maintainable**

---

## 🧠 Service Implementation (ANAgentContentSearchServiceV3)

### **Design Pattern: Smart Service**
The service is responsible for:
1. Input validation
2. Routing logic
3. SOQL queries
4. Data aggregation
5. Lifecycle calculations
6. Security enforcement
7. **DTO composition** (building the formatted String message)

### **Public API**
```apex
public static String search(
    String searchTerm, 
    String contentType, 
    String searchMode, 
    String userUtterance
)
```

**Returns**: Formatted String message following FR-style structure

### **Internal Architecture**

```
search()
  ├─→ intelligentRouting()
  │     ├─→ searchACTContent()
  │     │     ├─→ searchObject() × 3
  │     │     ├─→ populateLearnerCountData()
  │     │     └─→ buildACTMessage() ← Returns String
  │     ├─→ searchConsensusContent()
  │     │     └─→ buildConsensusMessage() ← Returns String
  │     └─→ searchBothSources()
  │           └─→ Combined message ← Returns String
  └─→ Returns formatted String to handler
```

---

## 📊 Message Composition (FR-Style DTO Pattern)

### **Structure**
Every message follows this structure:

```
## HEADER
Content type and result summary

### SUMMARY
- Search Term
- Routing Decision
- Total Records Found
- Showing count

### INSIGHTS
- Performance metrics
- Lifecycle analysis
- Recommendations
- Optimization opportunities

### DETAILS
- Top 5 results
- With metrics

### LIMITS & COUNTS
- Query limits applied
- Total matches before limit
- Records returned
- Filters applied

### DATA (JSON)
{
  "key1": value1,
  "key2": value2,
  ...  // 3-6 keys max
}
```

### **Implementation Example**
```apex
private static String buildACTMessage(
    List<UnifiedContent> records,
    String searchTerm,
    Integer totalCount,
    String routingDecision
) {
    String message = '';
    
    // 1. HEADER
    message += '## ACT LEARNING CONTENT SEARCH RESULTS\n\n';
    
    // 2. SUMMARY
    message += '### SUMMARY\n';
    message += '**Search Term**: ' + searchTerm + '\n';
    message += '**Routing Decision**: ' + routingDecision + '\n';
    message += '**Total Records Found**: ' + totalCount + '\n\n';
    
    // 3. INSIGHTS (if applicable)
    if (coursesWithData > 0) {
        message += '### INSIGHTS\n';
        message += '**📊 Course Performance Summary**\n';
        // ... metrics
        
        message += '**🎯 Lifecycle Analysis**\n';
        // ... analysis
        
        message += '**⚠️ Content Optimization Opportunities**\n';
        // ... recommendations
    }
    
    // 4. DETAILS
    message += '### DETAILS\n';
    message += '**📚 Top Results**\n';
    for (Integer i = 0; i < Math.min(records.size(), 5); i++) {
        // ... format results
    }
    
    // 5. LIMITS & COUNTS
    message += '### LIMITS & COUNTS\n';
    message += '**Query Limits Applied**\n';
    message += '- Records per object: 50\n';
    message += '- Total matches before limit: ' + totalCount + '\n';
    
    // 6. JSON (compact, 3-6 keys)
    message += '### DATA (JSON)\n';
    message += '```json\n{\n';
    message += '  "totalCount": ' + totalCount + ',\n';
    message += '  "coursesWithData": ' + coursesWithData + ',\n';
    message += '  "avgCompletionRate": ' + avgRate + '\n';
    message += '}\n```\n';
    
    return message;
}
```

---

## 🔐 Security Implementation

### **Field-Level Security**
```apex
// Apply stripInaccessible for security
SObjectAccessDecision decision = Security.stripInaccessible(
    AccessType.READABLE, 
    records
);
records = decision.getRecords();
```

### **Object-Level Security**
```apex
// Check object accessibility
if (!Schema.getGlobalDescribe().containsKey(objectName)) {
    return results; // Object doesn't exist
}

Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
if (!objectType.getDescribe().isAccessible()) {
    return results; // No access
}
```

### **Field Accessibility Check**
```apex
Schema.SObjectField descField = Schema.getGlobalDescribe()
    .get(objectName)
    .getDescribe()
    .fields.getMap()
    .get('Description__c');
    
if (descField != null && descField.getDescribe().isAccessible()) {
    // Safe to query
}
```

---

## 🧮 Lifecycle Analysis Logic

### **Metrics Calculation**
```apex
// Initialize counters
Integer coursesWithData = 0;
Integer totalEnrollment = 0;
Integer totalCompletions = 0;
Integer lowEnrollmentCount = 0;
Integer lowCompletionCount = 0;
Integer highPerformingCount = 0;
Integer coursesWithCSAT = 0;
Double totalCSATScore = 0.0;

// Process records
for (UnifiedContent record : records) {
    if (record.type == 'Course' && record.learnerCount > 0) {
        coursesWithData++;
        totalEnrollment += record.learnerCount;
        totalCompletions += record.completionCount;
        
        // CSAT analysis
        if (record.csatScore > 0) {
            coursesWithCSAT++;
            totalCSATScore += record.csatScore;
            if (record.csatScore < LOW_CSAT_THRESHOLD) {
                lowCSATCount++;
            }
        }
        
        // Lifecycle thresholds
        if (record.learnerCount < LOW_ENROLLMENT_THRESHOLD) {
            lowEnrollmentCount++;
        }
        if (record.completionRate < LOW_COMPLETION_THRESHOLD) {
            lowCompletionCount++;
        }
        if (record.learnerCount >= HIGH_PERFORMING_ENROLLMENT && 
            record.completionRate >= HIGH_PERFORMING_COMPLETION) {
            highPerformingCount++;
        }
    }
}
```

### **Enrollment Data Population**
```apex
private static void populateLearnerCountData(List<UnifiedContent> courseRecords) {
    // Get course IDs
    Set<String> courseIds = new Set<String>();
    for (UnifiedContent content : courseRecords) {
        if (content.type == 'Course') {
            courseIds.add(content.id);
        }
    }
    
    // Aggregate total learners
    List<AggregateResult> learnerCounts = [
        SELECT Course__c, COUNT(Id) learnerCount
        FROM Assigned_Course__c 
        WHERE Course__c IN :courseIds 
        GROUP BY Course__c
    ];
    
    // Aggregate completions
    List<AggregateResult> completionCounts = [
        SELECT Course__c, COUNT(Id) completionCount
        FROM Assigned_Course__c 
        WHERE Course__c IN :courseIds AND Completed__c = true
        GROUP BY Course__c
    ];
    
    // Map to courses and calculate rates
    // ... (see full implementation in service)
}
```

---

## 🔀 Routing Logic

### **Intelligent Routing Algorithm**
```apex
private static String intelligentRouting(
    String searchTerm, 
    String contentType, 
    String userUtterance
) {
    // Define keyword sets
    Set<String> consensusKeywords = new Set<String>{
        'consensus', 'demo', 'demo video', 'video', 'demo pack', 'presentation'
    };
    Set<String> actKeywords = new Set<String>{
        'act', 'course', 'training', 'learning', 'curriculum', 'asset'
    };
    
    // Detect keywords in utterance
    Boolean isConsensusRequest = false;
    Boolean isACTRequest = false;
    String lowerUtterance = userUtterance.toLowerCase();
    
    for (String keyword : consensusKeywords) {
        if (lowerUtterance.contains(keyword)) {
            isConsensusRequest = true;
            break;
        }
    }
    for (String keyword : actKeywords) {
        if (lowerUtterance.contains(keyword)) {
            isACTRequest = true;
            break;
        }
    }
    
    // Route based on keywords
    if (isConsensusRequest && isACTRequest) {
        return searchBothSources(searchTerm, contentType, 'Both keywords detected');
    } else if (isConsensusRequest) {
        return searchConsensusContent(searchTerm, 'Consensus keyword detected');
    } else {
        return searchACTContent(searchTerm, contentType, 'ACT default');
    }
}
```

### **Explicit Mode Routing**
```apex
public static String search(...) {
    String mode = String.isNotBlank(searchMode) 
        ? searchMode.toUpperCase() 
        : 'AUTO';
    
    if (mode == 'ACT') {
        return searchACTContent(searchTerm, contentType);
    } else if (mode == 'CONSENSUS') {
        return searchConsensusContent(searchTerm);
    } else if (mode == 'BOTH') {
        return searchBothSources(searchTerm, contentType);
    } else {
        return intelligentRouting(searchTerm, contentType, userUtterance);
    }
}
```

---

## 🔍 Query Building

### **Dynamic SOQL Construction**
```apex
private static String buildSearchQuery(String objectName, String searchTerm) {
    // Base fields
    String baseQuery = 'SELECT Id, Name, Description__c, Status__c, ' +
                      'CreatedDate, LastModifiedDate, Share_URL__c';
    
    // Conditional CSAT field (Course only)
    if (objectName == 'Course__c') {
        baseQuery += ', CSAT__c';
    }
    
    baseQuery += ' FROM ' + objectName;
    
    // WHERE clause with safe escaping
    String whereClause = ' WHERE (Name LIKE \'%' + 
                        String.escapeSingleQuotes(searchTerm) + '%\'';
    
    // Optional Description search
    try {
        Schema.SObjectField descField = Schema.getGlobalDescribe()
            .get(objectName)
            .getDescribe()
            .fields.getMap()
            .get('Description__c');
            
        if (descField != null && descField.getDescribe().isAccessible()) {
            whereClause += ' OR Description__c LIKE \'%' + 
                          String.escapeSingleQuotes(searchTerm) + '%\'';
        }
    } catch (Exception e) {
        // Field doesn't exist - continue
    }
    
    whereClause += ')';
    
    // Status filter
    whereClause += ' AND Status__c = \'Active\'';
    
    // Order and limit
    return baseQuery + whereClause + ' ORDER BY Name LIMIT 50';
}
```

---

## 🎨 Formatting Utilities

### **No Results Message**
```apex
private static String buildNoResultsMessage(
    String source, 
    String searchTerm, 
    String routingDecision
) {
    return '## NO RESULTS FOUND\n\n' +
           '### SUMMARY\n' +
           '**Search Term**: ' + searchTerm + '\n' +
           '**Source**: ' + source + '\n' +
           '**Routing Decision**: ' + routingDecision + '\n' +
           '**Total Records Found**: 0\n\n' +
           'No ' + source + ' content found.\n\n' +
           '### SUGGESTIONS\n' +
           '- Try different search terms\n' +
           '- Check spelling\n' +
           '- Use broader terms\n';
}
```

### **Error Message**
```apex
private static String buildErrorMessage(String errorMsg) {
    return '## ERROR\n\n' +
           '**Message**: ' + errorMsg + '\n\n' +
           'Please check your input and try again.\n';
}
```

---

## 🧪 Testing Strategy

### **Unit Tests**
```apex
@isTest
private class ANAgentContentSearchServiceV3Test {
    
    @TestSetup
    static void setupTestData() {
        // Create test courses
        List<Course__c> courses = new List<Course__c>();
        for (Integer i = 0; i < 10; i++) {
            courses.add(new Course__c(
                Name = 'Test Course ' + i,
                CSAT__c = 4.0 + (i * 0.1),
                Status__c = 'Active',
                Description__c = 'Test description'
            ));
        }
        insert courses;
        
        // Create enrollments
        // ...
    }
    
    @isTest
    static void testACTSearch() {
        String message = ANAgentContentSearchServiceV3.search(
            'Test', null, 'ACT', 'Show me test courses'
        );
        
        System.assert(message.contains('ACT LEARNING CONTENT'));
        System.assert(message.contains('SUMMARY'));
        System.assert(message.contains('INSIGHTS'));
        System.assert(message.contains('DETAILS'));
        System.assert(message.contains('LIMITS & COUNTS'));
        System.assert(message.contains('DATA (JSON)'));
    }
    
    @isTest
    static void testIntelligentRouting() {
        // Test consensus routing
        String message1 = ANAgentContentSearchServiceV3.search(
            'Demo', null, 'AUTO', 'Show me demo videos'
        );
        System.assert(message1.contains('CONSENSUS') || message1.contains('demo'));
        
        // Test ACT routing
        String message2 = ANAgentContentSearchServiceV3.search(
            'Course', null, 'AUTO', 'Show me courses'
        );
        System.assert(message2.contains('ACT'));
    }
}
```

---

## 📊 Performance Considerations

### **Governor Limits**
- **SOQL Queries**: Max 3 per search (Course, Asset, Curriculum) + 2 for enrollment data = 5 total
- **Query Rows**: Max 150 (50 per object)
- **CPU Time**: <1000ms typical
- **Heap Size**: <1MB typical

### **Optimization Techniques**
1. **Lazy Loading**: Only query enrollment data for courses
2. **Selective SOQL**: Only include CSAT for Course__c
3. **Limits**: Hard-coded LIMIT 50 per object
4. **Efficient Aggregation**: Use SOQL aggregation for counts
5. **String Building**: Efficient concatenation with `+=`

---

## 🔧 Configuration

### **Modifiable Constants**
```apex
// In ANAgentContentSearchServiceV3
private static final Integer LOW_ENROLLMENT_THRESHOLD = 20;      // Customize
private static final Double LOW_COMPLETION_THRESHOLD = 10.0;     // Customize
private static final Double LOW_CSAT_THRESHOLD = 3.0;           // Customize
private static final Integer HIGH_PERFORMING_ENROLLMENT = 50;    // Customize
private static final Double HIGH_PERFORMING_COMPLETION = 25.0;   // Customize
private static final Integer RESULT_LIMIT = 50;                  // Customize
```

### **Routing Keywords**
```apex
// Consensus keywords (modify as needed)
Set<String> consensusKeywords = new Set<String>{
    'consensus', 'demo', 'demo video', 'video', 'demo pack', 'presentation'
};

// ACT keywords (modify as needed)
Set<String> actKeywords = new Set<String>{
    'act', 'course', 'training', 'learning', 'curriculum', 'asset'
};
```

---

## 🎯 Best Practices Applied

| Best Practice | Implementation |
|---------------|----------------|
| **BP#7: 1 Variable** | ✅ Response has only `message:String` |
| **BP#8: Dumb Router** | ✅ Handler has zero business logic |
| **BP#9: Smart Service** | ✅ All logic in service |
| **BP#10: Flatten** | ✅ No Lists/Maps at boundary |
| **BP#13: Security** | ✅ stripInaccessible used |
| **BP#14: Limits** | ✅ Explicit LIMIT + counts |
| **BP#15: Stable Format** | ✅ FR-style structure |
| **BP#29: No Handler Logic** | ✅ Zero logic in handler |
| **BP#30: Single Invocable** | ✅ One @InvocableMethod |

---

**Implementation Guide**: ANAgent Search Content V3  
**Version**: 1.0  
**Last Updated**: October 9, 2025  
**Status**: Complete ✅

