/**
 * User information utility for the Field Readiness Agent
 * 
 * This class provides utilities for retrieving and managing user information
 * within the Field Readiness Agent application.
 * 
 * Key Features:
 * - Current user information retrieval
 * - User profile and permission checking
 * - User context management
 * 
 * @author Field Readiness Agent Team
 * @version 2.0
 */
public with sharing class FRAGENTUserInfo {

    /**
     * Retrieves information for the currently logged-in user.
     * 
     * This method queries the current user's record and returns key details
     * including profile, role, and contact information. It supports bulk
     * operations by accepting a list of dummy inputs and returning a response
     * for each input.
     * 
     * @param dummyInputs List of dummy strings to trigger the operation (one per request)
     * @return List<UserInfoResponse> List of user information responses
     */
    @InvocableMethod(label='FRAGENT Get Current User Information' description='Retrieves key details for the currently logged-in user.')
    public static List<UserInfoResponse> getUserInfo(List<String> dummyInputs) {
        
        // Query current user information with profile and role details
        User currentUser = [SELECT Id, Username, FirstName, LastName, Name, Email, Profile.Name, UserRole.Name, IsActive 
                          FROM User 
                          WHERE Id = :UserInfo.getUserId() 
                          LIMIT 1];
        
        List<UserInfoResponse> responses = new List<UserInfoResponse>();

        // Process each dummy input to create a response (supports bulk operations)
        for (String dummyInput : dummyInputs) {
            UserInfoResponse res = new UserInfoResponse();
            
            // Populate response with user information
            res.userId = currentUser.Id;
            res.username = currentUser.Username;
            res.firstName = currentUser.FirstName;
            res.lastName = currentUser.LastName;
            res.fullName = currentUser.Name;
            res.email = currentUser.Email;
            res.profileName = currentUser.Profile.Name;
            res.roleName = currentUser.UserRole != null ? currentUser.UserRole.Name : null;
            res.isActive = currentUser.IsActive;
            
            responses.add(res);
        }

        return responses;
    }

    /**
     * Response wrapper class containing user information details.
     * 
     * This class provides a standardized format for returning user information
     * to Einstein GPT agents. Each field includes detailed descriptions for
     * agent understanding.
     */
    public class UserInfoResponse {
        @InvocableVariable(label='User ID' description='The Salesforce ID of the user.')
        public String userId;

        @InvocableVariable(label='Username' description='The username of the user.')
        public String username;

        @InvocableVariable(label='First Name' description='The first name of the user.')
        public String firstName;

        @InvocableVariable(label='Last Name' description='The last name of the user.')
        public String lastName;

        @InvocableVariable(label='Full Name' description='The full name of the user.')
        public String fullName;

        @InvocableVariable(label='Email' description='The email address of the user.')
        public String email;

        @InvocableVariable(label='Profile Name' description='The name of the user\'s profile.')
        public String profileName;

        @InvocableVariable(label='Role Name' description='The name of the user\'s role.')
        public String roleName;

        @InvocableVariable(label='Is Active' description='Indicates if the user is active.')
        public Boolean isActive;
    }
}