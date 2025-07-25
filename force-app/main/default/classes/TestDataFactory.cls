@isTest
public class TestDataFactory {

    public static User createUser(String uniqueName) {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        
        User u = new User(
            Alias = uniqueName.substring(0, 8),
            Email = uniqueName + '@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = uniqueName + '@testorg.com'
        );
        return u;
    }

    public static Learner_Profile__c createLearnerProfile(User u, String name, String managerName, Boolean doInsert) {
        Learner_Profile__c lp = new Learner_Profile__c(
            Name = name,
            User__c = u.Id,
            Primary_Email__c = u.Email,
            Manager__c = managerName,
            Business_Unit_Name__c = 'Test BU',
            Division__c = 'Test Division',
            Work_Location_Country__c = 'USA',
            Employee_Number__c = String.valueOf(Math.random() * 100000).substring(0,6)
        );
        
        if (doInsert) {
            insert lp;
        }
        return lp;
    }
}