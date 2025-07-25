public with sharing class SessionCloneAction {
    
    @AuraEnabled
    public static String getSession(String sessionId) {
        ResponseData rd = new ResponseData();        
        try {
            Session__c session = [SELECT Id, Name, Session_Type__c, Physical_Capacity__c, Virtual_Capacity__c, Status__c, Start_Date__c, 
                                         Start_Time__c, End_Date__c, End_Time__c, Time_Zone__c,Learner_Instructions__c, 
                                         Zoom_Type__c, Zoom_Session_Id__c, Zoom_Occurrence_Id__c, Virtual_Type__c, 
                                         Asset__c, Asset__r.Name, Objective__c, Description__c, Session_Group__c, Total_Capacity__c, Physical_Registered_Guests__c, Virtual_Registered_Guests__c,
                                         Registered_Guests__c, Start_Time_Converted__c, End_Time_Converted__c, Owner.Name, Address__c, City__c,
                                         Country__c, Zip_Code__c, Url__c, Office_Location__r.Name, Office_Location__r.Address__c, Office_Location__r.City__c, Office_Location__r.Country__c,
                                         Office_Location__r.Postal_Code__c, Region__c, Room__c, Floor__c, Location__c
                                  FROM Session__c
                                  WHERE Id =: sessionId
                                  WITH USER_MODE]; 
            rd.put('session', session);            
        } catch (Exception e) {
            rd.addError(e);
        } 
        return rd.getJsonString();
    }   

}