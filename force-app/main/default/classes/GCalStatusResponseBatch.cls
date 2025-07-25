public with sharing class GCalStatusResponseBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // List<String> eventIds = getEventIds();

        // Batch_Data__c batchData = Batch_Data__c.getOrgDefaults();
        // batchData.Last_GCal_Run_Time__c = DateTime.now();

        // upsert batchData;      
        
        // return Database.getQueryLocator([SELECT Id, GCal_Event_Id__c, Session__c
        //                                  FROM GCal_Event__c 
        //                                  WHERE GCal_Event_Id__c =: eventIds
        //                                  WITH USER_MODE]);
        return null;
    }

    public void execute(Database.BatchableContext BC, List<GCal_Event__c> scope) {
        // GCalStatusResponseBatchHelper.updateCalendarResponses(scope);
    }

    public void finish(Database.BatchableContext BC) {
        // if(!Test.isRunningTest()){
        //     List<CronTrigger> gcalJob = [SELECT Id
        //                                  FROM CronTrigger
        //                                  WHERE CronJobDetail.Name =: constants.GCAL_JOB_NAME
        //                                  WITH USER_MODE];

        //     if(gcalJob.isEmpty()){
        //         System.scheduleBatch(new GCalStatusResponseBatch(), constants.GCAL_JOB_NAME, 5, 80);
        //     }
        // }
    }

    // public List<String> getEventIds(){
    //     Batch_Data__c batchData = Batch_Data__c.getOrgDefaults();
    //     DateTime lastran = batchData.Last_GCal_Run_Time__c;
    //     List<String> eventIds = new List<String>();

    //     if(lastRan == null){
    //         lastRan = DateTime.now().addMinutes(-5);
    //     }
    //     Map<String, String> headers = new Map <String, String> {
    //         'Content-Type' => 'application/json'
    //     };
    //     String pageToken;
    //     // String endpoint = constants.GCAL_EVENTS_ENDPOINT + '?maxAttendees=1&maxResults=500&updatedMin=' + lastran.format('yyyy-MM-dd\'T\'hh:mm:ss.SSSZ');
    //     String endpoint = constants.GCAL_EVENTS_ENDPOINT + '?maxAttendees=1&maxResults=500&updatedMin=' + lastran.format('yyyy-MM-dd\'T\'hh:mm:ss.SSS\'Z\'');
    //     System.debug('********************* endpoint ' + endpoint);
    //     String method = 'GET';

    //     do {
    //         if(pageToken != null){
    //             endpoint += '&pageToken=' + pageToken;
    //         }

    //         HttpResponse res = utilities.makeNCCallout(endpoint, method, headers);
    //         Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
    //         pageToken = (String)resBody.get('nextPageToken');
    //         List<Object> items = (List<Object>)resBody.get('items');
    //         System.debug('********************* resBody ' + resBody);
    //         for(Object item : items){
    //             Map<String, Object> eventMap = (Map<String, Object>)item;
    //             eventIds.add((String)eventMap.get('id'));
    //         }
    //     } while(pageToken != null);
    //     System.debug('************** eventIds ' + eventIds);
    //     return eventIds;
    // }

}