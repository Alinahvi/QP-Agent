public with sharing class WorkTriggerHandler {
	@TestVisible static Boolean bypassTrigger = false;
    
    final List<agf__ADM_Work__c> newRecords;
    final Map<Id, agf__ADM_Work__c> oldMap;
    public WorkTriggerHandler(List<agf__ADM_Work__c> newRecords, Map<Id, agf__ADM_Work__c> oldMap) {
        this.newRecords = newRecords;
        this.oldMap = oldMap;
    }
    
    public void afterInsert(){
        if (bypassTrigger) return;
        for(agf__ADM_Work__c W : newRecords) {
            //if (W.Built_From_Template__c) return;
            if (W.agf__Epic__c != NULL && W.Built_From_Template__c == FALSE) WorkService.updateProgress(W.agf__Epic__c);
            if (W.Project__c == NULL) WorkService.fillProject(W.agf__Epic__c, W.Id);
        }
    }
    
    public void beforeUpdate(){
        if (bypassTrigger) return;
        for(agf__ADM_Work__c W : newRecords) {
        	agf__ADM_Work__c oldW = oldMap.get(W.Id);
            if(W.agf__Status__c != oldW.agf__Status__c && W.agf__Status__c != 'New' && W.agf__Status__c != 'Never' && W.agf__Status__c != 'Duplicate' && W.Work_Started__c == FALSE){
                WorkService.setWorkStart(W);
            }
            if(W.agf__Status__c != oldW.agf__Status__c && W.agf__Status__c == 'Closed'){
                WorkService.setWorkEnd(W);
            }
            if(W.agf__Epic__c != oldW.agf__Epic__c) {
                WorkService.updateProject(W.agf__Epic__c, W);
            }
        }
    }
    
    public void afterUpdate(){
        if (bypassTrigger) return;
        for(agf__ADM_Work__c W : newRecords) {
            agf__ADM_Work__c oldW = oldMap.get(W.Id);
            if (W.agf__Epic__c != NULL && W.agf__Status__c != oldW.agf__Status__c) WorkService.updateProgress(W.agf__Epic__c);
            if (W.Work_Started__c != oldW.Work_Started__c) {
                EpicService.epicStartFromWork(W.agf__Epic__c);
            }
        }
    }
    
    public void beforeDelete(){
        if (bypassTrigger) return;
    }
    
    public void afterDelete(){
        if (bypassTrigger) return;
        for(agf__ADM_Work__c W : newRecords) {
            agf__ADM_Work__c oldW = oldMap.get(W.Id);
            if (W.agf__Epic__c != NULL && W.agf__Status__c != oldW.agf__Status__c) WorkService.updateProgress(W.agf__Epic__c);
        }
    }
}