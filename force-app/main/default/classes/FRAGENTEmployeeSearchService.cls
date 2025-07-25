/**
 * TEMPLATE SERVICE - Houses business logic and direct object manipulation in our handler/service pattern.
 * Business Requirement: Service methods return both Ids and Names for lookup fields to meet downstream flow requirements.
 * Handlers call into this class to perform CRUD and search operations.
 * @description Service layer for searching and retrieving unified employee data from Learner_Profile__c and User objects.
 *              This service abstracts the complexity of the underlying data model and provides a clean, unified view of an employee.
 *
 * Returned `UnifiedEmployee` records include fields such as `Id`, `Name`,
 * `Email`, `ManagerId`, `CreatedDate` and `LastModifiedDate`.
 *
 * @date 2025-07-10
 */
public with sharing class FRAGENTEmployeeSearchService extends FRAGENTGeneralService {
    @TestVisible private static List<Learner_Profile__c> mockResults;
    @TestVisible private static Integer mockCountResult;

    /**
     * @description A wrapper class to hold metadata about a field that can be used for filtering.
     */
    public class FilterableFieldInfo {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String apiName { get; set; }
        @AuraEnabled public String description { get; set; }

        public FilterableFieldInfo(String label, String apiName, String description) {
            this.label = label;
            this.apiName = apiName;
            this.description = description;
        }
    }

    /**
     * @description A wrapper class to hold both the list of results and the total count of records.
     */
    public class EmployeeSearchResult {
        @AuraEnabled public List<UnifiedEmployee> employees { get; set; }
        @AuraEnabled public Integer totalCount { get; set; }

        public EmployeeSearchResult() {
            this.employees = new List<UnifiedEmployee>();
            this.totalCount = 0;
        }
    }

    /**
     * @description A composite view model that combines key fields from both Learner_Profile__c and the standard User object.
     */
    public class UnifiedEmployee {
        @AuraEnabled public String learnerProfileId { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String division { get; set; }
        @AuraEnabled public String jobFamily { get; set; }
        @AuraEnabled public String managerName { get; set; }
        @AuraEnabled public String managerEmail { get; set; }
        @AuraEnabled public String country { get; set; }
        @AuraEnabled public String userId { get; set; }
        @AuraEnabled public Boolean isSalesforceUserActive { get; set; }
        @AuraEnabled public String profileName { get; set; }
        @AuraEnabled public String roleName { get; set; }
        @AuraEnabled public String acquiredCompany { get; set; }
        @AuraEnabled public String aeType { get; set; }
        @AuraEnabled public String contractorType { get; set; }
        @AuraEnabled public String marketSegment { get; set; }
        @AuraEnabled public String l1Cloud { get; set; }
        @AuraEnabled public String l1Product { get; set; }
        @AuraEnabled public String l2Cloud { get; set; }
        @AuraEnabled public String languageProficiency { get; set; }
        @AuraEnabled public String macroSegment { get; set; }
        @AuraEnabled public String managerLevel { get; set; }
        @AuraEnabled public String managerType { get; set; }
        @AuraEnabled public String ouName { get; set; }
        @AuraEnabled public String countryOfCoverage { get; set; }
        @AuraEnabled public String roleLevel3 { get; set; }
        @AuraEnabled public String roleLevel4 { get; set; }
        @AuraEnabled public Integer distance { get; set; }
    }

    public class OrgSummaryEntry {
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String userId { get; set; }
        @AuraEnabled public String learnerProfileId { get; set; }
    }

    public class OrgHierarchySummary {
        @AuraEnabled public Integer totalPeople { get; set; }
        @AuraEnabled public Integer directReports { get; set; }
        @AuraEnabled public Map<String, Integer> peopleByDepth { get; set; }
        @AuraEnabled public List<OrgSummaryEntry> directReportSummaries { get; set; }
        @AuraEnabled public String summaryMessage { get; set; }
        @AuraEnabled public List<OrgSummaryEntry> allPeopleInOrg { get; set; }

        public OrgHierarchySummary() {
            this.peopleByDepth = new Map<String, Integer>();
            this.directReportSummaries = new List<OrgSummaryEntry>();
            this.allPeopleInOrg = new List<OrgSummaryEntry>();
        }
    }

    /**
     * @description A wrapper class for sorting employees by Levenshtein distance.
     */
    private class RankedEmployee implements Comparable {
        public UnifiedEmployee employee;
        public Integer distance;

        public RankedEmployee(UnifiedEmployee employee, Integer distance) {
            this.employee = employee;
            this.distance = distance;
            this.employee.distance = distance;
        }

        public Integer compareTo(Object compareTo) {
            RankedEmployee other = (RankedEmployee)compareTo;
            if (this.distance == other.distance) {
                // If distances are equal, sort alphabetically by name
                return this.employee.name.compareTo(other.employee.name);
            }
            // Primary sort by distance, ascending
            return this.distance - other.distance;
        }
    }

    private static final List<FilterableFieldInfo> FILTERABLE_FIELDS_INFO = new List<FilterableFieldInfo>{
        new FilterableFieldInfo('Division', 'Division__c', 'Filter by a user\'s division. Examples: "AMER", "APAC", "EMEA", "Japan".'),
        new FilterableFieldInfo('AcquiredCompany', 'Acquired_Company__c', 'Filter by the company the employee was part of at acquisition. Examples: "Acumen", "Slack", "Tableau".'),
        new FilterableFieldInfo('AeType', 'AE_Type__c', 'Filter by the Account Executive type. Valid values: "Applications", "Core", "Digital", "ECS", "GAM/NAM/RAM", "MuleSoft", "Platform and Agents", "Tableau".'),
        new FilterableFieldInfo('ContractorType', 'Contractor_Type__c', 'Filter by the type of contractor. Valid values: "CW", "PW", "SOW".'),
        new FilterableFieldInfo('MarketSegment', 'Customer_Market_Segment__c', 'Filter by the customer market segment. Examples: "ECS", "ECS-HUNTER", "EMG-EB".'),
        new FilterableFieldInfo('L1Cloud', 'L1_Cloud__c', 'Filter by the high-level cloud product area. Examples: "Analytics", "Commerce", "Integration", "Marketing".'),
        new FilterableFieldInfo('L1Product', 'L1_Product__c', 'Filter by the high-level product. Valid values: "All (Core)", "Analytics", "Commerce", "Integration", "Marketing", "N/A", "Sales", "Salesforce Platform", "Service".'),
        new FilterableFieldInfo('L2Cloud', 'L2_Cloud__c', 'Filter by the specific cloud product. Examples: "B2C Commerce", "CRM Analytics", "Field Service".'),
        new FilterableFieldInfo('Language', 'Language_Proficiency__c', 'Filter by language proficiency. Valid values: "English", "Spanish".'),
        new FilterableFieldInfo('MacroSegment', 'Macro_Segment__c', 'Filter by the macro-economic segment. Valid values: "CMRCL", "ENTR", "ESMB", "GEN", "MID", "PubSec", "Shared", "TBD", "Unmapped".'),
        new FilterableFieldInfo('ManagerLevel', 'Manager_Level__c', 'Filter by the manager level in the hierarchy. Valid values: "Manager Level 1", "Manager Level 2", "Manager Level 3", "Manager Level 4", "Manager Level 5", "Manager Level 6", "Manager Level 7", "Manager Level 8", "Manager Level 9", "Manager Level 10".'),
        new FilterableFieldInfo('ManagerType', 'Manager_Type__c', 'Filter by the type of manager. Valid values: "AE Manager", "BDR Manager", "BVS Manager", "COO", "ECS Manager", "SDR Manager", "SE Manager", "Sales Strategy Manager", "Specialist AE Manager".'),
        new FilterableFieldInfo('OuName', 'OU_Name__c', 'Filter by the Operating Unit name. Examples: "AMER - CAN", "AMER - FINS", "APAC - INDIA".'),
        new FilterableFieldInfo('CountryOfCoverage', 'Primary_Country_of_Coverage__c', 'Filter by the primary country of coverage. Use standard country names or codes like "USA", "Spain", "AFRICA".'),
        new FilterableFieldInfo('RoleLevel3', 'Role_Level_3__c', 'Filter by the user\'s sales segment. Valid values: "Direct Sales Role", "Indirect Sales", "Shared Sales Support".'),
        new FilterableFieldInfo('RoleLevel4', 'Role_Level_4__c', 'Filter by a more specific role category. Examples: "Prime AE", "Exec Admin", "Indirect Sales".'),
        new FilterableFieldInfo('HireDate', 'Hire_Date__c', 'Filter by hire date. Supports formats like YYYY-MM-DD, YYYY-MM, or date literals like \'LAST_N_DAYS:30\'.')
    };

    private static final Set<String> SORTABLE_FIELDS = new Set<String>{
        'Name', 'Title__c', 'Hire_Date__c', 'Division__c', 'Job_Family__c'
    };
    
    // Helper map for quick lookups
    private static final Map<String, FilterableFieldInfo> FILTER_INFO_MAP = new Map<String, FilterableFieldInfo>();
    static {
        for (FilterableFieldInfo info : FILTERABLE_FIELDS_INFO) {
            FILTER_INFO_MAP.put(info.label, info);
        }
    }

    private static final Set<String> DATE_FIELDS = new Set<String>{'Hire_Date__c'};
    private static final Set<String> MULTIPICKLIST_FIELDS = new Set<String>{
        'Language_Proficiency__c'
    };
    // Fields representing each level of the management chain on the learner profile
    private static final List<String> MANAGEMENT_CHAIN_FIELDS = new List<String>{
        'Emp_Mgt_Chain_Lvl_01_Nm__c',
        'Emp_Mgt_Chain_Lvl_02_Nm__c',
        'Emp_Mgt_Chain_Lvl_03_Nm__c',
        'Emp_Mgt_Chain_Lvl_04_Nm__c',
        'Emp_Mgt_Chain_Lvl_05_Nm__c',
        'Emp_Mgt_Chain_Lvl_06_Nm__c',
        'Emp_Mgt_Chain_Lvl_07_Nm__c',
        'Emp_Mgt_Chain_Lvl_08_Nm__c',
        'Emp_Mgt_Chain_Lvl_09_Nm__c',
        'Emp_Mgt_Chain_Lvl_10_Nm__c',
        'Emp_Mgt_Chain_Lvl_11_Nm__c',
        'Emp_Mgt_Chain_Lvl_12_Nm__c'
    };

    /**
     * @description Retrieves a list of unique values for a given filterable field.
     * @param fieldLabel The user-friendly label of the field (e.g., 'Division', 'AeType').
     * @return A list of distinct string values, limited to 30 results.
     */
    public static List<String> getDistinctFieldValues(String fieldLabel) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_CRU);
        
        if (!FILTER_INFO_MAP.containsKey(fieldLabel)) {
            throw new AuraHandledException('Invalid field label provided: ' + fieldLabel);
        }

        String fieldApiName = FILTER_INFO_MAP.get(fieldLabel).apiName;
        
        // This check prevents SOQL injection by ensuring only pre-approved fields are used.
        if (!getCoreFields().contains(fieldApiName)) {
             throw new AuraHandledException('Field is not queryable: ' + fieldLabel);
        }

        List<String> distinctValues = new List<String>();

        // Multi-select picklists do not support the DISTINCT keyword, so they need special handling.
        if (MULTIPICKLIST_FIELDS.contains(fieldApiName)) {
            String soql = 'SELECT ' + fieldApiName + 
                          ' FROM Learner_Profile__c' +
                          ' WHERE ' + fieldApiName + ' != null' +
                          ' LIMIT 500'; // Limit to avoid hitting governor limits
            
            List<SObject> records;
            if (Test.isRunningTest() && mockResults != null) {
                records = mockResults;
            } else {
                records = Database.query(soql);
            }

            for (SObject sobj : records) {
                Object value = sobj.get(fieldApiName);
                if (value != null) {
                    for(String singleValue : String.valueOf(value).split(';')) {
                        if (!distinctValues.contains(singleValue.trim())) {
                            distinctValues.add(singleValue.trim());
                        }
                    }
                }
            }
            distinctValues.sort();

        } else {
            // For all other fields, use the efficient DISTINCT keyword.
            String soql = 'SELECT DISTINCT ' + fieldApiName + 
                          ' FROM Learner_Profile__c' +
                          ' WHERE ' + fieldApiName + ' != null' +
                          ' ORDER BY ' + fieldApiName + ' ASC' +
                          ' LIMIT 30';

            List<SObject> records;
            if (Test.isRunningTest() && mockResults != null) {
                records = mockResults;
            } else {
                records = Database.query(soql);
            }
            for (SObject sobj : records) {
                Object value = sobj.get(fieldApiName);
                if (value != null) {
                    distinctValues.add(String.valueOf(value));
                }
            }
        }
        
        // The query limit might be exceeded by splitting multi-selects, so we trim again.
        if (distinctValues.size() > 30) {
            List<String> trimmedList = new List<String>();
            for (Integer i = 0; i < 30; i++) {
                trimmedList.add(distinctValues[i]);
            }
            return trimmedList;
        }
        
        return distinctValues;
    }


    /**
     * @description Returns the user-friendly names and descriptions of fields that can be used for filtering.
     * @return A list of FilterableFieldInfo objects.
     */
    public static List<FilterableFieldInfo> getDescriptiveFilterableFields() {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_CRU);
        return FILTERABLE_FIELDS_INFO;
    }

    /**
     * @description A general-purpose search that finds employees by a search term and optional filters.
     * @param searchTerm A keyword to search in Name, Email, or Title. Can be null.
     * @param filters A map of filter criteria, where the key is the user-friendly field name.
     * @return A list of UnifiedEmployee objects matching the criteria.
     */
    public static EmployeeSearchResult searchEmployees(String searchTerm, Map<String, Object> filters) {
        return searchEmployees(searchTerm, filters, null, null, null, null);
    }

    /**
     * @description A general-purpose search that finds employees by a search term and optional filters, with sorting and pagination.
     * @param searchTerm A keyword to search in Name, Email, or Title. Can be null.
     * @param filters A map of filter criteria, where the key is the user-friendly field name.
     * @param sortBy The field API name to sort the results by.
     * @param sortOrder The direction to sort (ASC or DESC).
     * @param recordLimit The maximum number of records to return.
     * @param offset The starting row offset for pagination.
     * @return A list of UnifiedEmployee objects matching the criteria.
     */
    public static EmployeeSearchResult searchEmployees(String searchTerm, Map<String, Object> filters, String sortBy, String sortOrder, Integer recordLimit, Integer offset) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_CRU);
        
        EmployeeSearchResult result = new EmployeeSearchResult();
        
        Set<String> fieldsToQuery = new Set<String>();
        for (FilterableFieldInfo info : FILTERABLE_FIELDS_INFO) {
            fieldsToQuery.add(info.apiName);
        }
        fieldsToQuery.addAll(new List<String>{'Id', 'Name', 'Primary_Email__c', 'Title__c', 'Status__c', 'Job_Family__c', 'Manager__c', 'Manager_Email__c', 'Work_Location_Country__c', 'User__c'});

        List<String> whereClauses = new List<String>();
        String filterClause = buildWhereClause(filters);
        if (String.isNotBlank(filterClause)) {
            whereClauses.add(filterClause);
        }

        if (String.isNotBlank(searchTerm)) {
            String likeTerm = '\'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
            whereClauses.add('(Name LIKE ' + likeTerm + ' OR Primary_Email__c LIKE ' + likeTerm + ' OR Title__c LIKE ' + likeTerm + ')');
        }
        
        String finalWhereClause = String.join(whereClauses, ' AND ');

        // First, get the total count
        String countQuery = 'SELECT count() FROM Learner_Profile__c WHERE SlackId__c != null' + (String.isNotBlank(finalWhereClause) ? ' AND (' + finalWhereClause + ')' : '');
        if (Test.isRunningTest() && mockCountResult != null) {
            result.totalCount = mockCountResult;
        } else {
            result.totalCount = Database.countQuery(countQuery);
        }

        // Then, get the records
        String soqlQuery = buildQuery(fieldsToQuery, finalWhereClause, sortBy, sortOrder, recordLimit, offset);
        List<Learner_Profile__c> profiles;
        if (Test.isRunningTest() && mockResults != null) {
            profiles = mockResults;
        } else {
            profiles = Database.query(soqlQuery);
        }
        
        List<UnifiedEmployee> composedEmployees = composeUnifiedEmployees(profiles);

        // If a search term is provided, apply fuzzy ranking
        if (String.isNotBlank(searchTerm)) {
            result.employees = fuzzyRankAndSortEmployees(composedEmployees, searchTerm);
        } else {
            result.employees = composedEmployees;
        }

        return result;
    }
    
    /**
     * @description Counts the number of employees for each unique value of a specified field, applying optional filters.
     * @param fieldApiName The API name of the field to group by (e.g., 'Division__c').
     * @param filters A map of filter criteria to apply before counting.
     * @return A map where the key is a field value and the value is the count of records with that value.
     */
    public static Map<String, Integer> countFieldValues(String fieldApiName, Map<String, Object> filters) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_CRU);
        
        if (String.isBlank(fieldApiName) || !getCoreFields().contains(fieldApiName)) {
            throw new AuraHandledException('Invalid or unauthorized field for aggregation: ' + fieldApiName);
        }

        String whereClause = buildWhereClause(filters);
        String soql = 'SELECT ' + fieldApiName + ', COUNT(Id) recordCount FROM Learner_Profile__c WHERE SlackId__c != null';

        if (String.isNotBlank(whereClause)) {
            soql += ' AND (' + whereClause + ')';
        }
        soql += ' GROUP BY ' + fieldApiName + ' ORDER BY COUNT(Id) DESC LIMIT 50';

        Map<String, Integer> results = new Map<String, Integer>();
        for (AggregateResult ar : Database.query(soql)) {
            String fieldValue = String.valueOf(ar.get(fieldApiName));
            Integer count = (Integer)ar.get('recordCount');
            if (String.isNotBlank(fieldValue)) {
                results.put(fieldValue, count);
            }
        }
        return results;
    }
    
    /**
     * @description Retrieves the entire reporting hierarchy under a given manager's email, returning an aggregated summary.
     * @param managerEmail The email address of the top-level manager.
     * @return A summary of the organization's structure.
     */
    public static OrgHierarchySummary getOrganizationHierarchy(String managerEmail) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_CRU);
        User manager = [SELECT Id, Name, Title, Email FROM User WHERE Email = :managerEmail AND IsActive = true LIMIT 1];
        if (manager == null) {
            throw new AuraHandledException('No active manager found with email: ' + managerEmail);
        }

        // Attempt to find the manager's learner profile for direct report comparisons
        Learner_Profile__c managerLp = null;
        List<Learner_Profile__c> mList = [SELECT Id FROM Learner_Profile__c WHERE Primary_Email__c = :managerEmail LIMIT 1];
        if (!mList.isEmpty()) {
            managerLp = mList[0];
        }

        // Build a dynamic WHERE clause searching all management chain fields for the manager's email
        String escapedEmail = String.escapeSingleQuotes(managerEmail);
        List<String> clauses = new List<String>();
        for (String fieldName : MANAGEMENT_CHAIN_FIELDS) {
            clauses.add(fieldName + ' = \'' + escapedEmail + '\'');
        }
        String whereClause = String.join(clauses, ' OR ');

        // Query all learners that have the manager somewhere in their management chain
        Set<String> fields = new Set<String>();
        fields.addAll(getCoreFields());
        fields.addAll(MANAGEMENT_CHAIN_FIELDS);
        String soql = buildQuery(fields, whereClause, null, null, null, null);

        List<Learner_Profile__c> profiles;
        if (Test.isRunningTest() && mockResults != null) {
            profiles = mockResults;
        } else {
            profiles = Database.query(soql);
        }

        OrgHierarchySummary summary = new OrgHierarchySummary();
        Integer maxDepth = 0;

        for (Learner_Profile__c lp : profiles) {
            Integer depth = getDepthForManager(lp, managerEmail);
            maxDepth = Math.max(maxDepth, depth);

            OrgSummaryEntry entry = new OrgSummaryEntry();
            entry.name = lp.Name;
            entry.title = lp.Title__c;
            entry.email = lp.Primary_Email__c;
            entry.userId = lp.User__c;
            entry.learnerProfileId = lp.Id;
            summary.allPeopleInOrg.add(entry);

            String depthKey = String.valueOf(depth);
            Integer countAtDepth = summary.peopleByDepth.containsKey(depthKey) ? summary.peopleByDepth.get(depthKey) : 0;
            summary.peopleByDepth.put(depthKey, countAtDepth + 1);

            if ((lp.Manager_Email__c == managerEmail) || (managerLp != null && lp.Manager__c == managerLp.Id)) {
                summary.directReportSummaries.add(entry);
            }
        }

        summary.totalPeople = summary.allPeopleInOrg.size();
        summary.directReports = summary.directReportSummaries.size();
        summary.summaryMessage = 'Organization for ' + manager.Name + ' (' + manager.Title + ') includes ' +
                                 summary.totalPeople + ' people across ' + maxDepth + ' levels. They have ' +
                                 summary.directReports + ' direct reports.';

        return summary;
    }

    /**
     * @description Finds all employees who report directly to a given manager.
     * @param managerEmail The email address of the manager.
     * @return A list of direct reports as UnifiedEmployee objects.
     */
    public static EmployeeSearchResult getDirectReports(String managerEmail) {
        return getDirectReports(managerEmail, null);
    }

    public static EmployeeSearchResult getDirectReports(String managerEmail, String managerLearnerProfileId) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_CRU);

        EmployeeSearchResult result = new EmployeeSearchResult();
        List<String> clauses = new List<String>();
        if (String.isNotBlank(managerEmail)) {
            clauses.add('Manager_Email__c = \'' + String.escapeSingleQuotes(managerEmail) + '\'');
        }
        if (String.isNotBlank(managerLearnerProfileId)) {
            clauses.add('Manager__c = \'' + String.escapeSingleQuotes(managerLearnerProfileId) + '\'');
        }
        if (clauses.isEmpty()) {
            return result;
        }
        String whereClause = String.join(clauses, ' OR ');
        
        // First, get the total count
        String countQuery = 'SELECT count() FROM Learner_Profile__c WHERE SlackId__c != null AND ' + whereClause;
        if (Test.isRunningTest() && mockCountResult != null) {
            result.totalCount = mockCountResult;
        } else {
            result.totalCount = Database.countQuery(countQuery);
        }

        // Then, get the records
        String soqlQuery = buildQuery(getCoreFields(), whereClause, null, null, null, null);
        List<Learner_Profile__c> profiles;
        if (Test.isRunningTest() && mockResults != null) {
            profiles = mockResults;
        } else {
            profiles = Database.query(soqlQuery);
        }
        
        result.employees = composeUnifiedEmployees(profiles);
        return result;
    }

    // --- Private Helper Methods ---

    private static Set<String> getCoreFields() {
        Set<String> coreFields = new Set<String>();
        for (FilterableFieldInfo info : FILTERABLE_FIELDS_INFO) {
            coreFields.add(info.apiName);
        }
        coreFields.addAll(new List<String>{'Id', 'Name', 'Primary_Email__c', 'Title__c', 'Status__c', 'Job_Family__c', 'Manager__c', 'Manager_Email__c', 'Work_Location_Country__c', 'User__c'});
        return coreFields;
    }

    private static String buildWhereClause(Map<String, Object> filters) {
        List<String> whereClauses = new List<String>();
        if (filters != null && !filters.isEmpty()) {
            for (String key : filters.keySet()) {
                if (FILTER_INFO_MAP.containsKey(key) && filters.get(key) != null) {
                    FilterableFieldInfo info = FILTER_INFO_MAP.get(key);
                    String fieldApiName = info.apiName;
                    String value = String.valueOf(filters.get(key));
                    
                    if (DATE_FIELDS.contains(fieldApiName)) {
                        String dateClause = FRAGENTUtility.parseDateFilter(fieldApiName, value);
                        if (String.isNotBlank(dateClause)) {
                            whereClauses.add(dateClause);
                        }
                    } else if (MULTIPICKLIST_FIELDS.contains(fieldApiName)) {
                        whereClauses.add(fieldApiName + ' INCLUDES (\'' + String.escapeSingleQuotes(value) + '\')');
                    } else {
                        whereClauses.add(fieldApiName + ' = \'' + String.escapeSingleQuotes(value) + '\'');
                    }
                }
            }
        }
        return String.join(whereClauses, ' AND ');
    }

    private static String buildQuery(Set<String> fieldsToQuery, String additionalWhereClause, String sortBy, String sortOrder, Integer recordLimit, Integer offset) {
        String baseQuery = 'SELECT ' + String.join(new List<String>(fieldsToQuery), ', ') +
                           ' FROM Learner_Profile__c ' +
                           'WHERE SlackId__c != null';

        if (String.isNotBlank(additionalWhereClause)) {
            baseQuery += ' AND (' + additionalWhereClause + ')';
        }

        // Add Sorting
        if (String.isNotBlank(sortBy) && SORTABLE_FIELDS.contains(sortBy)) {
            baseQuery += ' ORDER BY ' + sortBy; // Sanitized by whitelist check
            if (String.isNotBlank(sortOrder) && (sortOrder.equalsIgnoreCase('ASC') || sortOrder.equalsIgnoreCase('DESC'))) {
                baseQuery += ' ' + sortOrder;
            } else {
                baseQuery += ' ASC'; // Default to ascending
            }
        } else {
            // Default sort order if none is provided
            baseQuery += ' ORDER BY Name ASC';
        }

        // Add Pagination
        if (recordLimit != null && recordLimit > 0) {
            baseQuery += ' LIMIT ' + recordLimit;
        }
        if (offset != null && offset > 0) {
            baseQuery += ' OFFSET ' + offset;
        }

        return baseQuery;
    }

    private static List<UnifiedEmployee> fuzzyRankAndSortEmployees(List<UnifiedEmployee> candidates, String searchTerm) {
        if (candidates == null || candidates.isEmpty() || String.isBlank(searchTerm)) {
            return candidates;
        }

        List<RankedEmployee> rankedList = new List<RankedEmployee>();
        // The threshold is the maximum allowed distance. A lower value is stricter.
        // We set it to 40% of the search term's length, with a minimum of 1.
        Integer threshold = Math.max(1, (Integer)(searchTerm.length() * 0.4));

        for (UnifiedEmployee ue : candidates) {
            // Get distance for Name. The method returns -1 if the threshold is exceeded.
            Integer nameDistance = ue.name.getLevenshteinDistance(searchTerm, threshold);

            if (nameDistance != -1) {
                rankedList.add(new RankedEmployee(ue, nameDistance));
            }
        }

        // Sort the list based on the compareTo method in RankedEmployee
        rankedList.sort();

        // Extract the sorted UnifiedEmployee objects
        List<UnifiedEmployee> sortedEmployees = new List<UnifiedEmployee>();
        for (RankedEmployee re : rankedList) {
            sortedEmployees.add(re.employee);
        }

        return sortedEmployees;
    }

    private static List<UnifiedEmployee> composeUnifiedEmployees(List<Learner_Profile__c> profiles) {
        List<UnifiedEmployee> unifiedEmployees = new List<UnifiedEmployee>();
        if (profiles == null || profiles.isEmpty()) {
            return unifiedEmployees;
        }

        Set<Id> userIds = new Set<Id>();
        for (Learner_Profile__c profile : profiles) {
            if (profile.User__c != null) {
                userIds.add(profile.User__c);
            }
        }

        Map<Id, User> userMap = new Map<Id, User>();
        if (!userIds.isEmpty()) {
            userMap = new Map<Id, User>([
                SELECT Id, IsActive, Profile.Name, UserRole.Name
                FROM User
                WHERE Id IN :userIds
            ]);
        }

        for (Learner_Profile__c profile : profiles) {
            User u = userMap.get(profile.User__c);

            UnifiedEmployee ue = new UnifiedEmployee();
            ue.learnerProfileId = profile.Id;
            ue.name = profile.Name;
            ue.email = profile.Primary_Email__c;
            ue.title = profile.Title__c;
            ue.status = profile.Status__c;
            ue.division = profile.Division__c;
            ue.jobFamily = profile.Job_Family__c;
            ue.managerName = profile.Manager__c;
            ue.managerEmail = profile.Manager_Email__c;
            ue.country = profile.Work_Location_Country__c;
            ue.acquiredCompany = profile.Acquired_Company__c;
            ue.aeType = profile.AE_Type__c;
            ue.contractorType = profile.Contractor_Type__c;
            ue.marketSegment = profile.Customer_Market_Segment__c;
            ue.l1Cloud = profile.L1_Cloud__c;
            ue.l1Product = profile.L1_Product__c;
            ue.l2Cloud = profile.L2_Cloud__c;
            ue.languageProficiency = profile.Language_Proficiency__c;
            ue.macroSegment = profile.Macro_Segment__c;
            ue.managerLevel = profile.Manager_Level__c;
            ue.managerType = profile.Manager_Type__c;
            ue.ouName = profile.OU_Name__c;
            ue.countryOfCoverage = profile.Primary_Country_of_Coverage__c;
            ue.roleLevel3 = profile.Role_Level_3__c;
            ue.roleLevel4 = profile.Role_Level_4__c;

            if (u != null) {
                ue.userId = u.Id;
                ue.isSalesforceUserActive = u.IsActive;
                ue.profileName = u.Profile?.Name;
                ue.roleName = u.UserRole?.Name;
            } else {
                // For users not found in the User object, we set isSalesforceUserActive to false.
                // Other string properties will default to null and be omitted from JSON.
                ue.isSalesforceUserActive = false;
            }

            unifiedEmployees.add(ue);
        }

        return unifiedEmployees;
    }

    // Determines how deep a given manager appears in the learner's management chain
    private static Integer getDepthForManager(Learner_Profile__c lp, String managerEmail) {
        Integer level = 0;
        for (Integer i = 0; i < MANAGEMENT_CHAIN_FIELDS.size(); i++) {
            String fieldName = MANAGEMENT_CHAIN_FIELDS[i];
            String value = (String)lp.get(fieldName);
            if (value != null && value.equalsIgnoreCase(managerEmail)) {
                level = i + 1;
                break;
            }
        }
        return level;
    }
}