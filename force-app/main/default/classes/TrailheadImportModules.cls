global with sharing class TrailheadImportModules implements Queueable, Database.AllowsCallouts {
    private Integer offSet;
    private Integer totalCount;
    private List<Asset__c> thOfferings;

    global TrailheadImportModules(Integer previousOffset){
        offSet = previousOffset;
        thOfferings = new List<Asset__c>();
    }

    global void execute(QueueableContext context) {
        try {
            String accessToken = Utilities.getAccessTokenFromRefresh();
            Boolean limitReached = false;
            System.debug('******************* accessToken: ' + accessToken);
            do {
                if(Limits.getCallouts() == Limits.getLimitCallouts()) {
                    limitReached = true;
                    break;
                }

                importModules(accessToken);
            } while(offset < totalCount);

            List<Database.UpsertResult> results = Database.upsert(thOfferings, Asset__c.Fields.Trailhead_Module_Id__c, false);
            List<Integration_Error__c> errors = new List<Integration_Error__c>();

            for(Database.UpsertResult r : results){
                if(r.isSuccess()){
                    continue;
                }

                List<Database.Error> errs = r.getErrors();

                Integration_Error__c errorObj = new Integration_Error__c(
                    Error_Message__c = errs[0].getMessage()
                );
                errors.add(errorObj);
            }
            
            insert errors;

            if(limitReached) {
                System.enqueueJob(new trailheadImportModules(offSet));
                return;
            }
        } catch (Exception e){
        System.debug('******************* e ' + e.getMessage());

            Integration_Error__c errorObj = new Integration_Error__c(
                Error_Message__c = 'Failed to retrieve trailhead modules due to system error: ' + e.getMessage() + ' at line ' + e.getLineNumber(),
                Type__c = 'Trailhead Import'
            );

            insert errorObj;
        }
    }

    private void importModules(String accessToken){
        System.debug('******************* ent: ' + accessToken);
        Map<String, String> headers = new Map<String, String>();

        headers.put('Authorization', 'Bearer ' + accessToken);
        headers.put('X-Api-Key', Constants.TRAILHEAD_API_KEY);

        String endpoint = constants.TRAILHEAD_API_MODULES + '?&offset=' + offSet;

        HttpResponse res = utilities.makeCallout(endpoint, 'GET', headers);
        // System.debug('**************** ' + res.statusCode());
        System.debug('**************** ' + res.getBody());
        if(res.getStatusCode() == 200) {
            Map<String, Object> thData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

            if(thData.containsKey('errorCode')) {
                Integration_Error__c errorObj = new Integration_Error__c(
                    Error_Message__c = 'Failed to retrieve trailhead modules : ' + (String)thData.get('message'),
                    Http_Response_Body__c = res.getBody(),
                    Type__c = 'Trailhead Import'
                );

                insert errorObj;

                return;
            }
            

            totalCount = Integer.valueOf(thData.get('total_count'));
            List<Object> modules = (List<Object>)thData.get('data');
            List<String> moduleIds = new List<String>();

            for(Object moduleObj : modules) {
                Map<String, Object> moduleMap = (Map<String, Object>)moduleObj;
                moduleIds.add((String)moduleMap.get('api_name'));
            }

            Id thRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Trailhead_Module').getRecordTypeId();

            for(Object moduleObj : modules) {
                Map<String, Object> moduleMap = (Map<String, Object>)moduleObj;

                if((Boolean)moduleMap.get('archived') == true) {
                    continue;
                }

                Integer calculatedTime = 0;

                for(Object moduleUnit : (List<Object>)moduleMap.get('units')) {
                    Map<String, Object> unitMap = (Map<String, Object>)moduleUnit;
                    calculatedTime += Integer.valueOf(unitMap.get('challenge_time'));
                }

                String moduleId = (String)moduleMap.get('api_name');

                //Boolean externallyAvailable = availabilityByModuleId.containsKey(moduleId) ?  availabilityByModuleId.get(moduleId) : usePartnerToken;

                Asset__c thModule = new Asset__c(
                    Name = ((String) moduleMap.get('title')).left(80),
                    Trailhead_Asset_Name__c = (String) moduleMap.get('title'),
                    Trailhead_Module_Id__c = moduleId,
                    Url__c = (String)moduleMap.get('web_url'),
                    Time_Estimate_Minutes__c = calculatedTime,
                    Description__c = ((String)moduleMap.get('description_html')).stripHtmlTags(),
                    Trailhead_Namespace__c = (String)moduleMap.get('namespace'),
                    Status__c = 'Active',
                    RecordTypeId = thRecordTypeId
                    );

                thOfferings.add(thModule);
            }

            offSet += modules.size();
        } else {
            Integration_Error__c errorObj = new Integration_Error__c(
                    Error_Message__c = 'Failed to retrieve trailhead modules : Code ' + res.getStatusCode(),
                    Http_Response_Body__c = res.getBody(),
                    Type__c = 'Trailhead Import'
                    );

            insert errorObj;
        }
    }
}