# 🎓 Search Content V5 - Salesforce Agent Action

## Overview
Searches ACT Learning Content (45,000+ courses) and Consensus Demo Videos (2,000+) to find relevant enablement materials, training programs, and customer demo videos.

## Purpose
- Find training courses by product, skill, or topic
- Discover customer demo videos
- Support enablement and customer education
- Enable just-in-time learning

## Files Included

### Apex Classes
- **`ANAgentContentSearchHandlerV5.cls`** - Handler layer (invocable method)
- **`ANAgentContentSearchHandlerV5.cls-meta.xml`** - Metadata
- **`ANAgentContentSearchServiceV5.cls`** - Service layer (business logic)
- **`ANAgentContentSearchServiceV5.cls-meta.xml`** - Metadata

### GenAI Function
- **`SearchContentV5/`** - GenAI Function metadata folder
  - `SearchContentV5.genAiFunction-meta.xml` - Function definition

## Salesforce Objects Used
- **`ACT_Learning_Content__c`** - Training courses, trails, modules
- **`Consensus_Demo_Video__c`** - Customer demo videos

## Key Features

### ✅ Dual Search Modes
1. **ACT** - Search training content (45,000+ courses)
2. **CONSENSUS** - Search demo videos (2,000+ videos)

### ✅ Flexible Input Handling
Accepts both string and proper types:
```json
{"searchTerm": "Data Cloud", "searchMode": "CONSENSUS", "limitValue": 50}
{"searchTerm": "Data Cloud", "searchMode": "CONSENSUS", "limitValue": "50"}
```

### ✅ Rich Filtering
- Search by title, description, keywords
- Filter by status (active/archived)
- Sort by relevance or date
- Limit results

### ✅ Enhanced Error Handling
All errors include:
- Error code
- Clear message
- 5+ correct examples
- Agent next steps

## Input Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `searchTerm` | String | **Yes** | Course/video title or keyword (min 2 chars) |
| `searchMode` | String | **Yes** | ACT or CONSENSUS |
| `limitValue` | String/Integer | No | Max results (1-200, default: 50) |
| `includeInactive` | String/Boolean | No | Include archived content (default: false) |

## Output Structure

```json
{
  "ok": true,
  "data": {
    "searchMode": "CONSENSUS",
    "summary": {
      "totalVideos": 50,
      "publishedVideos": 48,
      "archivedVideos": 2
    },
    "records": [
      {
        "id": "a7ZD7000000UfKPMA0",
        "name": "Data Cloud for Marketing",
        "description": "See Data Cloud in action...",
        "link": "https://play.goconsensus.com/...",
        "status": "Published",
        "type": "Consensus",
        "createdDate": "2025-08-29"
      }
    ]
  },
  "error": null
}
```

## Example Usage

### Search Training Content
```json
{
  "searchTerm": "Agentforce",
  "searchMode": "ACT",
  "limitValue": "50",
  "includeInactive": "false"
}
```

### Search Demo Videos
```json
{
  "searchTerm": "Data Cloud",
  "searchMode": "CONSENSUS",
  "limitValue": "20"
}
```

### Find Specific Product Content
```json
{
  "searchTerm": "Tableau",
  "searchMode": "ACT",
  "limitValue": "100"
}
```

## Deployment

### Using Salesforce CLI
```bash
sf project deploy start \
  --source-dir ANAgentContentSearchHandlerV5.cls \
  --source-dir ANAgentContentSearchServiceV5.cls \
  --source-dir SearchContentV5 \
  --target-org <your-org-alias>
```

### Using MCP Tool
```apex
mcp_salesforce_deploy_metadata({
  "usernameOrAlias": "your-org-alias",
  "directory": "/path/to/project",
  "sourceDir": [
    "force-app/main/default/classes/ANAgentContentSearchHandlerV5.cls",
    "force-app/main/default/classes/ANAgentContentSearchServiceV5.cls",
    "force-app/main/default/genAiFunctions/SearchContentV5"
  ]
})
```

