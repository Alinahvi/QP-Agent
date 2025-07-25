public class SEEDDataCloudTaxonomyHelper {
    /**
     * Data Cloud Object Metadata
     */
    private static final String DATA_LAKE_OBJECT = 'ESE_XL_SEED_Taxonomy__dlm';

    /**
     * Data Cloud Market Data Wrapper Class
     */
    // public class DataCloudSeedData {
    //     public String UUID__c {get; set;}
    //     public String Type__c {get; set;}
    //     public String Role_Name__c {get; set;}
    //     public String Skill_Name__c {get; set;}
    //     public String Category__c {get; set;}
    //     public String Growth_Factor__c {get; set;}
    //     public String Product_Level_1__c {get; set;}
    //     public String Product_Level_2__c {get; set;}
    //     public String Language_Label__c {get; set;}
    //     public String API_Name__c {get; set;}
    //     public String Enablement_Learning_Program__c {get; set;}
    //     public String Competency__c {get; set;}
    //     public String Definition__c {get; set;}
    //     public String AI_Defintion__c {get; set;}
    //     public String APM1__c {get; set;}
    //     public String APM2__c {get; set;}
    //     public String APM3__c {get; set;}
    //     public String APM4__c {get; set;}
    //     public String Statement__c {get; set;}
    //     public String Proficiency_Level__c {get; set;}
    //     public String Job_Code__c {get; set;}
    //     public String Role_Acronym__c {get; set;}
    //     public String Target__c {get; set;}
    //     public String Order__c {get; set;}
    // }

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
        //Growth_Factor__c is missing for some reason?
        List<String> fields = new List<String>{'UUID__c', 'Type__c', 'Role_Name__c', 'Skill_Name__c', 'Category__c', 
                                               'Product_Level_1__c', 'Product_Level_2__c', 'Language_Label__c', 
                                               'API_Name__c', 'Enablement_Learning_Program__c', 'Competency__c', 'Definition__c', 
                                               'AI_Defintion__c', 'APM1__c', 'APM2__c', 'APM3__c', 'APM4__c', 'Statement__c', 
                                               'Proficiency_Level__c', 'Job_Code__c', 'Role_Acronym__c', 'Target__c', 'Order__c'};

        // List<String> fields = new List<String>{'*'};

        String params = '?limit=' + queryLimit + '&offset=' + queryOffset;

        String sqlQuery = 'SELECT ' + String.join(fields, ', ') + ' ' +
                          'FROM ' + DATA_LAKE_OBJECT + ' ';

        // if (lastRunTime != null) {
        //     // Format Date Literal for Data Cloud as TIMESTAMP WITH TIME ZONE
        //     sqlQuery += 'WHERE ' + DATE_MODIFIED_FIELD + ' > TIMESTAMP \'' + lastRunTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '\' ';
        // }

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
    // public static DateTime processDataCloudRecommendations(List<Map<String, String>> dataList) {
    //     DateTime nextRunTime;
    //     List<Integration_Error__c> errors = new List<Integration_Error__c>();
    //     Set<String> learnerIds = new Set<String>();
    //     Map<String, String> lpIdByFLMEmployeeNumber = new Map<String, String>();
    //     Map<String, List<RecommendationDataCloudHelper.DataCloudRecommendation>> recommendationsByLearnerId = new Map<String, List<RecommendationDataCloudHelper.DataCloudRecommendation>>();

    //     for (Map<String, String> dataObj : dataList) {
    //         String dateModifedString = dataObj.get(DATE_MODIFIED_FIELD);
 
    //         if(dateModifedString != null){
    //             dateModifedString = dateModifedString.replace('T', ' ');
    //             DateTime dateModified = DateTime.valueOfGMT(dateModifedString);

    //             if(nextRunTime == null || dateModified > nextRunTime) {
    //                 nextRunTime = dateModified;
    //             }
    //         }

    //         Integration_Error__c error = validateData(dataObj);

    //         if(error != null){
    //             errors.add(error);
    //             continue;
    //         }

    //         RecommendationDataCloudHelper.DataCloudRecommendation recommendation = new RecommendationDataCloudHelper.DataCloudRecommendation();

    //         recommendation.contentId = String.valueOf(dataObj.get(CONTENT_FIELD));
    //         recommendation.learnerId = String.valueOf(dataObj.get(LEARNER_ID_FIELD));
    //         recommendation.recommendationType = 'ESE_XL_Skill_Recommendation__dlm';
    //         // Hard Coded Testing debug
    //         //recommendation.learnerId = 'a5jD3000000pQ6pIAE';

    //         recommendation.key = RecommendationHelper.getRecommendationKey(recommendation.learnerId, recommendation.contentId);

    //         System.debug('*************** ' + recommendation);

    //         learnerIds.add(recommendation.learnerId);

    //         if (recommendationsByLearnerId.containsKey(recommendation.learnerId)) {
    //             recommendationsByLearnerId.get(recommendation.learnerId).add(recommendation);
    //         } else {
    //             recommendationsByLearnerId.put(recommendation.learnerId, new List<RecommendationDataCloudHelper.DataCloudRecommendation>{ recommendation });
    //         }

    //         // Hard Coded Record Id for Testing
    //         //recommendation.contentId = 'a6JD3000000GsxGMAS';
    //     }

    //     //Recommendations where we found a Learner Profile
    //     List<RecommendationDataCloudHelper.DataCloudRecommendation> recommendations = new List<RecommendationDataCloudHelper.DataCloudRecommendation>();

    //     for (Learner_Profile__c learner :[SELECT Id, Employee_Number__c FROM Learner_Profile__c WHERE Id IN :learnerIds WITH USER_MODE]) {
    //         if(recommendationsByLearnerId.containsKey(learner.Id)){
    //             recommendations.addAll(recommendationsByLearnerId.get(learner.Id));
    //         }

    //         recommendationsByLearnerId.remove(learner.Id);
    //     }

    //     //Create errors for recommendations where we did not find a Learner Profile
    //     for (List<RecommendationDataCloudHelper.DataCloudRecommendation> recommendationList : recommendationsByLearnerId.values()) {
    //         for (RecommendationDataCloudHelper.DataCloudRecommendation recommendation : recommendationList) {
    //             String errorMessage = 'No Learner Profile found for: ' + recommendation.learnerId;
    //             System.debug(errorMessage);
    //             errors.add(new Integration_Error__c(Error_Message__c = errorMessage.left(255), Type__c = 'Data Cloud Skill Recommendations'));
    //         }
    //     }

    //     RecommendationHelper.addSeedRecommendations(recommendations);

    //     if (!errors.isEmpty()) {
    //         Database.insert(errors, System.AccessLevel.USER_MODE);
    //     }

    //     return nextRunTime;
    // }

    // public static Integration_Error__c validateData(Map<String, String> dataObj) {
    //     Integration_Error__c error = new Integration_Error__c();
    //     error.Type__c = 'Data Cloud Skill Recommendations';

    //     if (!dataObj.containsKey(CONTENT_FIELD)) {
    //         error.Error_Message__c = CONTENT_FIELD + ' not found in Data Cloud Recommendation';
    //         return error;
    //     }

    //     if (!dataObj.containsKey(LEARNER_ID_FIELD)) {
    //         error.Error_Message__c = LEARNER_ID_FIELD + ' not found in Data Cloud Recommendation';
    //         return error;
    //     }

    //     return null;
    // }
}