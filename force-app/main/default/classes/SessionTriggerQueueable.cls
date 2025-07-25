public with sharing class SessionTriggerQueueable implements Queueable, Database.AllowsCallouts {
    public Set<Id> updatedSessionIds;
    public Set<Id> processedAssignedSessionIds;
    public Set<Id> cancelledSessionIds;
    public Integer maxToProcess = 50;
    
    public SessionTriggerQueueable(Set<Id> updatedSessionIds, Set<Id> cancelledSessionIds) {
        this.updatedSessionIds = updatedSessionIds;
        this.cancelledSessionIds = cancelledSessionIds;
        this.processedAssignedSessionIds = new Set<Id>();
    }

    public SessionTriggerQueueable(Set<Id> updatedSessionIds, Set<Id> cancelledSessionIds, Set<Id> processedAssignedSessionIds) {
        this.updatedSessionIds = updatedSessionIds;
        this.cancelledSessionIds = cancelledSessionIds;
        this.processedAssignedSessionIds = processedAssignedSessionIds;
    }

    public void execute(QueueableContext context) {
        List<Assigned_Session__c> assignedSessionsToProcess = new List<Assigned_Session__c>();

        try{ 
            if(!updatedSessionIds.isEmpty()){
                assignedSessionsToProcess = [SELECT Id, Send_Updated_Registration_Email__c, Session__c
                                            FROM Assigned_Session__c 
                                            WHERE Session__c IN :updatedSessionIds 
                                            AND Status__c = 'Registered'
                                            AND Id NOT IN :processedAssignedSessionIds
                                            ORDER BY Session__c
                                            LIMIT :maxToProcess];
                
                if(assignedSessionsToProcess.size() < maxToProcess){
                    updatedSessionIds.clear(); //used to handle if we found 0 assigned ids
                }

                String currentSession;

                for(Assigned_Session__c aSession : assignedSessionsToProcess){
                    if(!cancelledSessionIds.contains(aSession.Session__c)){
                        aSession.Send_Updated_Registration_Email__c = true;
                    }

                    //if we swap ids it means we finished processing the current one.
                    //empty check is if we clear the ids earlier
                    if(currentSession == null){
                        currentSession = aSession.Session__c;
                    } else if(aSession.Session__c != currentSession && !updatedSessionIds.isEmpty()){
                        updatedSessionIds.remove(currentSession);
                        currentSession = aSession.Session__c;
                    }

                    processedAssignedSessionIds.add(aSession.Id);
                }

                if(!assignedSessionsToProcess.isEmpty()){
                    update as user assignedSessionsToProcess;
                }
            } else if(!cancelledSessionIds.isEmpty()){
                assignedSessionsToProcess = [SELECT Id, Status__c
                                            FROM Assigned_Session__c 
                                            WHERE Session__c IN :cancelledSessionIds 
                                            AND Status__c = 'Registered'
                                            LIMIT :maxToProcess];
                
                if(!assignedSessionsToProcess.isEmpty()){
                    for(Assigned_Session__c aSession : assignedSessionsToProcess){
                        aSession.Status__c = 'Unregistered';
                    }

                    update assignedSessionsToProcess;
                }

                //if we have no more to process clear the list
                if(assignedSessionsToProcess.size() < maxToProcess){
                    List<Session__c> cancelledSessions = new List<Session__c>();

                    for(Id cancelledSessionId : cancelledSessionIds){
                        cancelledSessions.add(new Session__c(Id = cancelledSessionId, Cancelling_Assigned_Session__c = false));
                    }

                    update cancelledSessions;
                    cancelledSessionIds.clear();
                }
            }

            System.debug('******************* updatedSessionIds ' + updatedSessionIds);
            System.debug('******************* cancelledSessionIds ' + cancelledSessionIds);
            if(!updatedSessionIds.isEmpty() || !cancelledSessionIds.isEmpty()){
                System.enqueueJob(new SessionTriggerQueueable(updatedSessionIds, cancelledSessionIds, processedAssignedSessionIds));
            }
        } catch(Exception e){
            String stackTrace = e.getStackTraceString();

            if(stackTrace.length() > 30000){
                stackTrace = stackTrace.subString(0, 30000);
            }

            insert new Integration_Error__c(Error_Message__c = e.getMessage(), Http_Response_Body__c = stackTrace, Type__c = 'SessionTriggerQueueable');
        }
    }
}