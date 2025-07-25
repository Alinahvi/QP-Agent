public with sharing class TempDeactivateRecomm implements Database.Batchable<sObject>, Database.AllowsCallouts{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, Name, User__r.Email, User__r.Org62_User_ID__c, Org62_User_ID__c, Last_Trailhead_Sync__c 
                                        FROM Learner_Profile__c
                                        WHERE Status__c = 'Active'
                                        AND User__r.Org62_User_ID__c != NULL
                                        AND Id != 'a5jHu000001EWkEIAW'
                                        ]);
    }

    public void execute(Database.BatchableContext BC, List<Learner_Profile__c> scope) {
        for(Learner_Profile__c lp : [SELECT Id, Name, User__r.Email, User__r.Org62_User_ID__c, Org62_User_ID__c, Last_Trailhead_Sync__c, 
										(
                                            SELECT Id, Completion_Date__c, Asset__r.Trailhead_Module_Id__c, Completed__c
                                            FROM Assignments__r
                                            WHERE Completed__c = false
                                            AND Asset__r.RecordType.DeveloperName = 'Trailhead_Module'
											AND CreatedDate != today
                                            ORDER BY lastModifiedDate DESC 
                                            LIMIT 1500 
                                        )
									FROM Learner_Profile__c
									WHERE Id IN: scope]) {
		
		}		
    }

    public void finish(Database.BatchableContext BC) {
        // Database.executeBatch(new ThCompletionBatch(), 25);
    }
}
/* public with sharing class TempDeactivateRecomm implements Database.Batchable<sObject>, Database.AllowsCallouts{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, Name, User__r.Email, User__r.Org62_User_ID__c, Org62_User_ID__c, Last_Trailhead_Sync__c, 
                                        (
                                            SELECT Id, Completion_Date__c, Asset__r.Trailhead_Module_Id__c, Completed__c
                                            FROM Assignments__r
                                            WHERE Completed__c = false
                                            AND Asset__r.Trailhead_Module_Id__c != NULL
                                            AND CreatedDate != today
                                            ORDER BY createdDate desc
                                            LIMIT 30
                                        )
                                        FROM Learner_Profile__c
                                        WHERE Status__c = 'Active'
                                        AND User__r.Org62_User_ID__c != NULL
                                        ]);
    }

    public void execute(Database.BatchableContext BC, List<Recommended_Learning__c> scope) {
        
    }

    public void finish(Database.BatchableContext BC) {
        // Database.executeBatch(new ThCompletionBatch(), 25);
    }
} */