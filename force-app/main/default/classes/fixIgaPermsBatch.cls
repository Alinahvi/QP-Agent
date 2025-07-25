////Id batchJobId = Database.executeBatch(new fixIgaPermsBatch('updatePermSetGroup'), 50);

global class fixIgaPermsBatch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    global final String Query;
    global final String jaAction;
    global  String perm_id;
    global  String perm_to_remove;
    global List<PermissionSetGroup> myPermissionSetgrp = new List<PermissionSetGroup>();
    global List<PermissionSetAssignment> PermissionSetAssignmentList = new List<PermissionSetAssignment>();
    
    //boolean isComplete=false;
    
    User baseUser;
  
    global fixIgaPermsBatch(String action){
        String q ='';
        jaAction=action;
    
        String permgrpName='%Act_Learn%';
        String grpName='%Act_%';
        String profName='Basecamp User';
        
        if (jaAction.equals('updatePermSetGroup')){
           q= ' SELECT Id, Name, createddate,email,user.profile.name from User where id not in (SELECT  AssigneeId FROM PermissionSetAssignment WHERE PermissionSetGroup.DeveloperName like \'' + String.escapeSingleQuotes(grpName)+'\') and isactive=true and user.profile.name in (\'' + String.escapeSingleQuotes(profName)+'\')'; 
        }
        else{
            system.debug('Error in fixIgaPermsBatch jaAction not found');
        }
        Query=q;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('query '+query);
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {  
      
      
        myPermissionSetgrp = [SELECT Id  FROM PermissionSetGroup WHERE DeveloperName like '%Act_Learn%'];
        /*
        PermissionSetAssignment psa;
psa = new PermissionSetAssignment (PermissionSetGroupId = myPermissionSetgrp[0].id, AssigneeId = '0058000000EgEaIAAV');
upsert psa;
        */
        System.debug('Records to Process: '+scope.size());
        for (sObject objScope: scope) {
            
            user userScope = (user)objScope ;
            
           
            if (jaAction.equals('updatePermSetGroup')){
                System.debug('User ---------------- '+userScope);
                try {  
                    
                    if (myPermissionSetgrp != null){
                        PermissionSetAssignment psa;
                        psa = new PermissionSetAssignment (PermissionSetGroupId = myPermissionSetgrp[0].id, AssigneeId = userScope.Id);
                        PermissionSetAssignmentList.add(psa);
                        
                    }else{
                        System.debug('Perm id missing ---------------- ');
                    }
                    
                }
                catch(exception e){
                System.debug('Runtime error:  fixIgaPermsBatch updatePermSetGroup '+e.getMessage());
            }
          
        } //end if
           
         
           
        }//end for
        
     
        
        if (PermissionSetAssignmentList.size() > 0){
            
            try{
                upsert PermissionSetAssignmentList;
            }  catch(exception e){
                System.debug('Runtime upsert error: fixIgaPermsBatch updatePermSetgroup======================================= '+e.getMessage());
                
            }
        }
        
    
        
        
    }//end execute
    
  
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