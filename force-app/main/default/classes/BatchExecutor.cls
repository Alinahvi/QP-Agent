global with sharing class BatchExecutor implements Schedulable {
    global void execute(SchedulableContext SC) {
        runJob();
    }

    global void runJob() {
        Database.executeBatch(new AudienceMemberCreationBatch(true, new Map<String, String>(), ''), 1);

        // Database.executeBatch(new noSessionReminderBatch(), 200);
        Auth_Setting__c authSettings = Auth_Setting__c.getOrgDefaults();

        // //internal trailhead import modules
        if(String.isNotEmpty(authSettings.Refresh_Token__c)) {
            System.enqueueJob(new trailheadImportModules(0));
        }

        //Back up to restart zoom attendance batch if it fails
        List<CronTrigger> attendanceJob = [SELECT Id, PreviousFireTime, NextFireTime, TimesTriggered, StartTime
                                           FROM CronTrigger
                                           WHERE CronJobDetail.Name =: constants.ZOOM_ATTENDANCE_BATCH_NAME
                                           WITH SECURITY_ENFORCED];

        if(attendanceJob.isEmpty()){
            Database.executeBatch(new zoomAttendanceBatch(false), 1);
        }
    }
}