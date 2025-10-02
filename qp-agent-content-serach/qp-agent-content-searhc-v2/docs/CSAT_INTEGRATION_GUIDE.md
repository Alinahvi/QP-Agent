# CSAT Integration Guide - Enhanced Lifecycle Management V2

## 🎯 **Overview**
This guide details the CSAT (Customer Satisfaction) integration in the Enhanced Lifecycle Management V2 system.

## 📊 **CSAT Field Integration**

### **Field Details**
- **Object**: Course__c
- **Field API Name**: CSAT__c
- **Field Type**: DOUBLE
- **Purpose**: Customer satisfaction scores for content quality assessment

### **Field Detection**
```apex
// Automatic CSAT field detection in UnifiedContent constructor
if (record.getSObjectType().getDescribe().getName() == 'Course__c' && record.get('CSAT__c') != null) {
    this.csatScore = (Double)record.get('CSAT__c');
}
```

## 🔍 **CSAT Data Processing**

### **Query Enhancement**
```apex
// Enhanced SOQL query with conditional CSAT field inclusion
private static String buildSearchQuery(String objectName, String searchTerm) {
    String baseQuery = 'SELECT Id, Name, Description__c, Status__c, CreatedDate, LastModifiedDate, Share_URL__c';
    
    // Add CSAT field for Course__c to support lifecycle management analysis
    if (objectName == 'Course__c') {
        baseQuery += ', CSAT__c';
    }
    
    baseQuery += ' FROM ' + objectName;
    // ... rest of query building
}
```

### **Data Validation**
```apex
// CSAT score validation and processing
if (record.csatScore > 0) {
    coursesWithCSAT++;
    totalCSATScore += record.csatScore;
    if (record.csatScore < 3.0) { // Low satisfaction threshold
        lowCSATCount++;
    }
}
```

## 📈 **CSAT Analysis Features**

### **1. Performance Summary Integration**
```apex
// Add CSAT summary to performance metrics
if (coursesWithCSAT > 0) {
    message += '• Average CSAT score: ' + String.valueOf(Math.round((totalCSATScore / coursesWithCSAT) * 10) / 10) + '/5.0 (' + coursesWithCSAT + ' courses with ratings)\n';
}
```

### **2. Lifecycle Analysis Integration**
```apex
// Include CSAT in lifecycle analysis
message += '🎯 **Lifecycle Analysis:**\n';
message += '• High-performing courses (≥50 learners, ≥25% completion): ' + highPerformingCount + '\n';
message += '• Low-enrollment courses (<20 learners): ' + lowEnrollmentCount + '\n';
message += '• Low-completion courses (<10% completion): ' + lowCompletionCount + '\n';
if (lowCSATCount > 0) {
    message += '• Low-satisfaction courses (<3.0 CSAT): ' + lowCSATCount + '\n';
}
```

### **3. Optimization Recommendations**
```apex
// CSAT-based optimization recommendations
if (lowEnrollmentCount > 0 || lowCompletionCount > 0 || lowCSATCount > 0) {
    message += '⚠️ **Content Optimization Opportunities:**\n';
    // ... other recommendations
    if (lowCSATCount > 0) {
        message += '• Redesign ' + lowCSATCount + ' course' + (lowCSATCount == 1 ? '' : 's') + ' with low satisfaction scores\n';
    }
}
```

### **4. Top Results Display**
```apex
// Include CSAT scores in top results
for (Integer i = 0; i < Math.min(records.size(), 5); i++) {
    ANAgentContentSearchServiceV2.UnifiedContent record = records[i];
    message += '• **' + record.name + '**';
    if (record.type == 'Course' && record.learnerCount > 0) {
        message += ' (' + record.learnerCount + ' learners, ' + Math.round(record.completionRate) + '% completion';
        if (record.csatScore > 0) {
            message += ', ' + record.csatScore + '/5.0 CSAT';
        }
        message += ')';
    }
    message += '\n';
}
```

## 🎛️ **CSAT Configuration**

### **Thresholds**
```apex
// Configurable CSAT thresholds
private static final Double LOW_CSAT_THRESHOLD = 3.0;        // Low satisfaction threshold
private static final Double HIGH_CSAT_THRESHOLD = 4.0;       // High satisfaction threshold
private static final Double EXCELLENT_CSAT_THRESHOLD = 4.5;  // Excellent satisfaction threshold
```

### **Score Interpretation**
- **5.0**: Excellent satisfaction
- **4.0 - 4.9**: Good satisfaction
- **3.0 - 3.9**: Average satisfaction
- **2.0 - 2.9**: Below average satisfaction
- **1.0 - 1.9**: Poor satisfaction
- **0.0**: No rating available

## 📊 **CSAT Analytics**

### **Aggregate Metrics**
```apex
// Calculate CSAT analytics
Integer coursesWithCSAT = 0;
Double totalCSATScore = 0.0;
Integer lowCSATCount = 0;
Integer highCSATCount = 0;

for (ANAgentContentSearchServiceV2.UnifiedContent record : records) {
    if (record.csatScore > 0) {
        coursesWithCSAT++;
        totalCSATScore += record.csatScore;
        
        if (record.csatScore < LOW_CSAT_THRESHOLD) {
            lowCSATCount++;
        } else if (record.csatScore >= HIGH_CSAT_THRESHOLD) {
            highCSATCount++;
        }
    }
}

// Calculate average CSAT
Double averageCSAT = coursesWithCSAT > 0 ? totalCSATScore / coursesWithCSAT : 0.0;
```

