//Id batchJobId = Database.executeBatch(new ProvisionLJBatch1('updateSystemTables'), 10);
global class ProvisionLJBatch2 implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    global final String Query;
    global final String ljAction;
    boolean Assign_LJ_License=false;
    boolean Assign_Lurniture_Object=false;
    boolean Assign_PermissionSets=false;
    boolean isComplete=false;
    String myMessage='';
    User baseUser;
    ProvisionLJ myPLJ = new ProvisionLJ();
    
    AutoProvisionLJ__c theAplj = new AutoProvisionLJ__c();
    List<AutoProvisionLJ__c> listAutoProvisionLJ = new List<AutoProvisionLJ__c>();
    
    global ProvisionLJBatch2(String action){
        String q = 'Select id,emailAddress__c  from AutoProvisionLJ__c where complete__c !=true '; 

        Query=q;
        ljAction=action;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('query '+query);
        
       
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {  
        
        for (sObject objScope: scope) {
         AutoProvisionLJ__c APLJObjScope = (AutoProvisionLJ__c)objScope ;
         try {  
              Assign_LJ_License=false;
              Assign_Lurniture_Object=false;
              Assign_PermissionSets=false;
              baseUser = myPLJ.getUserData(APLJObjScope.emailAddress__c);
             if (baseUser!=null){               
                 Assign_LJ_License=myPLJ.doesLicenseExist(baseUser);
                 Assign_PermissionSets=myPLJ.checkPermSets(baseUser);
                 Assign_Lurniture_Object=myPLJ.assignLJRoomObject(baseUser);
                 System.debug('Assign License ---------------- '+Assign_LJ_License);
                 System.debug('Assign_PermissionSets ---------------- '+Assign_PermissionSets);
                 System.debug('Assign_Lurniture_Object ---------------- '+Assign_Lurniture_Object);
                 theAplj = myPLJ.getAutoProvisionObject(Assign_LJ_License,Assign_Lurniture_Object,Assign_PermissionSets,APLJObjScope.emailAddress__c,true,'Valid Email');
                 theAplj.UserId__c=baseUser.id;
                 myPLJ.upsertAutoProvisionObject(theAplj);
             }
             else
             {
                 theAplj = myPLJ.getAutoProvisionObject(Assign_LJ_License,Assign_Lurniture_Object,Assign_PermissionSets,APLJObjScope.emailAddress__c,true,'Invalid Email');
                 theAplj.Id=APLJObjScope.id;
                 myPLJ.upsertAutoProvisionObject(theAplj);
             }
        }catch(exception e){
                System.debug('Error : '+e.getMessage());
                theAplj = myPLJ.getAutoProvisionObject(Assign_LJ_License,Assign_Lurniture_Object,Assign_PermissionSets,APLJObjScope.emailAddress__c,isComplete,'Error: '+e.getMessage());
                myPLJ.upsertAutoProvisionObject(theAplj);
            
    }
    
        }
    }
  
    global void finish(Database.BatchableContext BC){
       System.debug('ProvisionLJBatch2 Finished....');
    }                 
  

}