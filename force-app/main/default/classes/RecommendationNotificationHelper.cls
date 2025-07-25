public with sharing class RecommendationNotificationHelper {
    private static Map<String, Object> lpDetailsByLpId = new Map<String, Object>();
    private static Map<String, Map<String, List<Object>>> recomNotiByLpAndType = new Map<String, Map<String, List<Object>>>();
    private static String orgURL = new SiteLink().siteUrlWithPrefix;
    private static Map<Id, Map<String, String>> queryParamByAssetTypeId = new Map<Id, Map<String, String>>();

    public static Map<String, Object> sendRecommededNotification(List<Learner_Profile__c> scope) {
        
        Schema.DescribeSObjectResult objResult = Asset__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> objRecordType = objResult.getRecordTypeInfos();

        for(Schema.RecordTypeInfo type : objRecordType) {
            Map<String, String> recordTypeMap;
            switch on (type.getDeveloperName()) {
                when 'Event' {
                    recordTypeMap = new Map<String, String>{
                        'name' => type.getName(),
                        'path' => '/event-detail?id='
                    };                   
                }
                when 'Media' {
                    recordTypeMap = new Map<String, String>{
                        'name' => type.getName(),
                        'path' => '/media-detail?id='
                    };                   
                }
                when 'Trailhead_Module' {
                    recordTypeMap = new Map<String, String>{
                        'name' => type.getName(),
                        'path' => '/trailhead-module-detail?id='
                    };               
                }
                when 'In_App_Assessment' {
                    recordTypeMap = new Map<String, String>{
                        'name' => type.getName(),
                        'path' => '/in-app-assessment-detail?id='
                    };
                }
                when else {
                    recordTypeMap = new Map<String, String>{
                        'name' => type.getName(),
                        'path' => orgURL
                    };
                }
            }
            queryParamByAssetTypeId.put(type.getRecordTypeId(), recordTypeMap);           
        }
        
        for(Learner_Profile__c lp : scope) {
            learningByNotificationType(lp);
        } 

        if(!recomNotiByLpAndType.isEmpty()) {
            String payload = createSlackPayload();
            if(!String.isEmpty(payload)) {
                Map<String, Object> result = sendPayload(payload);
                return result;
            } else {
                Integration_Error__c ie = new Integration_Error__c(
                    Error_Message__c = 'sendRecommededNotificationHelper :: Exception :: '+ 'Recommended slack payload is empty',
                    Http_Response_Body__c =  'Recommended slack payload is empty'
                );
                return (new Map<String, Object> { 'ok' => (Object)false, 'error' => (Object)ie });
            }
        } else {
            return (new Map<String, Object> { 'ok' => (Object)true });
        }      
    }

    public static void learningByNotificationType(Learner_Profile__c lp) {
        if(lp != null && !lp.Recommended_Learnings__r.isEmpty()) {
            if(!lpDetailsByLpId.containsKey(lp.Id)) {
                Map<String, String> userDetail = new Map<String, String>{
                    'userName' => lp.Name,
                    'firstName' => lp.User__r.FirstName,
                    'userId' => lp.User__r.Id,
                    'lpId' => lp.Id,
                    'slackId' => lp.slackid__c,
                    'viewAllRecommendation' => orgURL+'/catalog?filter=Recommendations'
                };
                lpDetailsByLpId.put(lp.Id, (Object)userDetail);                
            }
            for(Recommended_Learning__c learning : lp.Recommended_Learnings__r) {
                recommendationByLearningType(learning, lp.Id);
            }
        }        
    }

    public static void recommendationByLearningType(Recommended_Learning__c data, String lpId) {
        String type = '';
        String assetType = '';
        String learningId = '';
        String learingName = '';
        String learningUrl = '';
        String learningDesc = 'NA';
        String timeEstimate = '';
        Map<String, String> learning = new Map<String, String>();

        if(data.Curriculum__r != null) {
            type = 'Curriculum';
            learningId = data.Curriculum__r.Id;
            learingName = data.Curriculum__r.Name.escapeJava();
            learningUrl = orgURL+'/curriculum-detail?id='+data.Curriculum__r.Id;
            timeEstimate = data.Curriculum__r.Time_Estimate__c != null ? ''+data.Curriculum__r.Time_Estimate__c : 'NA';
            learningDesc = String.isNotEmpty(data.Curriculum__r.Description__c) ? data.Curriculum__r.Description__c.escapeJava() : 'NA';            
        } else if(data.Course__r != null) {
            type = 'Course';
            learningId = data.Course__r.Id;
            learingName = data.Course__r.Name.escapeJava();
            learningUrl = orgURL+'/course-detail?id='+data.Course__r.Id;
            timeEstimate = data.Course__r.Time_Estimate__c != null ? ''+data.Course__r.Time_Estimate__c : 'NA';
            learningDesc = String.isNotEmpty(data.Course__r.Description__c) ? data.Course__r.Description__c.escapeJava() : 'NA';
        } else if(data.Session__r != null) {
            type = 'Session';
            learningId = data.Session__r.Id;
            learingName = data.Session__r.Name.escapeJava();
            learningUrl = orgURL+'/session-detail?id='+data.Session__r.Id;
            timeEstimate = 'NA';
            learningDesc = String.isNotEmpty(data.Session__r.Description__c) ? data.Session__r.Description__c.escapeJava() : 'NA';
        } 
        else {
            type = 'Asset';
            learningId = data.Asset__r.Id;
            learingName = data.Asset__r.Name.escapeJava();
            if(queryParamByAssetTypeId.containsKey(data.Asset__r.RecordTypeId)) {
                Map<String, String> tempMap = queryParamByAssetTypeId.get(data.Asset__r.RecordTypeId);
                assetType = tempMap.get('name');
                if(assetType == 'Assessment' || assetType == 'Quiz') {
                    learningUrl = orgURL +'/quiz-assessment-detail?id='+data.Asset__r.Id; //+tempMap.get('path')+data.Asset__r.Id;
                } /* else if(assetType == 'In_App_Assessment') {
                    learningUrl = orgURL +'/peer-assessment-detail?id='+data.Asset__r.Id; //+tempMap.get('path')+data.Asset__r.Id;
                } */ else {
                    learningUrl = orgURL+tempMap.get('path')+data.Asset__r.Id;
                }                
            } else {
                assetType = 'Asset';
                learningUrl = orgURL;
            }
            timeEstimate = data.Asset__r.Time_Estimate__c != null ? ''+data.Asset__r.Time_Estimate__c : 'NA';
            learningDesc = String.isNotEmpty(data.Asset__r.Description__c) ? data.Asset__r.Description__c.escapeJava() : 'NA';
        }
        learning.put('learningId', learningId);
        learning.put('recommendationId', data.Id);
        learning.put('name', learingName);
        learning.put('url', learningUrl);
        learning.put('type', type);
        learning.put('description', learningDesc);
        learning.put('timeEstimate', timeEstimate);
        learning.put('requiredBy', data.Content_Distribution_Organization__c);
        learning.put('subType', assetType);
        learning.put('message', 'You have new recommendations! Be sure to check out all of your active recommendations in Astro\'s Course Tracker.');

        if(recomNotiByLpAndType.containsKey(lpId)) {
            Map<String, List<Object>> notiDataByType = recomNotiByLpAndType.get(lpId);
            if(notiDataByType.containsKey(type)) {
                notiDataByType.get(type).add((Object)learning);   
            } else {
                notiDataByType.put(type, new List<Object>{(Object)learning});                        
            }
        } else {
            Map<String, List<Object>> tempMap = new Map<String, List<Object>> {
                type => new List<Object>{learning}
            };
            recomNotiByLpAndType.put(lpId, tempMap);                    
        }
    }
    
    public static String createSlackPayload() {
        if(lpDetailsByLpId.isEmpty()){
            return '';
        }

        Map<String, Object> payload = new Map<String, Object>();
        List<Object> blocks = new List<Object>();
        for(String lpId : lpDetailsByLpId.keySet()) {
            Map<String, String> tempMap = (Map<String, String>)lpDetailsByLpId.get(lpId);
            Map<String, Object> blockMap = new Map<String, Object>{
                'userName' => (Object)tempMap.get('userName'),
                'firstName' => (Object)tempMap.get('firstName'),
                'userId' => (Object)tempMap.get('userId'),
                'lpId' => (Object)tempMap.get('lpId'),
                'slackId' => (Object)tempMap.get('slackId'),
                'viewAllRecommendation' => (Object)tempMap.get('viewAllRecommendation')
            };
            Map<String, List<Object>> learningByType = recomNotiByLpAndType.get(lpId);
            if(learningByType != null) {
                blockMap.put('recommended', (Object)learningByType);
            }
            blocks.add((Object)blockMap);
        }

        payload.put('block', (Object)blocks);
        return JSON.serialize(payLoad);
    }

    public static Map<String, Object> sendPayload(String payload) {
        Map<String, Object> result = new Map<String, Object>();
        String endPoint = Constants.HEROKU_ENDPOINT + '/recommendedLearning'; 
        Map<String, String> headers = new Map<String, String> {
            'Authentication' => 'Bearer ' + Constants.HEROKU_API_KEY,
            'Content-Type' => 'application/json'
        };
        List<Slack_Notification_Error__c> errorList = new List<Slack_Notification_Error__c>();
        Map<String, Object> message = new Map<String, Object>{
            'notifications' => new Map<String, Object> {
                'learnerProfileId' => 'lpKey',
                'slackUserId' => 'slackId',
                'notificationMessages' => payload,
                'notificationType' => 'recommended-learning'
            }
        };

        try {
            String body = JSON.serialize(message);
            System.debug('Payload ------ '+body);
            HttpResponse res = Utilities.makeCallout(endPoint, 'POST', body, headers);
            Integer statusCode = res.getStatusCode();
            if(statusCode != 200 && statusCode != 201) {
                result.put('ok', (Object)false);
                Integration_Error__c ie = new Integration_Error__c(
                    Error_Message__c = 'Heroku Response Error Code :: '+ statusCode,
                    Http_Response_Body__c =  res.getBody()
                );
                result.put('error', (Object)ie);                
            } else {
                result.put('ok', (Object)true);
            }            
        } catch(Exception e) {
            result.put('ok', (Object)false);
            Integration_Error__c ie = new Integration_Error__c(
                Error_Message__c = 'sendRecommededNotification :: Exception :: '+ e.getMessage(),
                Http_Response_Body__c =  e.getStackTraceString()
            );
            result.put('error', (Object)ie);
            System.debug('Error:: Heroku api *********** :: ' + e.getMessage());
            System.debug('Error:: Heroku api *********** :: ' + e.getStackTraceString());
        }

        return result;        
    }     
    
}