//Only one at a time otherwise slack will error out. 
//Will rate limit and cause failure Id batchJobId = Database.executeBatch(new slackImportbatch('updateSlackid'), 1);
//Id batchJobId = Database.executeBatch(new slackImportbatch('updateSlackidFromTable'), 5);


global class slackImportbatch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    global final String Query;
    global final String jaAction;
  //  global final String passedEmail;
   
    User baseUser;
    User baselp;
    global slackImportbatch(String action){
        String q ='';
        jaAction=action;
       // passedEmail=parmEmail;
        String missing='Missing';
        if (jaAction.equals('updateSlackid')){
               q = 'select id , primary_email__c, user__r.email from learner_profile__c where user__r.isactive=true and slackid__c=null ';      
        }else if (jaAction.equals('updateSlackidFromTable')){
               q = 'select id , slackid__c,email__c from slackimport__c  where message__c=null';      
               //q = 'select id , slackid__c,email__c from slackimport__c where message__c=\'' + String.escapeSingleQuotes(missing)+'\' limit 100 ';      
        }
        else{
            system.debug('Error in slackImportbatch action not found '+jaAction);
        }
        Query=q;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('query '+query);
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {  
        
        List<learner_profile__c> lplist = new List<learner_profile__c>();
        List<slackimport__c> importlist = new List<slackimport__c>();
        
        System.debug('Records to Process: '+scope.size());
        for (sObject objScope: scope) {
           // manageSlackId msi = new manageSlackId();
            learner_profile__c lpScope ;
              
            slackimport__c importScope ;
              
            //slackimport__c
            if (jaAction.equals('updateSlackidFromTable')){
                try {   
                      importScope=(slackimport__c)objScope ;
                      learner_profile__c lp = getlpData(importScope.email__c);
                    if (lp!=null){
                        importScope.message__c='Complete';
                        lp.slackid__c=importScope.slackid__c;
                        lplist.add(lp);
                        importlist.add(importScope);
                    }else
                    {
                        importScope.message__c='Missing';
                        importlist.add(importScope);
                        
                    }
                }
                catch(exception e){
                    System.debug('Runtime error:  updateSlackidFromTable  '+e.getMessage());
                    
                }
            }
            /*if (jaAction.equals('updateSlackid')){
                try {
                       //lpScope.slackid__c=null; 
                       //update lpscope;
                   // system.debug('My primary email '+lpScope.primary_email__c);
                    //system.debug('My user email '+lpScope.user__r.email);
                    //
                    lpscope=(learner_profile__c)objScope ;
                    String sid='';
                    sid = msi.getSlackId(lpScope.primary_email__c.replace('.invalid',''));
                   
                    if (String.Isblank(sid)){
                       sid = msi.getSlackId(lpScope.user__r.email.replace('.invalid','')); 
                    }
                    if (!String.Isblank(sid)){
                       lpScope.slackid__c=sid; 
                     //  system.debug('My slackid '+lpScope.slackid__c );
                       update lpscope;
                    }
                    else
                    {
                       // system.debug('Slack Id Missing');
                        lpScope.slackid__c=null; 
                        update lpscope;
                    }
                    
                }
                catch(exception e){
                    System.debug('Runtime error:  slackImportbatch  '+e.getMessage());
                   // stageScope.errors__c=e.getMessage();
                   // update stageScope;
                }
               // stagelist.add(stageScope);
            }*/
        }//end for
          if (lplist.size()>0){
                System.debug('Records to Update learner profile list: '+lplist.size());
                update lplist ;
                lplist.clear();
            }
          if (importlist.size()>0){
                System.debug('Records to Update importlist: '+importlist.size());
                update importlist ;
                importlist.clear();
            }
        
    }//end execute
    
    public learner_profile__c getlpData(String primail) {
        String invalid = primail+'.invalid';
        
        List<learner_profile__c> mylp;
        mylp = [SELECT Id FROM learner_profile__c WHERE primary_email__c = :primail and status__c='Active'];
        if (mylp.size()>0){
            return mylp[0];
        }
        
        return null;
        
    }

global void finish(Database.BatchableContext BC){
    System.debug('slackImportbatch Finished .......');
    
}                 

}