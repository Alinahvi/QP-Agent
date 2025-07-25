public with sharing class AB_BulkAEPerformanceUpsert {

    // --- Inner classes remain the same ---
    public class AERow {
        public String OU;
        public String PRODUCT_L2;
        public String PRODUCT_L3;
        public String AE_NAME;
        public Decimal TOTAL_ACV;
        public Integer AE_RANK;
    }
    public class WrappedPayload { public List<AERow> records; }

    public class ResultDTO {
        @InvocableVariable public Boolean success;
        @InvocableVariable public String  message;
        @InvocableVariable public Integer insertedCount;
        @InvocableVariable public Integer updatedCount;
        @InvocableVariable public Integer failedCount;
        @InvocableVariable public String  errorDetails;
    }

    @InvocableMethod(label='Upsert AE Performance Records v2')
    public static List<ResultDTO> upsertAEData(List<String> jsonInputs) {
        
        // This list will collect all records from all JSON payloads for bulk processing.
        List<SME_Finder__c> recordsToUpsert = new List<SME_Finder__c>();
        List<String> parsingErrors = new List<String>();

        /* 1. PARSE & COLLECT: Iterate through all JSON inputs and collect records.
           No DML or SOQL should ever be inside a loop like this. */
        for (String jsonString : jsonInputs) {
            try {
                if (String.isBlank(jsonString)) continue;

                List<AERow> rows;
                String trimmedJson = jsonString.trim();

                // Simple check for JSON format (array vs wrapped object)
                if (trimmedJson.startsWith('[')) {
                    rows = (List<AERow>) JSON.deserialize(trimmedJson, List<AERow>.class);
                } else {
                    WrappedPayload wp = (WrappedPayload) JSON.deserialize(trimmedJson, WrappedPayload.class);
                    rows = (wp != null) ? wp.records : new List<AERow>();
                }
                
                if (rows == null) continue;

                // Map the parsed rows to the SObject we want to upsert
                for (AERow row : rows) {
                    if (String.isNotBlank(row.AE_NAME)) {
                        SME_Finder__c rec = new SME_Finder__c(
                            AE_Name__c    = row.AE_NAME, // This is our External ID
                            OU__c         = row.OU,
                            Product_L2__c = row.PRODUCT_L2,
                            Product_L3__c = row.PRODUCT_L3,
                            Total_ACV__c  = row.TOTAL_ACV,
                            AE_Rank__c    = row.AE_RANK
                        );
                        recordsToUpsert.add(rec);
                    }
                }
            } catch (Exception e) {
                // Collect parsing errors to report later
                parsingErrors.add('Failed to parse a JSON payload. Reason: ' + e.getMessage());
            }
        }
        
        /* 2. DML: Perform a single, bulk upsert operation outside the loop. */
        Integer insertedCount = 0;
        Integer updatedCount = 0;
        Integer failedCount = 0;
        String failedDetails = String.join(parsingErrors, '; ');

        if (!recordsToUpsert.isEmpty()) {
            // Specify the External ID field for the upsert operation
            Schema.SObjectField externalIdField = SME_Finder__c.Fields.AE_Name__c;
            
            // Use Database.upsert with allOrNone = false for partial success
            Database.UpsertResult[] upsertResults = Database.upsert(recordsToUpsert, externalIdField, false);

            // Process the results to get accurate counts
            for (Database.UpsertResult ur : upsertResults) {
                if (ur.isSuccess()) {
                    if (ur.isCreated()) {
                        insertedCount++;
                    } else {
                        updatedCount++;
                    }
                } else {
                    failedCount++;
                    // Aggregate failure reasons for a more informative message
                    for (Database.Error err : ur.getErrors()) {
                        failedDetails += 'Record with AE Name ' + recordsToUpsert[failedCount-1].AE_Name__c + ' failed: ' + err.getMessage() + '. ';
                    }
                }
            }
        }

        /* 3. RETURN RESULT: Build and return a single, aggregated result. */
        ResultDTO result = new ResultDTO();
        result.success       = failedCount == 0 && parsingErrors.isEmpty();
        result.message       = 'Processing complete.';
        result.insertedCount = insertedCount;
        result.updatedCount  = updatedCount;
        result.failedCount   = failedCount + parsingErrors.size();
        result.errorDetails  = failedDetails.trim();
        
        return new List<ResultDTO>{ result };
    }
}