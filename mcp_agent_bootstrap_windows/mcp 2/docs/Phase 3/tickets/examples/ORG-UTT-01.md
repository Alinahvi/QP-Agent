---
id: ORG-UTT-01
priority: P1
object: AssignedLearning__c
area: Agent Utterance
suite:
  - FR_Smoke
allowlist:
  - FRAGENTAssignedLearningService_Test
runAgent: true
allowDestructive: false
created: 2025-09-26
---

# Sample Utterance Test — Non‑Destructive

## Objective
Validate that the Agent can return assignments for a known learner without modifying data.

## Steps (pipeline)
1. **Seed permissions** (read‑only): `assign_permission_set: ACT_Test_Agent_ReadOnly`
2. **Fixtures**: `run_soql_query` to ensure `LearnerProfile__c` with `External_Id__c = 'LP-00123'` exists.
3. **Deploy** (if needed): `deploy_metadata` (NoTestRun).
4. **Apex tests**: run allowlist/suite (`FR_Smoke`) and ensure pass.
5. **Utterance** (non‑destructive):
   - `agentApiName`: `Field_Readiness_Agent`
   - `utterances`: `["Show assignments for learner LP-00123"]`
   - `maxTurns`: 1
   - `mode`: `non_destructive`
   - `capture`: `["transcript","actions","metrics"]`
6. **Artifacts**: Write `.artifacts/agent/ORG-UTT-01.json`.

## Expected envelope (last agent turn)
```json
{
  "contractName": "AssignedLearningActionEnvelope",
  "version": "1.0",
  "code": "OK",
  "message": "Found N assignments",
  "data": { "records": [{ "Id": "...", "Name": "..." }] }
}
```

## Success criteria
- `code = "OK"`
- First action topic matches **Assigned Learning** handler
- `coherence ≥ 0.75`, `adherence ≥ 0.8`, `latencyMs ≤ 3000`
- Artifacts saved with transcript + metrics
