public class RecommendationDataCloudSkillHelper {
    /**
     * Data Cloud Object Metadata
     */
    private static final String DATA_LAKE_OBJECT = 'ESE_XL_Skill_Recommendation__dlm';
    private static final String LEARNER_ID_FIELD = 'learner_id__c';
    private static final String CONTENT_FIELD = 'course_id__c';
    private static final String DATE_MODIFIED_FIELD = 'date_modified__c';

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
        List<String> fields = new List<String>{ 'date_modified__c', 'course_id__c', 'learner_id__c', 'skill_name__c', 'course_name__c' };
        String params = '?limit=' + queryLimit + '&offset=' + queryOffset + '&orderby=' + EncodingUtil.urlEncode('date_modified__c ASC', 'UTF-8');

        String sqlQuery = 'SELECT ' + String.join(fields, ', ') + ' ' +
                          'FROM ' + DATA_LAKE_OBJECT + ' ';

        if (lastRunTime != null) {
            // Format Date Literal for Data Cloud as TIMESTAMP WITH TIME ZONE
            sqlQuery += 'WHERE ' + DATE_MODIFIED_FIELD + ' > TIMESTAMP \'' + lastRunTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '\' ';
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
        Set<String> learnerIds = new Set<String>();
        Map<String, String> lpIdByFLMEmployeeNumber = new Map<String, String>();
        Map<String, List<RecommendationDataCloudHelper.DataCloudRecommendation>> recommendationsByLearnerId = new Map<String, List<RecommendationDataCloudHelper.DataCloudRecommendation>>();

        for (Map<String, String> dataObj : dataList) {
            String dateModifedString = dataObj.get(DATE_MODIFIED_FIELD);
 
            if(dateModifedString != null){
                dateModifedString = dateModifedString.replace('T', ' ');
                DateTime dateModified = DateTime.valueOfGMT(dateModifedString);

                if(nextRunTime == null || dateModified > nextRunTime) {
                    nextRunTime = dateModified;
                }
            }

            Integration_Error__c error = validateData(dataObj);

            if(error != null){
                errors.add(error);
                continue;
            }

            RecommendationDataCloudHelper.DataCloudRecommendation recommendation = new RecommendationDataCloudHelper.DataCloudRecommendation();

            recommendation.contentId = String.valueOf(dataObj.get(CONTENT_FIELD));
            recommendation.learnerId = String.valueOf(dataObj.get(LEARNER_ID_FIELD));
            recommendation.recommendationType = 'ESE_XL_Skill_Recommendation__dlm';
            // Hard Coded Testing debug
            //recommendation.learnerId = 'a5jD3000000pQ6pIAE';

            recommendation.key = RecommendationHelper.getRecommendationKey(recommendation.learnerId, recommendation.contentId);

            System.debug('*************** ' + recommendation);

            learnerIds.add(recommendation.learnerId);

            if (recommendationsByLearnerId.containsKey(recommendation.learnerId)) {
                recommendationsByLearnerId.get(recommendation.learnerId).add(recommendation);
            } else {
                recommendationsByLearnerId.put(recommendation.learnerId, new List<RecommendationDataCloudHelper.DataCloudRecommendation>{ recommendation });
            }

            // Hard Coded Record Id for Testing
            //recommendation.contentId = 'a6JD3000000GsxGMAS';
        }

        //Recommendations where we found a Learner Profile
        List<RecommendationDataCloudHelper.DataCloudRecommendation> recommendations = new List<RecommendationDataCloudHelper.DataCloudRecommendation>();

        for (Learner_Profile__c learner :[SELECT Id, Employee_Number__c FROM Learner_Profile__c WHERE Id IN :learnerIds WITH USER_MODE]) {
            if(recommendationsByLearnerId.containsKey(learner.Id)){
                recommendations.addAll(recommendationsByLearnerId.get(learner.Id));
            }

            recommendationsByLearnerId.remove(learner.Id);
        }

        //Create errors for recommendations where we did not find a Learner Profile
        for (List<RecommendationDataCloudHelper.DataCloudRecommendation> recommendationList : recommendationsByLearnerId.values()) {
            for (RecommendationDataCloudHelper.DataCloudRecommendation recommendation : recommendationList) {
                String errorMessage = 'No Learner Profile found for: ' + recommendation.learnerId;
                System.debug(errorMessage);
                errors.add(new Integration_Error__c(Error_Message__c = errorMessage.left(255), Type__c = 'Data Cloud Skill Recommendations'));
            }
        }

        RecommendationHelper.addSeedRecommendations(recommendations);

        if (!errors.isEmpty()) {
            Database.insert(errors, System.AccessLevel.USER_MODE);
        }

        return nextRunTime;
    }

    public static Integration_Error__c validateData(Map<String, String> dataObj) {
        Integration_Error__c error = new Integration_Error__c();
        error.Type__c = 'Data Cloud Skill Recommendations';

        if (!dataObj.containsKey(CONTENT_FIELD)) {
            error.Error_Message__c = CONTENT_FIELD + ' not found in Data Cloud Recommendation';
            return error;
        }

        if (!dataObj.containsKey(LEARNER_ID_FIELD)) {
            error.Error_Message__c = LEARNER_ID_FIELD + ' not found in Data Cloud Recommendation';
            return error;
        }

        return null;
    }
}