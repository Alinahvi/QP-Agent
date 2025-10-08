# Changelog - SME Search Implementation

All notable changes to the SME Search implementation are documented in this file.

---

## [3.0.0] - 2025-10-08 - **CURRENT VERSION** ✅

### 🎉 Complete Rebuild - FR-Style Implementation

#### Added
- **ANAgentSMESearchHandlerV3.cls** - FR-style dumb router handler
- **ANAgentSMESearchServiceV3.cls** - Complete business logic service with DTO composer
- Single message output following FR agent best practices
- Comprehensive formatted message with HEADER, SUMMARY, INSIGHTS, DETAILS, LIMITS, and JSON
- Enhanced ranking algorithm with relevance scoring
- Security compliance with `Security.stripInaccessible()`
- Deterministic limits with explicit truncation notification
- Deployment script (`deploy.sh`) for easy installation
- Comprehensive README with troubleshooting guide

#### Architecture Changes
- ✅ **Agent Boundary = 1 Variable**: Only `message` field exposed to agent
- ✅ **Handler = Dumb Router**: No business logic, only input validation and service calls
- ✅ **Service = All Logic**: Complete message building with stable formatting
- ✅ **Flattened Response**: No Lists, Maps, Sets, or nested DTOs at boundary

#### Fixed
- Resolved "Precondition Failed: Unable to load agent config" error
- Fixed complex DTO exposure causing agent incompatibility
- Corrected SOQL query bind variable issues
- Improved error handling and logging

#### Message Format
```markdown
# SME Search Results

## Summary
- Search parameters and counts

## Insights
- Top OU and academy member statistics

## SME Details
- Individual SME information with rankings

## Limits & Counts
- Explicit truncation info

## Data (JSON)
- Compact JSON for LLM parsing
```

#### Testing
- ✅ Tableau search in UKI (710 results, showing 5)
- ✅ Data Cloud search in UKI (412 results, showing 5)
- ✅ Academy members only search (621 results, showing 5)
- ✅ All tests passed with proper message formatting

---

## [2.0.0] - 2025-10-08 - **DEPRECATED** ❌

### Added
- **ANAgentSMESearchHandlerV2.cls** - Handler with complex response structure
- **ANAgentSMESearchServiceV2.cls** - Service returning complex DTOs

### Issues
- ❌ Exposed complex DTOs (`records`, `totalRecordCount`, `errors`) to agent
- ❌ Handler contained business logic (default setting)
- ❌ Violated FR agent best practices
- ❌ Caused "Precondition Failed" errors in Agentforce
- ❌ Referenced by GenAI Function Definition preventing clean deletion

### Removal
- Removed on 2025-10-08
- Required deletion of dependent GenAI Function `Search_SMEs_V2`
- All V2 components cleaned from org

---

## [1.0.0] - Initial Implementation - **DEPRECATED** ❌

### Components
- **ANAgentSMESearchHandler.cls** - Original handler
- **ANAgentSMESearchService.cls** - Original service
- **ANAgentSMESearchHandlerSimple.cls** - Simplified version
- **ANAgentSMESearchServiceSimple.cls** - Simplified service
- **AN_SearchSME_FromMCP_Simple.cls** - MCP integration

### Issues
- Missing dependencies causing `MISSING_RECORD` errors
- Version mismatches between handler and service
- Dynamic SOQL bind variable errors
- Invocable method label conflicts
- Missing field mappings

### Evolution
- Created "Simple" versions from GitHub repository
- Fixed SOQL query escaping issues
- Resolved field mapping problems
- Led to V2 development (which was also deprecated)
- Eventually replaced by V3 (current)

---

## Migration Guide

### From V2 to V3
```bash
# 1. Remove V2 components
sf project delete source \
  --metadata ApexClass:ANAgentSMESearchHandlerV2 \
  --metadata ApexClass:ANAgentSMESearchServiceV2 \
  --metadata GenAiFunction:Search_SMEs_V2 \
  --target-org YOUR_ORG

# 2. Deploy V3
cd qp-agent-sme-search-v3
./deploy.sh YOUR_ORG

# 3. Update Agent Action
# - Remove old "Search SMEs V2" action
# - Add new "Search SMEs V3" action
# - Configure with new input/output instructions
```