### **Coverage Analysis**
```apex
// CSAT coverage analysis
Integer totalCourses = records.size();
Integer csatCoverage = coursesWithCSAT;
Double coveragePercentage = totalCourses > 0 ? (Double)csatCoverage / totalCourses * 100 : 0.0;

message += '📊 **CSAT Coverage:**\n';
message += '• Courses with ratings: ' + csatCoverage + ' of ' + totalCourses + ' (' + Math.round(coveragePercentage) + '%)\n';
message += '• Average CSAT score: ' + String.valueOf(Math.round(averageCSAT * 10) / 10) + '/5.0\n';
```

## 🔧 **Implementation Examples**

### **Basic CSAT Integration Test**
```apex
@isTest
static void testCSATIntegration() {
    // Create test course with CSAT score
    Course__c testCourse = new Course__c(
        Name = 'Test Course with CSAT',
        CSAT__c = 4.5,
        Status__c = 'Active'
    );
    insert testCourse;
    
    // Test search with CSAT integration
    ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
    request.searchTerm = 'Test';
    request.searchMode = 'ACT';
    
    List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
        ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{request});
    
    // Verify CSAT integration
    System.assert(responses[0].message.contains('CSAT'), 'Should include CSAT analysis');
    System.assert(responses[0].message.contains('4.5'), 'Should display CSAT score');
}
```

### **CSAT Analysis Test**
```apex
@isTest
static void testCSATAnalysis() {
    // Create courses with varying CSAT scores
    List<Course__c> testCourses = new List<Course__c>();
    testCourses.add(new Course__c(Name = 'High CSAT Course', CSAT__c = 4.8, Status__c = 'Active'));
    testCourses.add(new Course__c(Name = 'Low CSAT Course', CSAT__c = 2.5, Status__c = 'Active'));
    testCourses.add(new Course__c(Name = 'No CSAT Course', Status__c = 'Active'));
    insert testCourses;
    
    // Test lifecycle analysis
    ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
    request.searchTerm = 'Course';
    request.searchMode = 'ACT';
    request.userUtterance = 'Do a life cycle analysis on these courses';
    
    List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
        ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{request});
    
    // Verify CSAT analysis
    String responseMessage = responses[0].message;
    System.assert(responseMessage.contains('Low-satisfaction courses'), 'Should identify low CSAT courses');
    System.assert(responseMessage.contains('Redesign'), 'Should recommend CSAT improvements');
}
```

## 🚀 **Deployment Considerations**

### **Field Requirements**
1. **Course__c.CSAT__c** field must exist
2. **Field Type**: DOUBLE
3. **Field Permissions**: Read access for the running user
4. **Data Quality**: Ensure CSAT scores are properly populated

### **Data Migration**
```sql
-- Example: Update existing courses with CSAT scores
UPDATE Course__c 
SET CSAT__c = 4.0 
WHERE Status__c = 'Active' 
AND CSAT__c = NULL;

-- Example: Set CSAT scores based on completion rates
UPDATE Course__c 
SET CSAT__c = CASE 
    WHEN Completion_Rate__c >= 80 THEN 4.5
    WHEN Completion_Rate__c >= 60 THEN 4.0
    WHEN Completion_Rate__c >= 40 THEN 3.5
    WHEN Completion_Rate__c >= 20 THEN 3.0
    ELSE 2.5
END
WHERE CSAT__c = NULL;
```

### **Validation Rules**
```apex
// Example validation rule for CSAT field
// CSAT__c must be between 1.0 and 5.0
CSAT__c >= 1.0 && CSAT__c <= 5.0
```

## 📈 **Performance Optimization**

### **Query Optimization**
- **Conditional Field Inclusion**: Only query CSAT field for Course__c objects
- **Null Handling**: Graceful handling of null CSAT values
- **Aggregation**: Efficient CSAT score calculations

### **Memory Management**
- **Lazy Loading**: Load CSAT data only when needed
- **Batch Processing**: Process large CSAT datasets efficiently
- **Error Handling**: Graceful degradation when CSAT field is unavailable

## 🔍 **Troubleshooting**

### **Common Issues**

#### **1. CSAT Field Not Found**
```
Error: Field 'CSAT__c' does not exist on object 'Course__c'
```
**Solution**: Ensure Course__c.CSAT__c field exists and is accessible

#### **2. CSAT Scores Not Displaying**
```
Issue: CSAT scores showing as 0.0 in results
```
**Solution**: Check if CSAT__c field has data and proper field permissions

#### **3. CSAT Analysis Missing**
```
Issue: Lifecycle analysis doesn't include CSAT recommendations
```
**Solution**: Verify CSAT field is included in SOQL query and data is populated

### **Debugging Steps**
1. **Check Field Existence**: Verify Course__c.CSAT__c field exists
2. **Validate Data**: Ensure CSAT scores are populated
3. **Test Query**: Run SOQL query manually to verify CSAT data
4. **Check Permissions**: Verify field-level security permissions
5. **Review Logs**: Check debug logs for CSAT-related errors

## 📊 **CSAT Reporting**

### **Key Metrics**
- **Average CSAT Score**: Overall satisfaction across all courses
- **CSAT Coverage**: Percentage of courses with ratings
- **Low Satisfaction Count**: Number of courses below threshold
- **High Satisfaction Count**: Number of courses above threshold

### **Trend Analysis**
- **CSAT Trends**: Track satisfaction scores over time
- **Course Performance**: Correlate CSAT with enrollment/completion
- **Improvement Tracking**: Monitor CSAT improvements after optimization

---

**CSAT Integration Guide**: Enhanced Lifecycle Management V2  
**Version**: 2.0  
**Last Updated**: October 1, 2025
