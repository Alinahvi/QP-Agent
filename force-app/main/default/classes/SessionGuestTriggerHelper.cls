public with sharing class SessionGuestTriggerHelper {

    public static void createAvailability(List<Session_Guest__c> triggerNew) {
        List<Availability__c> availability = new List<Availability__c>();
        List<Session_Guest__c> sessionGuestsWithData = [SELECT Id, Session__c, Session__r.Name, Session__r.Start_Time_Converted__c, Session__r.End_Time_Converted__c, Learner_Profile__c,
                                                               Learner_Profile__r.Is_Trainer__c
                                                        FROM Session_Guest__c
                                                        WHERE Id IN: triggerNew
                                                        AND Learner_Profile__r.Is_Trainer__c = true
                                                        WITH USER_MODE];


        for(Session_Guest__c sg : sessionGuestsWithData) {
            Availability__c newAvail = new Availability__c(
                Learner_Profile__c = sg.Learner_Profile__c,
                Name = sg.Session__r.Name,
                Type__c = 'Session',
                Session__c = sg.Session__c,
                Start_Date__c = sg.Session__r.Start_Time_Converted__c,
                End_Date__c = sg.Session__r.End_Time_Converted__c,
                Session_Guest__c = sg.Id
            );

            availability.add(newAvail);
        }

        if(!availability.isEmpty()) {
            insert as user availability;
        }
    }

    public static void deleteAvailability(List<Session_Guest__c> triggerOld) {
        // delete as user [SELECT Id FROM Availability__c WHERE Session_Guest__c IN: triggerOld];
        delete [SELECT Id FROM Availability__c WHERE Session_Guest__c IN: triggerOld];
    }
    
    public static void sendGestRoleUpdateMsg(Map<Id, Session_Guest__c> newMap, Map<Id, Session_Guest__c> oldMap) {
        Map<String, Object> data = new Map<String, Object>();
        Map<String, Map<String, String>> changedRoleByGuestId = new Map<String, Map<String, String>>();
        List<Slack_Notification_Error__c> errorList = new List<Slack_Notification_Error__c>();
        for(Session_Guest__c sg : newMap.values()) {
            Session_Guest__c oldSg = oldMap.get(sg.Id);
            if(sg.Role__c != oldSg.Role__c) {
                changedRoleByGuestId.put(sg.Id, new Map<String, String> {
                    'newRole' => sg.Role__c,
                    'oldRole' => oldSg.Role__c
                });                       
            }
        }
        if(!changedRoleByGuestId.isEmpty()) {
            for(Session_Guest__c sg : [SELECT Id, Learner_Profile__r.SlackId__c, Slack_Message_ID__c, Role__c
                                      FROM Session_Guest__c 
                                      WHERE Id IN: changedRoleByGuestId.keySet()]) {
                if(sg.Slack_Message_ID__c == null || sg.Learner_Profile__r.SlackId__c == null) {
                    Slack_Notification_Error__c se = new Slack_Notification_Error__c(
                        Learner_Profile__c =  sg.Learner_Profile__r.Id,
                        Request_Body__c =  'Session_Role_Changes',
                        Response_Body__c =  'slack_id OR threaded_message_id is null',
                        Time_Sent__c =  DateTime.now()
                    );
                    errorList.add(se);
                    continue;
                }
                Map<String, String> roles = changedRoleByGuestId.get(sg.Id);
                data.put(sg.Id, (Object) new Map<String, String> {
                    'newRole' => roles.get('newRole'),
                    'oldRole' => roles.get('oldRole'),
                    'slackId' => sg.Learner_Profile__r.SlackId__c,
                    'ts' => sg.Slack_Message_ID__c,
                    'lpId' => sg.Learner_Profile__r.Id
                });
            }
            
            Map<String, String> metaInfo = new Map<String, String> {
                'type' => 'SessionGuest',
                'action' => 'guest-role-changed'
            };

            System.enqueueJob(new SlackQueueableNotification(metaInfo, data));

            if(!errorList.isEmpty()) {
                try {
                    insert as user errorList;
                } catch(Exception e) {
                    System.debug('Error:: SessionGuestTriggerHelper *********** :: ' + e.getMessage());
                    System.debug('Error:: SessionGuestTriggerHelper *********** :: ' + e.getStackTraceString());
                }
            }      
        }
    }

    public static void sendSessionGuestRemovedMsg(List<Session_Guest__c> deletedList) {
        // List<Id> deletedGuest = new List<Id>();
        Map<String, Object> data = new Map<String, Object>();
        List<Slack_Notification_Error__c> errorList = new List<Slack_Notification_Error__c>();
        /* for(Session_Guest__c gs : deletedList) {
            deletedGuest.add(gs.Id);
        } */

        for(Session_Guest__c sg : [SELECT Id, Learner_Profile__r.SlackId__c, Slack_Message_ID__c, Role__c, Session__r.Status__c 
                                  FROM Session_Guest__c 
                                  WHERE Id IN: deletedList]) {
            if(sg.Slack_Message_ID__c == null || sg.Learner_Profile__r.SlackId__c == null) {
                Slack_Notification_Error__c se = new Slack_Notification_Error__c(
                    Learner_Profile__c =  sg.Learner_Profile__r.Id,
                    Request_Body__c =  'Session_Role_Deleted',
                    Response_Body__c =  'slack_id OR threaded_message_id is null',
                    Time_Sent__c =  DateTime.now()
                );
                errorList.add(se);
                continue;
            }
            data.put(sg.Id, (Object) new Map<String, String> {
                'slackId' => sg.Learner_Profile__r.SlackId__c,
                'role' => sg.Role__c,
                'ts' => sg.Slack_Message_ID__c,
                'lpId' => sg.Learner_Profile__r.Id,
                'messageType' => (sg.Session__r.Status__c == 'Cancelled' ? 'cancelled' : 'removed')
            });
        }

        Map<String, String> metaInfo = new Map<String, String> {
            'type' => 'SessionGuest',
            'action' => 'guest-role-deleted'
        };

        System.enqueueJob(new SlackQueueableNotification(metaInfo, data));

        if(!errorList.isEmpty()) {
            try {
                insert as user errorList;
            } catch(Exception e) {
                System.debug('Error:: SessionGuestTriggerHelper *********** :: ' + e.getMessage());
                System.debug('Error:: SessionGuestTriggerHelper *********** :: ' + e.getStackTraceString());
            }
        }
    }   

    public static void enforceSingleHost(List<Session_Guest__c> newGuests, Map<Id, Session_Guest__c> oldGuests) {
        List<String> newHosts = new List<String>();
        List<String> declinedHosts = new List<String>();
        List<String> sessionIds = new List<String>();
        List<Session_Guest__c> oldHostsToDelete = new List<Session_Guest__c>();
        Map<String, Session_Guest__c> existingHost = new Map<String, Session_Guest__c>();

        List<Session_Guest__c> newGuestsWithData = [SELECT Id, Role__c, Session_Role_Status__c, Session__c, Session__r.Virtual_Type__c
                                                    FROM Session_Guest__c
                                                    WHERE Id IN: newGuests];

        for(Session_Guest__c sg : newGuestsWithData){
            if(sg.Role__c == 'Host'){
                sessionIds.add(sg.Session__c);
            }
        }

        for(Session_Guest__c sg : [SELECT Id, Role__c, Session__c, Session_Role_Status__c
                                  FROM Session_Guest__c
                                  WHERE Session__c IN: sessionIds AND Role__c = 'Host' AND Session_Role_Status__c = 'Approved' AND Id NOT IN: newGuests]){
            existingHost.put(sg.Session__c, sg);
        }

        for(Session_Guest__c sg : newGuestsWithData){
            if(sg.Session__r.Virtual_Type__c == 'Zoom' && sg.Role__c == 'Host'){
                if(sg.Session_Role_Status__c == 'Approved' && oldGuests.get(sg.Id).Session_Role_Status__c != 'Approved'){
                    newHosts.add(sg.Id);
                }

                if(sg.Session_Role_Status__c == 'Declined' &&  oldGuests.get(sg.Id).Session_Role_Status__c == 'Approved'){
                    declinedHosts.add(sg.Id);
                }
            } else {
                if(sg.Role__c == 'Host' && existingHost.containsKey(sg.Session__c) && sg.Session_Role_Status__c == 'Approved' && oldGuests.get(sg.Id).Session_Role_Status__c != 'Approved'){
                    oldHostsToDelete.add(existingHost.get(sg.Session__c));
                }
            }
        }

        if(!newHosts.isEmpty() || !declinedHosts.isEmpty()){
            System.enqueueJob(new SessionGuestReassignZoomQueueable(newHosts, declinedHosts));
        }

        if(!oldHostsToDelete.isEmpty()){
            delete oldHostsToDelete;
        }
    }
}