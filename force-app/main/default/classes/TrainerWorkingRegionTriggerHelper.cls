public with sharing class TrainerWorkingRegionTriggerHelper {

    //add timezones by the region they are in
    
    public static void assignTimezones(List<Trainer_Working_Region__c> newLWRs) {
        // I used Custom Metadata to map region and timezone
        List<Working_Time_Zone__c> workingTZs = [SELECT Id, Name, Api_Name__c FROM Working_Time_Zone__c];
        Map<String, String> tzIdByApiName = new Map<String, String>();

        for(Working_Time_Zone__c wtz : workingTZs) {
            tzIdByApiName.put(wtz.Api_Name__c, wtz.Id);
        }


        List<String> lpIds = new List<String>();

        for(Trainer_Working_Region__c lwr : newLWRs) {
            lpIds.add(lwr.Learner_Profile__c);
        }

        List<Trainer_Working_Time_Zone__c> existingLearnerWorkingTz = [SELECT Id, Name, Working_Time_Zone__r.Api_Name__c 
                                                                       FROM Trainer_Working_Time_Zone__c
                                                                       WHERE Learner_Profile__c =: lpIds];

        Map<String, String> existingLearnerWorkingTzByApiName = new Map<String, String>();

        for(Trainer_Working_Time_Zone__c lwtz : existingLearnerWorkingTz) {
            existingLearnerWorkingTzByApiName.put(lwtz.Working_Time_Zone__r.Api_Name__c, lwtz.Id);
        }

        List<Timezone_Mapping__mdt> mappings = [SELECT Region__c, Timezone__c FROM Timezone_Mapping__mdt];
        Map<String, String> regionToTimezoneMap = new Map<String, String>();
    
        for (Timezone_Mapping__mdt mapping : mappings) {
            regionToTimezoneMap.put(mapping.Region__c, mapping.Timezone__c);
        }

        List<Trainer_Working_Region__c> lwrWithData = [SELECT Id, Learner_Profile__c, Working_Region__c, Working_Region__r.Name 
                                                       FROM Trainer_Working_Region__c 
                                                       WHERE Id IN :newLWRs];

        List<Trainer_Working_Time_Zone__c> lwtzs = new List<Trainer_Working_Time_Zone__c>();

        for(Trainer_Working_Region__c lwr : lwrWithData) {
            String timezones = regionToTimezoneMap.get(lwr.Working_Region__r.Name);
            List<String> timezonesList = timezones.split(';');

            for(String timezone : timezonesList){
                if(existingLearnerWorkingTzByApiName.containsKey(timezone)){
                    continue;
                }

                lwtzs.add(new Trainer_Working_Time_Zone__c(
                    Learner_Profile__c = lwr.Learner_Profile__c, 
                    Working_Time_Zone__c = tzIdByApiName.get(timezone)
                ));
            }
        }

        insert lwtzs;
    }

    //Remove timezones as they leave regions

    public static void removeTimezones(List<Trainer_Working_Region__c> oldLWRs) {
        List<Timezone_Mapping__mdt> mappings = [SELECT Region__c, Timezone__c FROM Timezone_Mapping__mdt];

        Map<String, String> regionToTimezoneMap = new Map<String, String>();
    
        for (Timezone_Mapping__mdt mapping : mappings) {
            regionToTimezoneMap.put(mapping.Region__c, mapping.Timezone__c);
        }

        List<Trainer_Working_Region__c> lwrWithData = [SELECT Id, Learner_Profile__c, Working_Region__c, Working_Region__r.Name 
                                                       FROM Trainer_Working_Region__c 
                                                       WHERE Id IN :oldLWRs];

        List<String> workingTimeZoneKeys = new List<String>();

        for(Trainer_Working_Region__c lwr : lwrWithData) {
            String timezones = regionToTimezoneMap.get(lwr.Working_Region__r.Name);
            List<String> timezonesList = timezones.split(';');

            for(String timezone : timezonesList){
                workingTimeZoneKeys.add(lwr.Learner_Profile__c + timezone);
            }
        }

        System.debug('*************** ' + workingTimeZoneKeys);

        List<Trainer_Working_Time_Zone__c> learnerWorkingTZToDelete = [SELECT Id 
                                                                       FROM Trainer_Working_Time_Zone__c 
                                                                       WHERE Learner_Time_Zone_Key__c IN :workingTimeZoneKeys];
               
        if(!learnerWorkingTZToDelete.isEmpty()){
            delete learnerWorkingTZToDelete;
        }
    }
}