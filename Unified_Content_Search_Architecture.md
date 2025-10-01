# Unified Content Search Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    UNIFIED CONTENT SEARCH                      │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │            ANAgentUnifiedContentSearchHandler           │   │
│  │                                                         │   │
│  │  Input Methods:                                         │   │
│  │  • searchTerm + contentType (Direct)                    │   │
│  │  • userUtterance (Natural Language)                     │   │
│  │  • searchMode + dataSources (Advanced)                  │   │
│  │                                                         │   │
│  │  Output:                                                │   │
│  │  • Unified message with standardized formatting         │   │
│  │  • Structured data objects                              │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                │
│                              ▼                                │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │         ANAgentUnifiedContentSearchService              │   │
│  │                                                         │   │
│  │  ┌─────────────────┐    ┌─────────────────────────────┐ │   │
│  │  │   ACT Search    │    │     Consensus Search        │ │   │
│  │  │                 │    │                             │ │   │
│  │  │ • Course__c     │    │ • Agent_Consensu__c         │ │   │
│  │  │ • Asset__c      │    │ • Demo videos               │ │   │
│  │  │ • Curriculum__c │    │ • Presentations             │ │   │
│  │  │ • Learner stats │    │ • Preview links             │ │   │
│  │  └─────────────────┘    └─────────────────────────────┘ │   │
│  │                              │                          │   │
│  │                              ▼                          │   │
│  │  ┌─────────────────────────────────────────────────────┐ │   │
│  │  │            Unified Data Model                       │ │   │
│  │  │                                                     │ │   │
│  │  │  UnifiedContent {                                   │ │   │
│  │  │    // Core fields                                   │ │   │
│  │  │    id, name, description, type, status              │ │   │
│  │  │    createdDate, lastModifiedDate                    │ │   │
│  │  │                                                     │ │   │
│  │  │    // Source identification                         │ │   │
│  │  │    sourceType: "ACT" | "Consensus"                 │ │   │
│  │  │                                                     │ │   │
│  │  │    // ACT-specific fields                           │ │   │
│  │  │    learnerCount, completionCount, completionRate    │ │   │
│  │  │                                                     │ │   │
│  │  │    // Consensus-specific fields                     │ │   │
│  │  │    previewLink, language, folder, creator           │ │   │
│  │  │    isPublic, isPublished, duration                  │ │   │
│  │  │  }                                                  │ │   │
│  │  └─────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. Input Processing
```
User Input → Handler → Service → Data Sources
     ↓
┌─────────────────┐
│ Input Detection │
├─────────────────┤
│ • Direct search │
│ • Natural lang  │
│ • Advanced      │
└─────────────────┘
```

### 2. Search Execution
```
┌─────────────────┐    ┌─────────────────┐
│   ACT Search    │    │ Consensus Search│
├─────────────────┤    ├─────────────────┤
│ • Course__c     │    │ • Agent_Consensu│
│ • Asset__c      │    │ • Demo videos   │
│ • Curriculum__c │    │ • Presentations │
│ • Learner stats │    │ • Preview links │
└─────────────────┘    └─────────────────┘
         │                       │
         └───────────┬───────────┘
                     ▼
         ┌─────────────────┐
         │ Unified Results │
         └─────────────────┘
```

### 3. Output Formatting
```
Unified Results → Formatting Engine → Standardized Output
                        │
        ┌───────────────┴───────────────┐
        ▼                               ▼
┌─────────────┐                ┌─────────────┐
│ Consensus   │                │ ACT Content │
│ Format:     │                │ Format:     │
│ 📹 Name     │                │ 📚 Course   │
│ • Link      │                │ • Created   │
│ • Duration  │                │ • Learners  │
│ • Desc      │                │ • Rate      │
└─────────────┘                └─────────────┘
```

## Output Examples

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

## Key Benefits

1. **Unified Interface**: Single handler for all content searches
2. **Consistent Formatting**: Standardized output across data sources
3. **Enhanced Functionality**: Cross-source search capabilities
4. **Improved Maintainability**: Single codebase to maintain
5. **Better User Experience**: Consistent presentation of results

## Migration Path

### Phase 1: Create Unified Components
- Unified data model
- Unified service class
- Data conversion methods

### Phase 2: Create Unified Handler
- Handler class with multiple input methods
- Output formatting engine
- Error handling

### Phase 3: Migration & Testing
- Deploy alongside existing handlers
- Update agent configurations
- Comprehensive testing

### Phase 4: Cleanup
- Remove legacy handlers
- Update documentation
- Final validation

This architecture provides a clean, maintainable solution for unified content search while preserving the specific formatting requirements for both Consensus and ACT content.
