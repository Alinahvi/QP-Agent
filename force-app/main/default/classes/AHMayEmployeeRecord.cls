public class AHMayEmployeeRecord {
    // Primary fields (always displayed)
    @AuraEnabled public Id recordId;
    @AuraEnabled public String name;
    @AuraEnabled public String email;
    @AuraEnabled public String manager;
    @AuraEnabled public String managerEmail;
    
    // Metadata for secondary fields
    @AuraEnabled public Map<String, Object> metadataMap;
}