//Id batchJobId = Database.executeBatch(new ProvisionVCBatch1('updateSTables'), 20);
global class ProvisionVCBatch1 implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    global final String Query;
    global final String ljAction;
    boolean Assign_PermissionSets=false;
    boolean isComplete=false;
    String myMessage='';
    User baseUser;
    //
    @AuraEnabled
    public static void fireBatchJob(){
      Database.executeBatch(new ProvisionVCBatch1('updateSTables'), 10);
    }

    global ProvisionVCBatch1(String action){
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
        AutoProvisionLJ__c theAplj = new AutoProvisionLJ__c();
        ProvisionVC myPVC = new ProvisionVC();
        System.debug('Records to Process: '+scope.size());
        for (sObject objScope: scope) {
            AutoProvisionLJ__c APLJObjScope = (AutoProvisionLJ__c)objScope ;
            try {  
                baseUser = myPVC.getUserData(APLJObjScope.emailAddress__c);
                if (baseUser!=null){
               
                    Assign_PermissionSets=myPVC.assignPermSets(baseUser);
                   
                    System.debug('Assign_PermissionSets ---------------- '+Assign_PermissionSets);
                    
                    //theAplj=ProvisionVC.getAutoProvisionObject(Assign_PermissionSets,APLJObjScope.emailAddress__c,true,'Valid Email');
                   // theAplj.UserId__c=baseUser.id;
                   // ProvisionVC.upsertAutoProvisionObject(theAplj);
                }
                 else
                {
                // theAplj=ProvisionVC.getAutoProvisionObject(Assign_PermissionSets,APLJObjScope.emailAddress__c,true,'Error: User Not Found');
                // ProvisionVC.upsertAutoProvisionObject(theAplj);
                }
            }
            catch(exception e){
                System.debug('ProvisionVCBatch1 Error : '+e.getMessage());
               //theAplj=ProvisionVC.getAutoProvisionObject(Assign_PermissionSets,APLJObjScope.emailAddress__c,false,e.getMessage());
                // ProvisionVC.upsertAutoProvisionObject(theAplj);
            }
        }

    
    
    //if (ljaction.equals('updateSystemTables')){
    //    listAutoProvisionLJ = (List<AutoProvisionLJ__c>) scope;  
    //    ProvisionLJ myPLJ = new ProvisionLJ(listAutoProvisionLJ);
    //    }
    
}//end execute



global void finish(Database.BatchableContext BC){
    System.debug('ProvisionVCBatch1 Finished .........');
    Database.executeBatch(new ProvisionVCBatch2('updateSTables'), 20);
}                 

}