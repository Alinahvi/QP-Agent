public with sharing class newEventOverride {
    @AuraEnabled(cacheable=true)
    public static ResponseData getPicklistValues() {
        ResponseData rd = new ResponseData();
        Schema.DescribeFieldResult fieldResult = Event.Type.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        
        List<PicklistValue> values = new List<PicklistValue>();
        try {
            for (Schema.PicklistEntry entry : picklistEntries) {
                values.add(new PicklistValue(entry.getLabel(), entry.getValue()));
            }
            rd.put('values', values);
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd;
    }

    public class PicklistValue {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }

        public PicklistValue(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    @AuraEnabled
    public static ResponseData createEvent(Map<String, Object> eventDetails) {
        ResponseData rd = new ResponseData();
        try {
            Date startDate = Date.valueOf((String)eventDetails.get('StartDateTime'));
            Date endDate = Date.valueOf((String)eventDetails.get('EndDateTime'));
            

            Event newEvent = new Event();
            newEvent.OwnerId = (String)eventDetails.get('OwnerId');
            newEvent.Type = (String)eventDetails.get('Type');
            newEvent.StartDateTime = DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0));
            newEvent.EndDateTime = DateTime.newInstance(endDate, Time.newInstance(1, 1, 1, 0));
            newEvent.IsAllDayEvent = true;
            newEvent.Subject = (String)eventDetails.get('Type');

            Learner_Profile__c lp = [SELECT Id FROM Learner_Profile__c WHERE User__c = :newEvent.OwnerId LIMIT 1];
            if (lp != null) {
                newEvent.WhatId = lp.Id;
            } else {
                System.debug('No Learner Profile found for this user.');
                rd.addError('No Learner Profile found.');
            }

            insert newEvent;
            rd.put('eventId', newEvent.Id);
            
            
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd;
    }
}