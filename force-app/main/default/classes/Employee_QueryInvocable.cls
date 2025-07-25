public with sharing class Employee_QueryInvocable {

    private static final Integer BATCH_SIZE = 200;
    // Define a threshold for what constitutes a large query that needs async processing.
    private static final Integer LARGE_QUERY_THRESHOLD = 1000;

    @InvocableMethod(label='Employee - Query and Segment' description='Processes a natural language query to find and segment employee records.')
    public static List<String> queryEmployees(List<Employee_QueryRequest> requests) {
        List<String> jsonResults = new List<String>();

        for (Employee_QueryRequest request : requests) {
            try {
                Long startTime = System.currentTimeMillis();
                Employee_QueryResult result = Employee_QueryService.processQuery(request);
                Long endTime = System.currentTimeMillis();

                result.metadataMap.put('executionTimeMs', endTime - startTime);
                storeSegmentedEmployees(result, request.sessionId);

                // After the initial query, check if it's a large dataset that needs background processing.
                if (result.success && result.totalRecords > LARGE_QUERY_THRESHOLD && String.isNotBlank(request.sessionId)) {
                    result.message += '\n\nYour request for ' + result.totalRecords + ' records is being processed in the background. ' +
                                      'The first page of results is available now.';
                    
                    // The initial query already fetched the first ~20 records. We start the background job from there.
                    Integer offset = result.records.size();
                    LargeQueryProcessor processor = new LargeQueryProcessor(request.sessionId, result.queryUsed, result.totalRecords, offset);
                    System.enqueueJob(processor);
                }

                jsonResults.add(JSON.serialize(result));

            } catch (Exception e) {
                Employee_QueryResult errorResult = new Employee_QueryResult();
                errorResult.success = false;
                errorResult.message = 'A system error occurred: ' + e.getMessage();
                jsonResults.add(JSON.serialize(errorResult));
                System.debug(LoggingLevel.ERROR, 'Employee_QueryInvocable Error: ' + e.getMessage() + ' Stack: ' + e.getStackTraceString());
            }
        }
        return jsonResults;
    }
    
    private static void storeSegmentedEmployees(Employee_QueryResult result, String sessionId) {
        if (result.success && result.records != null && !result.records.isEmpty() && String.isNotBlank(sessionId)) {
            List<Id> employeeIds = new List<Id>();
            for (Employee_EmployeeRecord record : result.records) {
                employeeIds.add(record.recordId);
            }
            Employee_SessionContext.storeSegmentedEmployees(sessionId, employeeIds);
            System.debug('Stored ' + employeeIds.size() + ' segmented employee IDs for session ' + sessionId);
        }
    }

    /**
     * @description Production-ready Queueable class for processing large query result sets.
     * It fetches data in batches and uses Platform Cache to aggregate results across transactions.
     */
    public class LargeQueryProcessor implements Queueable {
        private String sessionId;
        private String baseQuery;
        private Integer totalRecords;
        private Integer currentOffset;

        public LargeQueryProcessor(String sessionId, String queryUsed, Integer totalRecords, Integer offset) {
            this.sessionId = sessionId;
            // The query from the handler includes LIMIT and OFFSET, which we must remove
            // to create a reusable base query.
            this.baseQuery = queryUsed.substring(0, queryUsed.toLowerCase().indexOf(' order by '));
            this.totalRecords = totalRecords;
            this.currentOffset = offset;
        }

        public void execute(QueueableContext context) {
            // Build the query for the next batch of records
            String batchQuery = this.baseQuery + ' ORDER BY Name ASC LIMIT ' + BATCH_SIZE + ' OFFSET ' + this.currentOffset;
            System.debug('LargeQueryProcessor executing query: ' + batchQuery);

            List<Learner_Profile__c> newRecords = Database.query(batchQuery);

            if (!newRecords.isEmpty()) {
                // Get existing IDs from the cache, add new ones, and store back
                List<Id> existingIds = Employee_SessionContext.getSegmentedEmployeeIds(this.sessionId);
                Set<Id> allIds = new Set<Id>(existingIds);
                for(Learner_Profile__c record : newRecords) {
                    allIds.add(record.Id);
                }
                Employee_SessionContext.storeSegmentedEmployees(this.sessionId, new List<Id>(allIds));
                System.debug('LargeQueryProcessor cached ' + allIds.size() + ' total employee IDs for session ' + this.sessionId);
            }

            // Check if more records need to be processed and chain the job
            Integer nextOffset = this.currentOffset + newRecords.size();
            if (nextOffset < this.totalRecords) {
                LargeQueryProcessor nextProcessor = new LargeQueryProcessor(this.sessionId, this.baseQuery, this.totalRecords, nextOffset);
                System.enqueueJob(nextProcessor);
            } else {
                System.debug('LargeQueryProcessor finished for session: ' + this.sessionId);
            }
        }
    }
}