# ANAgentSMESearchHandler - Architecture Diagrams

## 🏗️ **System Architecture Overview**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           SME Search System Architecture                        │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│                           Agent UI/API Layer                                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│  │   MCP Router    │  │  Flow Builder   │  │   External API  │                │
│  │                 │  │                 │  │                 │                │
│  │ sme_search tool │  │ InvocableMethod │  │ REST/SOAP calls │                │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘                │
└─────────────────────────────┬───────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Handler Layer                                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentSMESearchHandler                             │   │
│  │                                                                         │   │
│  │  • Request Validation & Processing                                      │   │
│  │  • Response Formatting & Message Generation                            │   │
│  │  • Error Handling & Logging                                            │   │
│  │  • Conversation Logging Integration                                    │   │
│  │  • MCP Integration Interface                                           │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                ANAgentSMESearchHandlerSimple                           │   │
│  │                                                                         │   │
│  │  • Simplified Request Processing                                       │   │
│  │  • Basic Response Formatting                                           │   │
│  │  • Streamlined Error Handling                                          │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────┬───────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         Service Layer                                           │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentSMESearchService                             │   │
│  │                                                                         │   │
│  │  • Enhanced Search with Advanced Parameters                            │   │
│  │  • Data Enrichment & Contact Information Population                    │   │
│  │  • Product Counting & Statistical Analysis                            │   │
│  │  • Query Optimization & Governor Limit Management                     │   │
│  │  • Multi-Source Data Integration                                      │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                ANAgentSMESearchServiceSimple                           │   │
│  │                                                                         │   │
│  │  • Simplified Search Logic                                             │   │
│  │  • Relevance Ranking with Hardcoded Weights                           │   │
│  │  • Fuzzy Matching & Fallback Mechanisms                               │   │
│  │  • Contact Enrichment from Multiple Sources                           │   │
│  │  • Performance Optimization for Large Datasets                        │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────┬───────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          Data Layer                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│  │ AGENT_SME_      │  │ AGENT_OU_       │  │ Learner_        │                │
│  │ ACADEMIES__c    │  │ PIPELINE_V2__c  │  │ Profile__c      │                │
│  │                 │  │                 │  │                 │                │
│  │ • SME Catalog   │  │ • AE Roster     │  │ • Contact Info  │                │
│  │ • Product Info  │  │ • Email Data    │  │ • Learning Data │                │
│  │ • Performance   │  │ • OU Mapping    │  │ • Preferences   │                │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘                │
│                                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│  │     User        │  │ Agent_Utterance │  │   Custom        │                │
│  │                 │  │ Log__c          │  │   Metadata      │                │
│  │ • User Profiles │  │                 │  │                 │                │
│  │ • Email Data    │  │ • Conversation  │  │ • Configuration │                │
│  │ • Permissions   │  │   Logging       │  │ • Feature Flags │                │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘                │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔍 **Data Flow Sequence Diagram**

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    Agent    │    │   Handler   │    │   Service   │    │   Data      │    │  Response   │
│   Request   │    │   Layer     │    │   Layer     │    │   Layer     │    │  Formatter  │
└──────┬──────┘    └──────┬──────┘    └──────┬──────┘    └──────┬──────┘    └──────┬──────┘
       │                  │                  │                  │                  │
       │ 1. Search Request │                  │                  │                  │
       ├─────────────────►│                  │                  │                  │
       │                  │                  │                  │                  │
       │                  │ 2. Validate &    │                  │                  │
       │                  │    Process       │                  │                  │
       │                  ├─────────────────►│                  │                  │
       │                  │                  │                  │                  │
       │                  │                  │ 3. Build Query  │                  │
       │                  │                  │    with Filters │                  │
       │                  │                  ├─────────────────►│                  │
       │                  │                  │                  │                  │
       │                  │                  │ 4. Execute SOQL │                  │
       │                  │                  │    Query        │                  │
       │                  │                  │◄────────────────┤                  │
       │                  │                  │                  │                  │
       │                  │                  │ 5. Enrichment   │                  │
       │                  │                  │    Queries      │                  │
       │                  │                  ├─────────────────►│                  │
       │                  │                  │◄────────────────┤                  │
       │                  │                  │                  │                  │
       │                  │                  │ 6. Apply Ranking│                  │
       │                  │                  │    Algorithm    │                  │
       │                  │                  │                  │                  │
       │                  │                  │ 7. Processed    │                  │
       │                  │                  │    Results      │                  │
       │                  │◄─────────────────┤                  │                  │
       │                  │                  │                  │                  │
       │                  │ 8. Format        │                  │                  │
       │                  │    Response      │                  │                  │
       │                  ├─────────────────►│                  │                  │
       │                  │                  │                  │                  │
       │                  │ 9. Log           │                  │                  │
       │                  │    Conversation  │                  │                  │
       │                  ├─────────────────►│                  │                  │
       │                  │                  │                  │                  │
       │                  │ 10. Formatted    │                  │                  │
       │                  │     Response     │                  │                  │
       │◄─────────────────┤                  │                  │                  │
       │                  │                  │                  │                  │
