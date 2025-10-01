
# Audience Permissions Template — MCP Server Implementation Guide

**Scope:** This is a pragmatic, opinionated blueprint to turn the Audience *Handler → Service → Tests → Test Factory* pattern into a reusable **MCP function** template. It captures what worked in your codebase and bakes in guardrails so the next function your agent builds is production‑ready and CI‑stable from day one.

**Who this is for:** Engineers implementing new Audience-like functions, and the MCP server agent wiring those functions into your platform.

---

## 0) Architecture at a Glance (Copy This)

```
force-app/
  main/default/classes/
    AgentCore_Permissions.cls          // action-policy gating, custom-perm hooks, TEST_BYPASS
    AgentCore_SafeQuery.cls            // wraps SOQL, controls AccessLevel/SECURITY_ENFORCED
    AgentCore_TestFactory.cls          // users, perm sets, CRUD/FLS helpers, FieldPermissions
    FRAGENTAudienceHandler.cls         // input validation + orchestration
    FRAGENTAudienceService.cls         // business logic + security enforcement + DTO hydration
    FRAGENTAudienceHandler_Test.cls    // entrypoint behavior (positive via bypass, negative via perms)
    FRAGENTAudienceService_Test.cls    // service matrix: allow/deny, CRUD/FLS, policy gates, hydration
```

**Contract rules**
- **Handler** only validates inputs, maps to service calls, and returns **stable result codes**. No business logic.
- **Service** does: **requireAction() → CRUD/FLS → SOQL/ DML → hydration → DTO**. All denials return **stable codes**.
- **Permissions**: Use **custom permissions** + **action policies** for feature gates. **TEST_BYPASS** short‑circuits **before** policy checks for tests.
- **Queries**: Non‑bypass → `WITH SECURITY_ENFORCED` / USER_MODE. Bypass → dynamic `Database.queryWithBinds` in **SYSTEM_MODE** with a **secured string**.
- **Hydration**: Always requery by Ids to populate **CreatedBy.Name** / **LastModifiedBy.Name** in order‑preserving fashion.
- **RecordType**: Describe first; fallback to `RecordType` SOQL by `SObjectType + DeveloperName`. Include `RecordTypeId` in FLS set when writing.

---

## 1) Result Contract (Don’t Wing It)

Define a **stable**, serializable result used by both Handler and Service. Never assert on full error strings in tests.

```apex
public class AgentCore_Result {
    public Boolean success;
    public String code;            // e.g., 'OK', 'PERMISSION_DENIED', 'INVALID_INPUT', 'FLS_DENIED', 'NOT_FOUND'
    public String message;         // user-safe summary
    public List<String> errors;    // optional details
    public Object data;            // DTO or list of DTOs

    public static AgentCore_Result ok(Object dataObj) {
        AgentCore_Result r = new AgentCore_Result();
        r.success = true; r.code = 'OK'; r.data = dataObj;
        return r;
    }
    public static AgentCore_Result deny(String msg) {
        AgentCore_Result r = new AgentCore_Result();
        r.success = false; r.code = 'PERMISSION_DENIED'; r.message = msg;
        return r;
    }
    public static AgentCore_Result invalid(String msg) {
        AgentCore_Result r = new AgentCore_Result();
        r.success = false; r.code = 'INVALID_INPUT'; r.message = msg;
        return r;
    }
    public static AgentCore_Result fls(String msg) {
        AgentCore_Result r = new AgentCore_Result();
        r.success = false; r.code = 'FLS_DENIED'; r.message = msg;
        return r;
    }
}
```

**Guardrails**
- **Do not** leak raw exception text to clients. Map to `code` + friendly `message` and log the details server-side.
- **Do not** branch UI logic on full error strings. **Do** branch on `code`.

---

## 2) Permissions Layer (Policy First, Bypass Early)

