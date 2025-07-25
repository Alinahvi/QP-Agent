public with sharing class RecommendationDataCloudSkillBatch implements Database.Batchable<Map<String, String>>, Database.Stateful, Database.AllowsCallouts {
    // Set a cap on the total # of records to process
    // FOR TESTING, REMOVE FOR PRODUCTION
    // final Integer TOTAL_LIMIT = 2000;

    final Integer QUERY_LIMIT = 10000;
    final Integer BATCH_SIZE = 1000;

    DateTime lastRunTime;
    DateTime nextRunTime;
    String dataCloudURL;
    String dataCloudToken;
    Boolean queryNextBatch;
    Boolean foundData = false;
    Integer offset;

    public RecommendationDataCloudSkillBatch() {
        queryNextBatch = false;
        foundData = false;
        offset = 0;

        Batch_Data__c batchData = Batch_Data__c.getOrgDefaults();
        lastRunTime = batchData.Last_Data_Cloud_Skill_Run_Time__c;
        nextRunTime = lastRunTime;
        dataCloudURL = batchData.Data_Cloud_URL__c;
    }

    public RecommendationDataCloudSkillBatch(Integer offsetIn) {
        queryNextBatch = false;
        foundData = false;
        offset = offsetIn;

        Batch_Data__c batchData = Batch_Data__c.getOrgDefaults();
        lastRunTime = batchData.Last_Data_Cloud_Skill_Run_Time__c;
        nextRunTime = lastRunTime;
        dataCloudURL = batchData.Data_Cloud_URL__c;
    }

    public class DataCloudResponse {
        public List<Map<String, String>> data { get; set; }
        public DateTime startTime { get; set; }
        public DateTime endTime { get; set; }
        public Integer rowCount { get; set; }
        public String queryId { get; set; }
        public Boolean done { get; set; }
    }

    public Iterable<Map<String, String>> start(Database.BatchableContext context) {
        if (String.isEmpty(dataCloudToken)) {
            try {
                HttpResponse tokenResponse = RecommendationDataCloudHelper.getDataCloudToken();
    
                if (tokenResponse.getStatusCode() == 200) {
                    Map<String, Object> tokenResponseBody = (Map<String, Object>) JSON.deserializeUntyped(tokenResponse.getBody());
    
                    dataCloudToken = (String) tokenResponseBody.get('access_token');
                    dataCloudURL = 'https://' + (String) tokenResponseBody.get('instance_url');
                } else {
                    String errorMessage = 'Data Cloud Token API callout failed: ' + tokenResponse.getStatus();
                    System.debug(errorMessage + ' ' + tokenResponse.getBody());
                    insert as user new Integration_Error__c(Error_Message__c = errorMessage.left(255), Type__c = 'Data Cloud Skill Recommendations', Http_Response_Body__c = tokenResponse.getBody());
                    return new List<Map<String, String>>();
                }
            } catch (Exception e) {
                String errorMessage = 'Failed to get Recommendation Data Cloud Token: ' + e.getMessage();
                System.debug(errorMessage);
                System.debug('Line: ' + e.getLineNumber() + ' - ' + e.getStackTraceString());
                insert as user new Integration_Error__c(Error_Message__c = errorMessage.left(255), Type__c = 'Data Cloud Skill Recommendations');
                return new List<Map<String, String>>(); 
            }
        }
        
        HttpResponse response;

        try {
            response = RecommendationDataCloudSkillHelper.queryDataCloud(dataCloudURL, dataCloudToken, lastRunTime, QUERY_LIMIT, offset);

            if (response.getStatusCode() == 200) {
                DataCloudResponse responseBody = (DataCloudResponse) JSON.deserialize(response.getBody(), DataCloudResponse.class);

                queryNextBatch = !responseBody.done; // data.size() == QUERY_LIMIT; // && offset < TOTAL_LIMIT; // Use for testing smaller chunks

                if (queryNextBatch) {
                    offset += QUERY_LIMIT;
                }

                System.debug('************** responseBody.data ' + JSON.serialize(responseBody.data));

                return responseBody.data;
            } else {
                String errorMessage = 'Data Cloud Query API callout failed: ' + response.getStatus();
                System.debug(errorMessage + ' ' + response.getBody());
                insert as user new Integration_Error__c(Error_Message__c = errorMessage.left(255), Type__c = 'Data Cloud Skill Recommendations', Http_Response_Body__c = response.getBody());
            }
        } catch (Exception e) {
            String errorMessage = 'Failed to Query Recommendation Data Cloud: ' + e.getMessage();
            System.debug(errorMessage);
            System.debug('Line: ' + e.getLineNumber() + ' - ' + e.getStackTraceString());
            insert as user new Integration_Error__c(Error_Message__c = errorMessage.left(255), Type__c = 'Data Cloud Skill Recommendations');
        }

        return new List<Map<String, String>>();
    }

    public void execute(Database.BatchableContext context, List<Map<String, String>> scope) {
        foundData = true;

        try {
            DateTime newNextRunTime = RecommendationDataCloudSkillHelper.processDataCloudRecommendations(scope);//, fieldIndexMap);

            if(nextRunTime == null || newNextRunTime > nextRunTime){
                nextRunTime = newNextRunTime;
            }
        } catch (Exception e) {
            String errorMessage = 'Failed to Process Recommendation Data Cloud: ' + e.getMessage();
            System.debug(errorMessage);
            System.debug('Line: ' + e.getLineNumber() + ' - ' + e.getStackTraceString());
            insert as user new Integration_Error__c(Error_Message__c = errorMessage.left(255), Type__c = 'Data Cloud Skill Recommendations');
        }
    }

    public void finish(Database.BatchableContext context) {
        if (queryNextBatch) {
            // Schedule the next batch
            Database.executeBatch(new RecommendationDataCloudSkillBatch(offset), BATCH_SIZE);
        } else {
            // Update Batch Data
            Batch_Data__c batchData = Batch_Data__c.getOrgDefaults();

            if(foundData){
                //batchData.Last_Data_Cloud_Run_Time__c = Datetime.now();
                if(nextRunTime != null){
                    batchData.Last_Data_Cloud_Skill_Run_Time__c = nextRunTime;
                } else {
                    batchData.Last_Data_Cloud_Skill_Run_Time__c = Datetime.now();
                }
            }

            if (batchData.Data_Cloud_URL__c == null || batchData.Data_Cloud_URL__c != dataCloudURL) {
                batchData.Data_Cloud_URL__c = dataCloudURL;
            }

            upsert batchData;

            Database.executeBatch(new RecommendationNotification(), 20);
        }
    }
}