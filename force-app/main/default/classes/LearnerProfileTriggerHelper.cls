public with sharing class LearnerProfileTriggerHelper {
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