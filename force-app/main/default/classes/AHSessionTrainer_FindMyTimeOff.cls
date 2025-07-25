public with sharing class AHSessionTrainer_FindMyTimeOff {

    public class FindTimeOffRequest {
        @InvocableVariable(label='Start Request')
        public Boolean startRequest;
    }

    @InvocableMethod(label='AHSessionTrainer - Find My Time Off' description='Finds all future time-off entries for the current user.' category='AHSessionTrainer')
    public static List<List<Availability__c>> findMyTimeOff(List<FindTimeOffRequest> requests) {
        Id userProfileId;
        try {
            userProfileId = [SELECT Id FROM Learner_Profile__c WHERE User__c = :UserInfo.getUserId() LIMIT 1].Id;
        } catch (Exception e) {
            // If no profile exists, return an empty list.
            return new List<List<Availability__c>>{new List<Availability__c>()};
        }

        List<String> timeOffTypes = new List<String>{'PTO', 'VTO', 'No Travel Days', 'Other'};
        
        List<Availability__c> upcomingTimeOff = [
            SELECT Id, Type__c, Start_Date__c, End_Date__c, All_Day_Event__c
            FROM Availability__c
            WHERE Learner_Profile__c = :userProfileId
              AND End_Date__c >= TODAY
              AND Type__c IN :timeOffTypes
            ORDER BY Start_Date__c
        ];

        return new List<List<Availability__c>>{upcomingTimeOff};
    }
}