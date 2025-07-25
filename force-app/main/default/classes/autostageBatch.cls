//Id batchJobId = Database.executeBatch(new autostageBatch('updateStage'), 50);
//Id batchJobId = Database.executeBatch(new autostageBatch('updatePermSet'), 50);
//Id batchJobId = Database.executeBatch(new autostageBatch('removeUsersFromPermSet'), 1);



global class autostageBatch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    global final String Query;
    global final String jaAction;
    global  String perm_id;
    global  String perm_to_remove;
    //boolean isComplete=false;
    
    User baseUser;
    // @AuraEnabled
    // public static void fireBatchJob(){
    //   Database.executeBatch(new ProvisionLJBatch1('updateSTables'), 10);
    // }
    // List<AutoProvisionLJ__c> listAutoProvisionLJ = new List<AutoProvisionLJ__c>();
    global autostageBatch(String action){
        String q ='';
        jaAction=action;
        String updated='Updated';
        if (jaAction.equals('updateStage')){
            q = 'Select id, employeenumber__c from autostage__c '; 
            
        }
        else if (jaAction.equals('updatePermSet')){
            q = 'Select id, employeeId__c,username__c from autostage__c where errors__c =\'' + String.escapeSingleQuotes(updated)+'\'';             
        }
        else if (jaAction.equals('removeUsersFromPermSet')){
            q = 'Select id, employeeId__c,username__c from autostage__c where errors__c =\'' + String.escapeSingleQuotes(updated)+'\' limit 1';             
        }
        else{
            system.debug('Error in jaStage action not found');
        }
        Query=q;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('query '+query);
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {  
        autostage__c basestage = new autostage__c();
        List<autostage__c> stagelist = new List<autostage__c>();
        List<User> ulist = new List<User>();
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        PermissionSet ps = getPermSetId('employeemasterJA');
        
        //PermissionSet ps = getPermSetId('Job_Architecture_Admin');
        //EinsteinAnalyticsPlusUser
        perm_id=String.valueof(ps.id);
        
        
        
        System.debug('Records to Process: '+scope.size());
        for (sObject objScope: scope) {
            
            autostage__c stageScope = (autostage__c)objScope ;
            
            if (jaAction.equals('updateStage')){
                try {  
                    baseUser = getUserData(stageScope.employeenumber__c);
                    if (baseUser!=null){
                        stageScope.employeeid__c=baseUser.Id;
                        
                        if (baseUser.Isactive==true){
                            stageScope.errors__c='Updated';
                        }else
                        {
                            stageScope.errors__c='Inactive'; 
                        }
                        
                        System.debug('Stage Employee id ---------------- '+stageScope.employeeid__c);
                        System.debug('Stage Employee number ---------------- '+stageScope.employeenumber__c);
                    }
                    else
                    {
                        stageScope.errors__c='Missing';
                    }
                    
                }
                catch(exception e){
                    System.debug('Runtime error:  autostageBatch updateStage '+e.getMessage());
                    stageScope.errors__c=e.getMessage();
                    update stageScope;
                }
                stagelist.add(stageScope);
            }
            if (jaAction.equals('updatePermSet')){
                try {  
                    
                    if (perm_id != null){
                        if(!doesPermSetExist(stageScope.employeeid__c,perm_id)){
                            PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = perm_id, AssigneeId = stageScope.employeeid__c);
                            permissionSetList.add(psa);
                            System.debug('Stage Employee id ---------------- '+stageScope.employeeid__c);
                        }
                    }else{System.debug('Perm id missing ---------------- ');}
                    
                }
                catch(exception e){
                System.debug('Runtime error:  autostageBatch updatePermSet '+e.getMessage());
            }
          
        } //end if
           
         
           
        }//end for
        
          if (jaAction.equals('removeUsersFromPermSet')){
                try {  
                   
                        perm_to_remove='employeemasterJA';
                  
                        system.debug('Deleting for perm set id :  '+perm_to_remove);
                        List<PermissionSetAssignment> permissionSetDeleteList = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name = :perm_to_remove];
                        system.debug('Delete '+permissionSetDeleteList.size()+' User perm sets');
                        try{
                            if (permissionSetDeleteList.size()>0){
                                delete permissionSetDeleteList;
                            }else
                            {
                             System.debug('Perm Set has no users ...' );
 
                            }
                        }  catch(exception e){
                            System.debug('Runtime delete error: autostageBatch removeUsersFromPermSet======================================= '+e.getMessage());
                            
                        }
                       
                    
                    
                   
                    
                }
                catch(exception e){
                System.debug('Runtime error:  autostageBatch removeUsersFromPermSet '+e.getMessage());
            }
          
        } //end if
        
        if (permissionSetList.size() > 0){
            
            try{
                upsert permissionSetList;
            }  catch(exception e){
                System.debug('Runtime update error: autostageBatch updatePermSet======================================= '+e.getMessage());
                
            }
        }
        
        if (stagelist.size() > 0){
            
            try{
                update stagelist;
            }  catch(exception e){
                System.debug('Runtime update error: autostageBatch updateStage======================================= '+e.getMessage());
                
            }
        }
        
        
    }//end execute
    
    public User getUserData(String empnumber) {
        
        List<User> myUser = [SELECT Id,Isactive FROM User WHERE employeenumber = :empnumber];
        if (myUser.size()>0){
            return myUser[0];
        }
        
        
        return null;
        
    }
    public PermissionSet getPermSetId(String theName) {
        
        List<PermissionSet> myPS = [SELECT Id FROM PermissionSet WHERE name = :theName];
        if (myPS.size()>0){
            return myPS[0];
        }
        
        
        return null;
        
    }
    
    public static boolean doesPermSetExist(String myUser,String permId) {
        List<PermissionSetAssignment> myPerms = [select Id from PermissionSetAssignment  where AssigneeId =:myUser and PermissionSetId =:permId];
        if (myPerms.size()>0){
            return true;
        }
       else
       {
        return false;
       }
    }

    global void finish(Database.BatchableContext BC){
        System.debug('autostageBatch Finished .......');
        
    }                 
    
}