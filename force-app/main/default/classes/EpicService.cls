public class EpicService {
	//This updates the Project Progress bar
	public static void updateProgress (Id Project) {
        list<agf__PPM_Project__c> ProjectList = new List <agf__PPM_Project__c>();
        for(AggregateResult aRes : [SELECT Count(Id) Closed, agf__Health__c, agf__Project__c FROM agf__ADM_Epic__c WHERE agf__Project__c = :Project AND agf__Health__c = 'Completed' GROUP BY agf__Health__c, agf__Project__c]){
        	Integer Total = [SELECT Count() FROM agf__ADM_Epic__c WHERE agf__Project__c = :Project AND agf__Health__c != 'Canceled'];
        	ProjectList.add(new agf__PPM_Project__c(Id = (Id)aRes.get('agf__Project__c'), Percent_Complete__c = ((Decimal)aRes.get('Closed')/Total)*100));
        }
        try{
            Update ProjectList;
        }catch(DmlException de){
            System.debug(de);
        }
    }
    
    //This updates the Epic Start date and sets Epic Started? to True in a before update
    public static void epicStart (agf__ADM_Epic__c Epic) {
        List<agf__ADM_Work__c> WorkItems = [SELECT Id, Work_Started__c FROM agf__ADM_Work__c WHERE agf__Epic__c = :Epic.Id];
        for(agf__ADM_Work__c W : WorkItems) {
            if(W.Work_Started__c == TRUE) {
                Epic.agf__Start_Date__c = system.Today();
        		Epic.Epic_Started__c = TRUE;
            }
        }
    }
    
    //This updates the Epic Start date and sets Epic Started? to True in a before update
    public static void epicStartFromWork (Id Epic) {
        agf__ADM_Epic__c EpicCheck = [SELECT Id, Name, Epic_Started__c, agf__Start_Date__c FROM agf__ADM_Epic__c WHERE Id = :Epic];
        if (EpicCheck.Epic_Started__c == FALSE) {    
        	List<agf__ADM_Work__c> WorkItems = [SELECT Id, Work_Started__c FROM agf__ADM_Work__c WHERE agf__Epic__c = :Epic];
            for(agf__ADM_Work__c W : WorkItems) {
                if(W.Work_Started__c == TRUE) {
                    EpicCheck.agf__Start_Date__c = system.Today();
                    EpicCheck.Epic_Started__c = TRUE;
                }
            }
            try{
                Update EpicCheck;
            }catch(DmlException de){
                System.debug(de);
            }
        }
    }
    
    //This updates the Epic End date
    public static void epicEnd (agf__ADM_Epic__c Epic) {
        Epic.agf__End_Date__c = system.Today();
        if(Epic.Epic_Started__c == FALSE) Epic.Epic_Started__c = TRUE;
        
    }
    
}