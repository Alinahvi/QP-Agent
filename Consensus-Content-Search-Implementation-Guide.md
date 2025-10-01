# Consensus Content Search Implementation Guide

## Overview

This guide documents the implementation of a new Content Search system that intelligently routes searches between **Consensus** and **ACT** content based on user utterances. The system follows the FR Agent pattern with a single `@InvocableMethod` handler that returns only a `message:String`.

## Architecture

### Components

1. **ANAgentConsensusContentSearchHandler** - Main handler class with routing logic
2. **ANAgentConsensusContentSearchService** - Consensus-specific search service
3. **ANAgentContentSearchServiceV2** - Existing ACT search service (reused)

### Routing Logic

- **If user mentions "Consensus"** → Route to Consensus search
- **If user does NOT mention "Consensus"** → Route to ACT search
- **Case-insensitive** matching for "consensus" keyword

## Data Source: Agent_Consensu__c

### Field Mapping

| Business Name | API Name | Type | Usage |
|---------------|----------|------|-------|
| Title | `title__c` | Text | Primary display label |
| Internal Title | `internalTitle__c` | Text | Boost exact/phrase matches |
| Is Public | `isPublic__c` | Checkbox | Customer-viewable flag |
| Is Published | `isPublished__c` | Checkbox | Live/available flag |
| Created At | `createdAt__c` | Text (ISO datetime) | Recency boost |
| Description | `description__c` | Long Text | Fallback match |
| Preview Link | `previewLink__c` | URL | Playable link |
| Language Title | `languagetitle__c` | Text | Language filter |
| Folder Info | `folderInfoname__c` | Text | Organization filter |
| Creator First Name | `creatorDatafirstName__c` | Text | Creator info |
| Creator Last Name | `creatorDatalastName__c` | Text | Creator info |
| Creator Email | `creatorDataemail__c` | Email | Contact info |

## Search Behavior

### Default Filters
- **Published by default**: `isPublished__c = true` unless user asks for drafts
- **Page size**: 25 records maximum
- **Security**: `Security.stripInaccessible(READABLE, records)` applied

### Ranking Algorithm
1. **Exact/phrase match** in `title__c` (200 points)
2. **Prefix match** in `title__c` (100 bonus points)
3. **Match** in `internalTitle__c` (150 points)
4. **Match** in `description__c` (75 points)
5. **Published content** (100 points)
6. **Public content** (50 points)
7. **Language match** (30 points)
8. **Creator match** (40 points)
9. **Folder match** (25 points)
10. **Tiebreaker**: Alphabetical by title

### Query Building
- **Search fields**: `title__c`, `internalTitle__c`, `description__c`
- **Optional filters**: Language, published status, public status, creator, folder
- **Ordering**: Published → Public → Created Date → Title
- **Limit**: Configurable (default 25)

## Message Format

### FR Agent Sections

#### HEADER
- **Consensus Content Search** or **ACT Content Search**

#### SUMMARY
- What was searched
- Filters applied
- Total matches vs. returned count

#### INSIGHTS
- Top 3-5 highlights with key metadata

#### DETAILS
- Markdown list of results with:
  - Title (bold)
  - Preview link (clickable)
  - Internal title
  - Language, published, public flags
  - Folder information
  - Creator details

#### LIMITS & COUNTS
- Total found vs. returned
- Page size limits
- Default filters applied

#### DATA (JSON)
- Compact JSON with essential fields
- Structured for agent consumption

## Sample Utterances & Expected Behavior

### Consensus Searches

1. **"Find Consensus demos for Datorama on media planning"**
   - Route: Consensus
   - Search: "datorama media planning"
   - Filters: published=true (default)

2. **"Show me Consensus content in English for Financial Services"**
   - Route: Consensus
   - Search: "financial services"
   - Filters: language=English, published=true

3. **"I need a Consensus demo for Billing Reconciliation — published only"**
   - Route: Consensus
   - Search: "billing reconciliation"
   - Filters: published=true

4. **"Search Consensus by creator Justin Jones"**
   - Route: Consensus
   - Search: (all content)
   - Filters: creator="Justin Jones", published=true

### ACT Searches

5. **"Search ACT for Sales Cloud onboarding materials"**
   - Route: ACT
   - Search: "Sales Cloud onboarding materials"
   - Filters: None

6. **"Find onboarding courses for new employees"**
   - Route: ACT (no "Consensus" keyword)
   - Search: "onboarding courses new employees"
   - Filters: None

## Implementation Details