### 2.1 `requireAction` — short‑circuit for tests
```apex
public with sharing class AgentCore_Permissions {
    public static Boolean TEST_BYPASS = false;

    public class ActionEvaluation { public Boolean allowed; public String denyMessage; public ActionEvaluation(String k){ } }
    public class PermissionException extends Exception { public ActionEvaluation eval; public PermissionException(String m, ActionEvaluation e){ super(m); eval=e; } }

    public static ActionEvaluation requireAction(String actionKey) {
        if (TEST_BYPASS) { // EARLY EXIT for tests
            ActionEvaluation ev = new ActionEvaluation(actionKey);
            ev.allowed = true;
            return ev;
        }
        ActionEvaluation eval = evaluateAction(actionKey); // your policy eval
        if (!eval.allowed) throw new PermissionException(eval.denyMessage, eval);
        return eval;
    }

    // ---- Test hooks (used only in tests) ----
    public static void flushCache(){ /* clear policy graph */ }
    public static void testSeedPermissionNode(String key, String parentKey, String customPermApi, Integer rank){}
    public static void testSeedActionPolicy(String actionKey, List<String> requiresAny, List<String> requiresAll, String denyMessage, String helpUrl){}
    public static void setTestPermission(String customPermApi, Boolean hasIt){}
}
```

**Guardrails**
- `TEST_BYPASS` is **test‑only**. Never toggle it in production paths.
- Bypass must happen **before** CRUD/FLS and policy evaluation or your tests will churn.

### 2.2 Action policy test (deny → allow) — required
```apex
@IsTest
static void testRequireAction_Retrieve_PolicyGate() {
    AgentCore_Permissions.flushCache();
    AgentCore_Permissions.testSeedPermissionNode('Cohort.RetrieveGate', null, 'Can_Retrieve_Audience', 1);
    AgentCore_Permissions.testSeedActionPolicy(
        AgentCore_ActionKeys.Audience.readKey(),
        new List<String>{ 'Cohort.RetrieveGate' }, new List<String>(), 'Insufficient permissions', null
    );

    System.runAs(AgentCore_TestFactory.Users.cohortCru(null)) {
        AgentCore_Permissions.setTestPermission('Can_Retrieve_Audience', false);
        AgentCore_Result res = FRAGENTAudienceService.retrieve(...);
        System.assertEquals('PERMISSION_DENIED', res.code);
    }
    System.runAs(AgentCore_TestFactory.Users.cohortCru(null)) {
        AgentCore_Permissions.setTestPermission('Can_Retrieve_Audience', true);
        AgentCore_Result res = FRAGENTAudienceService.retrieve(...);
        System.assertEquals('OK', res.code);
    }
}
```

---

## 3) Handler Pattern (Validate Early, Return Stable Codes)

**Responsibilities**
- Validate and normalize inputs (IDs present? formats ok?).
- **No business logic.** Call the Service and return its result.
- Pre‑validate obvious errors (e.g., delete with empty Id list) and return `INVALID_INPUT` without touching the Service.

```apex
public with sharing class FRAGENTAudienceHandler {
    public static AgentCore_Result handleDelete(List<Id> ids) {
        if (ids == null || ids.isEmpty()) {
            return AgentCore_Result.invalid('At least one Audience Id is required for delete.');
        }
        try {
            return FRAGENTAudienceService.deleteAudiences(ids);
        } catch (Exception e) {
            // Map to stable code; log e
            return AgentCore_Result.deny('Unable to delete audience at this time.');
        }
    }
}
```

**Guardrails**
- Don’t pass obviously invalid input to the Service.
- Don’t return untyped maps or ad‑hoc shapes — always return `AgentCore_Result`.

---

## 4) Service Pattern (Gate → CRUD/FLS → Query → Hydrate → DTO)

