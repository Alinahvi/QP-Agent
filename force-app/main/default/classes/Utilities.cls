public with sharing class Utilities { 
    public class customException extends Exception {}

    /**
     * Batch Threshold for processing Datatable records
     */
    public static final Integer BATCH_THRESHOLD = 300;

    /**
     * Class to hold the parametrs used to process DataTable records
     */
    public virtual class DataTablePayload {
        // The Id of the record page that the DataTable is on
        @AuraEnabled 
        public Id recordId { get; set; }

        // The Ids of the selected records
        @AuraEnabled 
        public List<Id> idsToProcess { get; set; }

        // Search term the records are filtered by
        @AuraEnabled
        public String searchTerm { get; set; }

        // Current page of the DataTable
        @AuraEnabled
        public Integer page { get; set; }

        // Ids of records currently displayed on the DataTable
        @AuraEnabled
        public List<Id> currentlyDisplayedIds { get; set; }

        // True if all records are selected
        @AuraEnabled
        public Boolean selectAll { get; set; }
    }

    /**
     * Returns the current status of an ongoing batch job
     */
    @AuraEnabled
    public static ResponseData getBatchProgress(Id jobId, String apexClass){
        ResponseData rd = new ResponseData();
        
        try {
            Boolean inProgress = false;

            List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :jobId];

            if (jobs.isEmpty()) {
                throw new customException(apexClass + ' Batch Job Not Found, Job ID = ' + jobId);
            }

            switch on jobs[0].Status {
                when 'Queued', 'Preparing', 'Holding', 'Processing' {
                    inProgress = true;          
                }
                when 'Completed' {
                    inProgress = false;
                }
                when else {
                    throw new customException(apexClass + ' Batch Job ' + jobs[0].Status + ', Job ID = ' + jobId);
                }
            }

            rd.put('inProgress', inProgress);          
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    public static sObject getSobjectByMap(Object sourceMap, String sObjectName) {
        return getSobjectByMap((Map<String, Object>)sourceMap, sObjectName, '');
    }

    public static sObject getSobjectByMap(Map<String, Object> sourceMap, String sObjectName) {
        return getSobjectByMap(sourceMap, sObjectName, '');
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
                    if(String.valueOf(describedField.getType()) == 'Date' && String.valueOf(jsonValue) == '') {
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
        Schema.SObjectType searchObjType = globalDescribeMap.get(objType);
        Schema.DescribeSObjectResult describeObj = searchObjType.getDescribe();
        Schema.FieldSet fieldSetObj = describeObj.FieldSets.getMap().get(fieldSetName);
        if(fieldSetObj == null) {
            return new List<Schema.FieldSetMember>();
        }

        return fieldSetObj.getFields();
    }

    public static String getAccessTokenFromRefresh(){
        Auth_Setting__c authSettings = Auth_Setting__c.getOrgDefaults();
        String refreshToken = authSettings.Refresh_Token__c;

        String endPoint = 'https://login.salesforce.com/services/oauth2/token?';
        // String endPoint = 'https://test.salesforce.com/services/oauth2/token?';

        endPoint += 'grant_type=refresh_token' +
                    '&client_id=' + Constants.CLIENT_ID +
                    '&client_secret=' + Constants.CLIENT_SECRET +
                    '&refresh_token=' + refreshToken;

        System.debug('******* endPoint ' + endPoint);

        HttpResponse res = makeCallout(endPoint, 'POST');

        System.debug('******* token res status code : ' + res.getStatusCode());
        System.debug('******* token res body : ' + res.getBody());
        //handle non 200 status
        if(res.getStatusCode() != 200) {
            Map<String, Object> parsedRes = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

            Integration_Error__c errorObj = new Integration_Error__c(
                Error_Message__c = (String)parsedRes.get('error_description'),
                Http_Response_Body__c = res.getBody(),
                Type__c = 'OAuth Refresh'
            );

            insert as user errorObj;

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
        req.setTimeout(120000);

        if(body != null) {
            if(!headers.containsKey('Content-Type')){
                req.setHeader('Content-Type', 'application/json');
            }

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

    public static DateTime localizeSessionTime(Session__c scheduledSession, String fieldName){
        String sessionTZ = String.isNotEmpty(scheduledSession.Time_Zone__c) ? scheduledSession.Time_Zone__c : '';
        //
        // List<Session__History> sessionTimeEditHistories = [SELECT Field, CreatedDate, CreatedById
        //                                                    FROM Session__History
        //                                                    WHERE (Field =: fieldName OR Field = 'created')
        //                                                        AND ParentId =: scheduledSession.Id
        //                                                    ORDER BY CreatedDate DESC
        //                                                    LIMIT 1];
        //
        // String lastModId = sessionTimeEditHistories.size() > 0 ? sessionTimeEditHistories[0].CreatedById : scheduledSession.OwnerId;
        // String lastModTZ = [SELECT Id, TimeZoneSidKey
        //                     FROM User
        //                     WHERE Id =: lastModId].TimeZoneSidKey;
        //
        DateTime sessionTime = (DateTime) scheduledSession.get(fieldName);
        //
        // Integer lastModOffsetMs = Timezone.getTimeZone(lastModTZ).getOffset(sessionTime);
        Integer offSetHours = Timezone.getTimeZone(sessionTZ).getOffset(sessionTime) / (1000 * 60 * 60);

        // Integer totalOffsetMins = (lastModOffsetMs - sessionOffsetMs) / (60*1000);

        return sessionTime.addHours(offSetHours);
    }

    public static List<String> slice(List<String> input, Integer startIndex, Integer endIndex) {
        List<String> output = new List<String>();
        for(Integer i = 0; i < startIndex; i++) {
            input.remove(0);
        }

        for(Integer i = 0; i < endIndex; i++) {
            if(input.size() > 0) {
                output.add(input.remove(0));
            }
        }
        return output;
    }

    public static List<Map<String, String>> getPicklistVals(Schema.DescribeFieldResult fieldResult){
        List<Map<String, String>> picklistVals = new List<Map<String, String>>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for( Schema.PicklistEntry f : ple) {
            Map<String, String> picklistVal = new Map<String, String>();

            picklistVal.put('label', f.getLabel());
            picklistVal.put('value', f.getValue());
            
            picklistVals.add(picklistVal);
        }

        return picklistVals;
    }

    // Wrapper class for picklist entries
    private class PicklistEntryWrapper implements Comparable {
        public String label;
        public String value;

        public PicklistEntryWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }

        // Compare method to sort by label
        public Integer compareTo(Object obj) {
            PicklistEntryWrapper other = (PicklistEntryWrapper)obj;
            return this.label.compareTo(other.label);
        }
    }

    public static List<Map<String, String>> getPicklistVals(Schema.DescribeFieldResult fieldResult, Boolean sortPicklist){
        List<PicklistEntryWrapper> wrappers = new List<PicklistEntryWrapper>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for(Schema.PicklistEntry f : ple) {
            wrappers.add(new PicklistEntryWrapper(f.getLabel(), f.getValue()));
        }

        // Sort the wrapper list if sortPicklist is true
        if(sortPicklist) {
            wrappers.sort();
        }

        // Convert the sorted wrappers back into a list of maps
        List<Map<String, String>> picklistVals = new List<Map<String, String>>();
        for(PicklistEntryWrapper wrapper : wrappers) {
            Map<String, String> picklistVal = new Map<String, String>();
            picklistVal.put('label', wrapper.label);
            picklistVal.put('value', wrapper.value);
            picklistVals.add(picklistVal);
        }

        return picklistVals;
    }

    public static List<Object> sortByField(List<Object> objsToSort, String fieldToCompare, Boolean sortDesc){
        List<sorterWrapper> sorterWrappers = new List<sorterWrapper>();
        List<Object> sortedObjs = new List<Object>();

        for(Object sObj : objsToSort){
            sorterWrappers.add(new sorterWrapper(sObj, fieldToCompare, sortDesc));
        }

        sorterWrappers.sort();

        for(sorterWrapper sorterWrapper : sorterWrappers){
            sortedObjs.add(sorterWrapper.sourceSObj);
        }

        return sortedObjs;
    }

    public class sorterWrapper implements Comparable{
        public Object sourceSObj;
        public String compareField;
        public Boolean sortDesc;

        public sorterWrapper(Object sObj, String fieldToCompare, Boolean sortDesc){
            this.sourceSObj = sObj;
            this.compareField = fieldToCompare;
            this.sortDesc = sortDesc;
        }

        public Integer compareTo(Object compareTo){
            sorterWrapper compareSorterWrapper = (sorterWrapper)compareTo;
            Map<String,Object> sourceMap = (Map<String,Object>)sourceSObj;
            Map<String,Object> compareMap = (Map<String,Object>)compareSorterWrapper.sourceSObj;

            Integer returnValue = 0;
            Object sourceValue = sourceMap.get(compareField);
            Object compareValue = compareMap.get(compareSorterWrapper.compareField);

            if(sourceValue instanceOf Integer){
                Integer source = (Integer)sourceValue;
                Integer compare = (Integer)compareValue;

                if(source > compare){
                    returnValue = 1;
                } else if(source < compare){
                    returnValue = -1;
                }
            } else if(sourceValue instanceOf Decimal){
                Decimal source = (Decimal)sourceValue;
                Decimal compare = (Decimal)compareValue;

                if(source > compare){
                    returnValue = 1;
                } else if(source < compare){
                    returnValue = -1;
                }
            }  else if(sourceValue instanceOf Date){
                Date source = (Date)sourceValue;
                Date compare = (Date)compareValue;

                if(source > compare){
                    returnValue = 1;
                } else if(source < compare){
                    returnValue = -1;
                }
            } else if(sourceValue instanceOf DateTime){
                DateTime source = (DateTime)sourceValue;
                DateTime compare = (DateTime)compareValue;

                if(source > compare){
                    returnValue = 1;
                } else if(source < compare){
                    returnValue = -1;
                }
            } else {
                String source = String.valueOf(sourceValue);
                String compare = String.valueOf(compareValue);

                if(source > compare){
                    returnValue = 1;
                } else if(source < compare){
                    returnValue = -1;
                }
            }

            if(sortDesc){
                returnValue *= -1;
            }

            return returnValue;
        }
    }

    private static Map<String, Schema.SObjectField> lpFields;

    //
    public static String getCriteriaWhereClause(String audienceId, String criteriaLogic){
        List<Target_Criteria__c> tcs = [SELECT Id, Audience__c, Boolean_Value__c, Date_Value__c, Display_Value__c, 
                                               Field__c, Number_Value__c, Text_Value__c , Operator__c, 
                                               Custom_Soql__c
                                        FROM Target_Criteria__c
                                        WHERE Audience__c =: audienceId
                                        WITH USER_MODE
                                        ORDER BY Order__c ASC];

        if(tcs.isEmpty()){
            return '';
        }

        String whereClause = '';

        if(tcs.get(0).Field__c == 'Custom'){
            whereClause += tcs.get(0).Custom_Soql__c;
        } else {
            List<String> formatValues = formatCriteriaValues(tcs);

            if(String.isNotEmpty(criteriaLogic)){
                //need to fake the 0th entry since our filter logic index starts at {1}
                formatValues.add(0, '');
                String formatabbleCriteriaLogic = criteriaLogic.replaceAll('([\\d]+)','{$1}');
                whereClause += String.format(formatabbleCriteriaLogic, formatValues);
            } else {
                whereClause += String.join(formatValues, ' AND ');
            }
        }
        
        return whereClause;
    }

    public static List<String> formatCriteriaValues(List<Target_Criteria__c> tcs){
        List<String> values = new List<String>();

        if(lpFields == null){
            lpFields = Learner_Profile__c.SObjectType.getDescribe().fields.getMap();
        }

        for(Target_Criteria__c tc : tcs) {
            String memberField = tc.Field__c;
            String operator = tc.Operator__c;
            String soqlOperator = ' ' + operator + ' ';
            Schema.DescribeFieldResult describedField = lpFields.get(tc.Field__c).getDescribe();
            String fieldType = describedField.getType() + '';

            if(fieldType == 'BOOLEAN') {
                values.add(memberField + soqlOperator + tc.Boolean_Value__c);
            } else if(fieldType == 'DATE' || fieldType == 'DATETIME') {
                String dateValStr = String.valueOf(tc.Date_Value__c);

                if(fieldType == 'DATETIME') {
                    dateValStr += 'T00:00:00.000Z';
                }

                values.add(memberField + soqlOperator + dateValStr);
            } else if(fieldType == 'INTEGER' || fieldType == 'DOUBLE' || fieldType == 'PERCENT') {
                values.add(memberField + soqlOperator + tc.Number_Value__c);
            } else if(fieldType == 'MULTIPICKLIST') {
                String textVal = String.escapeSingleQuotes(tc.Text_Value__c);

                if(operator == 'includes' || operator == 'excludes'){
                    textVal = '(\'' + textVal.replace(';', '\',\'') + '\')';
                } else {
                    textVal = '\'' + textVal + '\'';
                }

                values.add(memberField + soqlOperator + textVal);
            } else if(fieldType == 'PICKLIST' || fieldType == 'STRING' || fieldType == 'EMAIL') {
                List<String> textVals = new List<String>();

                if(fieldType == 'PICKLIST' || fieldType == 'STRING' || fieldType == 'EMAIL'){
                    textVals = String.escapeSingleQuotes(tc.Text_Value__c).split(';');
                } else {
                    textVals.add(tc.Text_Value__c);
                }
                
                String textValWhereClause = ' (';

                //we need it to be NOT (Field__c LIKE '%val1%' OR Field__c LIKE '%val2%');
                if(operator == 'does not contains'){
                    textValWhereClause = ' ( NOT ';
                }

                for(String textVal : textVals) {
                    if(operator == 'contains' || operator == 'does not contains' || operator == 'starts with'){
                        soqlOperator = ' LIKE ';
                        
                        if(operator == 'starts with'){
                            textVal = textVal + '%';
                        } else {
                            textVal = '%' + textVal + '%';
                        }
                    }

                    textValWhereClause += ' ' + memberField + soqlOperator + ' \'' + textVal + '\'';
                    
                    
                    if(operator == '!=' || operator == 'does not contains'){
                        textValWhereClause += ' AND';
                    } else {
                        textValWhereClause += ' OR';
                    }
                }
                
                textValWhereClause = textValWhereClause.removeEnd(' AND');
                textValWhereClause = textValWhereClause.removeEnd(' OR');
                textValWhereClause += ')';

                values.add(textValWhereClause);
            }
        }

        return values;
    }

    public static String getZoomAccessToken(){
        String accessToken;
        String endpoint = 'https://zoom.us/oauth/token?grant_type=account_credentials&account_id=' + constants.ZOOM_ACCOUNT_ID;
        String creds = constants.ZOOM_ADMIN_CLIENT_ID + ':' + constants.ZOOM_ADMIN_CLIENT_SECRET;
        String base64Creds = sanatizeBase64(EncodingUtil.base64Encode(Blob.valueOf(creds)));
        Map<String, String> headers = new Map<String, String>{
            'Authorization' => 'Basic ' + base64Creds
        };

        HttpResponse res = makeCallout(endPoint, 'POST', headers);
        
        if(res.getStatusCode() == 200) {
            accessToken = (String)((Map<String, Object>)JSON.deserializeUntyped(res.getBody())).get('access_token');
        } else {
            Map<String, Object> parsedRes = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

            Integration_Error__c errorObj = new Integration_Error__c(
                Error_Message__c = (String)parsedRes.get('error_description'),
                Http_Response_Body__c = res.getBody()
            );

            insert as user errorObj;
        }

        return accessToken;
    }

    public static String sanatizeBase64(String base64){
        return base64.replaceAll('=', '').replaceAll('\\+', '-').replaceAll('/', '_');
    }
	
	public static HttpResponse makeNCCallout(String endPoint, String method){
        return makeCallout(endPoint, method, null, null);
    }
    
    public static HttpResponse makeNCCallout(String endPoint, String method, Map<String, String> headers) {
        return makeNCCallout(endPoint, method, null, headers);
    }

    public static HttpResponse makeNCCallout(String endPoint, String method, String body, Map<String, String> headers) {
        Http h = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(endPoint); 
        request.setMethod(method);
        request.setTimeout(120000);        
        
        if(headers != null) {
            for(String header : headers.keySet()) {
                request.setHeader(header, headers.get(header));
            }
        }

        if(body != null) {
            request.setBody(body);
        }
        
        HttpResponse res = h.send(request);
        return res;
    }

    public static String getErrorMessage(Exception e){
        String errMsg = e.getMessage();

        if(e.getTypeName() == 'System.QueryException' && !e.getInaccessibleFields().isEmpty()){
            errMsg = 'Missing permissions for';

            for(String obj : e.getInaccessibleFields().keySet()){
                errMsg += ' ' + obj + ': ' + (String.join(new List<String>(e.getInaccessibleFields().get(obj)), ', '));
            }
        } else if(e.getTypeName() == 'System.DMLException' && errMsg.contains('fields being inaccessible') && !e.getDmlFieldNames(0).isEmpty()){
            String objType = e.getDmlFields(0).get(0).getDescribe().getSObjectType() + '';
            errMsg = 'Error: Make sure you have access to the following fields on ' + objType + ': [' + String.join(e.getDmlFieldNames(0), ', ') + ']';
        }

        return errMsg;
    }

    public static String getHerokuEndpoint() {
        String sfUrl = System.URL.getOrgDomainUrl().toExternalForm();
        if(sfUrl.contains('readiness--act2dev')) {
            return 'https://act-slack-app-1ef373b96ec0.herokuapp.com/dev';
        } else if(sfUrl.contains('readiness--act2qa')) {
            return 'https://act-slack-app-1ef373b96ec0.herokuapp.com/dev';
        } else if(sfUrl.contains('readiness--act2uat')) {
            return 'https://act-slack-app-uat-c6dff6c87e89.herokuapp.com/uat';
        } else if(sfUrl.contains('readiness.my')) {
            return 'https://act-slack-app-prod-660658f0d117.herokuapp.com/prod';
        } else {
            return 'https://act-slack-app-1ef373b96ec0.herokuapp.com/dev';
        } 
    }

    public static String getHerokuApiKey(Credentials__mdt credentials) {
        String sfUrl = System.URL.getOrgDomainUrl().toExternalForm();
        if(sfUrl.contains('readiness--act2dev')) {
            return credentials.Heroku_Api_Key__c;
        } else if(sfUrl.contains('readiness--act2qa')) {
            return credentials.Heroku_Api_Key__c;
        } else if(sfUrl.contains('readiness--act2uat')) {
            return credentials.Heroku_Api_Uat_Key__c;
        } else if(sfUrl.contains('readiness.my')) {
            return credentials.Heroku_Api_Prod_Key__c;
        } else {
            return credentials.Heroku_Api_Key__c;
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getSiteOrigin() {
        String siteBaseUrl = Site.getBaseUrl();
        if (String.isEmpty(siteBaseUrl)) {
            return siteBaseUrl;
        }
        return 'https://' + (new URL(siteBaseUrl)).getHost();
    }
}