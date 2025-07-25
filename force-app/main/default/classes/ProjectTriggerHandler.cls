public with sharing class ProjectTriggerHandler {
	@TestVisible static Boolean bypassTrigger = false;
    
    final List<agf__PPM_Project__c> newRecords;
    final Map<Id, agf__PPM_Project__c> oldMap;
    public ProjectTriggerHandler(List<agf__PPM_Project__c> newRecords, Map<Id, agf__PPM_Project__c> oldMap) {
        this.newRecords = newRecords;
        this.oldMap = oldMap;
    }
    
    public void afterInsert(){
        if (bypassTrigger) return;
    }
    
    public void afterUpdate(){
        if (bypassTrigger) return;
    }
    
    public void afterDelete(){
        if (bypassTrigger) return;
    }
    
    public void beforeUpdate(){
        if (bypassTrigger) return;
        for(agf__PPM_Project__c P : newRecords) {
            agf__PPM_Project__c oldP = oldMap.get(P.Id);
            if (P.Project_Started__c == FALSE) {
                ProjectService.projectStart(P);
            }
            if (P.Percent_Complete__c == 100) ProjectService.ProjectEnd(P);
        }
    }
    
    public void beforeDelete(){
        if (bypassTrigger) return;
    }
}