### 4.1 Gate and CRUD/FLS
```apex
public with sharing class FRAGENTAudienceService {

    public static AgentCore_Result retrieve(AudienceFilter f) {
        // Gate
        try {
            AgentCore_Permissions.requireAction(AgentCore_ActionKeys.Audience.readKey());
        } catch (AgentCore_Permissions.PermissionException pe) {
            return AgentCore_Result.deny(pe.getMessage());
        }

        // CRUD/FLS (example read check)
        if (!Schema.sObjectType.Audience__c.isAccessible()) {
            return AgentCore_Result.fls('Audience is not readable for this user.');
        }

        // Query (dual path shown below) ...
        // Hydration ...
        // DTO build ...
        return AgentCore_Result.ok(dto);
    }
}
```

### 4.2 Dual-path querying (bypass vs enforced)

**Non-bypass (production):** Prefer inline `WITH SECURITY_ENFORCED` or **USER_MODE** secure queries.

**Bypass (tests):** Use `Database.queryWithBinds(...)` in **SYSTEM_MODE**, string built via `AgentCore_SafeQuery.secureForAccessLevel(...)` (to neutralize WSE conflicts).

```apex
String soql = 'SELECT Id, Name, CreatedDate, LastModifiedDate, CreatedById, CreatedBy.Name,' +
              ' LastModifiedById, LastModifiedBy.Name FROM Audience__c WHERE Id IN :ids';

List<Audience__c> rows =
    AgentCore_Permissions.TEST_BYPASS
    ? (List<Audience__c>)Database.queryWithBinds(
          AgentCore_SafeQuery.secureForAccessLevel(soql, System.AccessLevel.USER_MODE),
          new Map<String,Object>{ 'ids' => ids },
          System.AccessLevel.SYSTEM_MODE
      )
    : [SELECT Id, Name, CreatedDate, LastModifiedDate, CreatedById, CreatedBy.Name,
         LastModifiedById, LastModifiedBy.Name
       FROM Audience__c WHERE Id IN :ids WITH SECURITY_ENFORCED];
```

**Guardrails**
- Only run SYSTEM_MODE inside `TEST_BYPASS` branches.
- Keep the **exact same field list** in both branches to avoid shape drift.

### 4.3 RecordType resolution (describe → fallback SOQL)
```apex
Id rtId;
try {
    Schema.RecordTypeInfo info = Audience__c.SObjectType.getDescribe()
        .getRecordTypeInfosByDeveloperName().get('Cohort');
    rtId = (info != null) ? info.getRecordTypeId() : null;
} catch (Exception ignore) {
    rtId = null;
}
if (rtId == null) {
    try {
        rtId = [SELECT Id FROM RecordType
                WHERE SObjectType='Audience__c' AND DeveloperName='Cohort' LIMIT 1].Id;
    } catch (Exception ignore2) {}
}
// When writing, include in FLS set if present
if (rtId != null) { /* add to FLS fields & set on records */ }
```

### 4.4 Relationship hydration (CreatedBy/LastModifiedBy)
**Always** requery by Ids **after** you assemble result Ids to guarantee relationship fields exist and preserve order.

```apex
if (!ids.isEmpty()) {
    String s = 'SELECT Id, Name, CreatedDate, LastModifiedDate, CreatedById, CreatedBy.Name,' +
               ' LastModifiedById, LastModifiedBy.Name FROM Audience__c WHERE Id IN :ids';
    System.AccessLevel mode = AgentCore_Permissions.TEST_BYPASS
        ? System.AccessLevel.SYSTEM_MODE : System.AccessLevel.USER_MODE;
    List<Audience__c> hydrated = (List<Audience__c>)Database.queryWithBinds(
        AgentCore_SafeQuery.secureForAccessLevel(s, System.AccessLevel.USER_MODE),
        new Map<String,Object>{ 'ids' => ids }, mode
    );
    // preserve input order by mapping Id -> row and reassembling
}
```

---

## 5) Tests — What *Must* Exist

### 5.1 Test data factory (Mixed‑DML safe)
- Create **users** with known permission‑set **labels**.
- Provide helpers: CRUD, CRU, retrieve‑only, no‑perm.
- Provide `ensureFieldPermission(object, field)` that **tries** to insert `FieldPermissions` and **swallows failures**.

