public with sharing class utilitiesNP {
    public static sObject getSobjectByMap(Map<String, Object> sourceMap, String sObjectName) {
        return getSobjectByMap(sourceMap, sObjectName, constantsNP.NAMESPACE_API);
    }

    public static sObject getSobjectByMap(Map<String, Object> sourceMap, String sObjectName, String namespace) {
        List<Schema.Sobjectfield> thisObjectSchema;

        // Filter out std salesforce names. Like Contact and Account.
        sObjectName = (sObjectName.contains('__c')) ? namespace + sObjectName : sObjectName;

        Map<String, Object> objMap = new Map<String, Object>();
        Schema.SObjectType genericSObject = Schema.getGlobalDescribe().get(sObjectName);
        thisObjectSchema = genericSobject.getDescribe().fields.getMap().values();

        if (null != thisObjectSchema && null != sourceMap) {
            for (Schema.SObjectField field : thisObjectSchema) {
                Schema.DescribeFieldResult describedField = field.getDescribe();
                String fieldName = describedField.getLocalName();

                if(sourceMap.containsKey(fieldName)) {
                    Object jsonValue = sourceMap.get(fieldName);

                    //dates can't be empty string it needs to be null;
                    if(String.valueOf(describedField.getType()) == 'Date' && (String)jsonValue == '') {
                        jsonValue = null;
                    }

                    objMap.put(String.valueOf(field), jsonValue);
                }
            }
        }

        if (objMap.size() > 0) {
            return (sObject) JSON.deserialize(JSON.serialize(objMap), Type.forName(sObjectName));
        } else {
            return null;
        }
    }

    public static List<Schema.FieldSetMember> getFieldSet(String objType, String fieldSetName) {
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();

        Schema.SObjectType searchObjType = globalDescribeMap.get(constantsNP.NAMESPACE_API + objType);
        Schema.DescribeSObjectResult describeObj = searchObjType.getDescribe();
        Schema.FieldSet fieldSetObj = describeObj.FieldSets.getMap().get(constantsNP.NAMESPACE_API + fieldSetName);
        if(fieldSetObj == null) {
            return new List<Schema.FieldSetMember>();
        }
        return fieldSetObj.getFields();
    }

    public static String getAccessTokenFromRefresh(){
       // Auth_Setting__c authSettings = Auth_Setting__c.getOrgDefaults();

        String endPoint = 'https://login.salesforce.com/services/oauth2/token?';

        endPoint += 'grant_type=refresh_token' + '&client_id=' + constantsNP.CLIENT_ID +
            '&client_secret=' + constantsNP.CLIENT_SECRET + '&refresh_token=' + '5Aep8613HjGimJ61WOk_.CstVF1iydVQkEH_wngGMe2qKRCYIbPeraHPqUYB8EGqfc7fSWjVSsHSUWtlK_ebLsu';

        HttpResponse res = makeCallout(endPoint, 'POST');
        //handle non 200 status
        if(res.getStatusCode() != 200) {
            Map<String, Object> parsedRes = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

            /*Integration_Error__c errorObj = new Integration_Error__c(
                Error_Message__c = (String)parsedRes.get('error_description'),
                Http_Response_Body__c = res.getBody()
                );

            insert errorObj;*/
            System.debug('Error occured in oauth callout ...... '+res.getBody());

            return null;
        } else {
            Map<String, Object> parsedRes = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            return (String)parsedRes.get('access_token');
        }
    }

    public static HttpResponse makeCallout(String endPoint, String method){
        return makeCallout(endPoint, method, null, null);
    }

    public static HttpResponse makeCallout(String endPoint, String method, String body){
        return makeCallout(endPoint, method, body, null);
    }

    public static HttpResponse makeCallout(String endPoint, String method, Map<String, String> headers){
        return makeCallout(endPoint, method, null, headers);
    }

    public static HttpResponse makeCallout(String endPoint, String method, String body, Map<String, String> headers){
        Http h = new Http();
        HttpRequest req = new HttpRequest();

        req.setEndpoint(endPoint);
        req.setMethod(method);
        req.setTimeout(60000);

        if(body != null) {
            req.setHeader('Content-Type', 'application/json');
            req.setBody(body);
        }

        if(headers != null) {
            for(String header : headers.keySet()) {
                req.setHeader(header, headers.get(header));
            }
        }

        HttpResponse res = h.send(req);

        return res;
    }

    public static String getTimeZoneDisplayName(String tz){
        return Timezone.getTimeZone(tz).getDisplayName();
    }

   /* public static DateTime localizeSessionTime(Session__c scheduledSession, String fieldName){
        
        String sessionTZ = String.isNotEmpty(scheduledSession.Time_Zone__c) ? scheduledSession.Time_Zone__c : Org_Info__c.getOrgDefaults().Time_Zone__c;

        List<Session__History> sessionTimeEditHistories = [SELECT Field, CreatedDate, CreatedById 
                                                           FROM Session__History 
                                                           WHERE (Field =: fieldName OR Field = 'created')
                                                               AND ParentId =: scheduledSession.Id 
                                                           ORDER BY CreatedDate DESC
                                                           LIMIT 1];

        String lastModId = sessionTimeEditHistories.size() > 0 ? sessionTimeEditHistories[0].CreatedById : scheduledSession.OwnerId;
        String lastModTZ = [SELECT Id, TimeZoneSidKey 
                            FROM User 
                            WHERE Id =: lastModId].TimeZoneSidKey;

        DateTime sessionTime = (DateTime) scheduledSession.get(constants.NAMESPACE_API + fieldName);

        Integer lastModOffsetMs = Timezone.getTimeZone(lastModTZ).getOffset(sessionTime);
        Integer sessionOffsetMs = Timezone.getTimeZone(sessionTZ).getOffset(sessionTime);

        Integer totalOffsetHr = (lastModOffsetMs - sessionOffsetMs) / (60*60*1000);

        return sessionTime.addHours(totalOffsetHr);
    }*/
}