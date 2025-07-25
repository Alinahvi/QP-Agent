//Id batchJobId = Database.executeBatch(new ProvisionLJBatch1('updateSTables'), 10);
global class ProvisionLJBatch1 implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    global final String Query;
    global final String ljAction;
    boolean Assign_LJ_License=false;
    boolean Assign_Lurniture_Object=false;
    boolean Assign_PermissionSets=false;
    boolean isComplete=false;
    String myMessage='';
    User baseUser;
    
     @AuraEnabled
     public static void fireBatchJob(){
       Database.executeBatch(new ProvisionLJBatch1('updateSTables'), 10);
     }
    // List<AutoProvisionLJ__c> listAutoProvisionLJ = new List<AutoProvisionLJ__c>();
    global ProvisionLJBatch1(String action){
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
        ProvisionLJ myPLJ = new ProvisionLJ();
        System.debug('Records to Process: '+scope.size());
        for (sObject objScope: scope) {
            AutoProvisionLJ__c APLJObjScope = (AutoProvisionLJ__c)objScope ;
            try {  
                baseUser = myPLJ.getUserData(APLJObjScope.emailAddress__c);
                if (baseUser!=null){
                    Assign_LJ_License=myPLJ.assignLJlicense(baseUser);
                    Assign_PermissionSets=myPLJ.assignPermSets(baseUser);
                    System.debug('Assign License ---------------- '+Assign_LJ_License);
                    System.debug('Assign_PermissionSets ---------------- '+Assign_PermissionSets);
                    //Assign_Lurniture_Object=assignLJRoomObject(baseUser);
                    //theAplj = getAutoProvisionObject(Assign_LJ_License,Assign_Lurniture_Object,Assign_PermissionSets,apEntry.emailAddress__c,true,'Valid Email');
                    //theAplj.UserId__c=baseUser.id;
                    //ProvisionLJ.upsertAutoProvisionObject(theAplj);
                }
                
            }
            catch(exception e){
                System.debug('ProvisionLJBatch1 Error : '+e.getMessage());
                //ProvisionLJ.getAutoProvisionObject(Assign_LJ_License,Assign_Lurniture_Object,Assign_PermissionSets,APLJObjScope.emailAddress__c,isComplete,'Error: '+e.getMessage());
                //ProvisionLJ.upsertAutoProvisionObject(theAplj);
            }
        }

    
    
    //if (ljaction.equals('updateSystemTables')){
    //    listAutoProvisionLJ = (List<AutoProvisionLJ__c>) scope;  
    //    ProvisionLJ myPLJ = new ProvisionLJ(listAutoProvisionLJ);
    //    }
    
}//end execute



global void finish(Database.BatchableContext BC){
    System.debug('ProvisionLJBatch1 Finished ....... Call  ProvisionLJBatch2');
    Database.executeBatch(new ProvisionLJBatch2('updateSTables'), 10);
}                 

}