```apex
public class AgentCore_TestFactory {
    public class Users {
        public static User cohortCru(String suffix) {
            User u = buildStdUser('cohortCru'+suffix);
            insert u;
            assignPermSet(u, AgentCore_Permissions.PERM_LABEL_CRU);
            return u;
        }
        // ... other roles
    }
    private static void assignPermSet(User u, String psLabel) {
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Label = :psLabel LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
    }
    public static void ensureFieldPermission(String sobjectApi, String fieldApi, Boolean readable, Boolean updatable){
        try {
            // try insert FieldPermissions; ignore if org forbids system fields, etc.
            insert new FieldPermissions(
                SObjectType = sobjectApi, Field = sobjectApi+'.'+fieldApi,
                PermissionsRead = readable, PermissionsEdit = updatable
            );
        } catch (Exception ignore) {}
    }
}
```

**Guardrails**
- Don’t rely on `LIMIT 1` to fish for records. **Create what you need** per test.
- Keep setup‑object DML separate from business DML or use `System.runAs` to segment.

### 5.2 Mandatory test matrix
- **Create**: allow & deny (no C or FLS read‑only on required fields).
- **Retrieve/Search**: allow & deny (policy + CRUD) + **hydration present**.
- **Update**: allow & deny (CRU vs retrieve‑only).
- **Delete**: allow & deny (CRUD vs CRU).
- **Policy gate**: seeded policy deny → allow via `setTestPermission`.
- **Bypass**: positive tests wrapped in `TEST_BYPASS = true` where org variance (FLS/RT) causes fragility.

### 5.3 Patterns (runnable snippets)

**Update allow**
```apex
@IsTest
static void testUpdate_Succeeds_WithU() {
    System.runAs(AgentCore_TestFactory.Users.cohortCru('u1')) {
        Audience__c a = TestDataFactory.mkAudience(); insert a;
        a.Name = 'Updated';
        AgentCore_Result res = FRAGENTAudienceService.updateAudiences(new List<Audience__c>{ a });
        System.assertEquals('OK', res.code, res.message);
    }
}
```

**Update deny**
```apex
@IsTest
static void testUpdate_Fails_NoU() {
    System.runAs(AgentCore_TestFactory.Users.cohortRetrieve('u2')) {
        Audience__c a = TestDataFactory.mkAudience(); insert a;
        a.Name = 'Blocked';
        AgentCore_Result res = FRAGENTAudienceService.updateAudiences(new List<Audience__c>{ a });
        System.assertEquals('PERMISSION_DENIED', res.code);
    }
}
```

**Retrieve hydration**
```apex
@IsTest
static void testRetrieve_Hydrates_Relationships() {
    System.runAs(AgentCore_TestFactory.Users.cohortCru('h1')) {
        List<Id> ids = TestDataFactory.mkAudiences(3);
        AgentCore_Result res = FRAGENTAudienceService.retrieveByIds(ids);
        List<AudienceDTO> dtos = (List<AudienceDTO>)res.data;
        System.assertNotEquals(null, dtos[0].createdByName);
        System.assertNotEquals(null, dtos[0].lastModifiedByName);
    }
}
```

**Handler invalid input (no ids)**
```apex
@IsTest
static void testHandler_Delete_NoIds_Invalid() {
    AgentCore_Result r = FRAGENTAudienceHandler.handleDelete(new List<Id>());
    System.assertEquals('INVALID_INPUT', r.code);
}
```

---

## 6) MCP Function Wiring (Server-Side)

**Input contract** (JSON → Apex DTO)
- Validate in the MCP server **before** calling Handler (e.g., required fields present, ID formats).
- Attach **traceIds** and **caller context**; forward to Handler.

