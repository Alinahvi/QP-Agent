public class AHMayQueryResult {
    @AuraEnabled public Boolean success;
    @AuraEnabled public String message;
    @AuraEnabled public Integer totalRecords;
    @AuraEnabled public Integer pageNumber;
    @AuraEnabled public Boolean hasMore;
    @AuraEnabled public List<AHMayEmployeeRecord> records;
    @AuraEnabled public String queryUsed;
    @AuraEnabled public String parsedQuery;
    @AuraEnabled public Boolean processingInBackground;
    
    // Added for metadata responses
    @AuraEnabled public Map<String, Object> metadataMap;
    
    // Constructor to initialize values
    public AHMayQueryResult() {
        this.success = false;
        this.totalRecords = 0;
        this.pageNumber = 1;
        this.hasMore = false;
        this.records = new List<AHMayEmployeeRecord>();
        this.processingInBackground = false;
        this.metadataMap = new Map<String, Object>();
    }
}