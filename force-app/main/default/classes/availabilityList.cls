public with sharing class availabilityList {
    
    @AuraEnabled // (cacheable=true)
    public static ResponseData getData(){
        ResponseData rd = new ResponseData();
        
        try {
            String userId = UserInfo.getUserId();
            List<Learner_Profile__c> lP = [SELECT Id, Name FROM Learner_Profile__c WHERE User__c =: userId LIMIT 1];
            List<Availability__c> availability = [SELECT Id, Start_Date__c, End_Date__c, All_Day_Event__c, Learner_Profile__c, Name, Session__c, Type__c
                                                    FROM Availability__c 
                                                    WHERE Learner_Profile__r.User__c =: userId
                                                    AND End_Date__c >= TODAY
                                                    AND Type__c != 'Session'
                                                    ORDER BY Start_Date__c ASC];

            rd.put('availabilityData', availability);
            rd.put('currentUser', lP);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled
    public static void deleteAvailabilityRecords(List<Id> availabilityIds) {
        if (availabilityIds != null && !availabilityIds.isEmpty()) {
            try {
                List<Availability__c> recordsToDelete = [SELECT Id FROM Availability__c WHERE Id IN :availabilityIds AND Session__c = NULL];
                
                delete recordsToDelete;
            } catch (Exception e) {
                throw new AuraHandledException('Error deleting availability records: ' + e.getMessage());
            }
        } else {
            throw new AuraHandledException('No Availability records to delete.');
        }
    }

    @AuraEnabled
    public static void addAvailabilityRecords(DateTime startDate, DateTime endDate, String type, Id learnerProfile) {
        try {
            Availability__c newAvail = new Availability__c();
            newAvail.End_Date__c = endDate;
            newAvail.Start_Date__c = startDate;
            newAvail.Type__c = type;
            newAvail.Learner_Profile__c = learnerProfile;
            newAvail.Name = type;
            newAvail.All_Day_Event__c = false;
            upsert newAvail;
        } catch (Exception e) {
            throw new AuraHandledException('Error adding availability records: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void addAllDayAvailabilityRecords(String startDate, String endDate, String type, Id learnerProfile, Boolean allDay) {
        try {
            Date startDateTransform = Date.valueOf(startDate);
            Date endDateTransform = Date.valueOf(endDate);
            DateTime startDateTime = DateTime.newInstanceGmt(
                startDateTransform.year(),
                startDateTransform.month(),
                startDateTransform.day(),
                0,0,0);
            DateTime endDateTime = DateTime.newInstanceGmt(
                endDateTransform.year(),
                endDateTransform.month(),
                endDateTransform.day(),
                23,59,59);

            System.debug(startDateTime + ' ' + endDateTime);

            Availability__c newAvail = new Availability__c();
            newAvail.Start_Date__c = startDateTime;
            newAvail.End_Date__c = endDateTime;
            newAvail.Type__c = type;
            newAvail.Learner_Profile__c = learnerProfile;
            newAvail.Name = type;
            newAvail.All_Day_Event__c = allDay;
            upsert newAvail;
        } catch (Exception e) {
            throw new AuraHandledException('Error adding availability records: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static DateTime convertToUserTimeZone(DateTime utcDate) {
        Integer userTimeZoneOffset = UserInfo.getTimeZone().getOffset(utcDate);
        Integer userTimeZoneOffsetMins = userTimeZoneOffset / 60000;
        DateTime localDateTime = utcDate.addMinutes(userTimeZoneOffsetMins);
        
        return localDateTime;
    }

    @AuraEnabled(cacheable=true)
    public static ResponseData getPicklistValues() {
        ResponseData rd = new ResponseData();
        List<String> picklistValues = new List<String>();
        try {
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get('Availability__c');
            Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
            Schema.DescribeFieldResult fieldResult = describeResult.fields.getMap().get('Type__c').getDescribe();
            List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
            
            for (Schema.PicklistEntry entry : picklistEntries) {
                if(entry.getLabel() != 'Session') {
                        picklistValues.add(entry.getLabel());                                      
                }
            }
            rd.put('picklist', picklistValues);
            
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd;
    }
}