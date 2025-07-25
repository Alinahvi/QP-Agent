public with sharing class WorkService {
    //Updates the field that runs the progress bar on Epic, which in turn triggers the progress bar update on Project.
    public static void updateProgress (Id Epic) {
        list<agf__ADM_Epic__c> EpicList = new List <agf__ADM_Epic__c>();
		for(AggregateResult aRes : [SELECT Count(Id) Closed, agf__Status__c, agf__Epic__c FROM agf__ADM_Work__c WHERE agf__Epic__c = :Epic AND agf__Status__c = 'Closed' GROUP BY agf__Status__c, agf__Epic__c]){
            Integer Total = [SELECT Count() FROM agf__ADM_Work__c WHERE agf__Epic__c = :Epic AND agf__Status__c != 'Never' AND agf__Status__c != 'Duplicate'];
            EpicList.add(new agf__ADM_Epic__c(Id = (Id)aRes.get('agf__Epic__c'), Percent_Complete__c = ((Decimal)aRes.get('Closed')/Total)*100));
        }
        try{
        	Update EpicList;
    	}catch(DmlException de){
        	System.debug(de);
    	}
    }
    
    //Fills in the Project field based on the Project assigned to the Epic on a new Work item.
    public static void fillProject (Id Epic, Id Work) {
        list<agf__ADM_Work__c> WorkList = new List <agf__ADM_Work__c>();
        if(Epic != NULL){
            agf__ADM_Epic__c seeProj = [SELECT Id, agf__Project__c FROM agf__ADM_Epic__c WHERE Id = :Epic];
            WorkList.add(new agf__ADM_Work__c(
                Id = Work,
                Project__c = seeProj.agf__Project__c
            ));
            try{
                Update WorkList;
            }catch(DmlException de){
                System.debug(de);
            }
        }
    }
    
    //This updates the project if the Epic gets changed post-insert
    public static void updateProject (Id Epic, agf__ADM_Work__c Work) {
        agf__ADM_Epic__c seeProj = [SELECT Id, agf__Project__c FROM agf__ADM_Epic__c WHERE Id = :Epic];
        Work.Project__c = seeProj.agf__Project__c;
    }
    
    //Sets the start date of a Work Item due to a status change away from New
    public static void setWorkStart (agf__ADM_Work__c Work) {
        //if(Work.Work_Started__c == FALSE){
        	Work.Start_Date__c = system.Today();
        	Work.Work_Started__c = TRUE;
        //}
    }
    
    //Sets the end date of a Work Item due to a status change to Closed
    public static void setWorkEnd (agf__ADM_Work__c Work) {
        Work.Due_Date__c = system.Today();
    }
}