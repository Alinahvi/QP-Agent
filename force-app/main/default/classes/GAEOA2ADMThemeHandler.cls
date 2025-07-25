/**
 * @description Handles CRUD and search operations for Theme records (agf__ADM_Theme__c).
 * Themes represent high-level strategic initiatives or focus areas that can span
 * multiple projects and epics.
 */
public with sharing class GAEOA2ADMThemeHandler {
    private static final String SOBJECT_TYPE = 'agf__ADM_Theme__c';
    private static final String SOBJECT_TYPE_LABEL = 'Theme';

    // Request wrapper for invocable method
    public class Request {
        @InvocableVariable(label='Action Type' description='The action to perform: Create, Modify, Retrieve, or Search.' required=true)
        public String actionType;

        @InvocableVariable(label='Theme ID' description='The Salesforce ID of the Theme record. Required for Modify and Retrieve actions.')
        public String themeId;

        @InvocableVariable(label='Theme Name' description='The name of the theme (Name field).')
        public String name;
        @InvocableVariable(label='Active' description='Whether the theme is active (agf__Active__c).')
        public Boolean active;
        @InvocableVariable(label='Description' description='A description of the theme (agf__Description__c).')
        public String description;
        @InvocableVariable(label='External ID' description='External ID for the theme (agf__External_ID__c).')
        public String externalId;
        @InvocableVariable(label='Scrum Team ID' description='The ID of the associated Scrum Team (agf__Scrum_Team__c).')
        public String scrumTeamId;
        @InvocableVariable(label='Theme Rank' description='The rank of the theme (agf__Theme_Rank__c).')
        public Decimal themeRank;
        // Search-specific fields
        @InvocableVariable(label='Created Date' description='Date filter for search operations on the CreatedDate field. Supported formats: YYYY-MM-DD, YYYY-MM-DD:YYYY-MM-DD, or Salesforce date literals (e.g., TODAY, LAST_N_DAYS:30).')
        public String createdDate;
        @InvocableVariable(label='Last Modified Date' description='Date filter for search operations on the LastModifiedDate field. Supported formats: YYYY-MM-DD, YYYY-MM-DD:YYYY-MM-DD, or Salesforce date literals (e.g., TODAY, LAST_N_DAYS:30).')
        public String lastModifiedDate;
    }

    // Response wrapper for invocable method
    public class Response {
        @InvocableVariable(label='Success' description='True if the operation succeeded, false otherwise.')
        public Boolean success = false;
        @InvocableVariable(label='Message' description='A summary of the operation result, such as success or error messages.')
        public String message = '';
        @InvocableVariable(label='Theme Records' description='A list of agf__ADM_Theme__c records that were processed, created, or retrieved by the operation.')
        public List<agf__ADM_Theme__c> themeRecords = new List<agf__ADM_Theme__c>();
    }

    /**
     * @description Main entry point for managing Theme records. Supports Create, Modify, Retrieve, and Search actions.
     * @param requests A list of Request objects, each defining an operation to perform.
     * @return A list of Response objects corresponding to each input request.
     */
    @InvocableMethod(label='GA-EOA2 Manage Themes' description='Performs Create, Modify, Retrieve, and Search operations on Theme (agf__ADM_Theme__c) records.')
    public static List<Response> manageThemes(List<Request> requests) {
        List<agf__ADM_Theme__c> toCreate = new List<agf__ADM_Theme__c>();
        List<agf__ADM_Theme__c> toUpdate = new List<agf__ADM_Theme__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            Response res = new Response();
            responseMap.put(i, res);

            switch on req.actionType {
                when 'Create' {
                    if (String.isBlank(req.name)) {
                        res.message = 'Error: Theme Name is required for creation.';
                    } else {
                        toCreate.add(mapRequestToTheme(req, new agf__ADM_Theme__c()));
                    }
                }
                when 'Modify', 'Retrieve' {
                    if (String.isBlank(req.themeId)) {
                        res.message = 'Error: Theme ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.themeId);
                    }
                }
                when 'Search' {
                    handleSearch(req, res);
                }
                when else {
                    res.message = 'Error: Invalid or missing action type. Must be Create, Modify, Retrieve, or Search.';
                }
            }
        }

        if (!toCreate.isEmpty()) {
            Database.SaveResult[] createResults = Database.insert(toCreate, false);
            handleDmlResults(createResults, toCreate, 'Create', requests, responseMap);
        }

        if (!idsToProcess.isEmpty()) {
            String allFieldsQuery = 'SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('agf__ADM_Theme__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM agf__ADM_Theme__c WHERE Id IN :idsToProcess';
            Map<Id, agf__ADM_Theme__c> themesFromDb = new Map<Id, agf__ADM_Theme__c>((List<agf__ADM_Theme__c>)Database.query(allFieldsQuery));

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                if (String.isBlank(req.themeId) || !themesFromDb.containsKey(req.themeId)) continue;
                
                Response res = responseMap.get(i);
                agf__ADM_Theme__c theme = themesFromDb.get(req.themeId);

                if (req.actionType == 'Modify') {
                    toUpdate.add(mapRequestToTheme(req, theme));
                } else if (req.actionType == 'Retrieve') {
                    res.success = true;
                    res.message = 'Theme retrieved successfully.';
                    res.themeRecords.add(theme);
                }
            }
        }
        
        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] updateResults = Database.update(toUpdate, false);
            handleDmlResults(updateResults, toUpdate, 'Modify', requests, responseMap);
        }
        
        return new List<Response>(responseMap.values());
    }

    /**
     * @description Maps fields from a Request wrapper object to an agf__ADM_Theme__c SObject record.
     * @param req The Request object containing the input data.
     * @param theme The agf__ADM_Theme__c record to populate.
     * @return The populated agf__ADM_Theme__c record.
     */
    private static agf__ADM_Theme__c mapRequestToTheme(Request req, agf__ADM_Theme__c theme) {
        if(req.themeId != null) theme.Id = req.themeId;
        if(req.name != null) theme.Name = req.name;
        if(req.active != null) theme.agf__Active__c = req.active;
        if(req.description != null) theme.agf__Description__c = req.description;
        if(req.externalId != null) theme.agf__External_ID__c = req.externalId;
        if(req.scrumTeamId != null) theme.agf__Scrum_Team__c = req.scrumTeamId;
        if(req.themeRank != null) theme.agf__Theme_Rank__c = req.themeRank;
        return theme;
    }

    /**
     * @description Processes the results of a DML operation (insert or update) and updates the response map accordingly.
     * @param results The array of Database.SaveResult objects from the DML call.
     * @param records The list of records that were processed.
     * @param action The action performed ('Create' or 'Modify').
     * @param requests The original list of requests.
     * @param responseMap The map of responses to update.
     */
    private static void handleDmlResults(Database.SaveResult[] results, List<agf__ADM_Theme__c> records, String action, List<Request> requests, Map<Integer, Response> responseMap) {
        Integer recordIndex = 0;
        for (Integer i = 0; i < requests.size(); i++) {
            if (requests.get(i).actionType == action && ((action == 'Create' && String.isNotBlank(requests.get(i).name)) || (action == 'Modify' && String.isNotBlank(requests.get(i).themeId)))) {
                if (recordIndex < results.size()) {
                    Database.SaveResult sr = results[recordIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Theme ' + action.toLowerCase() + 'd successfully.';
                        res.themeRecords.add(records[recordIndex]);
                    } else {
                        String errorMessage = '';
                        for(Database.Error err : sr.getErrors()) {
                            errorMessage += err.getStatusCode() + ': ' + err.getMessage() + ' (Fields: ' + String.join(err.getFields(), ', ') + ')\n';
                        }
                        res.message = 'Error during ' + action + ': ' + errorMessage;
                    }
                    recordIndex++;
                }
            }
        }
    }

    /**
     * @description Constructs and executes a dynamic SOQL query based on search criteria in the Request object.
     * @param req The Request object containing the search parameters.
     * @param res The Response object to populate with the search results.
     */
    private static void handleSearch(Request req, Response res) {
        String soql = 'SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('agf__ADM_Theme__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM agf__ADM_Theme__c';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.name)) {
            conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(req.name) + '%\'');
        }
        if(req.createdDate != null) {
            String dateCondition = GAFRA2Utility.parseDateFilter('CreatedDate', req.createdDate);
            if(dateCondition != null) conditions.add(dateCondition);
        }
        if(req.lastModifiedDate != null) {
            String dateCondition = GAFRA2Utility.parseDateFilter('LastModifiedDate', req.lastModifiedDate);
            if(dateCondition != null) conditions.add(dateCondition);
        }
        
        if (!conditions.isEmpty()) {
            soql += ' WHERE ' + String.join(conditions, ' AND ');
        }
        
        soql += ' ORDER BY LastModifiedDate DESC LIMIT 200';

        try {
            res.themeRecords = Database.query(soql);
            res.success = true;
            res.message = 'Search completed successfully. Found ' + res.themeRecords.size() + ' records.';
        } catch (Exception e) {
            res.message = 'Error during search: ' + e.getMessage();
        }
    }
}