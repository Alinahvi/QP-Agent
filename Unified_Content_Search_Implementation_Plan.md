# Unified Content Search Implementation Plan

## Overview

This document outlines the implementation plan for consolidating `ANAgent Search Content V2` and `ANAgent Search Content (Consensus or ACT)` into a single unified handler with standardized output formatting.

## Target Output Formats

### Consensus Content (Demo Videos)
```
📹 **Data Cloud | Door Opener**
• **Link (Watch Video)**: [Watch Demo](https://play.goconsensus.com/...)
• **Duration**: 3 minutes
• **Description**: Quick conversation starter for Data Cloud discussions
```

### ACT Content (Courses)
```
📚 **Data Cloud**
• **Created**: May 9, 2025
• **Description**: Dive into the Data Cloud and unlock the potential of your data! This course will teach you how to harness data insights to drive smarter marketing decisions.
• **Learners**: 12 enrolled
• **Completion Rate**: 8.33%
```

## Implementation Phases

### Phase 1: Create Unified Data Model

#### 1.1 Unified Content Class
```apex
public class UnifiedContent {
    // Core fields
    public String id { get; set; }
    public String name { get; set; }
    public String description { get; set; }
    public String type { get; set; }
    public String status { get; set; }
    public Datetime createdDate { get; set; }
    public Datetime lastModifiedDate { get; set; }
    
    // Source identification
    public String sourceType { get; set; } // "ACT" or "Consensus"
    
    // ACT-specific fields
    public Integer learnerCount { get; set; }
    public Integer completionCount { get; set; }
    public Double completionRate { get; set; }
    
    // Consensus-specific fields
    public String previewLink { get; set; }
    public String language { get; set; }
    public String folder { get; set; }
    public String creator { get; set; }
    public Boolean isPublic { get; set; }
    public Boolean isPublished { get; set; }
    public String duration { get; set; }
    
    // Additional metadata
    public Map<String, Object> additionalMetadata { get; set; }
    
    public UnifiedContent() {
        this.learnerCount = 0;
        this.completionCount = 0;
        this.completionRate = 0.0;
        this.isPublic = false;
        this.isPublished = false;
        this.additionalMetadata = new Map<String, Object>();
    }
}
```

#### 1.2 Search Result Wrapper
```apex
public class UnifiedSearchResult {
    public Boolean success { get; set; }
    public List<UnifiedContent> records { get; set; }
    public List<String> errors { get; set; }
    public Integer totalCount { get; set; }
    public String searchType { get; set; } // "ACT", "Consensus", "Both"
    public String composedMessage { get; set; }
    
    public UnifiedSearchResult() {
        this.success = false;
        this.records = new List<UnifiedContent>();
        this.errors = new List<String>();
        this.totalCount = 0;
        this.searchType = '';
        this.composedMessage = '';
    }
}
```

### Phase 2: Create Unified Service

#### 2.1 Service Class Structure
```apex
public class ANAgentUnifiedContentSearchService {
    
    // Main search methods
    public static UnifiedSearchResult search(String searchTerm, String contentType)
    public static UnifiedSearchResult search(String userUtterance)
    public static UnifiedSearchResult searchAdvanced(UnifiedSearchRequest request)
    
    // Data source specific methods
    private static List<UnifiedContent> searchACT(String searchTerm, String contentType)
    private static List<UnifiedContent> searchConsensus(String userUtterance)
    
    // Formatting methods
    private static String formatConsensusContent(UnifiedContent content)
    private static String formatACTContent(UnifiedContent content)
    private static String composeUnifiedMessage(List<UnifiedContent> records, String searchType)
}
```

#### 2.2 Consensus Content Conversion
```apex
private static UnifiedContent convertConsensusToUnified(ConsensusContent consensus) {
    UnifiedContent unified = new UnifiedContent();
    unified.id = consensus.id;
    unified.name = consensus.title;
    unified.description = consensus.description;
    unified.type = 'Demo Video';
    unified.status = consensus.isPublished ? 'Published' : 'Draft';
    unified.createdDate = parseDateTime(consensus.createdAt);
    unified.sourceType = 'Consensus';
    unified.previewLink = consensus.previewLink;
    unified.language = consensus.languageTitle;
    unified.folder = consensus.folderInfoName;
    unified.creator = consensus.creatorFirstName + ' ' + consensus.creatorLastName;
    unified.isPublic = consensus.isPublic;
    unified.isPublished = consensus.isPublished;
    unified.duration = extractDuration(consensus.internalTitle);
    return unified;
}
```

#### 2.3 ACT Content Conversion
```apex
private static UnifiedContent convertACTToUnified(ANAgentContentSearchServiceV2.UnifiedContent act) {
    UnifiedContent unified = new UnifiedContent();
    unified.id = act.id;
    unified.name = act.name;
    unified.description = act.description;
    unified.type = act.type;
    unified.status = act.status;
    unified.createdDate = act.createdDate;
    unified.lastModifiedDate = act.lastModifiedDate;
    unified.sourceType = 'ACT';
    unified.learnerCount = act.learnerCount;
    unified.completionCount = act.completionCount;
    unified.completionRate = act.completionRate;
    return unified;
}
```

### Phase 3: Create Unified Handler

