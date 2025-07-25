global class provisionLJSchedule implements Schedulable{
    global void execute(SchedulableContext sc) {
        //invoke the batch class
        Database.executeBatch(new ProvisionLJBatch1('updateSTables'), 10);
    }
}