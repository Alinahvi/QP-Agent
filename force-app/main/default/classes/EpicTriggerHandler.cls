public with sharing class EpicTriggerHandler {
	@TestVisible static Boolean bypassTrigger = false;
    
    final List<agf__ADM_Epic__c> newRecords;
    final Map<Id, agf__ADM_Epic__c> oldMap;
    public EpicTriggerHandler(List<agf__ADM_Epic__c> newRecords, Map<Id, agf__ADM_Epic__c> oldMap) {
        this.newRecords = newRecords;
        this.oldMap = oldMap;
    }
    
    public void afterInsert(){
        if (bypassTrigger) return;
        for(agf__ADM_Epic__c E : newRecords) {
            //if (E.Built_From_Template__c) return;
            if (E.agf__Project__c != NULL) EpicService.updateProgress(E.agf__Project__c);
        }
    }
    
    public void afterUpdate(){
        if (bypassTrigger) return;
        for(agf__ADM_Epic__c E : newRecords) {
            agf__ADM_Epic__c oldE = oldMap.get(E.Id);
            if (E.agf__Project__c != NULL) EpicService.updateProgress(E.agf__Project__c);
            if (E.Epic_Started__c != oldE.Epic_Started__c) {
                ProjectService.ProjectStartFromEpic(E.agf__Project__c);
            }
        }
    }
    
    public void afterDelete(){
        if (bypassTrigger) return;
        for(agf__ADM_Epic__c E : newRecords) {
            if (E.agf__Project__c != NULL) EpicService.updateProgress(E.agf__Project__c);
        }
    }
    
    public void beforeUpdate(){
        if (bypassTrigger) return;
        for(agf__ADM_Epic__c E : newRecords) {
            agf__ADM_Epic__c oldE = oldMap.get(E.Id);
            if (E.Epic_Started__c == FALSE) {
                EpicService.epicStart(E);
            }
            if (E.Percent_Complete__c == 100) EpicService.epicEnd(E);
        }
    }
    
    public void beforeDelete(){
        if (bypassTrigger) return;
    }
}