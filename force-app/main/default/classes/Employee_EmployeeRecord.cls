/**
 * @description Represents a single, formatted employee record for display or use in results.
 * @author Your Name/Team
 * @date Created Date
 */
public with sharing class Employee_EmployeeRecord {
    @AuraEnabled
    public Id recordId;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String email;
    @AuraEnabled
    public String manager;
    @AuraEnabled
    public String managerEmail;
    
    // Stores all other secondary fields for potential analysis or detailed views
    @AuraEnabled
    public Map<String, Object> metadataMap;
}