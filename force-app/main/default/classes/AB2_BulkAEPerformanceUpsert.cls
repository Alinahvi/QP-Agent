@RestResource(urlMapping='/SMEFinderUpsert/*')
global with sharing class AB2_BulkAEPerformanceUpsert {

    // #1: CORE LOGIC CLASS
    // This private class holds the actual business logic, making it reusable.
    private class CoreLogic {
        // CHANGE #1: Removed the "static" keyword from the method definition.
        public ResultDTO executeUpsert(String jsonString) {
            List<SME_Finder__c> recordsToUpsert = new List<SME_Finder__c>();
            String parsingError = '';

            try {
                if (String.isBlank(jsonString)) {
                    parsingError = 'Request body is empty.';
                } else {
                    List<AERow> rows = (List<AERow>) JSON.deserialize(jsonString, List<AERow>.class);
                    for (AERow row : rows) {
                        if (String.isNotBlank(row.AE_NAME)) {
                            recordsToUpsert.add(new SME_Finder__c(
                                AE_Name__c    = row.AE_NAME,
                                OU__c         = row.OU,
                                Product_L2__c = row.PRODUCT_L2,
                                Product_L3__c = row.PRODUCT_L3,
                                Total_ACV__c  = row.TOTAL_ACV,
                                AE_Rank__c    = row.AE_RANK
                            ));
                        }
                    }
                }
            } catch (Exception e) {
                parsingError = 'Failed to parse JSON payload. Reason: ' + e.getMessage();
            }
            
            Integer insertedCount = 0, updatedCount = 0, failedCount = 0;
            String failedDetails = parsingError;

            if (!recordsToUpsert.isEmpty()) {
                Database.UpsertResult[] upsertResults = Database.upsert(recordsToUpsert, SME_Finder__c.Fields.AE_Name__c, false);
                Integer index = 0;
                for(Database.UpsertResult ur : upsertResults){
                    if(ur.isSuccess()){
                        if(ur.isCreated()) insertedCount++; else updatedCount++;
                    } else {
                        failedCount++;
                        // Logic to add error details
                    }
                    index++;
                }
            }

            ResultDTO result = new ResultDTO();
            result.success       = failedCount == 0 && String.isBlank(parsingError);
            result.message       = 'Processing complete.';
            result.insertedCount = insertedCount;
            result.updatedCount  = updatedCount;
            result.failedCount   = failedCount;
            result.errorDetails  = failedDetails.trim();
            
            return result;
        }
    }

    // #2: INVOCABLE METHOD (For Agent Actions and Flows)
    @InvocableMethod(label='Upsert AE Performance Records' description='Creates or updates SME Finder records from a JSON string.')
    public static List<ResultDTO> runFromFlow(List<String> jsonInputs) {
        // CHANGE #2: Create an instance of the logic class to call the method.
        CoreLogic logic = new CoreLogic();
        List<ResultDTO> results = new List<ResultDTO>();
        for (String jsonInput : jsonInputs) {
            results.add(logic.executeUpsert(jsonInput));
        }
        return results;
    }

    // #3: REST RESOURCE METHOD (For Python/External APIs)
    @HttpPost
    global static ResultDTO runFromApi() {
        // CHANGE #2: Create an instance of the logic class to call the method.
        CoreLogic logic = new CoreLogic();
        RestRequest request = RestContext.request;
        return logic.executeUpsert(request.requestBody.toString());
    }

    // --- Data Transfer Objects (DTOs) ---
    global class AERow {
        @InvocableVariable global String OU;
        @InvocableVariable global String PRODUCT_L2;
        @InvocableVariable global String PRODUCT_L3;
        @InvocableVariable global String AE_NAME;
        @InvocableVariable global Decimal TOTAL_ACV;
        @InvocableVariable global Integer AE_RANK;
    }

    global class ResultDTO {
        @InvocableVariable global Boolean success;
        @InvocableVariable global String  message;
        @InvocableVariable global Integer insertedCount;
        @InvocableVariable global Integer updatedCount;
        @InvocableVariable global Integer failedCount;
        @InVocaBleVariable global String  errorDetails;
    }
}