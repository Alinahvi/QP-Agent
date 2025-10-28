/**
 * @description SME Search Service V5 - Clean implementation with enhanced validation
 * @author Sales Operations Team
 * @version 5.0
 * @date 2025-10-27
 * 
 * IMPROVEMENTS FROM V4:
 * - Accepts normalized Integer/Boolean values from handler (no string parsing)
 * - Enhanced exception handling with clear agent guidance
 * - Consistent field mapping with AGENT_SME_ACADEMIES__c and Learner_Profile__c objects
 * - Better error messages for common failure scenarios
 * - No references to V4 code
 */
public with sharing class ANAgentSMESearchServiceV5 {

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

    private static String validateRequest(ANAgentSMESearchHandlerV5.SMESearchRequest r, Integer limitValue, Integer minTenureDays) {
        // CRUD/FLS upfront
        if (!FRPermissionGuard.hasRead('AGENT_SME_ACADEMIES__c')) {
            return err('INSUFFICIENT_ACCESS', 'No read access to AGENT_SME_ACADEMIES__c',
                       'object', 'Read on AGENT_SME_ACADEMIES__c', null, null,
                       new List<String>{'Contact support to grant read perms.'});
        }
        if (!FRPermissionGuard.hasRead('Learner_Profile__c')) {
            return err('INSUFFICIENT_ACCESS', 'No read access to Learner_Profile__c',
                       'object', 'Read on Learner_Profile__c', null, null,
                       new List<String>{'Contact support to grant read perms.'});
        }

        // requireds
        if (String.isBlank(r.searchTerm)) {
            return err('INVALID_INPUT', 'searchTerm is required',
                       'searchTerm', 'non-empty string', 'blank', null,
                       new List<String>{'Provide 2+ characters and retry'});
        }

        // shape
        if (!FRSearchGuard.isValidSearchTerm(r.searchTerm, 2)) {
            return err('INVALID_INPUT', 'searchTerm must be ≥ 2 chars',
                       'searchTerm', 'length >= 2', r.searchTerm, null,
                       new List<String>{'Trim to a core product or surname and retry'});
        }

        // picklist
        if (String.isNotBlank(r.searchType)) {
            Set<String> valid = new Set<String>{'Product','Name','All'};
            if (!FRSearchGuard.isValidPicklistValue(r.searchType, valid)) {
                List<String> samples = new List<String>{'Product','Name','All'};
                return err('INVALID_INPUT', 'searchType must be Product|Name|All',
                           'searchType', 'Product|Name|All', r.searchType, samples,
                           new List<String>{'Use Product to focus on PRODUCT_L2/L3'});
            }
        }

        // ranges
        if (limitValue != null && !FRSearchGuard.isInRange(limitValue, 1, 200)) {
            return err('INVALID_INPUT', 'limit must be 1–200',
                       'limit', '1–200', limitValue, new List<String>{'20','50','100'}, null);
        }
        if (minTenureDays != null && minTenureDays < 0) {
            return err('INVALID_INPUT', 'minTenureDays must be >= 0',
                       'minTenureDays', '>= 0', minTenureDays, new List<String>{'0','365','730'}, null);
        }

        // V5: Date filtering removed from SME Search (not needed for SME discovery)

        // OU / Country examples (real samples) if provided but look invalid length
        if (String.isNotBlank(r.ouName) && r.ouName.length() < 2) {
            return err('INVALID_INPUT','ouName too short','ouName','>=2 chars',r.ouName,
                       sampleOUs(3), new List<String>{'Pick one OU from samples and retry'});
        }
        if (String.isNotBlank(r.workCountry) && r.workCountry.length() < 2) {
            return err('INVALID_INPUT','workCountry too short','workCountry','country name',r.workCountry,
                       sampleCountries(3), new List<String>{'Use one of the countries above'});
        }

        return null;
    }

    /* ---------- Public entry (JSON-first, no silent fixes) ---------- */

    public static String searchSMEs(ANAgentSMESearchHandlerV5.SMESearchRequest r, Integer limitValue, Boolean academyMembersOnly, Integer minTenureDays, Boolean includeOnLeave, Boolean summaryOnly) {
        try {
            String v = validateRequest(r, limitValue, minTenureDays);
            if (v != null) return v;

            String searchType = String.isNotBlank(r.searchType) ? r.searchType : 'All';
            Integer limitVal = (limitValue == null) ? 20 : Math.min(Math.max(limitValue,1),200);
            Boolean academyOnly = (academyMembersOnly == null) ? false : academyMembersOnly;
            Boolean includeOnLeaveVal = (includeOnLeave == null) ? true : includeOnLeave;

            // Build query with proper escaping
            String query = buildSMEDynamicQuery(r, searchType, academyOnly, limitVal);
            System.debug('SME Search V4 Query: ' + query);

            // Execute query with security enforcement
            List<SObject> records = executeQuery(query);

            // Get Learner Profile data for the SME records
            Map<String, SObject> learnerProfileMap = getLearnerProfileData(records);

            // Process and rank results with Learner Profile data
            List<SMEInfoV4> smeList = processSMERecordsWithLPData(records, learnerProfileMap, r, includeOnLeaveVal, minTenureDays);

            // Sort by relevance score
            smeList.sort(new SMERankingComparatorV4());

            // Apply limit after sorting
            if (smeList.size() > limitVal) {
                List<SMEInfoV4> limitedList = new List<SMEInfoV4>();
                for (Integer i = 0; i < limitVal; i++) {
                    limitedList.add(smeList[i]);
                }
                smeList = limitedList;
            }

            // Get total count for pagination info
            Integer totalFound = getTotalCount(r, searchType, academyOnly);

            // Build complete result following V5 JSON structure
            return buildV4Result(smeList, r, totalFound, limitVal, summaryOnly, academyMembersOnly, minTenureDays, includeOnLeaveVal);

        } catch (QueryException qe) {
            return err('QUERY_ERROR','Database query failed', 'soql', 'valid SOQL', null, null,
                       new List<String>{'Reduce filters and retry','Check field API names'});
        } catch (SecurityException se) {
            return err('SECURITY_ERROR','Access denied', 'security', 'CRUD/FLS permitting read', null, null,
                       new List<String>{'Request necessary permissions'});
        } catch (NullPointerException npe) {
            return err('DATA_ERROR','Missing required data in related records', 'relationship', 'non-null references', null, null,
                       new List<String>{'Ensure Learner_Profile is populated for each SME'});
        } catch (Exception e) {
            return err('UNEXPECTED_ERROR','Unexpected system error', 'service', 'successful execution', e.getMessage(), null,
                       new List<String>{'Retry','Escalate with stack trace id'});
        }
    }

    /* ---------- Query building ---------- */

    private static String buildSMEDynamicQuery(ANAgentSMESearchHandlerV5.SMESearchRequest request, String searchType, Boolean academyOnly, Integer limitValue) {
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
            // Apply security stripping
            return Security.stripInaccessible(AccessType.READABLE, results).getRecords();
        } catch (QueryException qe) {
            System.debug(LoggingLevel.ERROR, 'SOQL Query Error: ' + qe.getMessage());
            throw qe; // Re-throw to be caught by main exception handler
        } catch (SecurityException se) {
            System.debug(LoggingLevel.ERROR, 'Security Error: ' + se.getMessage());
            throw se; // Re-throw to be caught by main exception handler
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Query execution error: ' + e.getMessage());
            throw new QueryException('Failed to execute SME search query: ' + e.getMessage());
        }
    }

    private static Integer getTotalCount(ANAgentSMESearchHandlerV5.SMESearchRequest request, String searchType, Boolean academyOnly) {
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
            return 0; // Return 0 if count fails
        }
    }

    /* ---------- Related data ---------- */

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
        
        // Query Learner Profile records
        String lpQuery = 'SELECT Id, Name, OU_Name__c, Work_Location_Country__c, Macro_Segment__c, ';
        lpQuery += 'Employee_Tenure__c, Emp_Mgt_Chain_Lvl_01_Nm__c, Emp_Mgt_Chain_Lvl_02_Nm__c, ';
        lpQuery += 'Emp_Mgt_Chain_Lvl_03_Nm__c, Emp_Mgt_Chain_Lvl_04_Nm__c, Emp_Mgt_Chain_Lvl_05_Nm__c, ';
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

    /* ---------- LP post-filters ---------- */

    private static Boolean passLPFilters(SMEInfoV4 info, ANAgentSMESearchHandlerV5.SMESearchRequest r, Integer minTenureDays) {
        if (String.isNotBlank(r.ouName) && String.isNotBlank(info.organizationalUnit)
            && !info.organizationalUnit.toLowerCase().contains(r.ouName.toLowerCase())) return false;

        if (String.isNotBlank(r.workCountry) && String.isNotBlank(info.workCountry)
            && !info.workCountry.toLowerCase().contains(r.workCountry.toLowerCase())) return false;

        if (String.isNotBlank(r.vertical) && String.isNotBlank(info.macroSegment)
            && !info.macroSegment.toLowerCase().contains(r.vertical.toLowerCase())) return false;

        if (String.isNotBlank(r.industry) && String.isNotBlank(info.industry)
            && !info.industry.toLowerCase().contains(r.industry.toLowerCase())) return false;

        if (minTenureDays != null && info.tenureDays != null && info.tenureDays < minTenureDays) return false;

        if (String.isNotBlank(r.managerEmail) && String.isNotBlank(info.managerL1)
            && !info.managerL1.toLowerCase().contains(r.managerEmail.toLowerCase())) return false;

        // V5: Date filtering removed from SME Search (not needed for SME discovery)
        return true;
    }

    /* ---------- SMEInfo model (factory-based) ---------- */

    private class SMEInfoV4 {
        public String id, name, learnerProfileId, learnerProfileName, organizationalUnit, productL3, productL2,
                      workCountry, macroSegment, industry, managerL1, managerL2, managerL3, managerL4, managerL5, scoringRationale;
        public Double aeRank, relevanceScore;
        public Decimal totalACV;
        public Boolean isAcademyMember, isOnLeave;
        public Integer tenureDays;
        public Date hireDate;
        public Datetime createdDate, lastModifiedDate;
    }
    
    private static SMEInfoV4 createSMEInfo(SObject rec, Map<String,SObject> lpById) {
        SMEInfoV4 o = new SMEInfoV4();
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
        o.learnerProfileId = lpId; // Store learner profile ID
        SObject lp = (lpId == null) ? null : lpById.get(lpId);
        if (lp != null) {
            o.learnerProfileName = (String) lp.get('Name');
            o.organizationalUnit = (String) lp.get('OU_Name__c');
            o.workCountry = (String) lp.get('Work_Location_Country__c');
            o.macroSegment = (String) lp.get('Macro_Segment__c');
            o.industry = (String) lp.get('em_Industry__c');
            o.tenureDays = (lp.get('Employee_Tenure__c') == null) ? null : Integer.valueOf(lp.get('Employee_Tenure__c'));
            o.managerL1 = (String) lp.get('Emp_Mgt_Chain_Lvl_01_Nm__c');
            o.managerL2 = (String) lp.get('Emp_Mgt_Chain_Lvl_02_Nm__c');
            o.managerL3 = (String) lp.get('Emp_Mgt_Chain_Lvl_03_Nm__c');
            o.managerL4 = (String) lp.get('Emp_Mgt_Chain_Lvl_04_Nm__c');
            o.managerL5 = (String) lp.get('Emp_Mgt_Chain_Lvl_05_Nm__c');
            o.isOnLeave = (lp.get('Employee_on_Leave__c') == null) ? false : (Boolean) lp.get('Employee_on_Leave__c');
            o.hireDate = (Date) lp.get('Hire_Date__c');
        }
        o.relevanceScore = 0.0;
        o.scoringRationale = '';
        return o;
    }

    private static List<SMEInfoV4> processSMERecordsWithLPData(List<SObject> records, Map<String, SObject> learnerProfileMap, 
                                                              ANAgentSMESearchHandlerV5.SMESearchRequest request, Boolean includeOnLeave, Integer minTenureDays) {
        List<SMEInfoV4> smeList = new List<SMEInfoV4>();
        
        for (SObject record : records) {
            String learnerProfileId = String.valueOf(record.get('LEARNER_PROFILE_ID__c'));
            SObject learnerProfile = learnerProfileMap.get(learnerProfileId);
            
            SMEInfoV4 sme = createSMEInfo(record, learnerProfileMap);
            
            // CRITICAL: Filter out SMEs with null learner profile name (anonymous experts)
            // These records don't have valid learner profile data and shouldn't be shown to agents
            if (String.isBlank(sme.learnerProfileName) || String.isBlank(sme.learnerProfileId)) {
                continue; // Skip anonymous/incomplete SME records
            }
            
            // Apply Learner Profile filters
            if (!includeOnLeave && sme.isOnLeave) {
                continue; // Skip this record if filtering out employees on leave
            }
            
            // Apply other LP filters
            if (!passLPFilters(sme, request, minTenureDays)) {
                continue; // Skip this record if it doesn't match LP filters
            }
            
            // Calculate relevance score
            calculateRelevanceScoreV4(sme, request);
            
            smeList.add(sme);
        }
        
        return smeList;
    }

    private class SMERankingComparatorV4 implements Comparator<SMEInfoV4> {
        public Integer compare(SMEInfoV4 a, SMEInfoV4 b) {
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

    // Cap to 3–5 values to keep messages small.
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

    /* ---------- Relevance scoring (kept, minor tidy) ---------- */

    private static void calculateRelevanceScoreV4(SMEInfoV4 sme, ANAgentSMESearchHandlerV5.SMESearchRequest r) {
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

    /* ---------- Aggregation helpers (V4 best practice) ---------- */
    
    private static List<Map<String, Object>> aggregateByOU(List<SMEInfoV4> smes) {
        Map<String, Integer> counts = new Map<String, Integer>();
        Map<String, Integer> academyCounts = new Map<String, Integer>();
        
        for (SMEInfoV4 sme : smes) {
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
    
    private static List<Map<String, Object>> aggregateByProduct(List<SMEInfoV4> smes) {
        Map<String, Integer> counts = new Map<String, Integer>();
        Map<String, Integer> academyCounts = new Map<String, Integer>();
        
        for (SMEInfoV4 sme : smes) {
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
    
    private static List<Map<String, Object>> aggregateByCountry(List<SMEInfoV4> smes) {
        Map<String, Integer> counts = new Map<String, Integer>();
        Map<String, Integer> academyCounts = new Map<String, Integer>();
        
        for (SMEInfoV4 sme : smes) {
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
    
    private static List<Map<String, Object>> aggregateBySegment(List<SMEInfoV4> smes) {
        Map<String, Integer> counts = new Map<String, Integer>();
        Map<String, Integer> academyCounts = new Map<String, Integer>();
        
        for (SMEInfoV4 sme : smes) {
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

    private static String buildV4Result(List<SMEInfoV4> smeList,
                                        ANAgentSMESearchHandlerV5.SMESearchRequest r,
                                        Integer totalFound, Integer limitVal, Boolean summaryOnly, Boolean academyMembersOnly, Integer minTenureDays, Boolean includeOnLeave) {
        // Check if summaryOnly mode
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
        
        // Build records list (empty if summaryOnly mode)
        List<Object> recordsList = new List<Object>();
        if (!summaryOnlyMode) {
            for (SMEInfoV4 s : smeList) {
                recordsList.add(new Map<String,Object>{
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
                });
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

    private static Map<String, Object> getAppliedFiltersMap(ANAgentSMESearchHandlerV5.SMESearchRequest r, Boolean academyMembersOnly, Integer minTenureDays, Boolean includeOnLeave) {
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

    private static String getTopOU(List<SMEInfoV4> smeList) {
        Map<String,Integer> m = new Map<String,Integer>();
        for (SMEInfoV4 s : smeList) {
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
    
    private static Integer getAcademyMemberCount(List<SMEInfoV4> smeList) {
        Integer c = 0;
        for (SMEInfoV4 s : smeList) {
            if (s.isAcademyMember == true) c++;
        }
        return c;
    }
    
    private static String getTopCountry(List<SMEInfoV4> smeList) {
        Map<String,Integer> m = new Map<String,Integer>();
        for (SMEInfoV4 s : smeList) {
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
    
    private static String getTopProduct(List<SMEInfoV4> smeList) {
        Map<String,Integer> m = new Map<String,Integer>();
        for (SMEInfoV4 s : smeList) {
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