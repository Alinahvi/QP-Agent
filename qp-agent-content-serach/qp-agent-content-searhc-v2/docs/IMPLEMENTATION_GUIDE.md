# Enhanced Lifecycle Management V2 - Implementation Guide

## 🎯 **Overview**
This guide provides detailed implementation instructions for the Enhanced Lifecycle Management V2 system with CSAT integration.

## 🏗️ **Architecture**

### **Component Structure**
```
ANAgentContentSearchHandlerV2 (Handler)
├── ContentSearchRequest (Input)
├── ContentSearchResponse (Output)
├── determineRoutingDecision() (Routing Logic)
├── executeSearch() (Search Execution)
├── extractCoreSearchTerm() (Term Extraction)
└── formatSuccessMessageWithLifecycle() (Lifecycle Analysis)

ANAgentContentSearchServiceV2 (Service)
├── UnifiedContent (Data Model)
├── ContentSearchResult (Result Wrapper)
├── search() (ACT Search)
├── searchConsensus() (Consensus Search)
├── searchBoth() (Combined Search)
├── populateLearnerCountData() (Enrollment Data)
└── buildSearchQuery() (Query Builder)
```

## 📊 **Enhanced Data Model**

### **UnifiedContent Class**
```apex
public class UnifiedContent {
    @AuraEnabled public String id { get; set; }
    @AuraEnabled public String name { get; set; }
    @AuraEnabled public String description { get; set; }
    @AuraEnabled public String type { get; set; }
    @AuraEnabled public String status { get; set; }
    @AuraEnabled public Datetime createdDate { get; set; }
    @AuraEnabled public Datetime lastModifiedDate { get; set; }
    
    // Lifecycle Management Metrics
    @AuraEnabled public Integer learnerCount { get; set; }        // Total enrollments
    @AuraEnabled public Integer completionCount { get; set; }     // Total completions
    @AuraEnabled public Double completionRate { get; set; }       // Completion percentage
    @AuraEnabled public Double csatScore { get; set; }           // CSAT score
    
    @AuraEnabled public String link { get; set; }
}
```

## 🔧 **Implementation Details**

### **1. CSAT Integration**

#### **Field Detection**
```apex
// Automatic CSAT field detection in constructor
if (record.getSObjectType().getDescribe().getName() == 'Course__c' && record.get('CSAT__c') != null) {
    this.csatScore = (Double)record.get('CSAT__c');
}
```

#### **Query Enhancement**
```apex
// Enhanced SOQL query with CSAT field
String baseQuery = 'SELECT Id, Name, Description__c, Status__c, CreatedDate, LastModifiedDate, Share_URL__c';
if (objectName == 'Course__c') {
    baseQuery += ', CSAT__c';  // Add CSAT field for lifecycle analysis
}
```

### **2. Lifecycle Analysis Engine**

#### **Performance Metrics Calculation**
```apex
// Analyze enrollment and completion data
for (ANAgentContentSearchServiceV2.UnifiedContent record : records) {
    if (record.type == 'Course' && record.learnerCount > 0) {
        coursesWithData++;
        totalEnrollment += record.learnerCount;
        totalCompletions += record.completionCount;
        
        // CSAT analysis for content quality assessment
        if (record.csatScore > 0) {
            coursesWithCSAT++;
            totalCSATScore += record.csatScore;
            if (record.csatScore < 3.0) { // Low satisfaction threshold
                lowCSATCount++;
            }
        }
        
        // Lifecycle analysis thresholds
        if (record.learnerCount < 20) {
            lowEnrollmentCount++;
        }
        if (record.completionRate < 10.0) {
            lowCompletionCount++;
        }
        if (record.learnerCount >= 50 && record.completionRate >= 25.0) {
            highPerformingCount++;
        }
    }
}
```

#### **Intelligent Recommendations**
```apex
// Generate optimization recommendations
if (lowEnrollmentCount > 0 || lowCompletionCount > 0 || lowCSATCount > 0) {
    message += '⚠️ **Content Optimization Opportunities:**\n';
    if (lowEnrollmentCount > 0) {
        message += '• Consider promoting or updating ' + lowEnrollmentCount + ' low-enrollment course' + (lowEnrollmentCount == 1 ? '' : 's') + '\n';
    }
    if (lowCompletionCount > 0) {
        message += '• Review and improve ' + lowCompletionCount + ' course' + (lowCompletionCount == 1 ? '' : 's') + ' with low completion rates\n';
    }
    if (lowCSATCount > 0) {
        message += '• Redesign ' + lowCSATCount + ' course' + (lowCSATCount == 1 ? '' : 's') + ' with low satisfaction scores\n';
    }
}
```

### **3. Search Term Extraction**

