public with sharing class FRAUserLookup {

    /**
     * Invocable method for looking up basic User information using Salesforce User IDs.
     * This action helps replace system user IDs with human-readable user details, such as Name, Username, and Email.
     * @param userLookupRequests List of requests containing User IDs.
     * @return List of UserLookupResponse with essential user details.
     */
    @InvocableMethod(label='GA-FRA User Lookup' description='Retrieves basic user information (Name, Username, Email) based on provided Salesforce User IDs.')
    public static List<UserLookupResponse> getUserDetails(List<UserLookupRequest> userLookupRequests) {

        List<Id> userIds = new List<Id>();
        for (UserLookupRequest req : userLookupRequests) {
            userIds.add(req.userId);
        }

        List<User> users = [SELECT Id, Name, Username, Email FROM User WHERE Id IN :userIds];

        List<UserLookupResponse> responses = new List<UserLookupResponse>();
        for (User usr : users) {
            UserLookupResponse response = new UserLookupResponse();
            response.userId = usr.Id;
            response.name = usr.Name;
            response.username = usr.Username;
            response.email = usr.Email;
            responses.add(response);
        }

        return responses;
    }

    /**
     * Inner class representing request parameters for User Lookup.
     */
    public class UserLookupRequest {
        @InvocableVariable(label='User ID' description='The Salesforce ID of the user to look up.' required=true)
        public Id userId;
    }

    /**
     * Inner class representing the response structure including essential user details.
     */
    public class UserLookupResponse {
        @InvocableVariable(label='User ID' description='The Salesforce ID of the user.')
        public Id userId;

        @InvocableVariable(label='Name' description='Full name of the user.')
        public String name;

        @InvocableVariable(label='Username' description='Username of the user.')
        public String username;

        @InvocableVariable(label='Email' description='Email address of the user.')
        public String email;
    }
}