**Error mapping**
- Apex returns `AgentCore_Result`. MCP must map `code` to your platform’s canonical error types:
  - `OK` → 200
  - `INVALID_INPUT` → 400
  - `PERMISSION_DENIED` → 403
  - `FLS_DENIED` → 403
  - `NOT_FOUND` → 404
  - else → 500

**Guardrails**
- **Never** toggle `TEST_BYPASS` from the MCP path.
- **Never** infer behavior from messages — use `code`.
- Enforce **time budgets**; log slow calls with `traceId` and `actionKey`.

**Skeleton**
```typescript
// Pseudo-code for MCP function handler
async function handleAudienceDelete(req): Promise<Response> {
  const ids = req.body?.ids;
  if (!Array.isArray(ids) || ids.length === 0) {
    return { status: 400, body: { code: 'INVALID_INPUT', message: 'At least one Audience Id is required.' }};
  }

  const apexRes = await salesforce.invoke('FRAGENTAudienceHandler.handleDelete', { ids });
  // apexRes matches AgentCore_Result
  return mapApexResultToHttp(apexRes);
}
```

---

## 7) Quality Gates & CI

**Static checks**
- Lint Apex and TypeScript/Node in MCP server.
- Scan for: queries without `WITH SECURITY_ENFORCED` in non‑bypass code; uses of `LIMIT 1` in tests; direct string matching of error messages in tests.

**CLI**
```bash
sf project deploy start --source-dir force-app --ignore-conflicts --wait 30
sf apex run test --tests FRAGENTAudienceService_Test,FRAGENTAudienceHandler_Test \
  --result-format human --code-coverage --wait 60
```

**Coverage expectations**
- ≥ 90% on Service/Handler, all permission branches executed.
- Policy gate test present (deny→allow).

---

## 8) Anti‑Patterns (Don’t Do These)

- Relying on profile names or user IDs in logic/tests.
- Calling Service methods directly from MCP without going through Handler validation.
- Asserting full error strings in tests.
- Using org data through `LIMIT 1` instead of creating specific records.
- Running enforced queries in SYSTEM_MODE outside of `TEST_BYPASS`.
- Skipping hydration and then dereferencing `CreatedBy.Name` in tests.

---

## 9) Quick Start Checklist (Print This)

- [ ] Result object has `code` and tests assert on it.
- [ ] Handler pre‑validates inputs and returns `INVALID_INPUT` when obvious problems exist.
- [ ] Service gates with `requireAction` and returns `PERMISSION_DENIED` on policy failure.
- [ ] CRUD/FLS checks are explicit; non‑bypass queries use `WITH SECURITY_ENFORCED`/USER_MODE.
- [ ] Bypass path present for tests only; **early** short‑circuit in `requireAction`.
- [ ] RecordType resolution has describe + SOQL fallback.
- [ ] Relationship hydration present (CreatedBy/LastModifiedBy names).
- [ ] Test factory creates users with labeled perm sets; ensures FLS as needed; avoids Mixed‑DML.
- [ ] Test matrix includes create/retrieve/update/delete allow & deny, policy gate deny→allow, handler invalids.
- [ ] No `LIMIT 1` dependence in tests; each test creates its own data.
- [ ] CI commands documented and passing locally.

---

## 10) Appendix — Minimal DTO

```apex
public class AudienceDTO {
    public Id id;
    public String name;
    public DateTime createdDate;
    public String createdByName;
    public DateTime lastModifiedDate;
    public String lastModifiedByName;
    // + members if needed
    public static AudienceDTO fromSObject(Audience__c a) {
        AudienceDTO d = new AudienceDTO();
        d.id = a.Id; d.name = a.Name;
        d.createdDate = a.CreatedDate;
        d.createdByName = (a.CreatedBy != null) ? a.CreatedBy.Name : null;
        d.lastModifiedDate = a.LastModifiedDate;
        d.lastModifiedByName = (a.LastModifiedBy != null) ? a.LastModifiedBy.Name : null;
        return d;
    }
}
```
