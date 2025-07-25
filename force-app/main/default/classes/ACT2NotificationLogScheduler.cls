global class ACT2NotificationLogScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
      	GetNotificationLogs.triggerLogService();       
  	}
}