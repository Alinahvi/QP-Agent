global class fixIgaPermsBatchSchedule implements Schedulable{
    global void execute(SchedulableContext sc) {
        //invoke the batch class
        Database.executeBatch(new fixIgaPermsBatch('updatePermSetGroup'), 50);
    }
}