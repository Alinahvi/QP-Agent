/**
 * @description SME Search Service V6 - AgentCore Integration + Enhanced Error Handling
 * @author Sales Operations Team
 * @version 6.0
 * @date 2025-11-04
 * 
 * IMPROVEMENTS FROM V5:
 * - ✅ AgentCore_PermissionValidator replaces FRPermissionGuard
 * - ✅ AgentCore_Exception for consistent error handling
 * - ✅ AgentCore_Constants for standardized codes/messages
 * - ✅ Enhanced exception handling with context-aware agent guidance
 * - ✅ 12-level manager chain filtering (Emp_Mgt_Chain_Lvl_01_Nm__c through _12)
 * - ✅ Better "no results" messages with actual org data samples (OUs, Countries)
 * - ✅ Removed FRSearchGuard dependency (inline validation)
 * - ✅ searchTerm remains REQUIRED for data quality
 */
public with sharing class ANAgentSMESearchServiceV6 {

    /* ---------- Error taxonomy helpers (JSON-first) ---------- */

    private static String ok(Object data, Integer total, Integer limitVal) {
        Map<String, Object> res = new Map<String, Object>{
            'ok' => true,
            'data' => data,
            'error' => null
        };
        if (total != null) res.put('total', total);
        if (limitVal != null) res.put('limit', limitVal);
        return JSON.serialize(res);
    }

    private static String err(String code, String message, String field, String expected, Object got,
                              List<String> samples, List<String> nextSteps) {
        Map<String, Object> res = new Map<String, Object>{
            'ok' => false,
            'data' => null,
            'error' => new Map<String, Object>{
                'code' => code,
                'message' => message,
                'details' => new Map<String, Object>{
                    'field' => field,
                    'expected' => expected,
                    'got' => got,
                    'samples' => (samples == null ? new List<String>() : samples),
                    'agent_next_steps' => (nextSteps == null ? new List<String>() : nextSteps)
                }
            }
        };
        return JSON.serialize(res);
    }

    /* ---------- Validation (agent-visible) ---------- */

    private static String validateRequest(ANAgentSMESearchHandlerV6.SMESearchRequest r, Integer limitValue, Integer minTenureDays) {
        // CRUD/FLS upfront using AgentCore
        AgentCore_PermissionValidator.PermissionResult smePermCheck = AgentCore_PermissionValidator.validate(
            new AgentCore_PermissionValidator.PermissionRequest(
                Schema.AGENT_SME_ACADEMIES__c.SObjectType, 
                'READ'
            ).addReadableField('LEARNER_PROFILE_ID__c')
             .addReadableField('PRODUCT_L2__c')
             .addReadableField('PRODUCT_L3__c')
             .addReadableField('Name')
             .addReadableField('ACADEMIES_MEMBER__c')
             .addReadableField('AE_RANK__c')
             .addReadableField('TOTAL_ACV__c')
        );
        
        if (!smePermCheck.allowed) {
            return err(AgentCore_Constants.RESULT_CODE_PERMISSION_DENIED, 
                       'No read access to AGENT_SME_ACADEMIES__c',
                       'object', 'Read on AGENT_SME_ACADEMIES__c', null, null,
                       new List<String>{'Contact support to grant read permissions on AGENT_SME_ACADEMIES__c'});
        }
        
        AgentCore_PermissionValidator.PermissionResult lpPermCheck = AgentCore_PermissionValidator.validate(
            new AgentCore_PermissionValidator.PermissionRequest(
                Schema.Learner_Profile__c.SObjectType, 
                'READ'
            ).addReadableField('OU_Name__c')
             .addReadableField('Work_Location_Country__c')
             .addReadableField('Macro_Segment__c')
             .addReadableField('Employee_Tenure__c')
             .addReadableField('Emp_Mgt_Chain_Lvl_01_Nm__c')
             .addReadableField('Employee_on_Leave__c')
        );
        
        if (!lpPermCheck.allowed) {
            return err(AgentCore_Constants.RESULT_CODE_PERMISSION_DENIED, 
                       'No read access to Learner_Profile__c',
                       'object', 'Read on Learner_Profile__c', null, null,
                       new List<String>{'Contact support to grant read permissions on Learner_Profile__c'});
        }

        // requireds
        if (String.isBlank(r.searchTerm)) {
            return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                       'searchTerm is required',
                       'searchTerm', 'non-empty string', 'blank', 
                       new List<String>{'Sales Cloud', 'Agentforce', 'Data Cloud', 'Smith'},
                       new List<String>{'Provide 2+ characters for product or person name', 'Example: "Sales Cloud" or "John Smith"'});
        }

        // shape - inline validation (removed FRSearchGuard dependency)
        if (r.searchTerm.length() < 2) {
            return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                       'searchTerm must be ≥ 2 chars',
                       'searchTerm', 'length >= 2', r.searchTerm, 
                       new List<String>{'Sales Cloud', 'Tableau', 'Data Cloud', 'Smith'},
                       new List<String>{'Trim to a core product name or surname', 'Use at least 2 characters'});
        }

        // picklist - inline validation (removed FRSearchGuard dependency)
        if (String.isNotBlank(r.searchType)) {
            Set<String> valid = new Set<String>{'Product','Name','All'};
            if (!valid.contains(r.searchType)) {
                List<String> samples = new List<String>{'Product','Name','All'};
                return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                           'searchType must be Product|Name|All',
                           'searchType', 'Product|Name|All', r.searchType, samples,
                           new List<String>{'Use "Product" to focus on PRODUCT_L2/L3', 'Use "Name" for person names', 'Use "All" for both'});
            }
        }

        // ranges
        if (limitValue != null && (limitValue < 1 || limitValue > 200)) {
            return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                       'limit must be 1–200',
                       'limit', '1–200', limitValue, new List<String>{'20','50','100'}, 
                       new List<String>{'Use default 20 or specify between 1-200'});
        }
        if (minTenureDays != null && minTenureDays < 0) {
            return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT, 
                       'minTenureDays must be >= 0',
                       'minTenureDays', '>= 0', minTenureDays, new List<String>{'0','365','730','1095'}, 
                       new List<String>{'Use 365 for 1 year, 730 for 2 years, 1095 for 3 years'});
        }

        // OU / Country examples (real samples) if provided but look invalid length
        if (String.isNotBlank(r.ouName) && r.ouName.length() < 2) {
            return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT,
                       'ouName too short','ouName','>=2 chars',r.ouName,
                       sampleOUs(3), new List<String>{'Pick one OU from samples and retry', 'Use at least 2 characters'});
        }
        if (String.isNotBlank(r.workCountry) && r.workCountry.length() < 2) {
            return err(AgentCore_Constants.RESULT_CODE_INVALID_INPUT,
                       'workCountry too short','workCountry','country name',r.workCountry,
                       sampleCountries(3), new List<String>{'Use one of the countries above', 'Use at least 2 characters'});
        }

        return null;
    }

    /* ---------- Public entry (JSON-first, no silent fixes) ---------- */

    public static String searchSMEs(ANAgentSMESearchHandlerV6.SMESearchRequest r, Integer limitValue, Boolean academyMembersOnly, Integer minTenureDays, Boolean includeOnLeave, Boolean summaryOnly) {
        try {
            String v = validateRequest(r, limitValue, minTenureDays);
            if (v != null) return v;

            String searchType = String.isNotBlank(r.searchType) ? r.searchType : 'All';
            Integer limitVal = (limitValue == null) ? 20 : Math.min(Math.max(limitValue,1),200);
            Boolean academyOnly = (academyMembersOnly == null) ? false : academyMembersOnly;
            Boolean includeOnLeaveVal = (includeOnLeave == null) ? true : includeOnLeave;

            // Build query with proper escaping
            String query = buildSMEDynamicQuery(r, searchType, academyOnly, limitVal);
            System.debug('SME Search V6 Query: ' + query);

            // Execute query with security enforcement
            List<SObject> records = executeQuery(query);

            // Get Learner Profile data for the SME records (with 12-level manager chain)
            Map<String, SObject> learnerProfileMap = getLearnerProfileData(records);

            // Process and rank results with Learner Profile data
            List<SMEInfoV6> smeList = processSMERecordsWithLPData(records, learnerProfileMap, r, includeOnLeaveVal, minTenureDays);

            // Check for no results and provide helpful guidance
            if (smeList.isEmpty()) {
                return buildNoResultsError(r, searchType, academyOnly, minTenureDays);
            }

            // Sort by relevance score
            smeList.sort(new SMERankingComparatorV6());

            // Apply limit after sorting
            if (smeList.size() > limitVal) {
                List<SMEInfoV6> limitedList = new List<SMEInfoV6>();
                for (Integer i = 0; i < limitVal; i++) {
                    limitedList.add(smeList[i]);
                }
                smeList = limitedList;
            }

            // Get total count for pagination info
            Integer totalFound = getTotalCount(r, searchType, academyOnly);

            // Build complete result following V6 JSON structure
            return buildV6Result(smeList, r, totalFound, limitVal, summaryOnly, academyMembersOnly, minTenureDays, includeOnLeaveVal);

        } catch (QueryException qe) {
            return err(AgentCore_Constants.RESULT_CODE_RETRIEVE_FAILED,
                       'Database query failed', 'soql', 'valid SOQL', qe.getMessage(), null,
                       new List<String>{'Reduce filters and retry','Check field API names','Contact support if issue persists'});
        } catch (AgentCore_Exception ace) {
            return err(AgentCore_Constants.RESULT_CODE_PERMISSION_DENIED,
                       'Access denied', 'security', 'CRUD/FLS permitting read', ace.getMessage(), null,
                       new List<String>{'Request necessary permissions from your administrator'});
        } catch (NullPointerException npe) {
            return err(AgentCore_Constants.RESULT_CODE_VALIDATION_ERROR,
                       'Missing required data in related records', 'relationship', 'non-null references', npe.getMessage(), null,
                       new List<String>{'Ensure Learner_Profile data is populated for each SME','Contact support if data is incomplete'});
        } catch (Exception e) {
            return err(AgentCore_Constants.RESULT_CODE_UNEXPECTED,
                       'Unexpected system error', 'service', 'successful execution', e.getMessage(), null,
                       new List<String>{'Retry with simpler filters','Escalate with error details if issue persists'});
        }
    }

    /* ---------- Query building ---------- */

    private static String buildSMEDynamicQuery(ANAgentSMESearchHandlerV6.SMESearchRequest request, String searchType, Boolean academyOnly, Integer limitValue) {
        String query = 'SELECT Id, Name, ACADEMIES_MEMBER__c, AE_RANK__c, PRODUCT_L2__c, PRODUCT_L3__c, ' +
                      'TOTAL_ACV__c, LEARNER_PROFILE_ID__c, CreatedDate, LastModifiedDate ' +
                      'FROM AGENT_SME_ACADEMIES__c WHERE LEARNER_PROFILE_ID__c != null';

        // Add search term filters
        if (String.isNotBlank(request.searchTerm)) {
            String escapedTerm = String.escapeSingleQuotes(request.searchTerm);
            List<String> searchConditions = new List<String>();
            
            if (searchType == 'Product' || searchType == 'All') {
                searchConditions.add('(PRODUCT_L3__c LIKE \'%' + escapedTerm + '%\' OR PRODUCT_L2__c LIKE \'%' + escapedTerm + '%\')');
            }
            if (searchType == 'Name' || searchType == 'All') {
                searchConditions.add('(Name LIKE \'%' + escapedTerm + '%\')');
            }
            
            if (!searchConditions.isEmpty()) {
                query += ' AND (' + String.join(searchConditions, ' OR ') + ')';
            }
        }

        // Add academy filter
        if (academyOnly == true) {
            query += ' AND ACADEMIES_MEMBER__c = true';
        }

        // Add ordering and limit
        query += ' ORDER BY AE_RANK__c DESC, TOTAL_ACV__c DESC LIMIT ' + limitValue;
        
        return query;
    }

    private static List<SObject> executeQuery(String query) {
        try {
            List<SObject> results = Database.query(query);
            // Apply security stripping using with sharing context
            return Security.stripInaccessible(AccessType.READABLE, results).getRecords();
        } catch (QueryException qe) {
            System.debug(LoggingLevel.ERROR, 'SOQL Query Error: ' + qe.getMessage());
            throw qe;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Query execution error: ' + e.getMessage());
            throw new AgentCore_Exception('Failed to execute SME search query: ' + e.getMessage());
        }
    }

    private static Integer getTotalCount(ANAgentSMESearchHandlerV6.SMESearchRequest request, String searchType, Boolean academyOnly) {
        String countQuery = 'SELECT COUNT() FROM AGENT_SME_ACADEMIES__c WHERE LEARNER_PROFILE_ID__c != null';
        
        if (String.isNotBlank(request.searchTerm)) {
            String escapedTerm = String.escapeSingleQuotes(request.searchTerm);
            List<String> searchConditions = new List<String>();
            
            if (searchType == 'Product' || searchType == 'All') {
                searchConditions.add('(PRODUCT_L3__c LIKE \'%' + escapedTerm + '%\' OR PRODUCT_L2__c LIKE \'%' + escapedTerm + '%\')');
            }
            if (searchType == 'Name' || searchType == 'All') {
                searchConditions.add('(Name LIKE \'%' + escapedTerm + '%\')');
            }
            
            if (!searchConditions.isEmpty()) {
                countQuery += ' AND (' + String.join(searchConditions, ' OR ') + ')';
            }
        }

        if (academyOnly == true) {
            countQuery += ' AND ACADEMIES_MEMBER__c = true';
        }

        try {
            return Database.countQuery(countQuery);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Count query error: ' + e.getMessage());
            return 0;
        }
    }

    /* ---------- Related data (12-level manager chain support) ---------- */

    private static Map<String, SObject> getLearnerProfileData(List<SObject> records) {
        Map<String, SObject> learnerProfileMap = new Map<String, SObject>();
        
        if (records == null || records.isEmpty()) {
            return learnerProfileMap;
        }
        
        // Collect Learner Profile IDs
        Set<String> learnerProfileIds = new Set<String>();
        for (SObject record : records) {
            String learnerProfileId = String.valueOf(record.get('LEARNER_PROFILE_ID__c'));
            if (String.isNotBlank(learnerProfileId)) {
                learnerProfileIds.add(learnerProfileId);
            }
        }
        
        if (learnerProfileIds.isEmpty()) {
            return learnerProfileMap;
        }
        
        // Query Learner Profile records with ALL 12 management levels
        String lpQuery = 'SELECT Id, Name, OU_Name__c, Work_Location_Country__c, Macro_Segment__c, ';
        lpQuery += 'Employee_Tenure__c, ';
        // V6: 12-level manager chain support
        lpQuery += 'Emp_Mgt_Chain_Lvl_01_Nm__c, Emp_Mgt_Chain_Lvl_02_Nm__c, ';
        lpQuery += 'Emp_Mgt_Chain_Lvl_03_Nm__c, Emp_Mgt_Chain_Lvl_04_Nm__c, Emp_Mgt_Chain_Lvl_05_Nm__c, ';
        lpQuery += 'Emp_Mgt_Chain_Lvl_06_Nm__c, Emp_Mgt_Chain_Lvl_07_Nm__c, Emp_Mgt_Chain_Lvl_08_Nm__c, ';
        lpQuery += 'Emp_Mgt_Chain_Lvl_09_Nm__c, Emp_Mgt_Chain_Lvl_10_Nm__c, Emp_Mgt_Chain_Lvl_11_Nm__c, ';
        lpQuery += 'Emp_Mgt_Chain_Lvl_12_Nm__c, ';
        lpQuery += 'Employee_on_Leave__c, Hire_Date__c, Primary_Email__c, em_Industry__c ';
        lpQuery += 'FROM Learner_Profile__c WHERE Id IN :learnerProfileIds';
        
        try {
            List<SObject> learnerProfiles = Database.query(lpQuery);
            
            // Create map for easy lookup
            for (SObject lp : learnerProfiles) {
                learnerProfileMap.put(String.valueOf(lp.get('Id')), lp);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Learner Profile query error: ' + e.getMessage());
        }
        
        return learnerProfileMap;
    }

    /* ---------- LP post-filters (12-level manager chain) ---------- */

    private static Boolean passLPFilters(SMEInfoV6 info, ANAgentSMESearchHandlerV6.SMESearchRequest r, Integer minTenureDays) {
        if (String.isNotBlank(r.ouName) && String.isNotBlank(info.organizationalUnit)
            && !info.organizationalUnit.toLowerCase().contains(r.ouName.toLowerCase())) return false;

        if (String.isNotBlank(r.workCountry) && String.isNotBlank(info.workCountry)
            && !info.workCountry.toLowerCase().contains(r.workCountry.toLowerCase())) return false;

        if (String.isNotBlank(r.vertical) && String.isNotBlank(info.macroSegment)
            && !info.macroSegment.toLowerCase().contains(r.vertical.toLowerCase())) return false;

        if (String.isNotBlank(r.industry) && String.isNotBlank(info.industry)
            && !info.industry.toLowerCase().contains(r.industry.toLowerCase())) return false;

        if (minTenureDays != null && info.tenureDays != null && info.tenureDays < minTenureDays) return false;

        // V6: 12-level manager chain filtering
        if (String.isNotBlank(r.managerEmail)) {
            Boolean foundInChain = false;
            String emailLower = r.managerEmail.toLowerCase();
            
            // Check all 12 levels
            if (String.isNotBlank(info.managerL1) && info.managerL1.toLowerCase().contains(emailLower)) foundInChain = true;
            if (String.isNotBlank(info.managerL2) && info.managerL2.toLowerCase().contains(emailLower)) foundInChain = true;
            if (String.isNotBlank(info.managerL3) && info.managerL3.toLowerCase().contains(emailLower)) foundInChain = true;
            if (String.isNotBlank(info.managerL4) && info.managerL4.toLowerCase().contains(emailLower)) foundInChain = true;
            if (String.isNotBlank(info.managerL5) && info.managerL5.toLowerCase().contains(emailLower)) foundInChain = true;
            if (String.isNotBlank(info.managerL6) && info.managerL6.toLowerCase().contains(emailLower)) foundInChain = true;
            if (String.isNotBlank(info.managerL7) && info.managerL7.toLowerCase().contains(emailLower)) foundInChain = true;
            if (String.isNotBlank(info.managerL8) && info.managerL8.toLowerCase().contains(emailLower)) foundInChain = true;
            if (String.isNotBlank(info.managerL9) && info.managerL9.toLowerCase().contains(emailLower)) foundInChain = true;
            if (String.isNotBlank(info.managerL10) && info.managerL10.toLowerCase().contains(emailLower)) foundInChain = true;
            if (String.isNotBlank(info.managerL11) && info.managerL11.toLowerCase().contains(emailLower)) foundInChain = true;
            if (String.isNotBlank(info.managerL12) && info.managerL12.toLowerCase().contains(emailLower)) foundInChain = true;
            
            if (!foundInChain) return false;
        }

        return true;
    }

    /* ---------- SMEInfo model (factory-based with 12 manager levels) ---------- */

    private class SMEInfoV6 {
        public String id, name, learnerProfileId, learnerProfileName, organizationalUnit, productL3, productL2,
                      workCountry, macroSegment, industry, 
                      managerL1, managerL2, managerL3, managerL4, managerL5, managerL6,
                      managerL7, managerL8, managerL9, managerL10, managerL11, managerL12,
                      scoringRationale;
        public Double aeRank, relevanceScore;
        public Decimal totalACV;
        public Boolean isAcademyMember, isOnLeave;
        public Integer tenureDays;
        public Date hireDate;
        public Datetime createdDate, lastModifiedDate;
    }
    
    private static SMEInfoV6 createSMEInfo(SObject rec, Map<String,SObject> lpById) {
        SMEInfoV6 o = new SMEInfoV6();
        o.id   = (String) rec.get('Id');
        o.name = (String) rec.get('Name');
        o.aeRank = (rec.get('AE_RANK__c') == null) ? null : (Double) rec.get('AE_RANK__c');
        o.totalACV = (Decimal) rec.get('TOTAL_ACV__c');
        o.productL3 = (String) rec.get('PRODUCT_L3__c');
        o.productL2 = (String) rec.get('PRODUCT_L2__c');
        o.isAcademyMember = (Boolean) rec.get('ACADEMIES_MEMBER__c');
        o.createdDate = (Datetime) rec.get('CreatedDate');
        o.lastModifiedDate = (Datetime) rec.get('LastModifiedDate');

        String lpId = (String) rec.get('LEARNER_PROFILE_ID__c');
        o.learnerProfileId = lpId;
        SObject lp = (lpId == null) ? null : lpById.get(lpId);
        if (lp != null) {
            o.learnerProfileName = (String) lp.get('Name');
            o.organizationalUnit = (String) lp.get('OU_Name__c');
            o.workCountry = (String) lp.get('Work_Location_Country__c');
            o.macroSegment = (String) lp.get('Macro_Segment__c');
            o.industry = (String) lp.get('em_Industry__c');
            o.tenureDays = (lp.get('Employee_Tenure__c') == null) ? null : Integer.valueOf(lp.get('Employee_Tenure__c'));
            
            // V6: 12-level manager chain
            o.managerL1 = (String) lp.get('Emp_Mgt_Chain_Lvl_01_Nm__c');
            o.managerL2 = (String) lp.get('Emp_Mgt_Chain_Lvl_02_Nm__c');
            o.managerL3 = (String) lp.get('Emp_Mgt_Chain_Lvl_03_Nm__c');
            o.managerL4 = (String) lp.get('Emp_Mgt_Chain_Lvl_04_Nm__c');
            o.managerL5 = (String) lp.get('Emp_Mgt_Chain_Lvl_05_Nm__c');
            o.managerL6 = (String) lp.get('Emp_Mgt_Chain_Lvl_06_Nm__c');
            o.managerL7 = (String) lp.get('Emp_Mgt_Chain_Lvl_07_Nm__c');
            o.managerL8 = (String) lp.get('Emp_Mgt_Chain_Lvl_08_Nm__c');
            o.managerL9 = (String) lp.get('Emp_Mgt_Chain_Lvl_09_Nm__c');
            o.managerL10 = (String) lp.get('Emp_Mgt_Chain_Lvl_10_Nm__c');
            o.managerL11 = (String) lp.get('Emp_Mgt_Chain_Lvl_11_Nm__c');
            o.managerL12 = (String) lp.get('Emp_Mgt_Chain_Lvl_12_Nm__c');
            
            o.isOnLeave = (lp.get('Employee_on_Leave__c') == null) ? false : (Boolean) lp.get('Employee_on_Leave__c');
            o.hireDate = (Date) lp.get('Hire_Date__c');
        }
        o.relevanceScore = 0.0;
        o.scoringRationale = '';
        return o;
    }

    private static List<SMEInfoV6> processSMERecordsWithLPData(List<SObject> records, Map<String, SObject> learnerProfileMap, 
                                                              ANAgentSMESearchHandlerV6.SMESearchRequest request, Boolean includeOnLeave, Integer minTenureDays) {
        List<SMEInfoV6> smeList = new List<SMEInfoV6>();
        
        for (SObject record : records) {
            String learnerProfileId = String.valueOf(record.get('LEARNER_PROFILE_ID__c'));
            SObject learnerProfile = learnerProfileMap.get(learnerProfileId);
            
            SMEInfoV6 sme = createSMEInfo(record, learnerProfileMap);
            
            // CRITICAL: Filter out SMEs with null learner profile name (anonymous experts)
            if (String.isBlank(sme.learnerProfileName) || String.isBlank(sme.learnerProfileId)) {
                continue;
            }
            
            // Apply Learner Profile filters
            if (!includeOnLeave && sme.isOnLeave) {
                continue;
            }
            
            // Apply other LP filters (including 12-level manager chain)
            if (!passLPFilters(sme, request, minTenureDays)) {
                continue;
            }
            
            // Calculate relevance score
            calculateRelevanceScoreV6(sme, request);
            
            smeList.add(sme);
        }
        
        return smeList;
    }

    private class SMERankingComparatorV6 implements Comparator<SMEInfoV6> {
        public Integer compare(SMEInfoV6 a, SMEInfoV6 b) {
            if (a.relevanceScore > b.relevanceScore) return -1;
            if (a.relevanceScore < b.relevanceScore) return 1;
            if (a.aeRank != null && b.aeRank != null) {
                if (a.aeRank > b.aeRank) return -1;
                if (a.aeRank < b.aeRank) return 1;
            }
            if (a.totalACV != null && b.totalACV != null) {
                if (a.totalACV > b.totalACV) return -1;
                if (a.totalACV < b.totalACV) return 1;
            }
            return 0;
        }
    }

    /* ---------- Real samples for agent corrective UX ---------- */

    private static List<String> sampleOUs(Integer cap) {
        try {
            List<AggregateResult> a = [
                SELECT OU_Name__c ou, COUNT(Id) c FROM Learner_Profile__c
                WHERE OU_Name__c != null
                GROUP BY OU_Name__c
                ORDER BY COUNT(Id) DESC
                LIMIT :cap
            ];
            List<String> r = new List<String>();
            for (AggregateResult ar : a) r.add((String) ar.get('ou'));
            return r;
        } catch (Exception e) {
            return new List<String>{'AMER REG', 'EMEA', 'APAC'};
        }
    }

    private static List<String> sampleCountries(Integer cap) {
        try {
            List<AggregateResult> a = [
                SELECT Work_Location_Country__c ctry, COUNT(Id) c FROM Learner_Profile__c
                WHERE Work_Location_Country__c != null
                GROUP BY Work_Location_Country__c
                ORDER BY COUNT(Id) DESC
                LIMIT :cap
            ];
            List<String> r = new List<String>();
            for (AggregateResult ar : a) r.add((String) ar.get('ctry'));
            return r;
        } catch (Exception e) {
            return new List<String>{'United States of America', 'Germany', 'Australia'};
        }
    }

    /* ---------- Relevance scoring ---------- */

    private static void calculateRelevanceScoreV6(SMEInfoV6 sme, ANAgentSMESearchHandlerV6.SMESearchRequest r) {
        Double score = 0.0; List<String> why = new List<String>();

        if (sme.aeRank != null) { score += sme.aeRank * 10; why.add('AE Rank +' + (sme.aeRank * 10)); }
        if (sme.isAcademyMember == true) { score += 30; why.add('Academy Member +30'); }

        if (String.isNotBlank(r.ouName) && String.isNotBlank(sme.organizationalUnit)
            && sme.organizationalUnit.toLowerCase().contains(r.ouName.toLowerCase())) { score += 50; why.add('OU match +50'); }

        if (String.isNotBlank(r.workCountry) && String.isNotBlank(sme.workCountry)
            && sme.workCountry.toLowerCase().contains(r.workCountry.toLowerCase())) { score += 25; why.add('Country match +25'); }

        if (String.isNotBlank(r.searchTerm)) {
            String term = r.searchTerm.toLowerCase();
            if (String.isNotBlank(sme.productL3) && sme.productL3.toLowerCase().contains(term)) { score += 40; why.add('L3 product match +40'); }
            else if (String.isNotBlank(sme.productL2) && sme.productL2.toLowerCase().contains(term)) { score += 30; why.add('L2 product match +30'); }
            if (String.isNotBlank(sme.learnerProfileName) && sme.learnerProfileName.toLowerCase().contains(term)) { score += 35; why.add('Name match +35'); }
        }

        if (sme.tenureDays != null && sme.tenureDays > 365) {
            Integer bonus = Math.min(sme.tenureDays / 365, 20);
            score += bonus; why.add('Tenure +' + bonus);
        }

        sme.relevanceScore = score;
        sme.scoringRationale = String.join(why, ', ');
    }

    /* ---------- No Results Error with Context ---------- */

    private static String buildNoResultsError(ANAgentSMESearchHandlerV6.SMESearchRequest r, String searchType, Boolean academyOnly, Integer minTenureDays) {
        String msg = 'No SMEs found';
        List<String> suggestions = new List<String>();
        
        if (String.isNotBlank(r.searchTerm)) {
            msg += ' matching "' + r.searchTerm + '"';
            suggestions.add('Try a broader search term (e.g., "Sales" instead of "Sales Cloud Enterprise")');
            suggestions.add('Check spelling of product or person name');
        }
        
        if (String.isNotBlank(r.ouName)) {
            msg += ' in OU "' + r.ouName + '"';
            List<String> topOUs = sampleOUs(3);
            if (!topOUs.isEmpty()) {
                suggestions.add('Try one of these OUs: ' + String.join(topOUs, ', '));
            }
        }
        
        if (String.isNotBlank(r.workCountry)) {
            msg += ' in country "' + r.workCountry + '"';
            List<String> topCountries = sampleCountries(3);
            if (!topCountries.isEmpty()) {
                suggestions.add('Try one of these countries: ' + String.join(topCountries, ', '));
            }
        }
        
        if (academyOnly == true) {
            msg += ' (academy members only)';
            suggestions.add('Remove academy filter to see all SMEs');
        }
        
        if (minTenureDays != null && minTenureDays > 0) {
            msg += ' with tenure >= ' + minTenureDays + ' days';
            suggestions.add('Reduce tenure requirement');
        }
        
        return err(AgentCore_Constants.RESULT_CODE_NOT_FOUND, 
                   msg,
                   'search_criteria', 
                   'At least 1 matching SME', 
                   buildSearchSummary(r),
                   suggestions,
                   new List<String>{
                       'Broaden your search by removing some filters',
                       'Try searching by product only without territory filters',
                       'Example: "Find Sales Cloud experts" (no OU/country filter)'
                   });
    }

    private static String buildSearchSummary(ANAgentSMESearchHandlerV6.SMESearchRequest r) {
        List<String> parts = new List<String>();
        if (String.isNotBlank(r.searchTerm)) parts.add('term=' + r.searchTerm);
        if (String.isNotBlank(r.searchType)) parts.add('type=' + r.searchType);
        if (String.isNotBlank(r.ouName)) parts.add('ou=' + r.ouName);
        if (String.isNotBlank(r.workCountry)) parts.add('country=' + r.workCountry);
        if (String.isNotBlank(r.vertical)) parts.add('segment=' + r.vertical);
        if (String.isNotBlank(r.industry)) parts.add('industry=' + r.industry);
        if (String.isNotBlank(r.managerEmail)) parts.add('manager=' + r.managerEmail);
        return String.join(parts, ', ');
    }

    /* ---------- Aggregation helpers ---------- */
    
    private static List<Map<String, Object>> aggregateByOU(List<SMEInfoV6> smes) {
        Map<String, Integer> counts = new Map<String, Integer>();
        Map<String, Integer> academyCounts = new Map<String, Integer>();
        
        for (SMEInfoV6 sme : smes) {
            String ou = String.isNotBlank(sme.organizationalUnit) ? sme.organizationalUnit : 'unknown';
            counts.put(ou, (counts.containsKey(ou) ? counts.get(ou) : 0) + 1);
            if (sme.isAcademyMember == true) {
                academyCounts.put(ou, (academyCounts.containsKey(ou) ? academyCounts.get(ou) : 0) + 1);
            }
        }
        
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        for (String ou : counts.keySet()) {
            result.add(new Map<String, Object>{
                'ou' => ou,
                'sme_count' => counts.get(ou),
                'academy_members' => (academyCounts.containsKey(ou) ? academyCounts.get(ou) : 0)
            });
        }
        result.sort(new AggregationCountComparator());
        return result;
    }
    
    private static List<Map<String, Object>> aggregateByProduct(List<SMEInfoV6> smes) {
        Map<String, Integer> counts = new Map<String, Integer>();
        Map<String, Integer> academyCounts = new Map<String, Integer>();
        
        for (SMEInfoV6 sme : smes) {
            String product = String.isNotBlank(sme.productL3) ? sme.productL3 : 
                           (String.isNotBlank(sme.productL2) ? sme.productL2 : 'unknown');
            counts.put(product, (counts.containsKey(product) ? counts.get(product) : 0) + 1);
            if (sme.isAcademyMember == true) {
                academyCounts.put(product, (academyCounts.containsKey(product) ? academyCounts.get(product) : 0) + 1);
            }
        }
        
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        for (String product : counts.keySet()) {
            result.add(new Map<String, Object>{
                'product' => product,
                'sme_count' => counts.get(product),
                'academy_members' => (academyCounts.containsKey(product) ? academyCounts.get(product) : 0)
            });
        }
        result.sort(new AggregationCountComparator());
        return result;
    }
    
    private static List<Map<String, Object>> aggregateByCountry(List<SMEInfoV6> smes) {
        Map<String, Integer> counts = new Map<String, Integer>();
        Map<String, Integer> academyCounts = new Map<String, Integer>();
        
        for (SMEInfoV6 sme : smes) {
            String country = String.isNotBlank(sme.workCountry) ? sme.workCountry : 'unknown';
            counts.put(country, (counts.containsKey(country) ? counts.get(country) : 0) + 1);
            if (sme.isAcademyMember == true) {
                academyCounts.put(country, (academyCounts.containsKey(country) ? academyCounts.get(country) : 0) + 1);
            }
        }
        
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        for (String country : counts.keySet()) {
            result.add(new Map<String, Object>{
                'country' => country,
                'sme_count' => counts.get(country),
                'academy_members' => (academyCounts.containsKey(country) ? academyCounts.get(country) : 0)
            });
        }
        result.sort(new AggregationCountComparator());
        return result;
    }
    
    private static List<Map<String, Object>> aggregateBySegment(List<SMEInfoV6> smes) {
        Map<String, Integer> counts = new Map<String, Integer>();
        Map<String, Integer> academyCounts = new Map<String, Integer>();
        
        for (SMEInfoV6 sme : smes) {
            String segment = String.isNotBlank(sme.macroSegment) ? sme.macroSegment : 'unknown';
            counts.put(segment, (counts.containsKey(segment) ? counts.get(segment) : 0) + 1);
            if (sme.isAcademyMember == true) {
                academyCounts.put(segment, (academyCounts.containsKey(segment) ? academyCounts.get(segment) : 0) + 1);
            }
        }
        
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        for (String segment : counts.keySet()) {
            result.add(new Map<String, Object>{
                'segment' => segment,
                'sme_count' => counts.get(segment),
                'academy_members' => (academyCounts.containsKey(segment) ? academyCounts.get(segment) : 0)
            });
        }
        result.sort(new AggregationCountComparator());
        return result;
    }
    
    private class AggregationCountComparator implements Comparator<Map<String, Object>> {
        public Integer compare(Map<String, Object> a, Map<String, Object> b) {
            Integer countA = (Integer) a.get('sme_count');
            Integer countB = (Integer) b.get('sme_count');
            if (countA > countB) return -1;
            if (countA < countB) return 1;
            return 0;
        }
    }

    /* ---------- Result builder (JSON-first + sections) ---------- */

    private static String buildV6Result(List<SMEInfoV6> smeList,
                                        ANAgentSMESearchHandlerV6.SMESearchRequest r,
                                        Integer totalFound, Integer limitVal, Boolean summaryOnly, Boolean academyMembersOnly, Integer minTenureDays, Boolean includeOnLeave) {
        Boolean summaryOnlyMode = (summaryOnly != null && summaryOnly == true);
        
        // Build aggregations
        Map<String, Object> summary = new Map<String, Object>();
        summary.put('totals', new Map<String, Object>{
            'total_smes' => totalFound,
            'showing' => smeList.size(),
            'academy_members' => getAcademyMemberCount(smeList),
            'top_ou' => getTopOU(smeList),
            'top_country' => getTopCountry(smeList),
            'top_product' => getTopProduct(smeList)
        });
        summary.put('by_ou', aggregateByOU(smeList));
        summary.put('by_product', aggregateByProduct(smeList));
        summary.put('by_country', aggregateByCountry(smeList));
        summary.put('by_segment', aggregateBySegment(smeList));
        
        // Build search metadata
        Map<String, Object> searchMetadata = new Map<String, Object>{
            'searchTerm' => r.searchTerm,
            'searchType' => (String.isNotBlank(r.searchType) ? r.searchType : 'All'),
            'limitN' => limitVal,
            'summaryOnly' => summaryOnlyMode,
            'appliedFilters' => getAppliedFiltersMap(r, academyMembersOnly, minTenureDays, includeOnLeave)
        };
        
        // Build records list (empty if summaryOnly mode) - includes 12 manager levels
        List<Object> recordsList = new List<Object>();
        if (!summaryOnlyMode) {
            for (SMEInfoV6 s : smeList) {
                Map<String, Object> record = new Map<String,Object>{
                    'learnerProfileId' => s.learnerProfileId,
                    'learnerProfileName' => s.learnerProfileName,
                    'productL3' => s.productL3,
                    'productL2' => s.productL2,
                    'organizationalUnit' => s.organizationalUnit,
                    'workCountry' => s.workCountry,
                    'macroSegment' => s.macroSegment,
                    'totalACV' => s.totalACV,
                    'aeRank' => s.aeRank,
                    'isAcademyMember' => s.isAcademyMember,
                    'tenureDays' => s.tenureDays,
                    'hireDate' => s.hireDate,
                    'isOnLeave' => s.isOnLeave,
                    'relevanceScore' => s.relevanceScore,
                    'scoringRationale' => s.scoringRationale
                };
                
                // V6: Include 12-level manager chain in records
                record.put('managerL1', s.managerL1);
                record.put('managerL2', s.managerL2);
                record.put('managerL3', s.managerL3);
                record.put('managerL4', s.managerL4);
                record.put('managerL5', s.managerL5);
                record.put('managerL6', s.managerL6);
                record.put('managerL7', s.managerL7);
                record.put('managerL8', s.managerL8);
                record.put('managerL9', s.managerL9);
                record.put('managerL10', s.managerL10);
                record.put('managerL11', s.managerL11);
                record.put('managerL12', s.managerL12);
                
                recordsList.add(record);
            }
        }
        
        // Build response data
        Map<String, Object> responseData = new Map<String, Object>{
            'analysisType' => 'SME_SEARCH',
            'searchMetadata' => searchMetadata,
            'summary' => summary,
            'records' => recordsList
        };
        
        // Return pure JSON
        return JSON.serialize(new Map<String, Object>{
            'ok' => true,
            'data' => responseData,
            'error' => null,
            'total' => totalFound,
            'limit' => limitVal
        });
    }

    /* ---------- Small helpers reused by result ---------- */

    private static Map<String, Object> getAppliedFiltersMap(ANAgentSMESearchHandlerV6.SMESearchRequest r, Boolean academyMembersOnly, Integer minTenureDays, Boolean includeOnLeave) {
        Map<String, Object> filters = new Map<String, Object>();
        if (academyMembersOnly == true) filters.put('academyOnly', true);
        if (String.isNotBlank(r.ouName)) filters.put('ouName', r.ouName);
        if (String.isNotBlank(r.workCountry)) filters.put('workCountry', r.workCountry);
        if (String.isNotBlank(r.vertical)) filters.put('segment', r.vertical);
        if (String.isNotBlank(r.industry)) filters.put('industry', r.industry);
        if (minTenureDays != null) filters.put('minTenureDays', minTenureDays);
        if (String.isNotBlank(r.managerEmail)) filters.put('managerEmail', r.managerEmail);
        if (includeOnLeave != null) filters.put('includeOnLeave', includeOnLeave);
        return filters;
    }

    private static String getTopOU(List<SMEInfoV6> smeList) {
        Map<String,Integer> m = new Map<String,Integer>();
        for (SMEInfoV6 s : smeList) {
            if (String.isNotBlank(s.organizationalUnit)) {
                m.put(s.organizationalUnit, (m.containsKey(s.organizationalUnit) ? m.get(s.organizationalUnit) : 0) + 1);
            }
        }
        Integer mx = 0; String ans = '';
        for (String k : m.keySet()) {
            if (m.get(k) > mx) { mx = m.get(k); ans = k; }
        }
        return ans;
    }
    
    private static Integer getAcademyMemberCount(List<SMEInfoV6> smeList) {
        Integer c = 0;
        for (SMEInfoV6 s : smeList) {
            if (s.isAcademyMember == true) c++;
        }
        return c;
    }
    
    private static String getTopCountry(List<SMEInfoV6> smeList) {
        Map<String,Integer> m = new Map<String,Integer>();
        for (SMEInfoV6 s : smeList) {
            if (String.isNotBlank(s.workCountry)) {
                m.put(s.workCountry, (m.containsKey(s.workCountry) ? m.get(s.workCountry) : 0) + 1);
            }
        }
        Integer mx = 0; String ans = '';
        for (String k : m.keySet()) {
            if (m.get(k) > mx) { mx = m.get(k); ans = k; }
        }
        return ans;
    }
    
    private static String getTopProduct(List<SMEInfoV6> smeList) {
        Map<String,Integer> m = new Map<String,Integer>();
        for (SMEInfoV6 s : smeList) {
            String product = String.isNotBlank(s.productL3) ? s.productL3 : 
                           (String.isNotBlank(s.productL2) ? s.productL2 : null);
            if (String.isNotBlank(product)) {
                m.put(product, (m.containsKey(product) ? m.get(product) : 0) + 1);
            }
        }
        Integer mx = 0; String ans = '';
        for (String k : m.keySet()) {
            if (m.get(k) > mx) { mx = m.get(k); ans = k; }
        }
        return ans;
    }
}

