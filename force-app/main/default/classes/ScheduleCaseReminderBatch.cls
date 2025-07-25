public class ScheduleCaseReminderBatch implements schedulable {
	public void execute(SchedulableContext sc){
     	database.executeBatch(new CaseReminderBatch(), 90);   
    }
}