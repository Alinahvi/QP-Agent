public with sharing class MembershipStatusHelper {
    public static void updateMembershipStatus(List<Learner_Profile__c> lpList, Map<Id, Learner_Profile__c> oldValues) {
//         Set<Id> changedLPs = new Set<Id>();
//         Map<Id, Set<String>> membershipsAdded = new Map<Id, Set<String>>();
//         Map<Id, Set<String>> membershipsRemoved = new Map<Id, Set<String>>();

// /*
// This trigger adds or updates a Learner Profile's Membership Status based on changes to the multi-select picklist 
// of memberships. If an item is no longer selected on the picklist it will fill in the end date so that they can be filtered
// out of that academy.
// */
//         for(Learner_Profile__c LP: lpList) {
//             //Get oldMap for comparison 
//             Learner_Profile__c oldLP = oldValues.get(LP.Id);
//             //See if there are membership changes
//             if(LP.Membership__c != oldLP.Membership__c) {
//                 changedLPs.add(LP.Id);
                
//                 //Get Trigger.new and Trigger.oldmap picklist values and store them here.
//                 Set<String> newMemberships = new Set<String>();
//                 Set<String> oldMemberships = new Set<String>();

//                 //Split on ; as its a multi-select picklist.
//                 if(LP.Membership__c != null) {
//                     newMemberships = new Set<String>(LP.Membership__c.split(';'));
//                 }
//                 if(oldLP.Membership__c != null) {
//                     oldMemberships = new Set<String>(oldLP.Membership__c.split(';'));
//                 }

//                 // Determine which memberships were added and removed by utilizing removeAll()
//                 Set<String> added = new Set<String>(newMemberships);
//                 added.removeAll(oldMemberships);

//                 Set<String> removed = new Set<String>(oldMemberships);
//                 removed.removeAll(newMemberships);

//                 //Put the added and removed memeberships into the Global
//                 if (!added.isEmpty()) {
//                     membershipsAdded.put(LP.Id, added);
//                 }
//                 if (!removed.isEmpty()) {
//                     membershipsRemoved.put(LP.Id, removed);
//                 }
//             }
//         }
//         //Only run if there are elements in changedLPs
//         if(!changedLPs.isEmpty()) {
//             //Query the MembershipStatus__c records that exist for the Learner Profiles
//             List<Membership_Status__c> statusRecords = [
//                 SELECT Id, Name, Start_Date__c, End_Date__c, Learner_Profile__c
//                 FROM Membership_Status__c
//                 WHERE Learner_Profile__c IN: changedLPs];
            
//             //Put results in a Map so you can reference Membership Status by the Learner Profile ID
//             Map<String, Membership_Status__c> membershipStatusMap = new Map<String, Membership_Status__c>();
//             for (Membership_Status__c ms : statusRecords) {
//                 membershipStatusMap.put(ms.Learner_Profile__c + '-' + ms.Name, ms);
//             }

//             // List to collect records to upsert
//             List<Membership_Status__c> memsToUpsert = new List<Membership_Status__c>();

//             // Handle added
//             for (Id lpId : membershipsAdded.keySet()) {
//                 for (String membership : membershipsAdded.get(lpId)) {
//                     String key = lpId + '-' + membership;
//                     Membership_Status__c ms = membershipStatusMap.get(key);
//                     /** First part evaluates if nothing existed. The second part of the OR evaluates
//                     if a previous record existed, and contained an End Date, create an entirely new record with a new start date.
//                     */
//                     if (ms == null || ms.End_Date__c != null) {
//                         // Create net-new Membership_Status__c record
//                         ms = new Membership_Status__c(
//                             Learner_Profile__c = lpId,
//                             Name = membership,
//                             Start_Date__c = Date.today()
//                         );
//                         memsToUpsert.add(ms);
//                     }
//                 }
//             }

//             // Handle removed
//             for (Id lpId : membershipsRemoved.keySet()) {
//                 for (String membership : membershipsRemoved.get(lpId)) {
//                     String key = lpId + '-' + membership;
//                     Membership_Status__c ms = membershipStatusMap.get(key);

//                     if (ms != null && ms.End_Date__c == null) {
//                         // Set End_Date__c for the removed service
//                         ms.End_Date__c = Date.today();
//                         memsToUpsert.add(ms);
//                     }
//                 }
//             }

//             if (!memsToUpsert.isEmpty()) {
//                 try{
//                     upsert memsToUpsert;
//                 }catch(DmlException de){
//                     System.debug(de);
//                 }
//             }
//         }
    }

    public static void assignTimezones(List<Learner_Profile__c> lpList, Map<Id, Learner_Profile__c> oldValues) {
        // I used Custom Metadata to map region and timezone
        List<Timezone_Mapping__mdt> mappings = [SELECT Region__c, Timezone__c FROM Timezone_Mapping__mdt];
    
        Map<String, String> regionToTimezoneMap = new Map<String, String>();
    
        for (Timezone_Mapping__mdt mapping : mappings) {
            regionToTimezoneMap.put(mapping.Region__c, mapping.Timezone__c);
        }

        for(Learner_Profile__c LP: lpList) {
            String selectedRegions = LP.Working_Region__c;
            Learner_Profile__c oldRecord = oldValues.get(LP.Id);
            String oldSelectedRegions = oldRecord.Working_Region__c;
            Set<String> selectedTimezones = new Set<String>();
            List<String> regionsList = new List<String>();
            if(selectedRegions != null) {
                 regionsList = selectedRegions.split(';');

                for(String region : regionsList) {
                    if (regionToTimezoneMap.containsKey(region.trim())){
                        String timezones = regionToTimezoneMap.get(region.trim());
                        List<String> timezonesList = timezones.split(';');
                        selectedTimezones.addAll(timezonesList);
                    }
                }
            }
            //This handles the case where someone removes a region and the timezones need to be taken off the LP
            if(oldSelectedRegions != null){
                List<String> oldRegionsList = oldSelectedRegions.split(';');

                for(String oldRegion : oldRegionsList) {
                    if (!regionsList.contains(oldRegion) && regionToTimezoneMap.containsKey(oldRegion.trim())) {
                        String removedTimezones = regionToTimezoneMap.get(oldRegion.trim());
                        List<String> removedTimezonesList = removedTimezones.split(';');
                        
                        for (String removedTimezone : removedTimezonesList) {
                            selectedTimezones.remove(removedTimezone);
                        }
                    }
                }
            }

            LP.Working_Time_Zone__c = String.join(new List<String>(selectedTimezones), ';');
        }
    }
}