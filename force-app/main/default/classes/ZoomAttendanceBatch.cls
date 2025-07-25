global with sharing class ZoomAttendanceBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    public Boolean processEvents = false;

    global ZoomAttendanceBatch(Boolean processEvents){
        this.processEvents = processEvents;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        // String objType = processEvents ? 'Enablement_Activity__c' : 'Session__c';
        String queryString = 'SELECT Id, Zoom_Type__c, Zoom_Host_Id__c, Zoom_Session_Id__c, Process_Zoom_Report__c, Total_Zoom_Report_Retries__c' +
                             ' FROM Session__c' +
                             ' WHERE Process_Zoom_Report__c = true' +
                             ' AND (Total_Zoom_Report_Retries__c < 30 OR Total_Zoom_Report_Retries__c = null)' +
                             ' WITH USER_MODE';

        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        ZoomAttendanceBatchHelper.processReport(scope);
    }

    global void finish(Database.BatchableContext BC){
        if(!Test.isRunningTest()){
            List<CronTrigger> attendanceJob = [SELECT Id
                                                FROM CronTrigger
                                                WHERE CronJobDetail.Name =: constants.ZOOM_ATTENDANCE_BATCH_NAME];

            if(attendanceJob.isEmpty()){
                System.scheduleBatch(new ZoomAttendanceBatch(false), constants.ZOOM_ATTENDANCE_BATCH_NAME, 2, 1);
            }
        }
    }
}