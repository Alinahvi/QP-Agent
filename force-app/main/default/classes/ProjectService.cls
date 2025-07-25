public with sharing class ProjectService {
    //This updates the Project Start Date triggered from Epic
    public static void projectStartFromEpic (Id Project) {
        agf__PPM_Project__c ProjectCheck = [SELECT Id, Name, Project_Started__c, agf__Planned_Start_Date__c FROM agf__PPM_Project__c WHERE Id = :Project];
        if(ProjectCheck.Project_Started__c == FALSE) {
            List<agf__ADM_Epic__c> EpicItems = [SELECT Id, Epic_Started__c FROM agf__ADM_Epic__c WHERE agf__Project__c = :Project];
            for(agf__ADM_Epic__c E : EpicItems) {
                if(E.Epic_Started__c == TRUE) {
                    ProjectCheck.agf__Planned_Start_Date__c = system.Today();
                    ProjectCheck.Project_Started__c = TRUE;
                }
            }
            try{
                Update ProjectCheck;
            }catch(DmlException de){
                System.debug(de);
            }
        }
    }
    
    //This updates the Project End date
    public static void ProjectEnd (agf__PPM_Project__c Project) {
        Project.agf__Planned_End_Date__c = system.Today();
        if(Project.Project_Started__c == FALSE) Project.Project_Started__c = TRUE;
    }
    
    //This updates the Epic Start date and sets Epic Started? to True in a before update
    public static void projectStart (agf__PPM_Project__c Project) {
        List<agf__ADM_Epic__c> EpicItems = [SELECT Id, Epic_Started__c FROM agf__ADM_Epic__c WHERE agf__Project__c = :Project.Id];
        for(agf__ADM_Epic__c E : EpicItems) {
            if(E.Epic_Started__c == TRUE) {
                Project.agf__Planned_Start_Date__c = system.Today();
        		Project.Project_Started__c = TRUE;
            }
        }
    }

}