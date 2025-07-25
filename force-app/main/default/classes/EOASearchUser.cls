public with sharing class EOASearchUser {

    // Invocable method to dynamically search User records
    @InvocableMethod(label='GA-EOA Search User Records' description='Dynamically searches User records based on provided search criteria. Supports flexible querying.')
    public static List<EOASearchUserResponse> searchUsers(List<EOASearchUserRequest> requests) {
        List<EOASearchUserResponse> responses = new List<EOASearchUserResponse>();

        for (EOASearchUserRequest request : requests) {
            String query = 'SELECT Id, FirstName, LastName, Email, Username, Title, Department FROM User';
            if (String.isNotBlank(request.criteria)) {
                query += ' WHERE ' + request.criteria;
            }

            List<User> users = Database.query(query);

            EOASearchUserResponse response = new EOASearchUserResponse();
            response.userIds = new List<Id>();
            response.userNames = new List<String>();
            response.emails = new List<String>();
            response.totalUsers = users.size();

            for (User user : users) {
                response.userIds.add(user.Id);
                response.userNames.add(user.FirstName + ' ' + user.LastName);
                response.emails.add(user.Email);
            }

            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOASearchUserRequest {
        @InvocableVariable(label='GA-EOA Search Criteria' required=false description='Dynamic SOQL criteria for searching Users. Example: "LastName LIKE \'%Smith%\'".')
        public String criteria;
    }

    // Response wrapper for invocable method outputs
    public class EOASearchUserResponse {
        @InvocableVariable(label='GA-EOA User IDs' description='List of Salesforce IDs for User records found.')
        public List<Id> userIds;

        @InvocableVariable(label='GA-EOA User Names' description='List of User full names.')
        public List<String> userNames;

        @InvocableVariable(label='GA-EOA Emails' description='List of User email addresses.')
        public List<String> emails;

        @InvocableVariable(label='GA-EOA Total Users' description='Total number of User records found.')
        public Integer totalUsers;
    }
}