## Testing

Test with Anonymous Apex:
```apex
List<ANAgentContentSearchHandlerV5.ContentSearchRequest> requests = 
    new List<ANAgentContentSearchHandlerV5.ContentSearchRequest>();

ANAgentContentSearchHandlerV5.ContentSearchRequest req = 
    new ANAgentContentSearchHandlerV5.ContentSearchRequest();
req.searchTerm = 'Data Cloud';
req.searchMode = 'CONSENSUS';
req.limitValue = '50';

requests.add(req);

List<ANAgentContentSearchHandlerV5.ContentSearchResponse> responses = 
    ANAgentContentSearchHandlerV5.searchContent(requests);

System.debug(responses[0].result);
```

## Field Mappings

### ACT_Learning_Content__c Fields:
- `Name` - Content ID
- `Content_Title__c` - Course/trail title
- `Description__c` - Content description
- `Content_Type__c` - Type (Course, Trail, Module)
- `Status__c` - Active/Archived
- `Product_Family__c` - Related product
- `Skill_Area__c` - Skill category
- `Duration_Minutes__c` - Length
- `Content_URL__c` - Link to content
- `Keywords__c` - Search keywords
- `CreatedDate` - Creation date

### Consensus_Demo_Video__c Fields:
- `Name` - Video ID
- `Video_Title__c` - Demo title
- `Description__c` - Video description
- `Status__c` - Published/Archived
- `Video_URL__c` - Consensus link
- `Product_Focus__c` - Featured products
- `Industry_Focus__c` - Target industries
- `Duration_Minutes__c` - Video length
- `Use_Case__c` - Demo scenario
- `CreatedDate` - Upload date

## Search Modes Explained

### ACT Mode (Training Content)
**Searches:** 45,000+ training courses, trails, modules

**Content Types:**
- Trailhead modules
- Instructor-led courses
- Video tutorials
- Product documentation
- Certification prep

**Use Cases:**
- AE onboarding
- Product training
- Skill development
- Certification support

**Example Results:**
- "Agentforce for Sales" (Trail)
- "Data Cloud Fundamentals" (Course)
- "Einstein AI Certification Prep" (Module)

### CONSENSUS Mode (Demo Videos)
**Searches:** 2,000+ customer demo videos

**Content Types:**
- Product demos
- Industry solutions
- Customer stories
- Executive briefings
- Technical deep dives

**Use Cases:**
- Sales enablement
- Customer presentations
- Competitive positioning
- Event preparation

**Example Results:**
- "Data Cloud for Financial Services"
- "Agentforce Healthcare Demo"
- "Dreamforce Keynote Highlights"

## Search Tips

### Effective Search Terms
✅ **Good:**
- "Data Cloud demo"
- "Agentforce training"
- "Sales Cloud certification"
- "Einstein AI overview"

❌ **Avoid:**
- Single letters ("A", "B")
- Too generic ("video", "course")
- Special characters only

### Filtering Best Practices
1. **Use ACT for training:** Internal employee learning
2. **Use CONSENSUS for demos:** External customer presentations
3. **Set appropriate limits:** 20-50 for focused results, 100+ for broad discovery
4. **Include inactive:** Only when researching historical content

## Version History
- **V5** (Oct 2025): Clean rebuild, flexible input, enhanced errors, no V4 references
- **V4** (Sep 2025): Added flexible boolean inputs, backward compatibility
- **V3** (Aug 2025): Enhanced search relevance
- **V2** (Jul 2025): Added CONSENSUS mode
- **V1** (Jun 2025): Initial ACT search only

## Support
For issues or questions, contact the Sales Operations team or reference:
- Test Report: `SEARCHCONTENTV5_20_TEST_REPORT.md`
- Migration Guide: `🏆_FINAL_V5_COMPLETE_SUMMARY.md`

---

**Status:** ✅ Production Ready | **Test Coverage:** 20/20 (100%) | **Last Updated:** Oct 27, 2025

