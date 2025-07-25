public with sharing class EOARetrieveUserDetails {

    // Invocable method to retrieve User details
    @InvocableMethod(label='GA-EOA Retrieve User Details' description='Retrieves detailed information about a User based on provided User ID. This is a read-only operation.')
    public static List<UserDetailsResponse> retrieveUserDetails(List<UserDetailsRequest> requests) {
        List<UserDetailsResponse> responses = new List<UserDetailsResponse>();

        Set<Id> userIds = new Set<Id>();
        for (UserDetailsRequest request : requests) {
            userIds.add(request.userId);
        }

        List<User> users = [SELECT Id, FirstName, LastName, Email, Username, Title, Department, Profile.Name, IsActive, ManagerId, UserRoleId, MobilePhone, Alias, CompanyName, Division, Employee_ID__c, TimeZoneSidKey FROM User WHERE Id IN :userIds];

        for (User user : users) {
            UserDetailsResponse response = new UserDetailsResponse();
            response.userId = user.Id;
            response.firstName = user.FirstName;
            response.lastName = user.LastName;
            response.email = user.Email;
            response.username = user.Username;
            response.title = user.Title;
            response.department = user.Department;
            response.profileName = user.Profile.Name;
            response.isActive = user.IsActive;
            response.managerId = user.ManagerId;
            response.userRoleId = user.UserRoleId;
            response.mobilePhone = user.MobilePhone;
            response.alias = user.Alias;
            response.companyName = user.CompanyName;
            response.division = user.Division;
            response.employeeId = user.Employee_ID__c;
            response.timeZone = user.TimeZoneSidKey;

            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class UserDetailsRequest {
        @InvocableVariable(label='GA-EOA User ID' required=true description='The Salesforce ID of the User whose details are to be retrieved.')
        public Id userId;
    }

    // Response wrapper for invocable method outputs
    public class UserDetailsResponse {
        @InvocableVariable(label='GA-EOA User ID' description='Salesforce ID of the User.')
        public Id userId;

        @InvocableVariable(label='GA-EOA First Name' description='First name of the User.')
        public String firstName;

        @InvocableVariable(label='GA-EOA Last Name' description='Last name of the User.')
        public String lastName;

        @InvocableVariable(label='GA-EOA Email' description='Email address of the User.')
        public String email;

        @InvocableVariable(label='GA-EOA Username' description='Salesforce Username of the User.')
        public String username;

        @InvocableVariable(label='GA-EOA Title' description='Job title of the User.')
        public String title;

        @InvocableVariable(label='GA-EOA Department' description='Department of the User.')
        public String department;

        @InvocableVariable(label='GA-EOA Profile Name' description='Profile name of the User.')
        public String profileName;

        @InvocableVariable(label='GA-EOA Active Status' description='Indicates if the User is active.')
        public Boolean isActive;

        @InvocableVariable(label='GA-EOA Manager ID' description='Salesforce ID of the User\'s manager.')
        public Id managerId;

        @InvocableVariable(label='GA-EOA User Role ID' description='Salesforce Role ID associated with the User.')
        public Id userRoleId;

        @InvocableVariable(label='GA-EOA Mobile Phone' description='Mobile phone number of the User.')
        public String mobilePhone;

        @InvocableVariable(label='GA-EOA Alias' description='Alias of the User.')
        public String alias;

        @InvocableVariable(label='GA-EOA Company Name' description='Company name associated with the User.')
        public String companyName;

        @InvocableVariable(label='GA-EOA Division' description='Division associated with the User.')
        public String division;

        @InvocableVariable(label='GA-EOA Employee ID' description='Employee ID of the User.')
        public String employeeId;

        @InvocableVariable(label='GA-EOA Time Zone' description='Time zone associated with the User.')
        public String timeZone;
    }
}