public with sharing class TrainerApproval {

    @AuraEnabled(cacheable=true)
    public static ResponseData getData(){
        ResponseData rd = new ResponseData();
        
        try {
            String userId = UserInfo.getUserId();

            List<Session_Guest__c> sessionGuests = [SELECT Id, Session__c, Session__r.Name, Session__r.Start_Time_Converted__c,
                                                           Session__r.Session_Type__c, Session__r.Office_Location__r.Combined_Address__c,
                                                           Session__r.Office_Location__r.City__c, Role__c, Session_Role_Status__c,
                                                           Session__r.Location__c, From_Scheduler__c
                                                    FROM Session_Guest__c 
                                                    WHERE Learner_Profile__r.User__c =: userId
                                                    AND Session__r.Start_Date__c >= TODAY
                                                    AND From_Scheduler__c = true
                                                    ORDER BY Session__r.Start_Time_Converted__c ASC];

            List<formattedSessionGuest> formattedSessionGuests = new List<formattedSessionGuest>();

            for(Session_Guest__c sg : sessionGuests){
                formattedSessionGuests.add(new formattedSessionGuest(sg));
            }

            rd.put('sessionGuests', formattedSessionGuests);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled
    public static ResponseData updateRoleStatuses(String jsonString){
        ResponseData rd = new ResponseData();
        
        try {
            Map<String, Object> parsedRes = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            List<Object> selectedRoles = (List<Object>)parsedRes.get('selectedRoles');
            Boolean approved = (Boolean)parsedRes.get('approved');

            List<Session_Guest__c> sessionGuestsToUpdate = new List<Session_Guest__c>();

            for(Object selectedRole : selectedRoles){
                Map<String, Object> selectedRoleMap = (Map<String, Object>)selectedRole;
                Session_Guest__c sg = new Session_Guest__c(Id = (String)selectedRoleMap.get('id'), 
                                                           Session_Role_Status__c = approved ? 'Approved' : 'Declined');
                sessionGuestsToUpdate.add(sg);
            }

            update sessionGuestsToUpdate;
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    public class formattedSessionGuest {
        @AuraEnabled public String id;
        @AuraEnabled public String sgId; //used for managers
        @AuraEnabled public String name;
        @AuraEnabled public String formattedDateTime;
        @AuraEnabled public String role;
        @AuraEnabled public String status;
        @AuraEnabled public String sessionType;
        @AuraEnabled public Office_Location__c office;
        @AuraEnabled public Map<String, Object> location;
        @AuraEnabled public String url;
        @AuraEnabled public Boolean fromScheduler;

        public formattedSessionGuest(Session_Guest__c sg){
            setFields(sg);
        }

        public formattedSessionGuest(Session_Guest__c sg, Boolean isManager){
            setFields(sg);

            id = UUID.randomUUID().toString();
            sgId = sg.Id;
        }

        public void setFields(Session_Guest__c sg){
            String timezone = UserInfo.getTimeZone().getId();
            String displayTimezone = UserInfo.getTimeZone().getDisplayName().substringBetween(') ', ' (');

            id = sg.Id;
            name = sg.Session__r.Name;
            formattedDateTime = sg.Session__r.Start_Time_Converted__c.format('MMM dd, yyyy h:mm a', timezone);
            role = sg.Role__c;
            status = sg.Session_Role_Status__c;
            sessionType = sg.Session__r.Session_Type__c;
            office = sg.Session__r.Office_Location__r;
            location = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(sg.Session__r.Location__c));
            url = '/' + sg.Session__c;
            fromScheduler = sg.From_Scheduler__c;
        }
    }
}