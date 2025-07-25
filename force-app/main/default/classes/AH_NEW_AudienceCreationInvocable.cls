/**
 * @description Invocable class for creating audiences
 * @author Enhanced Architecture
 */
public with sharing class AH_NEW_AudienceCreationInvocable {
    
    @InvocableMethod(label='Create Audience' 
                    description='Create a new audience')
    public static List<AudienceCreationResult> createAudience(List<AudienceCreationRequest> requests) {
        List<AudienceCreationResult> results = new List<AudienceCreationResult>();
        
        for (AudienceCreationRequest req : requests) {
            // Create an audience creation result
            AudienceCreationResult result = new AudienceCreationResult();
            
            try {
                // Input validation
                if (String.isBlank(req.audienceName)) {
                    result.success = false;
                    result.message = 'Please provide an audience name';
                    results.add(result);
                    continue;
                }
                
                // Create the audience directly using Salesforce API
                // Note: Replaced complex dependency chain with direct audience creation
                Audience__c newAudience = new Audience__c(
                    Name = req.audienceName
                );
                
                // Insert with security enforcement
                if (Schema.sObjectType.Audience__c.isCreateable()) {
                    insert newAudience;
                    
                    // Set success result
                    result.success = true;
                    result.message = 'Successfully created audience "' + req.audienceName + '"';
                    result.audienceId = newAudience.Id;
                    result.audienceName = req.audienceName;
                    
                    // Get additional details
                    try {
                        Audience__c audience = [
                            SELECT Id, Name, CreatedDate, CreatedBy.Name
                            FROM Audience__c
                            WHERE Id = :result.audienceId
                            LIMIT 1
                        ];
                        
                        result.createdDate = audience.CreatedDate;
                        result.createdByName = audience.CreatedBy.Name;
                    } catch (Exception e) {
                        // No additional action needed
                    }
                } else {
                    result.success = false;
                    result.message = 'Insufficient permissions to create audience';
                }
                
            } catch (Exception e) {
                result.success = false;
                result.message = 'Error creating audience: ' + e.getMessage();
            }
            
            results.add(result);
        }
        
        return results;
    }
    
    public class AudienceCreationRequest {
        @InvocableVariable(label='Audience Name' required=true)
        public String audienceName;
        
    }
    
    public class AudienceCreationResult {
        @InvocableVariable(label='Success')
        public Boolean success;
        
        @InvocableVariable(label='Message')
        public String message;
        
        @InvocableVariable(label='Audience ID')
        public Id audienceId;
        
        @InvocableVariable(label='Audience Name')
        public String audienceName;
        
        @InvocableVariable(label='Created Date')
        public Datetime createdDate;
        
        @InvocableVariable(label='Created By')
        public String createdByName;
    }
}