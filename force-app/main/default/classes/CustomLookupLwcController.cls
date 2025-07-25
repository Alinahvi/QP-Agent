/*
API : 50
Source : lwcFactory.com
*/
public class CustomLookupLwcController {
    // Method to fetch lookup search result   
     @AuraEnabled(cacheable=true)
     public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName) {    
         List < sObject > returnList = new List < sObject > ();
 
         string sWildCardText = '%' + searchKey + '%';
         string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Name Like : sWildCardText order by createdDate DESC LIMIT 5';
         for (sObject obj: database.query(sQuery)) {
             returnList.add(obj);
         }
         return returnList;
     }
     
     // Method to fetch lookup default value 
     @AuraEnabled
     public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
         string sRecId = recordId;    
         string sQuery = 'Select Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
         for (sObject obj: database.query(sQuery)) {
             return obj;
         }
         return null;
     }
     /*
     @AuraEnabled(cacheable = true)
    public static List<slj__enablement_activity__c> getActivity(String recordId) {
        List<slj__enablement_activity__c> eactlist =  [SELECT Name FROM slj__enablement_activity__c WHERE Id = :recordId];
        system.debug('Record '+eactlist);
        return eactlist;
    }
    @AuraEnabled(cacheable = true)
    public static List<slj__Session_Attendance__c> updateAttendance(String eventId,String userId) {
        system.debug('eventid '+eventId+' user '+userId);
        List<slj__Session_Attendance__c> attList =  new List<slj__Session_Attendance__c>(); 
        attList =  [select id , name from slj__Session_Attendance__c  where slj__Learner_Profile__r.slj__User__c='0052E00000LysVEQAZ' and slj__Enablement_Activity__c=:eventId];
        system.debug('Attendance Record '+attList);
        return attList;
    }
    */
     
 }