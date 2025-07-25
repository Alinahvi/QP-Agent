//Id batchJobId = Database.executeBatch(new permsetbatch('updateStage'), 100);
//Id batchJobId = Database.executeBatch(new permsetbatch('updatePerm'), 100);
//Id batchJobId = Database.executeBatch(new permsetbatch('updateStatus'), 100);


global class permsetbatch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    global final String Query;
    global final String permsetAction;
    global String idActperm='';
    boolean isComplete=false;
    String myMessage='';
    User baseUser;
    
    public static final String[] PERMISSION_SETS = new String[] {
      'ACT_Content_Tagging'
    };
     
    global permsetbatch(String action){
       
        String q ='';
        permsetAction=action;
        if (permsetAction.equals('updateStage')) {
              //String val = 'User Missing';
              idActperm  = getPermissionSetId('ACT_Content_Tagging');
            system.debug('Permission set id '+idActperm);
             //q = 'Select id, email__c from permsetstage__c where error__c =\'' + String.escapeSingleQuotes(val)+'\'';
             q = 'Select id, email__c from permsetstage__c '; 
        } else if (permsetAction.equals('updatePerm')) {
           idActperm  = getPermissionSetId('ACT_Content_Tagging');
           q = 'Select id, email__c , userid__c from permsetstage__c where userid__c != null  ';
            
        
         } else if (permsetAction.equals('updateStatus')) {
           idActperm  = getPermissionSetId('ACT_Content_Tagging');
           q = 'Select id, email__c , userid__c from permsetstage__c where userid__c != null ';
            
        } 
        else {
             system.debug('Error in permsetStage action not found');
        }
     
    
        Query=q;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('query '+query);
        return Database.getQueryLocator(query);
    }
    public static String getPermissionSetId(String PermissionName) {
        
        List<PermissionSet> myPermissionSet = [SELECT Id FROM PermissionSet WHERE name=:PermissionName];
      
        
        if (myPermissionSet.size()>0){
            return myPermissionSet[0].id;
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
    private static String upsertPermSets(String myUser,String PermId)
    {
        
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        
        
        PermissionSetAssignment psa;
        if(!doesPermSetExist(myUser,PermId)){
            psa = new PermissionSetAssignment (PermissionSetId = PermId, AssigneeId = myUser);
            permissionSetList.add(psa);
        }
        
        if (permissionSetList.size()>0){
            //system.debug('permset update -: '+permissionSetList);
            upsert permissionSetList;
        }
        return 'Success';
    }
    public User getUserData(String email) {
        
       // String withInvalid = email+'.invalid';
       
        List<User> myUser = [SELECT Id,isactive FROM User WHERE email = :email];
        if (myUser.size()>0){
            return myUser[0];
        }
        

        return null;
        
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {  
        
        permsetstage__c basestage = new permsetstage__c();
        List<permsetstage__c> stagelist = new List<permsetstage__c>();
        List<User> ulist = new List<User>();
        System.debug('Records to Process: '+scope.size());
        for (sObject objScope: scope) {
            
            permsetstage__c stageScope = (permsetstage__c)objScope ;
            if (permsetAction.equals('updateStage')){
                try {  
                      system.debug('2Permission set id '+idActperm);
                      stageScope.permsetid__c = idActperm  ;
                 
                    baseUser = getUserData(stageScope.email__c);
                    if (baseUser!=null){
                        stageScope.userid__c=baseUser.Id;
                        //stageScope.uname__c=baseUser.Name;
                        if (baseUser.isactive==true){
                            stageScope.error__c='Updated';
                        }
                        if (baseUser.isactive==false){
                            stageScope.error__c='Inactive';
                        }  
                      
                    }
                    else
                    {
                       stageScope.error__c='User Missing';
                    }
                    
                }
                catch(exception e){
                    System.debug('Runtime error:  permsetBatch updateStage '+e.getMessage());
                    stageScope.error__c=e.getMessage();
                    update stageScope;
                }
                stagelist.add(stageScope);
            } else if (permsetAction.equals('updatePerm')) {
                try {  
                    
                    String result =  upsertPermSets(stageScope.userid__c,idActperm);
               
                    
                }
                catch(exception e){
                    System.debug('Runtime error:  permsetBatch updatePerm '+e.getMessage());
                    //stageScope.error__c=e.getMessage()+'-updatePerm';
                    //update stageScope;
                }
                //stagelist.add(stageScope);
            } else if (permsetAction.equals('updateStatus')) {
                try {  
                    
                    boolean result =  doesPermSetExist(stageScope.userid__c,idActperm);
                    if (result==true){
                        // stageScope.userid__c=baseUser.Id;
                        //stageScope.uname__c=baseUser.Name;
                       stageScope.error__c='Perm Assigned';
                       
                    }
                    else
                    {
                       stageScope.error__c='Perm Not Assigned';
                    }
                    
                }
                catch(exception e){
                    System.debug('Runtime error:  permsetBatch updateStatus '+e.getMessage());
                    stageScope.error__c=e.getMessage()+'-updateStatus';
                    update stageScope;
                }
                stagelist.add(stageScope);
            }
            else 
            {System.debug('Missing permset action '+permsetAction);
            }
    
        }
        
        if (stagelist.size() > 0){
            
            try{
                update stagelist;
            }  catch(exception e){
                System.debug('Runtime update error: permsetBatch updateStage======================================= '+e.getMessage());
                
            }
        }
        
    }//end execute
    
    
    
    global void finish(Database.BatchableContext BC){
        System.debug('permsetBatch Finished ....... ');
        
    }                 
    
}