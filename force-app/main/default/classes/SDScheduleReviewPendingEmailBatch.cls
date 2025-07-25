global with sharing class SDScheduleReviewPendingEmailBatch implements Schedulable {
    
    public SDScheduleReviewPendingEmailBatch() {

    }

    global void execute(SchedulableContext ctx) {
        SDTriggerReviewPendingEmailBatch emailBatch = new SDTriggerReviewPendingEmailBatch(null); 
        Database.executeBatch(emailBatch,1);
    }

}