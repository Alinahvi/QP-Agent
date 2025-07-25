public class RecommendationDataCloudHelper {
    /**
     * Data Cloud Settings
     * NOTE : Replace with Prod record when ready
     */
    private static final String ENVIRONMENT = constants.IS_SANDBOX ? 'Sandbox' : 'Production'; // Replace with 'Production' when ready 
    private static final Map<String, String> ENVIRONMENT_NAMES = new Map<String, String>{
        'Dev' => 'SEED_Dev',
        'Sandbox' => 'SEED_Sandbox',
        'Production' => 'SEED_Production'  
    };
    private static final Data_Cloud_Settings__mdt DATA_CLOUD_MDT { get { return Data_Cloud_Settings__mdt.getInstance(ENVIRONMENT_NAMES.get(ENVIRONMENT)); } }
    private static final String ISSUER { get { return DATA_CLOUD_MDT.Seed_Consumer_Key__c; } }
    private static final String USERNAME { get { return  DATA_CLOUD_MDT.Seed_Integration_Username__c; } }
    private static final String SEED_URL { get { return  DATA_CLOUD_MDT.Seed_URL__c; } }
    private static final String AUDIENCE = 'https://login.salesforce.com'; // Use https://test.salesforce.com for sandbox
    private static final String KEY_NAME = ENVIRONMENT.equals('Production') ? 'prodcert' : ENVIRONMENT.equals('Sandbox') ? 'qasandbox' : 'devcert';
    private static final String TOKEN_URL = SEED_URL + '/services/a360/token';

    /**
     * Data Cloud Object Metadata
     */
    private static final String DATA_SPACE_NAME = 'BT_ES_Employee';
    private static final String DATA_SOURCE_FIELD = 'feature_level__c';
    private static final String DATA_LAKE_OBJECT = 'ESE_XL_AEs_Insights__dlm';
    private static final String EMPLOYEE_NUMBER_FIELD = 'emp_id__c';
    private static final String CONTENT_ID_FIELD = 'action_identifier__c';
    private static final String CONTENT_SOURCE_FIELD = 'action_source__c';
    private static final String DATE_MODIFIED_FIELD = 'date_modified__c';
    private static final Set<String> DATA_LAKE_FIELDS { get { return new Set<String> { CONTENT_SOURCE_FIELD, CONTENT_ID_FIELD, DATE_MODIFIED_FIELD, EMPLOYEE_NUMBER_FIELD }; } }

    /**
     * Data Cloud Recommendation Wrapper Class
     */
    public class DataCloudRecommendation {
        public Id contentId { get; set; } //course or asset
        public Id learnerId { get; set; } //learner profile
        public Id nudgerId { get; set;} //learner profile
        public Boolean isNudge { get; set;}
        public String recommendationType { get; set; } //data cloud object table
        public String employeeNumber { get; set; }
        public String nudgerEmployeeNumber { get; set; }
        public String key { get; set; }

        public DataCloudRecommendation(){
            isNudge = false;
        }
    }

    /**
     * Get Data Cloud Instance URL
     * @return HttpResponse from Data Cloud Token callout
     */
    public static HttpResponse getDataCloudToken() {
        String jwt = generateJWT();

        if (String.isEmpty(jwt)) {
            return null;
        }

        String accessToken = getAccessToken(jwt);

        if (accessToken == null) {
            System.debug('Failed to obtain Data Cloud Access Token.');
        }

        return exchangeTokenForDataCloudToken(accessToken);
    }

    /**
     * Query Data Cloud for recommendations made since last run time
     * Data Cloud Object = ESE_XL_AEs_Insights__dlm
     * @param dataCloudURL Data Cloud Instance URL
     * @param dataCloudToken Data Cloud Token
     * @param lastRunTime Last Time the batch job ran
     * @param queryLimit Number of records to return
     * @param queryOffset Number of records to skip
     * @return HttpResponse from Data Cloud
     */
    public static HttpResponse queryDataCloud(String dataCloudURL, String dataCloudToken, DateTime lastRunTime, Integer queryLimit, Integer queryOffset) {
        String instanceUrl = dataCloudURL + '/api/v1/query';
        String params = '?limit=' + queryLimit + '&offset=' + queryOffset + '&orderby=' + EncodingUtil.urlEncode(DATE_MODIFIED_FIELD + ' ASC', 'UTF-8');
        System.debug('************* instanceUrl ' + instanceUrl);
        String sqlQuery =
            'SELECT ' + String.join(DATA_LAKE_FIELDS, ', ') + ' ' +
            'FROM ' + DATA_LAKE_OBJECT + ' ' +
            'WHERE ' + DATA_SOURCE_FIELD + ' LIKE \'%GF%\' ' +
            'AND ' + CONTENT_SOURCE_FIELD + ' = \'ACT\' ' +
            'AND ' + CONTENT_ID_FIELD + ' LIKE \'a6J%\' '; // TODO : Filters out ACT1 Courses,remove after first run in Prod

        if (lastRunTime != null) {
            // Format Date Literal for Data Cloud as TIMESTAMP WITH TIME ZONE
            sqlQuery += 'AND ' + DATE_MODIFIED_FIELD + ' > TIMESTAMP \'' + lastRunTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '\' ';
        }

        // sqlQuery += 'ORDER BY ' + DATE_MODIFIED_FIELD + ' ASC ' +
        //     'LIMIT ' + queryLimit + ' ' +
        //     'OFFSET ' + queryOffset;

        HttpRequest request = new HttpRequest();
        request.setEndpoint(instanceUrl + params);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + dataCloudToken);
        request.setBody('{"sql":' + JSON.serialize(sqlQuery) + '}');
        request.setTimeout(120000);

        Http http = new Http();

        return http.send(request);
    }

    /**
     * Process Data Cloud ESE_XL_AEs_Insights__dlm Recommendations
     * @param dataList List of records from Data Cloud
     */
    public static DateTime processDataCloudRecommendations(List<Map<String, String>> dataList) {
        DateTime nextRunTime;
        List<Integration_Error__c> errors = new List<Integration_Error__c>();
        Set<String> employeeNumbers = new Set<String>();
        Map<String, List<DataCloudRecommendation>> recommendationsByEmployeeNumber = new Map<String, List<DataCloudRecommendation>>();

        for (Map<String, String> dataObj : dataList) {
            String dateModifedString = dataObj.get(DATE_MODIFIED_FIELD);
 
            if(dateModifedString != null){
                dateModifedString = dateModifedString.replace('T', ' ');
                DateTime dateModified = DateTime.valueOfGMT(dateModifedString);

                if(nextRunTime == null || dateModified > nextRunTime) {
                    nextRunTime = dateModified;
                }
            }

            DataCloudRecommendation recommendation = new DataCloudRecommendation();

            recommendation.recommendationType = 'ESE_XL_AEs_Insights__dlm';

            if (dataObj.containsKey(CONTENT_ID_FIELD)) {
                recommendation.contentId = String.valueOf(dataObj.get(CONTENT_ID_FIELD));
            } else {
                String errorMessage = 'CONTENT_ID_FIELD not found in Data Cloud Recommendation';
                System.debug(errorMessage);
                errors.add(new Integration_Error__c(Error_Message__c = errorMessage.left(255), Type__c = 'Data Cloud Recommendations'));
                continue;
            }

            if (dataObj.containsKey(EMPLOYEE_NUMBER_FIELD)) {
                recommendation.employeeNumber = String.valueOf(dataObj.get(EMPLOYEE_NUMBER_FIELD));

                employeeNumbers.add(recommendation.employeeNumber);

                if (recommendationsByEmployeeNumber.containsKey(recommendation.employeeNumber)) {
                    recommendationsByEmployeeNumber.get(recommendation.employeeNumber).add(recommendation);
                } else {
                    recommendationsByEmployeeNumber.put(recommendation.employeeNumber, new List<DataCloudRecommendation>{ recommendation });
                }

            } else {
                String errorMessage = 'EMPLOYEE_NUMBER_FIELD not found in Data Cloud Recommendation';
                System.debug(errorMessage);
                errors.add(new Integration_Error__c(Error_Message__c = errorMessage.left(255), Type__c = 'Data Cloud Recommendations'));
                continue;
            }

            // Hard Coded Record Id for Testing
            // recommendation.contentId = 'a6JD30000004qB9MAI';

            // recommendation.flmPush = false;
        }

        // ASSIGN EMPLOYEE NUMBERS TO LEARNER PROFILES for Testing / Debugging
        // List<Learner_Profile__c> learners = [SELECT Id, Employee_Number__c FROM Learner_Profile__c WHERE Employee_Number__c = null WITH USER_MODE];
        // if (!learners.isEmpty()) {
        //     List<String> employeeNumberList = new List<String>(employeeNumbers);
        //     for (Integer i = 0 ; i < learners.size() && i < employeeNumbers.size() ; i++) {
        //         learners[i].Employee_Number__c = employeeNumberList[i];
        //     }
    
        //     update learners;
        // }

        List<String> recommendationKeyList = new List<String>();

        // Find Learner Profile Ids that match employeeNumbers
        for (Learner_Profile__c learner :[SELECT Id, Employee_Number__c FROM Learner_Profile__c WHERE Employee_Number__c IN :employeeNumbers WITH USER_MODE]) {
            for (DataCloudRecommendation recommendation : recommendationsByEmployeeNumber.get(learner.Employee_Number__c)) {
                recommendation.key = RecommendationHelper.getRecommendationKey(learner.Id, recommendation.contentId);
                recommendation.learnerId = learner.Id;
            }
        }

        List<DataCloudRecommendation> recommendations = new List<DataCloudRecommendation>();

        for (List<DataCloudRecommendation> recommendationList : recommendationsByEmployeeNumber.values()) {
            for (DataCloudRecommendation recommendation : recommendationList) {
                if (recommendation.learnerId != null) {
                    recommendations.add(recommendation);
                } else {
                    String errorMessage = 'No Learner Profile found for Employee Number: ' + recommendation.employeeNumber;
                    System.debug(errorMessage);
                    errors.add(new Integration_Error__c(Error_Message__c = errorMessage.left(255), Type__c = 'Data Cloud Recommendations'));
                }
            }
        }

        RecommendationHelper.addSeedRecommendations(recommendations);

        if (!errors.isEmpty()) {
            Database.insert(errors, System.AccessLevel.USER_MODE);
        }

        return nextRunTime;
    }

    private static String generateJWT() {
        String header = '{"alg":"RS256"}';
        String claimsJson = JSON.serialize(
            new Map<String, Object>{
                'iss' => ISSUER,
                'sub' => USERNAME,
                'aud' => AUDIENCE,
                'exp' => ( System.now().addMinutes(3).getTime() / 1000 )
            }
        );
        System.debug('***************** ' + claimsJson);
        String encodedHeader = base64UrlEncode(Blob.valueOf(header));
        String encodedClaims = base64UrlEncode(Blob.valueOf(claimsJson));

        Blob signatureBlob = Crypto.signWithCertificate('RSA-SHA256', Blob.valueOf(encodedHeader + '.' + encodedClaims), KEY_NAME);
        String signature = base64UrlEncode(signatureBlob);

        String jwt = encodedHeader + '.' + encodedClaims + '.' + signature;

        return jwt;
    }

    private static String getAccessToken(String jwtToken) {
        String tokenEndpoint = AUDIENCE + '/services/oauth2/token';
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(tokenEndpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody('grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=' + EncodingUtil.urlEncode(jwtToken, 'UTF-8'));
        Http http = new Http();
        HttpResponse response;

        try {
            response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

                String accessToken = (String) responseBody.get('access_token');

                return accessToken;
            } else {
                String errorMessage = 'Failed to obtain Recommendation Data Cloud access token: ' + response.getStatus();
                System.debug(errorMessage + ' ' + response.getBody());
                insert as user new Integration_Error__c(Error_Message__c = errorMessage.left(255), Type__c = 'Data Cloud Recommendations', Http_Response_Body__c = response.getBody());
            }
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            String errorMessage = 'Failed to obtain Recommendation Data Cloud access token: ' + e.getMessage();
            System.debug(errorMessage);
            insert as user new Integration_Error__c(Error_Message__c = errorMessage.left(255), Type__c = 'Data Cloud Recommendations');
        }
        return null;
    }

    private static HttpResponse exchangeTokenForDataCloudToken(String accessToken) {
        String requestBody = String.format(
            'subject_token_type=urn:ietf:params:oauth:token-type:access_token&subject_token={0}&grant_type=urn:salesforce:grant-type:external:cdp&dataspace={1}',
            new List<String>{ 
                EncodingUtil.urlEncode(accessToken, 'UTF-8'), 
                DATA_SPACE_NAME 
            }
        );
            System.debug('************* ' + requestBody);
            System.debug('************* ' + TOKEN_URL);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(TOKEN_URL);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(requestBody);

        Http http = new Http();

        return http.send(request);
    }

    private static String base64UrlEncode(Blob input) {
        String output = EncodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        output = output.replaceAll('=+$', '');

        return output;
    }

    // Query using v2 API

    // /**
    //  * Query Data Cloud for recommendations made since last run time
    //  * Data Cloud Object = ESE_XL_AEs_Insights__dlm
    //  * @param dataCloudURL Data Cloud Instance URL
    //  * @param dataCloudToken Data Cloud Token
    //  * @param lastRunTime Last Time the batch job ran
    //  * @param queryLimit Number of records to return
    //  * @param queryOffset Number of records to skip
    //  * @return HttpResponse from Data Cloud
    //  */
    // public static HttpResponse queryDataCloud(String dataCloudURL, String dataCloudToken, DateTime lastRunTime, Integer queryLimit, Integer queryOffset) {
    //     String instanceUrl = dataCloudURL + '/api/v2/query';
    //     String sqlQuery =
    //         'SELECT ' + String.join(DATA_LAKE_FIELDS, ', ') + ' ' +
    //         'FROM ' + DATA_LAKE_OBJECT + ' ' +
    //         'WHERE DataSourceObject__c LIKE \'%GF%\' ' +
    //         'AND ' + CONTENT_SOURCE_FIELD + ' = \'ACT\' ' +
    //         'AND ' + CONTENT_ID_FIELD + ' LIKE \'a6J%\' '; // TODO : Filters out ACT1 Courses,remove after first run in Prod

    //     if (lastRunTime != null) {
    //         // Format Date Literal for Data Cloud as TIMESTAMP WITH TIME ZONE
    //         sqlQuery += 'AND ' + DATE_MODIFIED_FIELD + ' > TIMESTAMP \'' + lastRunTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '\' ';
    //     }

    //     sqlQuery += 'ORDER BY ' + DATE_MODIFIED_FIELD + ' ASC ' +
    //         'LIMIT ' + queryLimit + ' ' +
    //         'OFFSET ' + queryOffset;

    //     HttpRequest request = new HttpRequest();
    //     request.setEndpoint(instanceUrl);
    //     request.setMethod('POST');
    //     request.setHeader('Content-Type', 'application/json');
    //     request.setHeader('Authorization', 'Bearer ' + dataCloudToken);
    //     request.setBody('{"sql":' + JSON.serialize(sqlQuery) + '}');
    //     request.setTimeout(120000);

    //     Http http = new Http();

    //     return http.send(request);
    // }

    /**
     * OLD CODE FOR QUERYING / PROCESSING ESE_MarketJourneyActivity__dlm
     */
    /*
    SEED ACTIVITY, NOT USED CURRENTLY Data Model Object Name : 

    ESE_MarketJourneyActivity__dlm

    Fields :

    CreatedDate__c : Contains the date when the recommendation captured on SEED
    XL_EventType__c : Uniquely identifies the type of event, Currently three types of events can be pulled → lc-recommendation-act or gf-recommendation-act or skill-recommendation-act
    XL_EmployeeNumber__c : Employee Number of the AE
    Name__c : Contains payload with different fields as below
        ToId : Slack Id of AE
        FromId : Slack Id of FLM
        Status : Status of the captured information from SEED app to Data Cloud
        AEEmployeeNumber : Employee Number of of AE
        FLMEmployeeNumber : Employee Number of FLM, It is blank for Non FLMPush recommendations
        SentDate : Date on which Recommendation captured on SEED
        RecommendationName : Recommendation Name
        RecommendationId : Recommendation Id
        FLMPush : true for FLM push recommendations and false for non FLM push recommendations
    */

    // QUERY FOR ESE_MarketJourneyActivity__dlm
    public static HttpResponse queryDataCloudForMarketJourney(String dataCloudURL, String dataCloudToken, DateTime lastRunTime, Integer queryLimit, Integer queryOffset) {
        // Get the first batch of recommendations
        String instanceUrl = dataCloudURL + '/api/v1/query';
        // String params = '?limit=' + queryLimit + '&offset=' + queryOffset + '&orderby=' + EncodingUtil.urlEncode(DATE_MODIFIED_FIELD + ' ASC', 'UTF-8');

        String sqlQuery =
            'SELECT CreatedDate__c, XL_EventType__c, XL_EmployeeNumber__c, Name__c ' +
            'FROM ESE_MarketJourneyActivity__dlm ' +
            'WHERE XL_EventType__c IN (\'lc-recommendation\', ' +
            '\'nudge-recommendation\') ';

        if (lastRunTime != null) {
            // Format Date Literal for Data Cloud as TIMESTAMP WITH TIME ZONE
            sqlQuery += 'AND CreatedDate__c > TIMESTAMP \'' + lastRunTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '\' ';
        }

        HttpRequest request = new HttpRequest();
        request.setEndpoint(instanceUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + dataCloudToken);
        request.setBody('{"sql":' + JSON.serialize(sqlQuery) + '}');

        System.debug('request= ' + request.getBody());

        request.setTimeout(120000);
        Http http = new Http();

        return http.send(request);
    }

    // PROCESSING FOR ESE_MarketJourneyActivity__dlm
    // public static void processDataCloudRecommendations(List<Object> dataList, Map<String, Integer> fieldIndex) {
    //     Set<String> employeeNumbers = new Set<String>();
    //     Map<String, List<DataCloudRecommendation>> recommendationsByEmployeeNumber = new Map<String, List<DataCloudRecommendation>>();

    //     for (Object data : dataList) {
    //         System.debug('data= ' + data);

    //         List<Object> dataArray = (List<Object>) data;

    //         String name = String.valueOf(dataArray[fieldIndex.get('Name__c')]).replace('|', ',');

    //         // Use Regex to Replace " with \" anywhere it's not either before or after the following characters: { or } or : or ,
    //         name = name.replaceAll('(?<!\\{|\\}|:|,|\\\\)\"(?!\\{|\\}|:|,|\\\\)', '\\\\"');

    //         Map<String, Object> nameObj = (Map<String, Object>) JSON.deserializeUntyped(name);

    //         DataCloudRecommendation recommendation = new DataCloudRecommendation();

    //         // Get XL_EmployeeNumber__c
    //         recommendation.employeeNumber = String.valueOf(nameObj.get('AEEmployeeNumber'));

    //         // recommendation.contentId = String.valueOf(nameObj.get('RecommendationId'));
    //         recommendation.contentId = 'a6JD30000004qB9MAI';


    //         // Get FLMPush from Name__c
    //         recommendation.flmPush = Boolean.valueOf(nameObj.get('FLMPush'));

    //         // Add to employeeNumbers
    //         employeeNumbers.add(recommendation.employeeNumber);

    //         // Add to recommendationsByEmployeeNumber
    //         if (recommendationsByEmployeeNumber.containsKey(recommendation.employeeNumber)) {
    //             recommendationsByEmployeeNumber.get(recommendation.employeeNumber).add(recommendation);
    //         } else {
    //             recommendationsByEmployeeNumber.put(recommendation.employeeNumber, new List<DataCloudRecommendation>{ recommendation });
    //         }
    //     }

    //     // System.debug('recommendationsByEmployeeNumber= ' + recommendationsByEmployeeNumber);

    //     List<String> recommendationKeyList = new List<String>();

    //     // Find Learner Profile Ids that match employeeNumbers
    //     for (Learner_Profile__c learner :[SELECT Id, Employee_Number__c FROM Learner_Profile__c WHERE Employee_Number__c IN :employeeNumbers WITH USER_MODE]) {
    //         for (DataCloudRecommendation recommendation : recommendationsByEmployeeNumber.get(learner.Employee_Number__c)) {
    //             recommendation.key = RecommendationHelper.getRecommendationKey(learner.Id, recommendation.contentId);
    //             recommendation.learnerId = learner.Id;
    //         }
    //     }

    //     // System.debug('recommendationsByEmployeeNumber.values()= ' + recommendationsByEmployeeNumber.values());
    //     List<DataCloudRecommendation> recommendations = new List<DataCloudRecommendation>();

    //     for (List<DataCloudRecommendation> recommendationList : recommendationsByEmployeeNumber.values()) {
    //         recommendations.addAll(recommendationList);
    //     }

    //     RecommendationHelper.addSeedRecommendations(recommendations);
    //     RecommendationHelper.performDml();
    // }
}