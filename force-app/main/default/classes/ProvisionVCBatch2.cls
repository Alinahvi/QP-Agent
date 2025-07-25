//Id batchJobId = Database.executeBatch(new ProvisionVCBatch1('updateSystemTables'), 10);
global class ProvisionVCBatch2 implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    global final String Query;
    global final String ljAction;
   
    boolean Assign_PermissionSets=false;
    boolean isComplete=false;
    String myMessage='';
    User baseUser;
    ProvisionVC myPVC = new ProvisionVC();
    
    AutoProvisionLJ__c theAplj = new AutoProvisionLJ__c();
    List<AutoProvisionLJ__c> listAutoProvisionLJ = new List<AutoProvisionLJ__c>();
    
    global ProvisionVCBatch2(String action){
        String q = 'Select id,emailAddress__c  from AutoProvisionLJ__c where complete__c !=true '; 

        Query=q;
        ljAction=action;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        //System.debug('query '+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {  
        
        for (sObject objScope: scope) {
         AutoProvisionLJ__c APLJObjScope = (AutoProvisionLJ__c)objScope ;
         try {  
              
              Assign_PermissionSets=false;
              baseUser = myPVC.getUserData(APLJObjScope.emailAddress__c);
             if (baseUser!=null){               
                
                 Assign_PermissionSets=myPVC.checkPermSets(baseUser);
                              
                // System.debug('Assign_PermissionSets ---------------- '+Assign_PermissionSets);
                
                 theAplj = ProvisionVC.getAutoProvisionObject(Assign_PermissionSets,APLJObjScope.emailAddress__c,true,'Valid Email');
                 theAplj.UserId__c=baseUser.id;
                 ProvisionVC.upsertAutoProvisionObject(theAplj);
             }
             else
             {
                 theAplj = ProvisionVC.getAutoProvisionObject(Assign_PermissionSets,APLJObjScope.emailAddress__c,true,'Invalid Email');
                 theAplj.Id=APLJObjScope.id;
                 ProvisionVC.upsertAutoProvisionObject(theAplj);
             }
        }catch(exception e){
                System.debug('Error : '+e.getMessage());
                theAplj = ProvisionVC.getAutoProvisionObject(Assign_PermissionSets,APLJObjScope.emailAddress__c,isComplete,'Error: '+e.getMessage());
                ProvisionVC.upsertAutoProvisionObject(theAplj);
            
    }
    
        }
    }
  
    global void finish(Database.BatchableContext BC){
       System.debug('ProvisionVCBatch2 Finished....');
    }                 
  

}