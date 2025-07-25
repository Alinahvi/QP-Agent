global class provisionVCSchedule implements Schedulable{
    global void execute(SchedulableContext sc) {
        //invoke the batch class
        Database.executeBatch(new ProvisionVCBatch1('updateSTables'), 10);
    }
}