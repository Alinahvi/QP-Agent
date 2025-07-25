Public with sharing class GAFRA2ContentSearchHandler {

    public class Request {
        @InvocableVariable(label='Action Type' description='Specify the action: Retrieve | Search' required=true)
        public String actionType;
        @InvocableVariable(label='Content Type' description='For a "Retrieve" action, you MUST specify the type of content. Valid values: Curriculum, Course, Asset')
        public String contentType;
        @InvocableVariable(label='Content ID' description='For a "Retrieve" action, provide the unique Salesforce ID of the record.')
        public String contentId;
        @InvocableVariable(label='Search Keyword' description='For a "Search" action, provide a keyword to search in the Name and Description fields across all content types.')
        public String searchKeyword;
        @InvocableVariable(label='Status' description='Search Filter. Valid values: Draft, Active, Archived')
        public String status;
        @InvocableVariable(label='Primary Category' description='Search Filter. Valid values: Skills, DMJ, Product, Industry')
        public String primaryCategory;
        @InvocableVariable(label='Content Owner Organization' description='Search Filter. Filters by the content owning organization.')
        public String contentOwnerOrg;
        @InvocableVariable(label='Created Date' description='Search Filter. Example: "2023-10-27" or "LAST_N_DAYS:10"')
        public String createdDate;
        @InvocableVariable(label='Last Modified Date' description='Search Filter. Example: "YESTERDAY"')
        public String lastModifiedDate;
        @InvocableVariable(label='Created By User ID' description='Search Filter. Example: "005Hu000001ERwyIAG"')
        public String createdById;
        @InvocableVariable(label='Last Modified By User ID' description='Search Filter. Example: "005Hu000001ERwzIAG"')
        public String lastModifiedById;
    }

    public class Response {
        @InvocableVariable(label='Success' description='Indicates if the operation succeeded.')
        public Boolean success = false;
        @InvocableVariable(label='Message' description='A summary of the operation result.')
        public String message = '';
        @InvocableVariable(label='Curriculum Records' description='A list of matching Curriculum records.')
        public List<Curriculum__c> curriculumRecords;
        @InvocableVariable(label='Course Records' description='A list of matching Course records.')
        public List<Course__c> courseRecords;
        @InvocableVariable(label='Asset Records' description='A list of matching Asset records.')
        public List<Asset__c> assetRecords;
    }

    @InvocableMethod(label='GA-FRA2 Search Content' description='A powerful tool to retrieve or search for content across Curriculums, Courses, and Assets simultaneously.')
    public static List<Response> searchContent(List<Request> requests) {
        List<Response> responses = new List<Response>();

        for (Request req : requests) {
            Response res = new Response();
            try {
                if (req.actionType == 'Retrieve') {
                    if(String.isNotBlank(req.contentId) && String.isNotBlank(req.contentType)) {
                        if(req.contentType == 'Curriculum') {
                            res.curriculumRecords = [SELECT Id, Name, Description__c, Status__c, Primary_Category__c FROM Curriculum__c WHERE Id = :req.contentId];
                        } else if (req.contentType == 'Course') {
                            res.courseRecords = [SELECT Id, Name, Description__c, Status__c, Primary_Category__c FROM Course__c WHERE Id = :req.contentId];
                        } else if (req.contentType == 'Asset') {
                            res.assetRecords = [SELECT Id, Name, Description__c, Status__c, Primary_Category__c FROM Asset__c WHERE Id = :req.contentId];
                        }
                        res.success = true;
                        res.message = req.contentType + ' retrieved successfully.';
                    } else {
                        res.message = 'Error: Content ID and Content Type are required for Retrieve.';
                    }
                } else if (req.actionType == 'Search') {
                    handleSoslSearch(req, res);
                } else {
                    res.message = 'Error: Invalid action type. Must be Retrieve or Search.';
                }
            } catch (Exception e) {
                res.message = 'Error: ' + e.getMessage();
            }
            responses.add(res);
        }
        return responses;
    }
    
    private static void handleSoslSearch(Request req, Response res) {
        if (String.isBlank(req.searchKeyword)) {
            res.message = 'Error: A search keyword is required for Search actions.';
            res.success = false;
            return;
        }

        String searchString = req.searchKeyword;
        if(!searchString.contains('*')) {
            searchString += '*'; 
        }
        
        String whereClause = buildWhereClause(req);
        String soslQuery = 'FIND :searchString IN ALL FIELDS RETURNING ' +
                           'Curriculum__c (Id, Name, Description__c, Status__c, Primary_Category__c, Content_Owner_Organization__c ' + whereClause + '), ' +
                           'Course__c (Id, Name, Description__c, Status__c, Primary_Category__c, Content_Owner_Organization__c ' + whereClause + '), ' +
                           'Asset__c (Id, Name, Description__c, Status__c, Primary_Category__c, Content_Owner_Organization__c ' + whereClause + ')';
        
        List<List<SObject>> searchResults = Search.query(soslQuery);

        res.curriculumRecords = (List<Curriculum__c>)searchResults[0];
        res.courseRecords = (List<Course__c>)searchResults[1];
        res.assetRecords = (List<Asset__c>)searchResults[2];

        Integer totalRecords = res.curriculumRecords.size() + res.courseRecords.size() + res.assetRecords.size();
        res.success = true;
        res.message = 'Search completed. Found ' + totalRecords + ' records.';
    }

    private static String buildWhereClause(Request req) {
        List<String> conditions = new List<String>();
        if (String.isNotBlank(req.status)) conditions.add('Status__c = \'' + String.escapeSingleQuotes(req.status) + '\'');
        if (String.isNotBlank(req.primaryCategory)) conditions.add('Primary_Category__c = \'' + String.escapeSingleQuotes(req.primaryCategory) + '\'');
        if (String.isNotBlank(req.contentOwnerOrg)) conditions.add('Content_Owner_Organization__c = \'' + String.escapeSingleQuotes(req.contentOwnerOrg) + '\'');
        if (String.isNotBlank(req.createdById)) conditions.add('CreatedById = \'' + String.escapeSingleQuotes(req.createdById) + '\'');
        if (String.isNotBlank(req.lastModifiedById)) conditions.add('LastModifiedById = \'' + String.escapeSingleQuotes(req.lastModifiedById) + '\'');
        if (String.isNotBlank(req.createdDate)) conditions.add(GAFRA2Utility.parseDateFilter('CreatedDate', req.createdDate));
        if (String.isNotBlank(req.lastModifiedDate)) conditions.add(GAFRA2Utility.parseDateFilter('LastModifiedDate', req.lastModifiedDate));
        
        if (conditions.isEmpty()) return '';
        else return 'WHERE ' + String.join(conditions, ' AND ');
    }
}