### From V1 to V3
```bash
# 1. Remove all V1 components
sf project delete source \
  --metadata ApexClass:ANAgentSMESearchHandler \
  --metadata ApexClass:ANAgentSMESearchService \
  --metadata ApexClass:ANAgentSMESearchHandlerSimple \
  --metadata ApexClass:ANAgentSMESearchServiceSimple \
  --metadata ApexClass:AN_SearchSME_FromMCP_Simple \
  --target-org YOUR_ORG

# 2. Deploy V3
cd qp-agent-sme-search-v3
./deploy.sh YOUR_ORG

# 3. Update Agent Action
# - Remove all old SME search actions
# - Add new "Search SMEs V3" action
```

---

## Best Practices Learned

### What Worked ✅
1. **Single message output** - Agent can only read one field reliably
2. **Dumb router pattern** - Keep handler simple, logic in service
3. **Stable formatting** - Predictable message structure with sections
4. **Explicit limits** - Tell user when results are truncated
5. **Compact JSON** - Include structured data but keep it small (3-6 keys)
6. **Unique labels** - Avoid invocable method label conflicts
7. **Fresh deployments** - Sometimes easier to build V3 than fix V2

### What Didn't Work ❌
1. **Complex DTOs** - Lists, Maps, nested objects confuse the agent
2. **Multiple output fields** - Agent only reliably reads one field
3. **Business logic in handler** - Makes testing and debugging harder
4. **Bind variables in dynamic SOQL** - Use string concatenation with escaping
5. **Fixing broken implementations** - Sometimes better to start fresh

---

## Version Comparison

| Feature | V1.0 | V2.0 | V3.0 |
|---------|------|------|------|
| Single message output | ❌ | ❌ | ✅ |
| Dumb router handler | ❌ | ❌ | ✅ |
| FR-style compliance | ❌ | ❌ | ✅ |
| Works with Agentforce | ⚠️ | ❌ | ✅ |
| Ranking algorithm | ❌ | ✅ | ✅ |
| Security (FLS) | ⚠️ | ⚠️ | ✅ |
| Deterministic limits | ❌ | ⚠️ | ✅ |
| Documentation | ⚠️ | ❌ | ✅ |
| Deployment script | ❌ | ❌ | ✅ |
| Test coverage | ⚠️ | ⚠️ | ✅ |

---

## Known Issues & Limitations

### V3.0 (Current)
- **None currently identified** ✅
- Waiting for production feedback

### General Limitations
- Requires `AGENT_SME_ACADEMIES__c` object with specific fields
- Maximum 50,000 records per query (governor limit)
- Ranking algorithm is static (no ML/AI)
- No caching mechanism (queries run on every request)
- No internationalization support

---

## Future Roadmap

### Planned Enhancements
- [ ] **V3.1** - Add fuzzy matching for product names
- [ ] **V3.2** - Implement caching layer for frequently searched terms
- [ ] **V3.3** - Add email and phone fields to SME output
- [ ] **V3.4** - Support multiple language locales
- [ ] **V3.5** - Add export to CSV functionality
- [ ] **V4.0** - ML-based ranking using Einstein Analytics

### Under Consideration
- Real-time availability status
- Integration with Slack/Teams for contact
- SME recommendation engine
- Automated SME profile updates
- Skills taxonomy mapping

---

## Support & Feedback

### Report Issues
If you encounter issues with V3:
1. Check the troubleshooting guide in README.md
2. Verify all prerequisites are met
3. Review the deployment logs
4. Document the error message and steps to reproduce
5. Contact the Readiness Team

### Success Stories
If V3 works well for you:
- Share your use cases
- Suggest improvements
- Contribute test scenarios
- Help document edge cases

---

**Current Production Version:** 3.0.0  
**Release Date:** October 8, 2025  
**Next Review:** November 8, 2025  
**Status:** Production Ready ✅
