/**
 * @description Audience service for agent actions.
 * Provides business logic for managing audiences.
 * @version 1.0
 */
public with sharing class ANAgentAudienceService {

    /**
     * @description Search for audiences
     */
    public static ANAgentAudienceHandler.AudienceResponse searchAudiences(ANAgentAudienceHandler.AudienceRequest request) {
        ANAgentAudienceHandler.AudienceResponse response = new ANAgentAudienceHandler.AudienceResponse();
        
        try {
            String query = 'SELECT Id, Name, Description__c FROM Audience__c';
            List<String> conditions = new List<String>();
            
            if (String.isNotBlank(request.audienceName)) {
                conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(request.audienceName) + '%\'');
            }
            
            if (!conditions.isEmpty()) {
                query += ' WHERE ' + String.join(conditions, ' AND ');
            }
            
            query += ' ORDER BY Name LIMIT 50';
            
            List<Audience__c> audiences = Database.query(query);
            
            response.success = true;
            response.message = 'Found ' + audiences.size() + ' audiences';
            response.audienceData = JSON.serialize(audiences);
            
        } catch (Exception e) {
            response.success = false;
            response.message = 'Error searching audiences: ' + e.getMessage();
        }
        
        return response;
    }

    /**
     * @description Create a new audience
     */
    public static ANAgentAudienceHandler.AudienceResponse createAudience(ANAgentAudienceHandler.AudienceRequest request) {
        ANAgentAudienceHandler.AudienceResponse response = new ANAgentAudienceHandler.AudienceResponse();
        
        try {
            if (String.isBlank(request.audienceName)) {
                response.message = 'Audience name is required for creation';
                return response;
            }
            
            Audience__c newAudience = new Audience__c();
            newAudience.Name = request.audienceName;
            
            insert newAudience;
            
            response.success = true;
            response.message = 'Audience created successfully';
            response.audienceData = JSON.serialize(newAudience);
            
        } catch (Exception e) {
            response.success = false;
            response.message = 'Error creating audience: ' + e.getMessage();
        }
        
        return response;
    }

    /**
     * @description Update an existing audience
     */
    public static ANAgentAudienceHandler.AudienceResponse updateAudience(ANAgentAudienceHandler.AudienceRequest request) {
        ANAgentAudienceHandler.AudienceResponse response = new ANAgentAudienceHandler.AudienceResponse();
        
        try {
            if (String.isBlank(request.audienceId)) {
                response.message = 'Audience ID is required for update';
                return response;
            }
            
            Audience__c audience = [SELECT Id, Name FROM Audience__c WHERE Id = :request.audienceId LIMIT 1];
            
            if (String.isNotBlank(request.audienceName)) {
                audience.Name = request.audienceName;
            }
            
            update audience;
            
            response.success = true;
            response.message = 'Audience updated successfully';
            response.audienceData = JSON.serialize(audience);
            
        } catch (Exception e) {
            response.success = false;
            response.message = 'Error updating audience: ' + e.getMessage();
        }
        
        return response;
    }

    /**
     * @description Delete an audience
     */
    public static ANAgentAudienceHandler.AudienceResponse deleteAudience(ANAgentAudienceHandler.AudienceRequest request) {
        ANAgentAudienceHandler.AudienceResponse response = new ANAgentAudienceHandler.AudienceResponse();
        
        try {
            if (String.isBlank(request.audienceId)) {
                response.message = 'Audience ID is required for deletion';
                return response;
            }
            
            Audience__c audience = [SELECT Id, Name FROM Audience__c WHERE Id = :request.audienceId LIMIT 1];
            delete audience;
            
            response.success = true;
            response.message = 'Audience deleted successfully';
            
        } catch (Exception e) {
            response.success = false;
            response.message = 'Error deleting audience: ' + e.getMessage();
        }
        
        return response;
    }
}
