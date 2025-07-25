public with sharing class GAFRA2UserInfo {

    @InvocableMethod(label='GA-FRA2 Get Current User Information' description='Retrieves key details for the currently logged-in user.')
    public static List<UserInfoResponse> getUserInfo(List<String> dummyInputs) {
        
        User currentUser = [SELECT Id, Username, FirstName, LastName, Name, Email, Profile.Name, UserRole.Name, IsActive 
                          FROM User 
                          WHERE Id = :UserInfo.getUserId() 
                          LIMIT 1];
        
        List<UserInfoResponse> responses = new List<UserInfoResponse>();

        // The input list is just a trigger; we loop to create a response for each request.
        for (String dummyInput : dummyInputs) {
            UserInfoResponse res = new UserInfoResponse();
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