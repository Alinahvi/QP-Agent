/**
 * @description Invocable class for removing members from audiences
 * @author Enhanced Architecture
 */
public with sharing class AH_NEW_AudienceMemberRemoveInvocable {
    
    @InvocableMethod(label='Remove Members from Audience' 
                    description='Remove employees from an audience')
    public static List<MemberOperationResult> removeMembersFromAudience(List<MemberOperationRequest> requests) {
        List<MemberOperationResult> results = new List<MemberOperationResult>();
        
        for (MemberOperationRequest req : requests) {
            MemberOperationResult result = new MemberOperationResult();
            
            try {
                // Input validation
                if (String.isBlank(req.audienceName) && req.audienceId == null) {
                    result.success = false;
                    result.message = 'Please provide either an audience name or ID';
                    results.add(result);
                    continue;
                }
                
                if ((req.employeeIds == null || req.employeeIds.isEmpty()) && 
                    (req.employeeNames == null || req.employeeNames.isEmpty())) {
                    result.success = false;
                    result.message = 'Please provide employee IDs or names to remove';
                    results.add(result);
                    continue;
                }
                
                // Get the audience ID if needed
                Id audienceId = req.audienceId;
                String audienceName = req.audienceName;
                
                if (audienceId == null && String.isNotBlank(audienceName)) {
                    // Try to find audience
                    audienceId = findAudienceIdByName(audienceName);
                    
                    if (audienceId == null) {
                        result.success = false;
                        result.message = 'Could not find audience named "' + audienceName + '"';
                        results.add(result);
                        continue;
                    }
                } else if (audienceId != null && String.isBlank(audienceName)) {
                    // Get audience name from ID
                    try {
                        Audience__c audience = [SELECT Name FROM Audience__c WHERE Id = :audienceId LIMIT 1];
                        audienceName = audience.Name;
                    } catch (Exception e) {
                        result.success = false;
                        result.message = 'Could not find audience with ID ' + audienceId;
                        results.add(result);
                        continue;
                    }
                }
                
                // Determine employee IDs to remove
                List<Id> employeeIdsToRemove = new List<Id>();
                
                // Add explicitly provided IDs
                if (req.employeeIds != null && !req.employeeIds.isEmpty()) {
                    employeeIdsToRemove.addAll(req.employeeIds);
                }
                
                // Look up IDs for provided names
                if (req.employeeNames != null && !req.employeeNames.isEmpty()) {
                    for (String name : req.employeeNames) {
                        Id empId = findEmployeeIdByName(name);
                        if (empId != null) {
                            employeeIdsToRemove.add(empId);
                        }
                    }
                }
                
                if (employeeIdsToRemove.isEmpty()) {
                    result.success = false;
                    result.message = 'No valid employees found to remove from audience';
                    results.add(result);
                    continue;
                }
                
                // Direct implementation to remove members instead of using AH_NEW_AudienceMemberRemover
                // Find audience members to delete
                List<Audience_Member__c> membersToDelete = [
                    SELECT Id
                    FROM Audience_Member__c
                    WHERE Audience__c = :audienceId
                    AND Learner_Profile__c IN :employeeIdsToRemove
                    WITH SECURITY_ENFORCED
                ];
                
                Integer removedCount = membersToDelete.size();
                Integer skippedCount = employeeIdsToRemove.size() - removedCount;
                
                // Delete audience members with security enforcement
                if (!membersToDelete.isEmpty() && Schema.sObjectType.Audience_Member__c.isDeletable()) {
                    delete membersToDelete;
                }
                
                // Set result
                result.success = true;
                result.message = 'Removed ' + removedCount + ' member(s) from audience "' + audienceName + 
                               '". ' + skippedCount + ' member(s) were not found.';
                result.audienceId = audienceId;
                result.audienceName = audienceName;
                result.affectedCount = removedCount;
                result.skippedCount = skippedCount;
                
            } catch (Exception e) {
                result.success = false;
                result.message = 'Error removing members from audience: ' + e.getMessage();
            }
            
            results.add(result);
        }
        
        return results;
    }
    
    /**
     * @description Find audience ID by name
     * @param audienceName The audience name
     * @return Id The audience ID
     */
    private static Id findAudienceIdByName(String audienceName) {
        if (String.isBlank(audienceName)) return null;
        
        // Try exact match first
        List<Audience__c> exactMatches = [
            SELECT Id 
            FROM Audience__c 
            WHERE Name = :audienceName
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        
        if (!exactMatches.isEmpty()) {
            return exactMatches[0].Id;
        }
        
        // Then try with "the" prefix
        if (!audienceName.toLowerCase().startsWith('the ')) {
            List<Audience__c> prefixMatches = [
                SELECT Id 
                FROM Audience__c 
                WHERE Name = :('the ' + audienceName)
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            
            if (!prefixMatches.isEmpty()) {
                return prefixMatches[0].Id;
            }
        }
        
        // Then try partial match
        String namePattern = '%' + audienceName + '%';
        List<Audience__c> partialMatches = [
            SELECT Id 
            FROM Audience__c 
            WHERE Name LIKE :namePattern
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        
        if (!partialMatches.isEmpty()) {
            return partialMatches[0].Id;
        }
        
        return null;
    }
    
    /**
     * @description Find employee ID by name
     * @param employeeName The employee name
     * @return Id The employee ID
     */
    private static Id findEmployeeIdByName(String employeeName) {
        if (String.isBlank(employeeName)) return null;
        
        // Try exact match first
        List<Learner_Profile__c> exactMatches = [
            SELECT Id 
            FROM Learner_Profile__c 
            WHERE Name = :employeeName
            AND Status__c = 'Active'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        
        if (!exactMatches.isEmpty()) {
            return exactMatches[0].Id;
        }
        
        // Then try partial match
        String namePattern = '%' + employeeName + '%';
        List<Learner_Profile__c> partialMatches = [
            SELECT Id 
            FROM Learner_Profile__c 
            WHERE Name LIKE :namePattern
            AND Status__c = 'Active'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        
        if (!partialMatches.isEmpty()) {
            return partialMatches[0].Id;
        }
        
        return null;
    }
    
    public class MemberOperationRequest {
        @InvocableVariable(label='Audience ID')
        public Id audienceId;
        
        @InvocableVariable(label='Audience Name')
        public String audienceName;
        
        @InvocableVariable(label='Employee IDs')
        public List<Id> employeeIds;
        
        @InvocableVariable(label='Employee Names')
        public List<String> employeeNames;
    }
    
    public class MemberOperationResult {
        @InvocableVariable(label='Success')
        public Boolean success;
        
        @InvocableVariable(label='Message')
        public String message;
        
        @InvocableVariable(label='Audience ID')
        public Id audienceId;
        
        @InvocableVariable(label='Audience Name')
        public String audienceName;
        
        @InvocableVariable(label='Affected Count')
        public Integer affectedCount;
        
        @InvocableVariable(label='Skipped Count')
        public Integer skippedCount;
    }
}