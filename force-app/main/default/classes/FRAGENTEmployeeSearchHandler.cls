/**
 * TEMPLATE HANDLER - This class acts as agent instructions in our handler/service template.
 * Business Requirement: Responses include both Ids and Names when applicable to meet user-friendly output requirements.
 * The handler validates requests and delegates business logic to the service layer.
 * @description Handler for Employee Search functionality, providing a single, invocable entry point for various search actions.
 *              This class is designed to be invoked from Salesforce Flows and GenAI functions.
 *
 * Results are returned as `UnifiedEmployee` records defined in the service.
 *
 * @date 2025-07-10
 */
public with sharing class FRAGENTEmployeeSearchHandler {

    public class Request {
        @InvocableVariable(label='Action' description='The action to perform: Search, GetOrgHierarchy, GetDirectReports, CountFieldValues, GetDistinctFieldValues, GetSearchableFields' required=true)
        public String action;
        
        @InvocableVariable(label='Search Term' description='The name or keyword to search for. Can be a full name, partial name, or email.' required=false)
        public String searchTerm;

        @InvocableVariable(label='Get Org Hierarchy' description='Default: false. If true, returns the full reporting organization for the employee found via the Search Term. Only the first result of the search will be used.')
        public Boolean getOrgHierarchy = false;

        @InvocableVariable(label='Get Direct Reports' description='Default: false. If true, returns the direct reports for the employee found via the Search Term. Only the first result of the search will be used.')
        public Boolean getDirectReports = false;

        // --- Optional Filters ---
        @InvocableVariable(label='FILTER BY: Division' description='Filter by a user\'s division. Examples: "AMER", "APAC", "EMEA", "Japan".')
        public String Division;

        @InvocableVariable(label='FILTER BY: Acquired Company' description='Filter by the company the user was a part of. Examples: "Acumen", "Slack", "Tableau".')
        public String AcquiredCompany;

        @InvocableVariable(label='FILTER BY: AE Type' description='Filter by the Account Executive type. Valid values: "Applications", "Core", "Digital", "ECS", "GAM/NAM/RAM", "MuleSoft", "Platform and Agents", "Tableau".')
        public String AeType;

        @InvocableVariable(label='FILTER BY: Contractor Type' description='Filter by the type of contractor. Valid values: "CW", "PW", "SOW".')
        public String ContractorType;

        @InvocableVariable(label='FILTER BY: Market Segment' description='Filter by the customer market segment. Examples: "ECS", "ECS-HUNTER", "EMG-EB".')
        public String MarketSegment;

        @InvocableVariable(label='FILTER BY: L1 Cloud' description='Filter by the high-level cloud product area. Examples: "Analytics", "Commerce", "Integration", "Marketing".')
        public String L1Cloud;

        @InvocableVariable(label='FILTER BY: L1 Product' description='Filter by the high-level product. Valid values: "All (Core)", "Analytics", "Commerce", "Integration", "Marketing", "N/A", "Sales", "Salesforce Platform", "Service".')
        public String L1Product;

        @InvocableVariable(label='FILTER BY: L2 Cloud' description='Filter by the specific cloud product. Examples: "B2C Commerce", "CRM Analytics", "Field Service".')
        public String L2Cloud;

        @InvocableVariable(label='FILTER BY: Language' description='Filter by language proficiency. Valid values: "English", "Spanish".')
        public String Language;

        @InvocableVariable(label='FILTER BY: Macro Segment' description='Filter by the macro-economic segment. Valid values: "CMRCL", "ENTR", "ESMB", "GEN", "MID", "PubSec", "Shared", "TBD", "Unmapped".')
        public String MacroSegment;

        @InvocableVariable(label='FILTER BY: Manager Level' description='Filter by the manager level in the hierarchy. Valid values: "Manager Level 1", "Manager Level 2", "Manager Level 3", "Manager Level 4", "Manager Level 5", "Manager Level 6", "Manager Level 7", "Manager Level 8", "Manager Level 9", "Manager Level 10".')
        public String ManagerLevel;

        @InvocableVariable(label='FILTER BY: Manager Type' description='Filter by the type of manager. Valid values: "AE Manager", "BDR Manager", "BVS Manager", "COO", "ECS Manager", "SDR Manager", "SE Manager", "Sales Strategy Manager", "Specialist AE Manager".')
        public String ManagerType;

        @InvocableVariable(label='FILTER BY: OU Name' description='Filter by the Operating Unit name. Examples: "AMER - CAN", "AMER - FINS", "APAC - INDIA".')
        public String OuName;

        @InvocableVariable(label='FILTER BY: Country of Coverage' description='Filter by the primary country of coverage. Use standard country names or codes like "USA", "Spain", "AFRICA".')
        public String CountryOfCoverage;

        @InvocableVariable(label='FILTER BY: Role Level 3' description='Filter by the user\'s sales segment. Valid values: "Direct Sales Role", "Indirect Sales", "Shared Sales Support".')
        public String RoleLevel3;

        @InvocableVariable(label='FILTER BY: Role Level 4' description='Filter by a more specific role category. Examples: "Prime AE", "Exec Admin", "Indirect Sales".')
        public String RoleLevel4;

        @InvocableVariable(label='FILTER BY: Hire Date' description='To narrow your search, provide a hire date. Supports formats like YYYY-MM-DD, YYYY-MM, or date literals like LAST_N_DAYS:30.')
        public String HireDate;

        // --- Sorting & Pagination ---
        @InvocableVariable(label='Sort By' description='Optional. The API name of the field to sort by (e.g., Name, Hire_Date__c). Must be on the pre-approved list in the service.')
        public String sortBy;
        
        @InvocableVariable(label='Sort Order' description='Optional. The direction to sort (ASC or DESC). Defaults to ASC.')
        public String sortOrder;

        @InvocableVariable(label='Record Limit' description='Optional. The maximum number of records to return.')
        public Integer recordLimit;

        @InvocableVariable(label='Offset' description='Optional. The starting row offset for pagination.')
        public Integer offset;

        // --- Aggregation Actions ---
        @InvocableVariable(label='Count Field Values' description='Optional. Returns a count of unique values for the specified field (e.g., Division__c). This overrides all other actions.')
        public String countValuesForField;

        @InvocableVariable(label='Get Distinct Values For Field' description='Optional. When using the GetDistinctFieldValues action, provide the user friendly field name to retrieve values for.')
        public String fieldNameForValues;
    }

    public class Response {
        @InvocableVariable(label='Success' description='Indicates if the operation was successful.')
        public Boolean success;

        @InvocableVariable(label='Message' description='Provides a success or error message.')
        public String message;

        @InvocableVariable(label='Employees' description='The list of unified employee records found.')
        public List<FRAGENTEmployeeSearchService.UnifiedEmployee> employees;

        @InvocableVariable(label='Total Record Count' description='The total number of records found, even if not all are returned.')
        public Integer totalRecordCount;

        @InvocableVariable(label='Refine Search By' description='A helpful list of fields you can use to narrow down your search results further, like Division, Title, etc.')
        public List<RefineByField> refineByFields;

        @InvocableVariable(label='Organization Summary' description='If an organization hierarchy search was performed, this contains the aggregated summary of the results.')
        public FRAGENTEmployeeSearchService.OrgHierarchySummary orgSummary;

        @InvocableVariable(label='Primary Match' description='If a search returns exactly one employee, that employee record is populated here for convenience.')
        public FRAGENTEmployeeSearchService.UnifiedEmployee primaryMatch;
    
        @InvocableVariable(label='Next Offset' description='The calculated offset to use for requesting the next page of results.')
        public Integer nextOffset;

        @InvocableVariable(label='Has More Records' description='True if there are more records available beyond the current page.')
        public Boolean hasMoreRecords;

        @InvocableVariable(label='Field Value Counts (JSON)' description='If a "Count Field Values" action was performed, this contains the results as a JSON string map.')
        public String fieldValueCountsJSON;

        @InvocableVariable(label='Field Values' description='If a GetDistinctFieldValues action was performed, this contains the list of distinct values for the requested field.')
        public List<String> fieldValues;

        public Response() {
            this.success = false;
            this.message = '';
            this.employees = new List<FRAGENTEmployeeSearchService.UnifiedEmployee>();
            this.totalRecordCount = 0;

            this.fieldValues = new List<String>();
            
            this.refineByFields = new List<RefineByField>();
            for (FRAGENTEmployeeSearchService.FilterableFieldInfo info : FRAGENTEmployeeSearchService.getDescriptiveFilterableFields()) {
                this.refineByFields.add(new RefineByField(info.label, info.description));
            }
        }
    }
    
    public class RefineByField {
        @InvocableVariable(label='Field Name' description='The user-friendly name of the filter field.')
        @AuraEnabled
        public String name;
        @InvocableVariable(label='Field Description' description='A description of what the filter field is and how to use it.')
        @AuraEnabled
        public String description;

        public RefineByField(String name, String description) {
            this.name = name;
            this.description = description;
        }
    }

    @InvocableMethod(label='FRAGENT Search for Employees' description='A simplified action to search for employees by name or email and/or filter by specific criteria like their division, role, or hire date.')
    public static List<Response> searchEmployees(List<Request> requests) {
        List<Response> responses = new List<Response>();

        for (Request req : requests) {
            Response res = new Response();
            try {
                // Validate action parameter
                if (String.isBlank(req.action)) {
                    res.message = 'Action parameter is required. Valid actions: Search, GetOrgHierarchy, GetDirectReports, CountFieldValues, GetDistinctFieldValues, GetSearchableFields';
                    responses.add(res);
                    continue;
                }

                String action = req.action.toLowerCase();
                
                // Route to appropriate service method based on action
                switch on action {
                    when 'search' {
                        res = handleSearch(req);
                    }
                    when 'getorghierarchy' {
                        res = handleGetOrgHierarchy(req);
                    }
                    when 'getdirectreports' {
                        res = handleGetDirectReports(req);
                    }
                    when 'countfieldvalues' {
                        res = handleCountFieldValues(req);
                    }
                    when 'getdistinctfieldvalues' {
                        res = handleGetDistinctFieldValues(req);
                    }
                    when 'getsearchablefields' {
                        res = handleGetSearchableFields(req);
                    }
                    when else {
                        res.message = 'Invalid action: ' + req.action + '. Valid actions: Search, GetOrgHierarchy, GetDirectReports, CountFieldValues, GetDistinctFieldValues, GetSearchableFields';
                    }
                }
                
            } catch (Exception e) {
                res.success = false;
                res.message = 'An error occurred: ' + e.getMessage();
                        }
            responses.add(res);
        }
        return responses;
    }
    
    private static Response handleSearch(Request req) {
        Response res = new Response();
        
        String validationError = validateRequest(req);
        if (String.isNotBlank(validationError)) {
            res.message = validationError;
            return res;
        }
        
        FRAGENTEmployeeSearchService.EmployeeSearchResult result = FRAGENTEmployeeSearchService.searchEmployees(req.searchTerm, buildFilterMap(req), req.sortBy, req.sortOrder, req.recordLimit, req.offset);
        
                    if (result.totalCount > 0) {
                        res.message = 'Search returned ' + result.employees.size() + ' of ' + result.totalCount + ' total employees.';
                    } else {
                        res.message = 'No employees found matching the criteria.';
                }

                    res.employees = result.employees;
                    res.totalRecordCount = result.totalCount;

                    // Set pagination metadata
                    if (req.recordLimit != null && req.recordLimit > 0) {
                        Integer currentOffset = req.offset != null ? req.offset : 0;
                        res.nextOffset = currentOffset + req.recordLimit;
                        res.hasMoreRecords = res.nextOffset < result.totalCount;
                    } else {
                        res.hasMoreRecords = false; // No limit was applied, so all records were returned
                    }

                    // Set primary match if there is exactly one result
                    if (result.employees != null && result.employees.size() == 1) {
                        res.primaryMatch = result.employees[0];
                    }
        
        res.success = true;
        return res;
    }
    
    private static Response handleGetOrgHierarchy(Request req) {
        Response res = new Response();
        
        if (String.isBlank(req.searchTerm)) {
            req.searchTerm = [SELECT Email FROM User WHERE Id = :UserInfo.getUserId()].Email;
        }
        
        FRAGENTEmployeeSearchService.EmployeeSearchResult initialResults = FRAGENTEmployeeSearchService.searchEmployees(req.searchTerm, buildFilterMap(req));
        
        if (initialResults.employees.isEmpty()) {
            res.message = 'No employee found matching the search term to start the action.';
        } else {
            String managerEmail = initialResults.employees[0].email;
            if (String.isBlank(managerEmail)) {
                res.message = 'The found employee, ' + initialResults.employees[0].name + ', does not have an email address to proceed with the hierarchy search.';
            } else {
                res.orgSummary = FRAGENTEmployeeSearchService.getOrganizationHierarchy(managerEmail);
                res.message = res.orgSummary.summaryMessage;
                res.success = true;
            }
        }
        
        return res;
    }
    
    private static Response handleGetDirectReports(Request req) {
        Response res = new Response();
        
        if (String.isBlank(req.searchTerm)) {
            req.searchTerm = [SELECT Email FROM User WHERE Id = :UserInfo.getUserId()].Email;
        }
        
        FRAGENTEmployeeSearchService.EmployeeSearchResult initialResults = FRAGENTEmployeeSearchService.searchEmployees(req.searchTerm, buildFilterMap(req));

        if (initialResults.employees.isEmpty()) {
            res.message = 'No employee found matching the search term to start the action.';
        } else {
             String managerEmail = initialResults.employees[0].email;
             String managerProfileId = initialResults.employees[0].learnerProfileId;
            if (String.isBlank(managerEmail)) {
                res.message = 'The found employee, ' + initialResults.employees[0].name + ', does not have an email address to proceed with the direct reports search.';
            } else {
                FRAGENTEmployeeSearchService.EmployeeSearchResult result = FRAGENTEmployeeSearchService.getDirectReports(managerEmail, managerProfileId);
                res.employees = result.employees;
                res.totalRecordCount = result.totalCount;
                res.message = 'Returned direct reports for ' + initialResults.employees[0].name;
                res.success = true;
            }
        }
        
        return res;
    }
    
    private static Response handleCountFieldValues(Request req) {
        Response res = new Response();
        
        if (String.isBlank(req.countValuesForField)) {
            res.message = 'Count Field Values field is required for CountFieldValues action';
            return res;
        }
        
        Map<String, Integer> counts = FRAGENTEmployeeSearchService.countFieldValues(req.countValuesForField, buildFilterMap(req));
        res.fieldValueCountsJSON = JSON.serialize(counts);
        res.message = 'Returned count of unique values for field: ' + req.countValuesForField;
        res.success = true;
        
        return res;
    }

    private static Response handleGetDistinctFieldValues(Request req) {
        Response res = new Response();

        if (String.isBlank(req.fieldNameForValues)) {
            res.message = 'fieldNameForValues is required for GetDistinctFieldValues action';
            return res;
        }

        try {
            res.fieldValues = FRAGENTEmployeeSearchService.getDistinctFieldValues(req.fieldNameForValues);
            res.message = 'Returned distinct values for field: ' + req.fieldNameForValues;
            res.success = true;
        } catch (Exception e) {
            res.message = 'Error retrieving distinct values: ' + e.getMessage();
        }

        return res;
    }

    private static Response handleGetSearchableFields(Request req) {
        Response res = new Response();
        res.message = 'Returned list of searchable fields.';
        res.success = true;
        return res;
    }

    private static String validateRequest(Request req) {
        if (req == null) {
            return 'Request cannot be null.';
        }
    
        Map<String, Object> filters = buildFilterMap(req);
    
        // Standard search requires a search term or a filter.
        if (String.isBlank(req.searchTerm) && filters.isEmpty()) {
            return 'You must provide a search term or at least one filter to begin your search.';
        }
    
        return ''; // No validation errors
    }

    private static Map<String, Object> buildFilterMap(Request req) {
        Map<String, Object> filters = new Map<String, Object>();
        if(String.isNotBlank(req.Division)) filters.put('Division', req.Division);
        if(String.isNotBlank(req.AcquiredCompany)) filters.put('AcquiredCompany', req.AcquiredCompany);
        if(String.isNotBlank(req.AeType)) filters.put('AeType', req.AeType);
        if(String.isNotBlank(req.ContractorType)) filters.put('ContractorType', req.ContractorType);
        if(String.isNotBlank(req.MarketSegment)) filters.put('MarketSegment', req.MarketSegment);
        if(String.isNotBlank(req.L1Cloud)) filters.put('L1Cloud', req.L1Cloud);
        if(String.isNotBlank(req.L1Product)) filters.put('L1Product', req.L1Product);
        if(String.isNotBlank(req.L2Cloud)) filters.put('L2Cloud', req.L2Cloud);
        if(String.isNotBlank(req.Language)) filters.put('Language', req.Language);
        if(String.isNotBlank(req.MacroSegment)) filters.put('MacroSegment', req.MacroSegment);
        if(String.isNotBlank(req.ManagerLevel)) filters.put('ManagerLevel', req.ManagerLevel);
        if(String.isNotBlank(req.ManagerType)) filters.put('ManagerType', req.ManagerType);
        if(String.isNotBlank(req.OuName)) filters.put('OuName', req.OuName);
        if(String.isNotBlank(req.CountryOfCoverage)) filters.put('CountryOfCoverage', req.CountryOfCoverage);
        if(String.isNotBlank(req.RoleLevel3)) filters.put('RoleLevel3', req.RoleLevel3);
        if(String.isNotBlank(req.RoleLevel4)) filters.put('RoleLevel4', req.RoleLevel4);
        if(String.isNotBlank(req.HireDate)) filters.put('HireDate', req.HireDate);
        return filters;
    }
}