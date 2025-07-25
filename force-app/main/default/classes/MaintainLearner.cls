/**
 * @File Name          : MaintainLearner.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 4/10/2020, 11:22:05 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/10/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class MaintainLearner {
    @future(callout=true) 
    public static void createOrUpdateLearnersHelper(Set<Id> UserIds) {
    	//Act 1 createOrUpdateLearners(UserIds);
        createOrUpdateLearnersUnmanaged(UserIds);
    }
    
      public static Map<Id, Learner_Profile__c> createOrUpdateLearnersUnmanaged(Set<Id> userIds) {
   
        List<Integration_Error__c> errorMsg = new List<Integration_Error__c>();
        Map<Id, User> userMap = new Map<Id, User>([  SELECT Id, name, Manager.Name, Email,Manager_Email__c, isActive, uniqueEmployeeNumber__c
                                                       FROM User 
                                                      WHERE Id =: userIds ]);
        
        List<Learner_Profile__c> learnerProfilesUnManaged = 
                                                    [SELECT  id,slackid__c,name,User__c,employee_number__c ,Status__c,Primary_Email__c,Manager__c,Manager_Email__c
                                                      FROM Learner_Profile__c 
                                                      WHERE user__c =: userIds ];
        
  
        //unmanaged update
        Map<Id, Learner_Profile__c> learnerMapByUserUnManaged = new Map<Id,Learner_Profile__c>();
        
 
        //unmanaged update
        for (Learner_Profile__c learner: learnerProfilesUnManaged) {
            learnerMapByUserUnManaged.put(learner.User__c, learner);
        }
        
        
        //unmanaged update
        Map<Id, Learner_Profile__c> updatedLearnerMapUnmanaged = new Map<Id, Learner_Profile__c>();
        
        for (User user: userMap.values()) {
            
            updatedLearnerMapUnmanaged.put(user.Id, mapUserToLearnerUnmanaged(user, learnerMapByUserUnmanaged.get(user.Id)));
            
        }
        
        try {
	      System.debug('upsert updatedLearnerMapUnmanaged: '+updatedLearnerMapUnmanaged.values());
            UPSERT updatedLearnerMapUnmanaged.values();      
        } catch (Exception e) {
            System.debug('Exception MaintainLearner: '+e.getMessage());
            errorMsg.add(ExceptionUtility2.createErrorLog('ACT', 'MaintainLearner', 'Learner_Profile__c', e.getCause()+' :: '+e.getStackTraceString()));
        }

        ExceptionUtility2.insertErrorLogs(errorMsg);
        return updatedLearnerMapUnmanaged;
    }
    
    
    /*
    ACT1
    public static Map<Id, slj__Learner_Profile__c> createOrUpdateLearners(Set<Id> userIds) {
        
        List<slj__Integration_Error__c> errorMsg = new List<slj__Integration_Error__c>();
        Map<Id, User> userMap = new Map<Id, User>([  SELECT Id, name, Manager.Name, Email,Manager_Email__c, isActive, uniqueEmployeeNumber__c
                                                       FROM User 
                                                      WHERE Id =: userIds ]);
        
        
        List<slj__Learner_Profile__c> learnerProfiles = 
                                                    [SELECT  id,name,slj__User__c,slj__employee_number__c ,slj__Status__c,Manager_Email__c,Primary_Email__c,Manager__c
                                                      FROM slj__Learner_Profile__c 
                                                      WHERE slj__user__c =: userIds ];
        List<Learner_Profile__c> learnerProfilesUnManaged = 
                                                    [SELECT  id,slackid__c,name,User__c,employee_number__c ,Status__c,Primary_Email__c,Manager__c,Manager_Email__c
                                                      FROM Learner_Profile__c 
                                                      WHERE user__c =: userIds ];
        
        Map<Id, slj__Learner_Profile__c> learnerMapByUser = new Map<Id, slj__Learner_Profile__c>();
        //unmanaged update
        Map<Id, Learner_Profile__c> learnerMapByUserUnManaged = new Map<Id,Learner_Profile__c>();
        
        
        for (slj__Learner_Profile__c learner: learnerProfiles) {
            learnerMapByUser.put(learner.slj__User__c, learner);
        }
        //unmanaged update
        for (Learner_Profile__c learner: learnerProfilesUnManaged) {
            learnerMapByUserUnManaged.put(learner.User__c, learner);
        }
        
        Map<Id, slj__Learner_Profile__c> updatedLearnerMap = new Map<Id, slj__Learner_Profile__c>();
        
        //unmanaged update
        Map<Id, Learner_Profile__c> updatedLearnerMapUnmanaged = new Map<Id, Learner_Profile__c>();
        
        for (User user: userMap.values()) {
        	updatedLearnerMap.put(user.Id, mapUserToLearner(user, learnerMapByUser.get(user.Id)));
            
            updatedLearnerMapUnmanaged.put(user.Id, mapUserToLearnerUnmanaged(user, learnerMapByUserUnmanaged.get(user.Id)));
            
        }
        
        try {
	        UPSERT updatedLearnerMap.values();
            UPSERT updatedLearnerMapUnmanaged.values();      
        } catch (DmlException e) {
            System.debug(e.getMessage());
            errorMsg.add(ExceptionUtility.createErrorLog('ACT', 'MaintainLearner', 'slj__Learner_Profile__c', e.getCause()+' :: '+e.getStackTraceString()));
        }

        ExceptionUtility.insertErrorLogs(errorMsg);
        return updatedLearnerMap;
    }
    */
    
     public static Learner_Profile__c mapUserToLearnerUnmanaged(User user, Learner_Profile__c learnerProfileUnmanaged) {

        if (null == learnerProfileUnmanaged) {
            learnerProfileUnmanaged = new Learner_Profile__c();
        }

        learnerProfileUnmanaged.User__c = user.id;
        learnerProfileUnmanaged.employee_number__c = user.uniqueEmployeeNumber__c;
        learnerProfileUnmanaged.name = user.name;
        learnerProfileUnmanaged.Manager_Email__c = user.Manager_Email__c;
        //aug 7 2023 Slack id update not working - updating from ikram static batch data
        /* if(String.isBlank(learnerProfileUnmanaged.slackid__c))
        {
            
                String sid = getSlackIdByEmail(user.Email.replace('.invalid',''));  
                if (!String.Isblank(sid)){
                learnerProfileUnmanaged.slackid__c = sid;
                }
                system.debug('My slack id: '+sid+' Email:'+user.Email);
            //if(user.Email.equals('dglassman@salesforce.com')){
            //}
         
        }
         */
        
         //Slack id end update
        //learnerProfileUnmanaged.Primary_Email__c = user.Email;
        if(String.isBlank(learnerProfileUnmanaged.Primary_Email__c))
        {
           learnerProfileUnmanaged.Primary_Email__c = user.Email;        
        }
        learnerProfileUnmanaged.manager__c = user.Manager.Name;

        //activate and inactive users
		if(user.isActive)
	        learnerProfileUnmanaged.Status__c = 'Active';
        else
    	    learnerProfileUnmanaged.Status__c = 'Inactive';
            
                 
        System.debug('learnerProfileUnmanaged- Id: ' + learnerProfileUnmanaged.Id);
		RETURN learnerProfileUnmanaged;     
    }
    
    /*public static slj__Learner_Profile__c mapUserToLearner(User user, slj__Learner_Profile__c learnerProfile) {

        if (null == learnerProfile) {
            learnerProfile = new slj__Learner_Profile__c();
        }
        
        learnerProfile.slj__User__c = user.id;
        learnerProfile.slj__employee_number__c = user.uniqueEmployeeNumber__c;
        learnerProfile.name = user.name;
        learnerProfile.Manager_Email__c = user.Manager_Email__c;
        learnerProfile.Primary_Email__c = user.Email;
        learnerProfile.manager__c = user.Manager.Name;

        //activate and inactive users
		if(user.isActive)
	        learnerProfile.slj__Status__c = 'Active';
        else
    	    learnerProfile.slj__Status__c = 'Inactive';
            
                 
        System.debug('learnerProfile- Id: ' + learnerProfile.Id);
		RETURN learnerProfile;     
    }
    */
    public static String getSlackIdByEmail(String parmEmail) {
        String slackid;
        try {  
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://slack.com/api/users.lookupByEmail?email='+parmEmail);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setHeader('Authorization', 'Bearer xoxb-1570924848016-3192038456112-nDQM3EjV4HGWL5WUEzJFM0rC');
            HttpResponse res = http.send(req);
            
            JSONParser parser = JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    switch on parser.getText() {
                        when 'id' {
                            parser.nextToken();
                            slackid = parser.getText();
                            break;
                        } 
                    }
                }
            }
            //System.debug(' SlackIDFound: - '+slackid+' Email: '+parmEmail);
            
        }catch(exception e){
            //System.debug('manageSlackId Error : '+e.getMessage()); 
            Integration_Error__c ie = new Integration_Error__c(type__c='Slackid',error_message__c=e.getMessage()+parmEmail);
            insert ie;    
            return null;
        }
        if (String.isBlank(slackid)){
            Integration_Error__c ie = new Integration_Error__c(type__c='Slackid',error_message__c=parmEmail);
            insert ie;
            return null;
        }
        return slackid;
        
    }
}