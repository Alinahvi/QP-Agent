public class RecommendationDataCloudMarketHelper {
    /**
     * Data Cloud Object Metadata
     */
    private static final String DATA_LAKE_OBJECT = 'ESE_MarketJourneyActivity__dlm';
    private static final String EMPLOYEE_NUMBER_FIELD = 'XL_EmployeeNumber__c';
    private static final String CONTENT_FIELD = 'Name__c';
    private static final String DATE_MODIFIED_FIELD = 'CreatedDate__c';

    /**
     * Data Cloud Market Data Wrapper Class
     */
    public class DataCloudMarketData {
        public String ToId { get; set;}
        public String FromId { get; set;}
        public String Status { get; set;}
        public String AEEmployeeNumber { get; set;}
        public String FLMEmployeeNumber { get; set;}
        public Date SentDate { get; set;}
        public String RecommendationName { get; set;}
        public String RecommendationId { get; set;}
        public Boolean FLMPush { get; set;}

        public DataCloudMarketData() {
            FLMPush = false;
        }
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
        // Get the first batch of recommendations
        String instanceUrl = dataCloudURL + '/api/v1/query';
        List<String> fields = new List<String>{ 'CreatedDate__c', 'XL_EventType__c', 'XL_EmployeeNumber__c', 'Name__c' };
        String params = '?limit=' + queryLimit + '&offset=' + queryOffset + '&orderby=' + EncodingUtil.urlEncode('CreatedDate__c ASC', 'UTF-8');

        String sqlQuery =
            'SELECT ' + String.join(fields, ', ') + ' ' +
            'FROM ' + DATA_LAKE_OBJECT + ' ' +
            'WHERE XL_EventType__c IN (\'lc-recommendation\', \'nudge-recommendation\') ';

        if (lastRunTime != null) {
            // Format Date Literal for Data Cloud as TIMESTAMP WITH TIME ZONE
            sqlQuery += 'AND ' + DATE_MODIFIED_FIELD + ' > TIMESTAMP \'' + lastRunTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '\' ';
        }

        System.debug('************** sqlQuery= ' + sqlQuery);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(instanceUrl + params);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + dataCloudToken);
        request.setBody('{"sql":' + JSON.serialize(sqlQuery) + '}');

        System.debug('request= ' + request.getBody());

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
        Set<String> flmEmployeeNumbers = new Set<String>();
        Map<String, String> lpIdByFLMEmployeeNumber = new Map<String, String>();
        Map<String, List<RecommendationDataCloudHelper.DataCloudRecommendation>> recommendationsByEmployeeNumber = new Map<String, List<RecommendationDataCloudHelper.DataCloudRecommendation>>();

        for (Map<String, String> dataObj : dataList) {
            String dateModifedString = dataObj.get(DATE_MODIFIED_FIELD);
 
            if(dateModifedString != null){
                dateModifedString = dateModifedString.replace('T', ' ');
                DateTime dateModified = DateTime.valueOfGMT(dateModifedString);

                if(nextRunTime == null || dateModified > nextRunTime) {
                    nextRunTime = dateModified;
                }
            }

            String recData = String.valueOf(dataObj.get(CONTENT_FIELD)).replace('|', ',');
            DataCloudMarketData recDataObj = (DataCloudMarketData)JSON.deserialize(recData, DataCloudMarketData.class);
            Integration_Error__c error = validateData(dataObj, recDataObj);

            if(error != null){
                errors.add(error);
                continue;
            }


            RecommendationDataCloudHelper.DataCloudRecommendation recommendation = new RecommendationDataCloudHelper.DataCloudRecommendation();

            recommendation.contentId = recDataObj.RecommendationId;
            recommendation.recommendationType = 'ESE_MarketJourneyActivity__dlm';

            if(recDataObj.FLMPush){
                recommendation.isNudge = true;
                recommendation.nudgerEmployeeNumber = recDataObj.FLMEmployeeNumber;
                flmEmployeeNumbers.add(recDataObj.FLMEmployeeNumber);
            }

            recommendation.employeeNumber = String.valueOf(dataObj.get(EMPLOYEE_NUMBER_FIELD));

            employeeNumbers.add(recommendation.employeeNumber);

            if (recommendationsByEmployeeNumber.containsKey(recommendation.employeeNumber)) {
                recommendationsByEmployeeNumber.get(recommendation.employeeNumber).add(recommendation);
            } else {
                recommendationsByEmployeeNumber.put(recommendation.employeeNumber, new List<RecommendationDataCloudHelper.DataCloudRecommendation>{ recommendation });
            }

            // Hard Coded Record Id for Testing
            //recommendation.contentId = 'a6JD3000000GsxGMAS';
        }

        if(!flmEmployeeNumbers.isEmpty()){
            for(Learner_Profile__c lp : [SELECT Id, Employee_Number__c FROM Learner_Profile__c WHERE Employee_Number__c IN :flmEmployeeNumbers]){
                lpIdByFLMEmployeeNumber.put(lp.Employee_Number__c, lp.Id);
            }
        }

        //Recommendations where we found a Learner Profile
        List<RecommendationDataCloudHelper.DataCloudRecommendation> recommendations = new List<RecommendationDataCloudHelper.DataCloudRecommendation>();

        // Find Learner Profile Ids that match employeeNumbers
        for (Learner_Profile__c learner :[SELECT Id, Employee_Number__c FROM Learner_Profile__c WHERE Employee_Number__c IN :employeeNumbers WITH USER_MODE]) {
            for (RecommendationDataCloudHelper.DataCloudRecommendation recommendation : recommendationsByEmployeeNumber.get(learner.Employee_Number__c)) {
                recommendation.key = RecommendationHelper.getRecommendationKey(learner.Id, recommendation.contentId);
                recommendation.learnerId = learner.Id;
                
                if(recommendation.isNudge){
                    recommendation.nudgerId = lpIdByFLMEmployeeNumber.get(recommendation.nudgerEmployeeNumber);
                }

                recommendations.add(recommendation);
            }

            recommendationsByEmployeeNumber.remove(learner.Employee_Number__c);
        }

        //Create errors for recommendations where we did not find a Learner Profile
        for (List<RecommendationDataCloudHelper.DataCloudRecommendation> recommendationList : recommendationsByEmployeeNumber.values()) {
            for (RecommendationDataCloudHelper.DataCloudRecommendation recommendation : recommendationList) {
                String errorMessage = 'No Learner Profile found for Employee Number: ' + recommendation.employeeNumber;
                System.debug(errorMessage);
                errors.add(new Integration_Error__c(Error_Message__c = errorMessage.left(255), Type__c = 'Data Cloud Market Recommendations'));
            }
        }

        RecommendationHelper.addSeedRecommendations(recommendations);

        if (!errors.isEmpty()) {
            Database.insert(errors, System.AccessLevel.USER_MODE);
        }

        return nextRunTime;
    }

    public static Integration_Error__c validateData(Map<String, String> dataObj, DataCloudMarketData recDataObj) {
        Integration_Error__c error = new Integration_Error__c();
        error.Type__c = 'Data Cloud Market Recommendations';

        if (!dataObj.containsKey(CONTENT_FIELD)) {
            error.Error_Message__c = CONTENT_FIELD + ' not found in Data Cloud Recommendation';
            return error;
        }

        if (!dataObj.containsKey(EMPLOYEE_NUMBER_FIELD)) {
            error.Error_Message__c = EMPLOYEE_NUMBER_FIELD + ' not found in Data Cloud Recommendation';
            return error;
        }

        if (recDataObj.RecommendationId == null) {
            error.Error_Message__c = 'RecommendationId not found in Data Cloud Recommendation';
            return error;
        }

        if (recDataObj.FLMPush && String.isEmpty(recDataObj.FLMEmployeeNumber)) {
            error.Error_Message__c = 'FLMEmployeeNumber not found in Data Cloud Recommendation';
            return error;
        }

        return null;
    }
}