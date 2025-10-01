# SCF-01 — Scaffold FRAGENT Audience handler/service/DTO (single-output)

Object: Audience__c

**Acceptance Criteria**
- Handler: `FRAGENTAudienceHandler.manageAudiences` exists with @InvocableMethod, @InvocableVariables per requirements.
- Response.message returns ActionOutputEnvelope JSON with `contractName`, `version`, `code`, `message`, `data`.
- Service: `FRAGENTAudienceService` implements CRUD gates, secure queries, record-type assignment, dedupe, and delete guards.
- DTO: AudienceDetails mirrors `Id, Name, Created/Modified, CreatedBy/LastModified names`, `memberCount`, optional `members`.
- All compile; smoke passes: `FR_Smoke`.
