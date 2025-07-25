global with sharing class sendSurveyEmailScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        runJob();
    }

    global void runJob() {
        Database.executeBatch(new sendSurveyEmailBatch('course'), 20);
    }
}