#### 3.1 Handler Class Structure
```apex
public class ANAgentUnifiedContentSearchHandler {
    
    public class UnifiedSearchRequest {
        @InvocableVariable(label='Search Term', description='Direct search term')
        public String searchTerm;
        
        @InvocableVariable(label='Content Type', description='Course, Asset, Curriculum, or Demo')
        public String contentType;
        
        @InvocableVariable(label='User Utterance', description='Natural language search')
        public String userUtterance;
        
        @InvocableVariable(label='Search Mode', description='direct, natural, or auto')
        public String searchMode;
        
        @InvocableVariable(label='Data Sources', description='ACT, Consensus, or Both')
        public String dataSources;
    }
    
    public class UnifiedSearchResponse {
        @InvocableVariable(label='Message', description='Formatted search results')
        public String message;
        
        @InvocableVariable(label='Success', description='Search success status')
        public Boolean success;
        
        @InvocableVariable(label='Total Count', description='Total records found')
        public Integer totalCount;
        
        @InvocableVariable(label='Search Type', description='Data source used')
        public String searchType;
    }
    
    @InvocableMethod(
        label='ANAgent Unified Content Search',
        description='Unified content search across ACT and Consensus with standardized formatting'
    )
    public static List<UnifiedSearchResponse> searchContent(List<UnifiedSearchRequest> requests)
}
```

### Phase 4: Output Formatting Implementation

#### 4.1 Consensus Content Formatting
```apex
private static String formatConsensusContent(UnifiedContent content) {
    String formatted = '';
    formatted += '📹 **' + content.name + '**\n';
    if (String.isNotBlank(content.previewLink)) {
        formatted += '• **Link (Watch Video)**: [Watch Demo](' + content.previewLink + ')\n';
    }
    if (String.isNotBlank(content.duration)) {
        formatted += '• **Duration**: ' + content.duration + '\n';
    }
    if (String.isNotBlank(content.description)) {
        formatted += '• **Description**: ' + content.description + '\n';
    }
    return formatted;
}
```

#### 4.2 ACT Content Formatting
```apex
private static String formatACTContent(UnifiedContent content) {
    String formatted = '';
    formatted += '📚 **' + content.name + '**\n';
    if (content.createdDate != null) {
        formatted += '• **Created**: ' + content.createdDate.format('MMMM d, yyyy') + '\n';
    }
    if (String.isNotBlank(content.description)) {
        formatted += '• **Description**: ' + content.description + '\n';
    }
    if (content.learnerCount > 0) {
        formatted += '• **Learners**: ' + content.learnerCount + ' enrolled\n';
    }
    if (content.completionRate > 0) {
        formatted += '• **Completion Rate**: ' + String.valueOf(content.completionRate).substring(0, Math.min(5, String.valueOf(content.completionRate).length())) + '%\n';
    }
    return formatted;
}
```

#### 4.3 Unified Message Composition
```apex
private static String composeUnifiedMessage(List<UnifiedContent> records, String searchType) {
    String message = '';
    
    // Header based on search type
    if (searchType == 'Consensus') {
        message += '**Consensus Content Search**\n\n';
    } else if (searchType == 'ACT') {
        message += '**ACT Content Search**\n\n';
    } else {
        message += '**Unified Content Search**\n\n';
    }
    
    // Summary
    message += '**SUMMARY**\n';
    message += 'Total matches: ' + records.size() + '\n\n';
    
    // Results
    message += '**RESULTS**\n';
    for (UnifiedContent content : records) {
        if (content.sourceType == 'Consensus') {
            message += formatConsensusContent(content) + '\n';
        } else if (content.sourceType == 'ACT') {
            message += formatACTContent(content) + '\n';
        }
    }
    
    return message;
}
```

### Phase 5: Migration Strategy

#### 5.1 Backward Compatibility
- Maintain existing handler classes during transition
- Add deprecation warnings to old handlers
- Provide migration guide for existing integrations

#### 5.2 Agent Configuration Updates
- Update agent action configurations to use unified handler
- Test all existing agent flows
- Update documentation and training materials

#### 5.3 Testing Strategy
- Unit tests for all new classes
- Integration tests for both data sources
- Performance tests for combined searches
- User acceptance testing with new formatting

## Implementation Timeline

### Week 1: Phase 1 & 2
- Create unified data model
- Implement unified service class
- Add data conversion methods

### Week 2: Phase 3 & 4
- Create unified handler class
- Implement output formatting
- Add comprehensive error handling

### Week 3: Phase 5
- Migration planning and execution
- Testing and validation
- Documentation updates

### Week 4: Cleanup
- Remove legacy code
- Final testing
- Production deployment

## Success Criteria

1. **Functionality**: All existing search capabilities maintained
2. **Formatting**: Consistent output format across both data sources
3. **Performance**: Response times within acceptable limits
4. **Compatibility**: Existing integrations continue to work
5. **User Experience**: Improved search results presentation

## Risk Mitigation

1. **Gradual Rollout**: Deploy alongside existing handlers
2. **Feature Flags**: Enable/disable unified functionality
3. **Rollback Plan**: Quick revert to existing handlers if needed
4. **Monitoring**: Track performance and error rates
5. **User Feedback**: Collect feedback during transition period

This implementation plan provides a clear path to consolidating the content search handlers while maintaining the specific formatting requirements for both Consensus and ACT content.
