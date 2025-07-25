/**
 * @description Represents the complete result of a query operation. This is the main
 * data transfer object returned by the query system.
 * @author Your Name/Team
 * @date Created Date
 */
public with sharing class Employee_QueryResult {
    @AuraEnabled
    public Boolean success;

    @AuraEnabled
    public String message;

    @AuraEnabled
    public Integer totalRecords = 0;

    @AuraEnabled
    public Integer pageNumber = 1;

    @AuraEnabled
    public Boolean hasMore = false;

    // The query that was constructed and executed
    @AuraEnabled
    public String queryUsed;

    // The raw JSON returned by the LLM
    @AuraEnabled
    public String parsedQuery;

    // A list of formatted employee records
    @AuraEnabled
    public List<Employee_EmployeeRecord> records;

    // Additional metadata about the result, like execution time or grouping info
    @AuraEnabled
    public Map<String, Object> metadataMap;

    public Employee_QueryResult() {
        this.success = false;
        this.records = new List<Employee_EmployeeRecord>();
        this.metadataMap = new Map<String, Object>();
    }
}