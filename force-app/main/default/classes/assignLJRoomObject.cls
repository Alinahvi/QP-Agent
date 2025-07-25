global class assignLJRoomObject implements Database.Batchable<sObject> {
   Map<id,user> IdUserMapBatch=new Map<id,user>();
    global assignLJRoomObject(Map<id,user> IdUserMap){
        IdUserMapBatch=IdUserMap;
    }
      global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([SELECT id,name,email,profile.name from user where id in:IdUserMapBatch.keySet()]);
    }
      global void execute(Database.BatchableContext BC, List<User> scope) {     
        for(User usr : scope)
        {    
            try {
               // System.debug('Trying lrn room creation  ============================: '+usr);

             assign(usr);
            }catch (exception e){
            System.debug('lrn room creation error ============================: '+e.getMessage()+ 'User-'+usr);
           
        }
        }
    }
    global void finish(Database.BatchableContext BC)
    {
        system.debug('lrn batch user room run complete');
    }
    private void assign(User myUser) {

        List<LRN__Lurniture_User__c> myLurnitureUser = [select Id from LRN__Lurniture_User__c where LRN__User__c=:myUser.id];
        if (myLurnitureUser.size()>0){
           System.debug('LRN room Exists ============================: '+myUser);

           return;
        }
         LRN__Lurniture_User__c lurnUser = new LRN__Lurniture_User__c();

          System.debug('Create LRN room  ============================: '+myUser);
        if (myUser.Profile.Name=='Basecamp User'){
            lurnUser.LRN__Active__c=TRUE;
            lurnUser.LRN__Can_Assign_Video__c=FALSE;
            lurnUser.LRN__Can_Publish_Video__c=FALSE;
            lurnUser.LRN__Can_Create_Tags__c=FALSE;
            lurnUser.LRN__Can_Create_Rooms__c=FALSE;
            lurnUser.LRN__Disable_Public_Playlist_Creation__c=TRUE;
            lurnUser.LRN__User__c =myUser.Id;
            insert lurnUser;
            return ;
        }
        if (myUser.Profile.Name=='Enablement Design User'){
            lurnUser.LRN__Active__c=TRUE;
            lurnUser.LRN__Disable_Public_Playlist_Creation__c=TRUE;
            lurnUser.LRN__Can_Create_Rooms__c=TRUE;
            lurnUser.LRN__Can_Assign_Video__c=FALSE;
            lurnUser.LRN__Can_Publish_Video__c=FALSE;
            lurnUser.LRN__Can_Create_Tags__c=FALSE;
            lurnUser.LRN__User__c =myUser.Id;
            insert lurnUser;
            return ;
        }
        return ;
    }


}