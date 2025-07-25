public with sharing class GAEOA2UserHandler {

    public class Request {
        @InvocableVariable(label='GA-EOA2 Action Type' description='Specify the action: Retrieve | Search' required=true)
        public String actionType;
        @InvocableVariable(label='GA-EOA2 User ID' description='Salesforce User record ID. Required for Retrieve action.')
        public String userId;

        // --- Search Fields ---
        @InvocableVariable(label='GA-EOA2 Name' description='Search by first name, last name, or full name.')
        public String name;
        @InvocableVariable(label='GA-EOA2 Email' description='Search by email.')
        public String email;
        @InvocableVariable(label='GA-EOA2 Title' description='Search by title.')
        public String title;
        @InvocableVariable(label='GA-EOA2 Department' description='Search by department.')
        public String department;
        @InvocableVariable(label='GA-EOA2 IsActive' description='Filter by active status.')
        public Boolean isActive;
        @InvocableVariable(label='GA-EOA2 Created Date' description='For search operations. Supported formats: YYYY-MM-DD, YYYY-MM-DD:YYYY-MM-DD, or Salesforce date literals.')
        public String createdDate;
        @InvocableVariable(label='GA-EOA2 Last Modified Date' description='For search operations. Supported formats: YYYY-MM-DD, YYYY-MM-DD:YYYY-MM-DD, or Salesforce date literals.')
        public String lastModifiedDate;
    }

    public class Response {
        @InvocableVariable(label='GA-EOA2 Success' description='True if the operation succeeded.')
        public Boolean success = false;
        @InvocableVariable(label='GA-EOA2 Message' description='Summary of the operation result.')
        public String message = '';
        @InvocableVariable(label='GA-EOA2 User Records' description='List of User records from the operation.')
        public List<User> userRecords = new List<User>();
    }

    @InvocableMethod(label='GA-EOA2 Manage Users' description='Handles Retrieve and Search actions for User records.')
    public static List<Response> manageUsers(List<Request> requests) {
        Set<Id> idsToRetrieve = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            responseMap.put(i, new Response());
            Request req = requests.get(i);
            
            switch on req.actionType {
                when 'Retrieve' {
                    if (String.isBlank(req.userId)) {
                        responseMap.get(i).message = 'Error: User ID is required for Retrieve.';
                    } else {
                        idsToRetrieve.add(req.userId);
                    }
                }
                when 'Search' {
                    handleSearch(req, responseMap.get(i));
                }
                when else {
                    responseMap.get(i).message = 'Error: Invalid action type specified. Only Retrieve and Search are supported for Users.';
                }
            }
        }
        
        if (!idsToRetrieve.isEmpty()) {
            Map<Id, User> usersFromDb = new Map<Id, User>([
                SELECT Id, Username, LastName, FirstName, Name, CompanyName, Division, Department, Title, Street, City, State, PostalCode, Country, Email, Phone, Fax, MobilePhone, IsActive, ProfileId, UserRoleId 
                FROM User WHERE Id IN :idsToRetrieve
            ]);

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                Response res = responseMap.get(i);
                if (req.actionType == 'Retrieve' && String.isNotBlank(req.userId) && usersFromDb.containsKey(req.userId)) {
                    res.success = true;
                    res.message = 'User retrieved successfully.';
                    res.userRecords.add(usersFromDb.get(req.userId));
                }
            }
        }
        
        return new List<Response>(responseMap.values());
    }

    private static void handleSearch(Request req, Response res) {
        String soql = 'SELECT Id, Username, LastName, FirstName, Name, CompanyName, Division, Department, Title, Street, City, State, PostalCode, Country, Email, Phone, Fax, MobilePhone, IsActive, ProfileId, UserRoleId FROM User';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.name)) {
            conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(req.name) + '%\'');
        }
        if (String.isNotBlank(req.email)) {
            conditions.add('Email LIKE \'%' + String.escapeSingleQuotes(req.email) + '%\'');
        }
        if (String.isNotBlank(req.title)) {
            conditions.add('Title LIKE \'%' + String.escapeSingleQuotes(req.title) + '%\'');
        }
        if (String.isNotBlank(req.department)) {
            conditions.add('Department LIKE \'%' + String.escapeSingleQuotes(req.department) + '%\'');
        }
        if (req.isActive != null) {
            conditions.add('IsActive = ' + req.isActive);
        }
        if (String.isNotBlank(req.createdDate)) {
            String dateCondition = GAFRA2Utility.parseDateFilter('CreatedDate', req.createdDate);
            if(String.isNotBlank(dateCondition)) {
                conditions.add(dateCondition);
            }
        }
        if (String.isNotBlank(req.lastModifiedDate)) {
            String dateCondition = GAFRA2Utility.parseDateFilter('LastModifiedDate', req.lastModifiedDate);
            if(String.isNotBlank(dateCondition)) {
                conditions.add(dateCondition);
            }
        }
        
        if (!conditions.isEmpty()) {
            soql += ' WHERE ' + String.join(conditions, ' AND ');
        }
        soql += ' ORDER BY LastModifiedDate DESC LIMIT 500';

        try {
            res.userRecords = Database.query(soql);
            res.success = true;
            res.message = 'User search executed. Records found: ' + res.userRecords.size();
        } catch (Exception e) {
            res.message = 'Error during User search: ' + e.getMessage();
        }
    }
}