#### **Smart Term Extraction**
```apex
private static String extractCoreSearchTerm(String userUtterance) {
    if (String.isBlank(userUtterance)) {
        return '';
    }
    
    // Remove command phrases and content type words to get core product names
    Set<String> removePhrases = new Set<String>{
        'show me', 'find', 'search for', 'get', 'give me', 'i need',
        'from consensus', 'from act', 'in consensus', 'in act',
        'content related to', 'related to'
    };
    
    String coreTerm = userUtterance.toLowerCase();
    
    // Remove phrases to get core product names
    for (String phrase : removePhrases) {
        coreTerm = coreTerm.replace(phrase, '').trim();
    }
    
    // Remove extra whitespace and return
    return coreTerm.replaceAll('\\s+', ' ').trim();
}
```

## 🎛️ **Configuration**

### **Lifecycle Thresholds**
```apex
// Configurable thresholds for lifecycle analysis
private static final Integer LOW_ENROLLMENT_THRESHOLD = 20;      // Low enrollment courses
private static final Double LOW_COMPLETION_THRESHOLD = 10.0;     // Low completion rate (%)
private static final Double LOW_CSAT_THRESHOLD = 3.0;           // Low satisfaction score
private static final Integer HIGH_PERFORMING_ENROLLMENT = 50;    // High-performing enrollment
private static final Double HIGH_PERFORMING_COMPLETION = 25.0;   // High-performing completion (%)
```

### **Routing Keywords**
```apex
// Keyword sets for intelligent routing
Set<String> consensusKeywords = new Set<String>{
    'consensus', 'demo', 'demo video', 'video', 'demo pack', 'presentation'
};

Set<String> actKeywords = new Set<String>{
    'act', 'course', 'training', 'learning', 'curriculum', 'asset'
};
```

## 📈 **Performance Optimization**

### **Query Optimization**
- **Selective Field Querying**: Only query CSAT field for Course__c objects
- **Conditional Logic**: Skip CSAT analysis when field is not available
- **Efficient Aggregation**: Use SOQL aggregation for enrollment/completion data

### **Memory Management**
- **Lazy Loading**: Load CSAT data only when needed
- **Batch Processing**: Process large result sets in chunks
- **Error Handling**: Graceful degradation when CSAT field is missing

## 🔍 **Testing Strategy**

### **Unit Tests**
```apex
@isTest
private class ANAgentContentSearchHandlerV2Test {
    @TestSetup
    static void setupTestData() {
        // Create test courses with CSAT scores
        List<Course__c> testCourses = new List<Course__c>();
        for (Integer i = 0; i < 5; i++) {
            testCourses.add(new Course__c(
                Name = 'Test Course ' + i,
                CSAT__c = 4.0 + (i * 0.2),
                Status__c = 'Active'
            ));
        }
        insert testCourses;
    }
    
    @isTest
    static void testLifecycleAnalysisWithCSAT() {
        // Test lifecycle analysis with CSAT integration
        ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request.searchTerm = 'Test';
        request.searchMode = 'ACT';
        
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{request});
        
        System.assert(responses.size() == 1, 'Should return one response');
        System.assert(responses[0].success, 'Should succeed');
        System.assert(responses[0].message.contains('CSAT'), 'Should include CSAT analysis');
    }
}
```

### **Integration Tests**
```apex
@isTest
private class LifecycleManagementIntegrationTest {
    @isTest
    static void testEndToEndLifecycleAnalysis() {
        // Test complete lifecycle analysis flow
        String userUtterance = 'Do a life cycle analysis on Tableau content';
        
        ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request.searchTerm = 'Tableau';
        request.searchMode = 'AUTO';
        request.userUtterance = userUtterance;
        
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{request});
        
        // Verify comprehensive response
        System.assert(responses[0].message.contains('Course Performance Summary'));
        System.assert(responses[0].message.contains('Lifecycle Analysis'));
        System.assert(responses[0].message.contains('Content Optimization Opportunities'));
    }
}
```

## 🚀 **Deployment Checklist**

### **Pre-Deployment**
- [ ] Verify Course__c.CSAT__c field exists
- [ ] Check field permissions and accessibility
- [ ] Validate test data availability
- [ ] Review governor limits impact

### **Deployment**
- [ ] Deploy service class first (ANAgentContentSearchServiceV2)
- [ ] Deploy handler class (ANAgentContentSearchHandlerV2)
- [ ] Run test classes
- [ ] Verify CSAT integration

### **Post-Deployment**
- [ ] Test lifecycle analysis with sample data
- [ ] Verify CSAT scores in responses
- [ ] Check performance with large datasets
- [ ] Monitor governor limit usage

## 📊 **Monitoring & Maintenance**

### **Key Metrics to Monitor**
- **Query Performance**: SOQL query execution times
- **Governor Limits**: CPU time and SOQL query usage
- **CSAT Coverage**: Percentage of courses with CSAT scores
- **Response Quality**: Accuracy of lifecycle recommendations

### **Maintenance Tasks**
- **Regular Review**: Monthly review of lifecycle thresholds
- **Performance Tuning**: Quarterly performance optimization
- **Data Quality**: Ongoing CSAT data validation
- **Feature Updates**: Regular enhancement updates

---

**Implementation Guide**: Enhanced Lifecycle Management V2  
**Version**: 2.0  
**Last Updated**: October 1, 2025