```

---

## 🎯 **Intelligence Features Architecture**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Intelligence Features Architecture                       │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│                              Search Input                                      │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│  │   Search Term   │  │   Search Type   │  │   OU Context    │                │
│  │                 │  │                 │  │                 │                │
│  │ • Product Name  │  │ • PRODUCT       │  │ • AMER ACC      │                │
│  │ • AE Name       │  │ • AE            │  │ • UKI           │                │
│  │ • OU Name       │  │ • OU            │  │ • LATAM         │                │
│  │ • Mixed         │  │ • ALL           │  │ • EMEA          │                │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘                │
└─────────────────────────────┬───────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          Query Processing                                      │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                    Dynamic Query Builder                               │   │
│  │                                                                         │   │
│  │  • Search Term Escaping & Validation                                   │   │
│  │  • Search Type Condition Building                                      │   │
│  │  • OU Filter Application                                               │   │
│  │  • Academy Member Filtering                                            │   │
│  │  • Country & Product Level Filters                                     │   │
│  │  • Stale Record Handling                                               │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────┬───────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          Data Retrieval                                        │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                      SOQL Query Execution                              │   │
│  │                                                                         │   │
│  │  • Primary Query: AGENT_SME_ACADEMIES__c                              │   │
│  │  • Contact Enrichment: User & Learner_Profile__c                       │   │
│  │  • Performance Data: AGENT_OU_PIPELINE_V2__c                          │   │
│  │  • Governor Limit Optimization                                        │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────┬───────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         Intelligence Processing                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│  │   Relevance     │  │   Fuzzy         │  │   Contact       │                │
│  │   Ranking       │  │   Matching      │  │   Enrichment    │                │
│  │                 │  │                 │  │                 │                │
│  │ • Same OU +3.0  │  │ • Case Insensitive │ • User.Email    │                │
│  │ • Academy +2.5  │  │ • Partial Match │  │ • Learner Email │                │
│  │ • L2 Match +3.0 │  │ • Synonym Match │  │ • Multi-Source  │                │
│  │ • L3 Match +1.0 │  │ • Fallback Logic│  │ • Batch Lookup  │                │
│  │ • ACV Signal    │  │ • Jaccard Sim   │  │ • Name Matching │                │
│  │ • Recency +0.5  │  │ • Product Syns  │  │ • Error Handling│                │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘                │
└─────────────────────────────┬───────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         Response Generation                                     │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                    Intelligent Response Builder                        │   │
│  │                                                                         │   │
│  │  • Top 5 SME Ranking with Emojis                                      │   │
│  │  • Product Distribution Summary                                        │   │
│  │  • Academy Member Percentage                                           │   │
│  │  • Geographic Coverage Analysis                                        │   │
│  │  • Contact Information Population                                      │   │
│  │  • Ranking Explanation & Rationale                                     │   │
│  │  • Performance Metrics & Execution Time                               │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 **Enhanced Flow Sequence Diagram**

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Enhanced  │    │   Handler   │    │   Service   │    │   Ranking   │    │   Contact   │
│   Request   │    │   Layer     │    │   Layer     │    │   Engine    │    │   Enrich   │
└──────┬──────┘    └──────┬──────┘    └──────┬──────┘    └──────┬──────┘    └──────┬──────┘
       │                  │                  │                  │                  │
       │ 1. Enhanced      │                  │                  │                  │
       │    Search Request│                  │                  │                  │
       ├─────────────────►│                  │                  │                  │
       │                  │                  │                  │                  │
       │                  │ 2. Validate      │                  │                  │
       │                  │    Parameters    │                  │                  │
       │                  ├─────────────────►│                  │                  │
       │                  │                  │                  │                  │
       │                  │                  │ 3. Build Enhanced│                  │
       │                  │                  │    Query        │                  │
       │                  │                  ├─────────────────►│                  │
       │                  │                  │                  │                  │
       │                  │                  │ 4. Execute Query │                  │
       │                  │                  │    with Filters │                  │
       │                  │                  │◄────────────────┤                  │
       │                  │                  │                  │                  │
       │                  │                  │ 5. Raw Results  │                  │
       │                  │                  │                  │                  │
       │                  │                  │ 6. Apply Ranking│                  │
       │                  │                  │    Algorithm    │                  │
       │                  │                  ├─────────────────►│                  │
       │                  │                  │                  │                  │
       │                  │                  │ 7. Ranked       │                  │
       │                  │                  │    Results      │                  │
       │                  │                  │◄────────────────┤                  │
       │                  │                  │                  │                  │
       │                  │                  │ 8. Contact      │                  │
       │                  │                  │    Enrichment   │                  │
       │                  │                  ├─────────────────►│                  │
       │                  │                  │                  │                  │
       │                  │                  │ 9. Enriched     │                  │
       │                  │                  │    Data         │                  │
       │                  │                  │◄────────────────┤                  │
       │                  │                  │                  │                  │
       │                  │                  │ 10. Processed   │                  │
       │                  │                  │     Results     │                  │
       │                  │◄─────────────────┤                  │                  │
       │                  │                  │                  │                  │
       │                  │ 11. Format       │                  │                  │
       │                  │     Enhanced     │                  │                  │
       │                  │     Response     │                  │                  │
       │                  │                  │                  │                  │
       │                  │ 12. Final        │                  │                  │
       │                  │     Response     │                  │                  │
       │◄─────────────────┤                  │                  │                  │
       │                  │                  │                  │                  │
```

