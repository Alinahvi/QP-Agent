public with sharing class IntakeHistoryTriggerHandler {
	@TestVisible static Boolean bypassTrigger = false;
    
    final List<ENB_Intake__c> newRecords;
    final Map<Id, ENB_Intake__c> oldMap;
    public IntakeHistoryTriggerHandler(List<ENB_Intake__c> newRecords, Map<Id, ENB_Intake__c> oldMap) {
        this.newRecords = newRecords;
        this.oldMap = oldMap;
    }
    
    public void afterInsert(){
        if (bypassTrigger) return;
        for(ENB_Intake__c I : newRecords) {
            if (I.Name != NULL) IntakeHistoryService.CreateIntakeHistory(I.Id);
        }
    }
    
    public void afterUpdate(){
        if (bypassTrigger) return;
        for(ENB_Intake__c I : newRecords) {
            System.debug(oldMap.get(I.Id).Intake_Status__c + ' ' + I.Intake_Status__c);
            if (oldMap.get(I.Id).Intake_Status__c == 'New' && I.Intake_Status__c != 'New') IntakeHistoryService.CreateIntakeHistoryWithDayCount(I.ID);
            else if (I.Decision_Reason__c != NULL) IntakeHistoryService.CreateIntakeHistory(I.Id);
        }
    }
    
    public void afterDelete(){
        if (bypassTrigger) return;
    }
    
    public void beforeUpdate(){
        if (bypassTrigger) return;
    }
    
    public void beforeDelete(){
        if (bypassTrigger) return;
    }
}