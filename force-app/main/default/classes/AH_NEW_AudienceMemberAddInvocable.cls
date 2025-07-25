/**
 * @description Invocable class for adding members to audiences
 * @author Enhanced Architecture
 */
public with sharing class AH_NEW_AudienceMemberAddInvocable {
    
    @InvocableMethod(label='Add Members to Audience' 
                    description='Add employees to an audience')
    public static List<MemberOperationResult> addMembersToAudience(List<MemberOperationRequest> requests) {
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
                    result.message = 'Please provide employee IDs or names to add';
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
                
                // Determine employee IDs to add
                List<Id> employeeIdsToAdd = new List<Id>();
                
                // Add explicitly provided IDs
                if (req.employeeIds != null && !req.employeeIds.isEmpty()) {
                    employeeIdsToAdd.addAll(req.employeeIds);
                }
                
                // Look up IDs for provided names
                if (req.employeeNames != null && !req.employeeNames.isEmpty()) {
                    for (String name : req.employeeNames) {
                        Id empId = findEmployeeIdByName(name);
                        if (empId != null) {
                            employeeIdsToAdd.add(empId);
                        }
                    }
                }
                
                if (employeeIdsToAdd.isEmpty()) {
                    result.success = false;
                    result.message = 'No valid employees found to add to audience';
                    results.add(result);
                    continue;
                }
                
                // Direct implementation to add members instead of using AH_NEW_AudienceMemberAdder
                List<Audience_Member__c> membersToInsert = new List<Audience_Member__c>();
                Integer addedCount = 0;
                Integer skippedCount = 0;
                
                // Check for existing members to avoid duplicates
                Set<Id> existingMemberIds = new Set<Id>();
                for (Audience_Member__c existing : [
                    SELECT Learner_Profile__c 
                    FROM Audience_Member__c 
                    WHERE Audience__c = :audienceId 
                    AND Learner_Profile__c IN :employeeIdsToAdd
                    WITH SECURITY_ENFORCED
                ]) {
                    existingMemberIds.add(existing.Learner_Profile__c);
                }
                
                // Create new audience members
                for (Id employeeId : employeeIdsToAdd) {
                    if (existingMemberIds.contains(employeeId)) {
                        skippedCount++;
                        continue; // Skip existing members
                    }
                    
                    Audience_Member__c newMember = new Audience_Member__c(
                        Audience__c = audienceId,
                        Learner_Profile__c = employeeId
                    );
                    membersToInsert.add(newMember);
                    addedCount++;
                }
                
                // Insert new members with security enforcement
                if (!membersToInsert.isEmpty() && Schema.sObjectType.Audience_Member__c.isCreateable()) {
                    insert membersToInsert;
                }
                
                // Set result
                result.success = true;
                result.message = 'Added ' + addedCount + ' member(s) to audience "' + audienceName + 
                               '". Skipped ' + skippedCount + ' existing member(s).';
                result.audienceId = audienceId;
                result.audienceName = audienceName;
                result.affectedCount = addedCount;
                result.skippedCount = skippedCount;
                
            } catch (Exception e) {
                result.success = false;
                result.message = 'Error adding members to audience: ' + e.getMessage();
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