---

## 🛡️ **Error Handling Flow**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           Error Handling Architecture                          │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│                              Error Detection                                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│  │   Input         │  │   Query         │  │   Processing    │                │
│  │   Validation    │  │   Execution     │  │   Errors        │                │
│  │                 │  │                 │  │                 │                │
│  │ • Blank Search  │  │ • SOQL Errors   │  │ • Ranking Fail  │                │
│  │ • Invalid Type  │  │ • No Results    │  │ • Enrichment    │                │
│  │ • Missing Params│  │ • Gov Limits    │  │   Failures      │                │
│  │ • Type Mismatch │  │ • Timeout       │  │ • Memory Issues │                │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘                │
└─────────────────────────────┬───────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           Error Classification                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                        Error Categorizer                               │   │
│  │                                                                         │   │
│  │  • Validation Errors (400)                                             │   │
│  │  • Query Errors (500)                                                  │   │
│  │  • Processing Errors (500)                                             │   │
│  │  • Governor Limit Errors (503)                                         │   │
│  │  • Data Quality Issues (422)                                           │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────┬───────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          Error Response Generation                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                      Error Response Builder                            │   │
│  │                                                                         │   │
│  │  • User-Friendly Error Messages                                        │   │
│  │  • Technical Error Details (Debug Mode)                               │   │
│  │  • Suggested Actions & Workarounds                                    │   │
│  │  • Error Code & Reference ID                                          │   │
│  │  • Fallback Response Options                                          │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────┬───────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           Error Recovery                                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│  │   Graceful      │  │   Fallback      │  │   Logging &     │                │
│  │   Degradation   │  │   Mechanisms    │  │   Monitoring    │                │
│  │                 │  │                 │  │                 │                │
│  │ • Return Partial│  │ • Basic Search  │  │ • Error Logs    │                │
│  │ • Skip Enrichment│  │ • Cached Data  │  │ • Performance   │                │
│  │ • Use Defaults  │  │ • Empty Result │  │   Metrics       │                │
│  │ • Continue Flow │  │ • Error Message │  │ • Alert System  │                │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘                │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 📊 **Field Mapping Architecture**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         Field Mapping Architecture                             │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│                            Source Objects                                      │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                    AGENT_SME_ACADEMIES__c                              │   │
│  │                                                                         │   │
│  │  Id ────────────────────────► SMEInfo.id                               │   │
│  │  Name ──────────────────────► SMEInfo.name                             │   │
│  │  AE_NAME__c ────────────────► SMEInfo.aeName                          │   │
│  │  AE_RANK__c ────────────────► SMEInfo.aeRank                          │   │
│  │  OU__c ─────────────────────► SMEInfo.ou                              │   │
│  │  TOTAL_ACV__c ──────────────► SMEInfo.totalAcv                        │   │
│  │  PRODUCT_L2__c ─────────────► SMEInfo.productL2                       │   │
│  │  PRODUCT_L3__c ─────────────► SMEInfo.productL3                       │   │
│  │  ACADEMIES_MEMBER__c ───────► SMEInfo.academyMember                   │   │
│  │  WORK_LOCATION_COUNTRY__c ──► SMEInfo.workLocationCountry             │   │
│  │  CreatedDate ───────────────► SMEInfo.createdDate                     │   │
│  │  LastModifiedDate ──────────► SMEInfo.lastModifiedDate                │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────┬───────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         Contact Enrichment Mapping                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                            User Object                                 │   │
│  │                                                                         │   │
│  │  Name ──────────────────────► Name Matching                            │   │
│  │  Email ─────────────────────► SMEInfo.email (Primary)                  │   │
│  │  Title ─────────────────────► SMEInfo.title                            │   │
│  │  Department ────────────────► SMEInfo.department                       │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                       Learner_Profile__c                               │   │
│  │                                                                         │   │
│  │  Name ──────────────────────► Name Matching                            │   │
│  │  Primary_Email__c ──────────► SMEInfo.email (Fallback)                │   │
│  │  Phone__c ──────────────────► SMEInfo.phone                            │   │
│  │  externalid__c ─────────────► Cross-Reference ID                       │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                    AGENT_OU_PIPELINE_V2__c                             │   │
│  │                                                                         │   │
│  │  FULL_NAME__c ──────────────► Name Matching                            │   │
│  │  EMP_EMAIL_ADDR__c ─────────► SMEInfo.email (Fallback)                │   │
│  │  OU_NAME__c ────────────────► OU Validation                           │   │
│  │  LEARNER_PROFILE_ID__c ─────► Profile Linking                          │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🎯 **Intelligence Scoring Architecture**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                       Intelligence Scoring Architecture                         │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│                              Scoring Inputs                                    │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│  │   SME Record    │  │   Search        │  │   Context       │                │
│  │   Data          │  │   Parameters    │  │   Information   │                │
│  │                 │  │                 │  │                 │                │
│  │ • Product L2/L3 │  │ • Search Term   │  │ • OU Name       │                │
│  │ • OU Assignment │  │ • Search Type   │  │ • Country       │                │
│  │ • Academy Status│  │ • Max Results   │  │ • Product Level │                │
│  │ • ACV Value     │  │ • Academy Only  │  │ • Time Context  │                │
│  │ • Last Modified │  │ • Enhanced Mode │  │ • User Context  │                │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘                │
└─────────────────────────────┬───────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           Scoring Algorithm                                    │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                        Score Calculator                                │   │
│  │                                                                         │   │
│  │  Base Score: 0.0                                                        │   │
│  │                                                                         │   │
│  │  ┌─────────────────────────────────────────────────────────────────┐   │   │
│  │  │                    Scoring Factors                              │   │   │
│  │  │                                                                 │   │   │
│  │  │  • Same OU Match: +3.0 points                                  │   │   │
│  │  │  • Excellence Academy: +2.5 points                             │   │   │
│  │  │  • Product L2 Exact Match: +3.0 points                         │   │   │
│  │  │  • Product L2 Partial Match: +2.0 points                       │   │   │
│  │  │  • Product L3 Exact Match: +1.0 points                         │   │   │
│  │  │  • Product L3 Partial Match: +0.5 points                       │   │   │
│  │  │  • ACV Signal: min((ACV/1M), 2.0) points                       │   │   │
│  │  │  • Recency Bonus: +0.5 points (if < 90 days)                   │   │   │
│  │  │  • Fuzzy Match Penalty: -0.5 points                             │   │   │
│  │  └─────────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────┬───────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         Score Processing                                       │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                      Score Normalizer                                 │   │
│  │                                                                         │   │
│  │  • Validate Score Range (0.0 - 10.0)                                   │   │
│  │  • Apply Weight Adjustments                                            │   │
│  │  • Handle Null/Zero Values                                             │   │
│  │  • Calculate Confidence Level                                          │   │
│  │  • Generate Rationale Explanation                                      │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────┬───────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         Score Output                                           │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                        Final Score Package                             │   │
│  │                                                                         │   │
│  │  • Final Relevance Score (0.0 - 10.0)                                  │   │
│  │  • Scoring Rationale (Human Readable)                                  │   │
│  │  • Confidence Level (High/Medium/Low)                                  │   │
│  │  • Contributing Factors (List)                                         │   │
│  │  • Ranking Position (1-N)                                              │   │
│  │  • Comparison Metrics (vs. Other SMEs)                                 │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 **MCP Integration Flow**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           MCP Integration Architecture                         │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│                              MCP Router                                        │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentUtteranceRouterViaMCP                        │   │
│  │                                                                         │   │
│  │  • Pattern Recognition & Intent Classification                         │   │
│  │  • Tool Selection Logic (sme_search)                                  │   │
│  │  • Parameter Extraction & Validation                                  │   │
│  │  • Context-Aware Routing                                              │   │
│  │  • Error Handling & Fallback                                          │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────┬───────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            Tool Invocation                                     │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                        sme_search Tool                                 │   │
│  │                                                                         │   │
│  │  Input Parameters:                                                      │   │
│  │  • searchTerm (required)                                               │   │
│  │  • searchType (optional)                                               │   │
│  │  • ouName (optional)                                                   │   │
│  │  • maxResults (optional)                                               │   │
│  │  • academyMembersOnly (optional)                                       │   │
│  │  • useEnhancedSearch (optional)                                        │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────┬───────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         Handler Integration                                    │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                    ANAgentSMESearchHandler                             │   │
│  │                                                                         │   │
│  │  • MCP Parameter Mapping                                               │   │
│  │  • Request Validation & Processing                                     │   │
│  │  • Service Layer Invocation                                           │   │
│  │  • Response Formatting for MCP                                        │   │
│  │  • Error Handling & Logging                                           │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────┬───────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          Response Processing                                   │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                        MCP Response Builder                            │   │
│  │                                                                         │   │
│  │  • Structured Response Formatting                                      │   │
│  │  • Error Message Standardization                                       │   │
│  │  • Performance Metrics Inclusion                                       │   │
│  │  • Conversation Logging Integration                                    │   │
│  │  • Tool Response Optimization                                          │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

**Documentation Version**: 1.0  
**Last Updated**: December 2024  
**Architecture Status**: Production Ready
