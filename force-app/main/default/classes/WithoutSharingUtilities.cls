public without sharing class WithoutSharingUtilities {
    public WithoutSharingUtilities() {
 
    }

    /*** Used by ZoomAttendanceTracker ***/
    public static sObject findZoomSession(String zoomSessionId){
        List<Session__c> session = [SELECT Id, Process_Zoom_Report__c, Total_Zoom_Report_Retries__c, Zoom_Session_Id__c 
                                    FROM Session__c 
                                    WHERE Zoom_Session_Id__c =: zoomSessionId];

        if(!session.isEmpty()){
            return session.get(0);
        }
        
        /* List<Enablement_Activity__c> ea = [SELECT Id, Process_Zoom_Report__c, Total_Zoom_Report_Retries__c, Zoom_Session_Id__c FROM Enablement_Activity__c WHERE Zoom_Session_Id__c =: sessionId WITH SECURITY_ENFORCED];

        if(!ea.isEmpty()){
            return ea.get(0);
        } */

        return null;
    }

    public static void updateRecords(List<sObject> records){
        update records;
    }

    public static void upsertRecords(List<sObject> records){
        upsert records;
    }
}