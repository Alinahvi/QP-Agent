public with sharing class SessionGuestReassignZoomQueueable implements Queueable, Database.AllowsCallouts {
    public List<String> newHostIds;
    public List<String> declinedHostIds;
    
    public SessionGuestReassignZoomQueueable(List<String> newHostIds, List<String> declinedHostIds) {
        this.newHostIds = newHostIds;
        this.declinedHostIds = declinedHostIds;
    }

    public void execute(QueueableContext context) {
        List<String> sessionIds = new List<String>();
        Map<String, Session_Guest__c> newHostsBySessionId = new Map<String, Session_Guest__c>();
        Map<String, Session_Guest__c> oldHostsBySessionId = new Map<String, Session_Guest__c>();
        
        List<Session_Guest__c> newHosts = [SELECT Id, Learner_Profile__r.Primary_Email__c, Session__c
                                           FROM Session_Guest__c
                                           WHERE Id =: newHostIds];

        List<Session_Guest__c> declinedHosts = [SELECT Id, Learner_Profile__r.Primary_Email__c, Session__r.OwnerId
                                                FROM Session_Guest__c
                                                WHERE Id =: declinedHostIds];

        for(Session_Guest__c sg : newHosts){
            sessionIds.add(sg.Session__c);
            newHostsBySessionId.put(sg.Session__c, sg);
        }

        List<Session_Guest__c> oldHosts = [SELECT Id, Learner_Profile__r.Primary_Email__c, Session__c
                                           FROM Session_Guest__c
                                           WHERE Role__c = 'Host'
                                           AND Session__c =: sessionIds
                                           AND Session_Role_Status__c = 'Approved'
                                           AND Id NOT IN: newHosts];

        List<Session_Guest__c> oldHostsToDelete = new List<Session_Guest__c>();
        List<Session_Guest__c> newHostsToInsert = new List<Session_Guest__c>();
        List<Integration_Error__c> errors = new List<Integration_Error__c>();

        for(Session_Guest__c oldHost : oldHosts){
            Session_Guest__c newHost = newHostsBySessionId.get(oldHost.Session__c);
            ResponseData rd = Attendees.reassignZoomHost(oldHost.Session__c, oldHost.Learner_Profile__r.Primary_Email__c, newHost.Learner_Profile__r.Primary_Email__c);

            if(rd.isSuccess){
                oldHostsToDelete.add(oldHost);
            } else {
                errors.add(new Integration_Error__c(
                    Type__c = 'Approved Session Guest Host Reassignment',
                    Error_Message__c = rd.errMsg,
                    Http_Response_Body__c = JSON.serialize(rd.results.get('resBody'))
                ));
            }
        }

        Set<String> ownerIds = new Set<String>();

        for(Session_Guest__c declinedHost : declinedHosts){
            ownerIds.add(declinedHost.Session__r.OwnerId);
        }

        List<Learner_Profile__c> lps = [SELECT Id, Name, Primary_Email__c, User__c
                                        FROM Learner_Profile__c
                                        WHERE User__c IN: ownerIds];

        Map<String, Learner_Profile__c> lpIdByUserId = new Map<String, Learner_Profile__c>();

        for(Learner_Profile__c lp : lps){
            lpIdByUserId.put(lp.User__c, lp);
        }

        for(Session_Guest__c declinedHost : declinedHosts){
            Learner_Profile__c ownerLp = lpIdByUserId.get(declinedHost.Session__r.OwnerId);
            ResponseData rd = Attendees.reassignZoomHost(declinedHost.Session__c, declinedHost.Learner_Profile__r.Primary_Email__c, ownerLp.Primary_Email__c);

            if(rd.isSuccess){
                newHostsToInsert.add(new Session_Guest__c(
                    Session__c = declinedHost.Session__c,
                    Learner_Profile__c = ownerLp.Id,
                    Role__c = 'Host',
                    Session_Role_Status__c = 'Approved'
                ));
            } else {
                errors.add(new Integration_Error__c(
                    Type__c = 'Declined Session Guest Host Reassignment',
                    Error_Message__c = rd.errMsg,
                    Http_Response_Body__c = JSON.serialize(rd.results.get('resBody'))
                ));
            }
        }

        if(!newHostsToInsert.isEmpty()){
            insert newHostsToInsert;
        }

        if(!oldHostsToDelete.isEmpty()){
            delete oldHostsToDelete;
        }

        if(!errors.isEmpty()){
            insert errors;
        }
    }
}