### Handler Class
```apex
@InvocableMethod(
    label='ANAgent Search Content (Consensus or ACT)'
    description='Intelligently routes content searches to Consensus or ACT based on user utterance.'
)
public static List<ContentSearchResponse> searchContent(List<ContentSearchRequest> requests)
```

### Service Methods
- **Consensus**: `ANAgentConsensusContentSearchService.searchConsensusContent(userUtterance)`
- **ACT**: `ANAgentContentSearchServiceV2.search(searchTerm, contentType)`

### Security
- **CRUD/FLS**: Enforced via `Security.stripInaccessible(READABLE, records)`
- **Sharing**: `with sharing` class modifier
- **Field access**: Validated before query execution

## Deployment

### Files to Deploy
1. `ANAgentConsensusContentSearchService.cls`
2. `ANAgentConsensusContentSearchService.cls-meta.xml`
3. `ANAgentConsensusContentSearchHandler.cls`
4. `ANAgentConsensusContentSearchHandler.cls-meta.xml`

### Deployment Script
```bash
./scripts/deploy/deploy_consensus_content_search.sh <username>
```

### Post-Deployment Steps
1. **Add to Permission Set**: Include classes in Agent Integration User permissions
2. **Refresh Action Schema**: Remove → Save → Re-add action in Agent Builder
3. **Test Functionality**: Run test script with sample utterances

## Testing

### Test Script
```apex
scripts/testing/test_consensus_content_search.apex
```

### Test Scenarios
1. **Consensus routing** (explicit mention)
2. **ACT routing** (no Consensus keyword)
3. **Filter parsing** (language, published, creator, folder)
4. **Error handling** (empty/null inputs)
5. **Message composition** (all FR sections)
6. **Security validation** (field access)

### Validation Criteria
- ✓ Consensus keyword routes to Consensus service
- ✓ Non-Consensus routes to ACT service
- ✓ Published filter applied by default
- ✓ Results show Title and Preview Link prominently
- ✓ Message includes total matches and returned count
- ✓ All outputs pass Security.stripInaccessible
- ✓ Handler returns exactly one message:String

## Error Handling

### Service Errors
- **Query failures**: Caught and returned as error message
- **Security violations**: Handled gracefully with fallback
- **Invalid parameters**: Validated before processing

### Handler Errors
- **Null inputs**: Return error message
- **Empty utterances**: Return error message
- **Service exceptions**: Catch and return error details

## Performance Considerations

### Query Optimization
- **Indexed fields**: `isPublished__c`, `isPublic__c`, `createdAt__c`
- **Selective queries**: Only required fields selected
- **Result limiting**: Configurable page size (default 25)

### Memory Management
- **Streaming results**: Process records in batches
- **String building**: Use StringBuilder for message composition
- **Garbage collection**: Minimize object creation

## Maintenance

### Monitoring
- **Debug logs**: Service method execution
- **Error tracking**: Exception handling and logging
- **Performance metrics**: Query execution times

### Updates
- **Field additions**: Extend SearchParams and ConsensusContent classes
- **Ranking changes**: Modify calculateRelevanceScore method
- **Filter logic**: Update parseSearchParams method

## Troubleshooting

### Common Issues

1. **Permission errors**
   - Verify Agent Integration User permissions
   - Check field-level security on Agent_Consensu__c

2. **Query failures**
   - Validate object and field existence
   - Check SOQL syntax and limits

3. **Routing issues**
   - Confirm "consensus" keyword detection
   - Verify service method calls

4. **Message formatting**
   - Check markdown syntax
   - Validate JSON structure

### Debug Steps
1. **Enable debug logs** for the classes
2. **Run test script** with verbose output
3. **Check field mappings** against object schema
4. **Verify security settings** and permissions

## Future Enhancements

### Potential Improvements
1. **Advanced filtering**: Date ranges, content types
2. **Search suggestions**: Auto-complete functionality
3. **Result caching**: Performance optimization
4. **Analytics**: Search pattern analysis
5. **Multi-language**: Enhanced language support

### Integration Points
1. **Agent Builder**: Action schema updates
2. **Permission Sets**: User access management
3. **Monitoring**: Performance and usage tracking
4. **Documentation**: User guides and training

---

## Summary

The Consensus Content Search system provides intelligent routing between Consensus and ACT content based on user intent. It follows FR Agent best practices with a single handler boundary, comprehensive error handling, and structured message output. The system maintains backward compatibility while adding new Consensus search capabilities with advanced ranking and filtering.





