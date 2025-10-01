/**
 * SALES COACH FEEDBACK SERVICE
 * 
 * This service provides Next Best Action (NBA) recommendations for Sales Coach feedback.
 * It integrates with the existing pipeline analysis service to surface Renewal, Cross-sell, and Upsell opportunities.
 * 
 * Key Features:
 * - Accepts Learner Profile ID from Flow
 * - Resolves seller context from Opportunity
 * - Calls existing pipeline analysis logic
 * - Returns structured NBA recommendation
 * - Integrates with Sales Coach feedback prompt
 * 
 * @version 1.0 - Initial implementation
 */
public with sharing class SalesCoachFeedbackService {

    // NextBestActionDTO is now a separate class

    /**
     * DTO for Flow input parameters
     */
    public class FeedbackRequest {
        @InvocableVariable(required=true label='Learner Profile ID')
        public String learnerProfileId;
        
        @InvocableVariable(label='Opportunity ID')
        public String opportunityId;
        
        @InvocableVariable(label='Include Cross-sell')
        public Boolean includeCrossSell = true;
        
        @InvocableVariable(label='Include Upsell')
        public Boolean includeUpsell = true;
    }

    /**
     * DTO for Flow response
     */
    public class FeedbackResponse {
        @InvocableVariable(label='Next Best Action')
        public String nextBestAction;
        
        @InvocableVariable(label='Success')
        public Boolean success;
        
        @InvocableVariable(label='Error Message')
        public String errorMessage;
    }

    /**
     * Main invocable method for Flow integration
     * Returns NBA recommendation for Sales Coach feedback
     */
    @InvocableMethod(label='Get Next Best Action for Sales Coach Feedback' 
                     description='Provides NBA recommendation based on Learner Profile ID and opportunity context')
    public static List<FeedbackResponse> getNextBestAction(List<FeedbackRequest> requests) {
        List<FeedbackResponse> responses = new List<FeedbackResponse>();
        
        for (FeedbackRequest request : requests) {
            FeedbackResponse response = new FeedbackResponse();
            
            try {
                // Validate input
                if (String.isBlank(request.learnerProfileId)) {
                    response.success = false;
                    response.errorMessage = 'Learner Profile ID is required';
                    responses.add(response);
                    continue;
                }

                // Get seller context from Opportunity
                Map<String, Object> sellerContext = getSellerContext(request.learnerProfileId, request.opportunityId);
                if (sellerContext == null) {
                    response.success = false;
                    response.errorMessage = 'Unable to resolve seller context for Learner Profile ID: ' + request.learnerProfileId;
                    responses.add(response);
                    continue;
                }

                // Get NBA recommendation
                NextBestActionDTO nba = getNextBestActionRecommendation(sellerContext, request);
                if (nba == null) {
                    response.success = false;
                    response.errorMessage = 'No Next Best Action found for the given context';
                    responses.add(response);
                    continue;
                }

                // Serialize the DTO to JSON string for Flow
                response.nextBestAction = JSON.serialize(nba);
                response.success = true;
                responses.add(response);

            } catch (Exception e) {
                response.success = false;
                response.errorMessage = 'Error generating NBA recommendation: ' + e.getMessage();
                responses.add(response);
            }
        }
        
        return responses;
    }

    /**
     * Resolves seller context from Learner Profile ID and Opportunity
     */
    private static Map<String, Object> getSellerContext(String learnerProfileId, String opportunityId) {
        Map<String, Object> context = new Map<String, Object>();
        
        try {
            // First, try to get context from Opportunity if provided
            if (String.isNotBlank(opportunityId)) {
                List<Opportunity> opportunities = [
                    SELECT Id, Name, AccountId, Account.Name, OwnerId, Owner.Name, Owner.Email,
                           CloseDate, Amount, StageName, Type, Learner_Profile__c
                    FROM Opportunity 
                    WHERE Id = :opportunityId 
                    AND Learner_Profile__c = :learnerProfileId
                    LIMIT 1
                ];
                
                if (!opportunities.isEmpty()) {
                    Opportunity opp = opportunities[0];
                    context.put('opportunityId', opp.Id);
                    context.put('opportunityName', opp.Name);
                    context.put('accountId', opp.AccountId);
                    context.put('accountName', opp.Account.Name);
                    context.put('sellerId', opp.OwnerId);
                    context.put('sellerName', opp.Owner.Name);
                    context.put('sellerEmail', opp.Owner.Email);
                    context.put('closeDate', opp.CloseDate);
                    context.put('amount', opp.Amount);
                    context.put('stageName', opp.StageName);
                    context.put('type', opp.Type);
                    return context;
                }
            }

            // Fallback: Get context from any pipeline object
            List<SObject> pipelineRecords = new List<SObject>();
            
            // Try Renewals first
            pipelineRecords = [
                SELECT Id, full_name__c, emp_email_addr__c, emp_id__c, 
                       renewal_acct_nm__c, renewal_prod_nm__c, renewal_opty_amt__c
                FROM Agent_Renewals__c 
                WHERE learner_profile_id__c = :learnerProfileId 
                LIMIT 1
            ];
            
            if (pipelineRecords.isEmpty()) {
                // Try Cross-sell
                pipelineRecords = [
                    SELECT Id, full_name__c, emp_email_addr__c, emp_id__c,
                           cross_sell_acct_nm__c, cross_sell_next_best_product__c
                    FROM Agent_Cross_Sell__c 
                    WHERE learner_profile_id__c = :learnerProfileId 
                    LIMIT 1
                ];
            }
            
            if (pipelineRecords.isEmpty()) {
                // Try Upsell
                pipelineRecords = [
                    SELECT Id, full_name__c, emp_email_addr__c, emp_id__c,
                           upsell_acct_nm__c, upsell_sub_category__c
                    FROM Agent_Upsell__c 
                    WHERE learner_profile_id__c = :learnerProfileId 
                    LIMIT 1
                ];
            }
            
            if (!pipelineRecords.isEmpty()) {
                SObject record = pipelineRecords[0];
                context.put('sellerName', record.get('full_name__c'));
                context.put('sellerEmail', record.get('emp_email_addr__c'));
                context.put('sellerId', record.get('emp_id__c'));
                
                // Add account info if available
                if (record.getSObjectType() == Agent_Renewals__c.SObjectType) {
                    context.put('accountName', record.get('renewal_acct_nm__c'));
                } else if (record.getSObjectType() == Agent_Cross_Sell__c.SObjectType) {
                    context.put('accountName', record.get('cross_sell_acct_nm__c'));
                } else if (record.getSObjectType() == Agent_Upsell__c.SObjectType) {
                    context.put('accountName', record.get('upsell_acct_nm__c'));
                }
                
                return context;
            }

        } catch (Exception e) {
            System.debug('Error getting seller context: ' + e.getMessage());
        }
        
        return null;
    }

    /**
     * Generates Next Best Action recommendation
     */
    private static NextBestActionDTO getNextBestActionRecommendation(Map<String, Object> sellerContext, FeedbackRequest request) {
        try {
            // For now, randomly select between Renewal and Cross-sell
            // This can be enhanced later with more sophisticated logic
            List<String> availableActions = new List<String>();
            
            if (request.includeCrossSell != false) {
                availableActions.add('CROSS_SELL');
            }
            if (request.includeUpsell != false) {
                availableActions.add('UPSELL');
            }
            
            // Always include Renewals as fallback
            availableActions.add('RENEWALS');
            
            if (availableActions.isEmpty()) {
                return null;
            }
            
            // Random selection for now
            String selectedAction = availableActions[Math.mod(Math.abs(Crypto.getRandomInteger()), availableActions.size())];
            
            // Get recommendation based on selected action type
            return getRecommendationForActionType(selectedAction, sellerContext);
            
        } catch (Exception e) {
            System.debug('Error generating NBA recommendation: ' + e.getMessage());
            return null;
        }
    }

    /**
     * Gets specific recommendation for action type
     */
    private static NextBestActionDTO getRecommendationForActionType(String actionType, Map<String, Object> sellerContext) {
        try {
            // Use existing pipeline analysis service to get data
            String analysisResult = ABAgentFuturePipeAnalysisService.analyzePipeline(
                actionType,                    // analysisType
                null,                         // ouName
                null,                         // workLocationCountry
                'ACCOUNT',                    // groupBy
                null,                         // filterCriteria
                null,                         // restrictInValuesCsv
                false,                        // perAENormalize
                5,                           // limitN
                'COUNT',                     // aggregationType
                'Top ' + actionType + ' Opportunities', // analysisTypeDetail
                null,                        // startDate
                null                         // endDate
            );
            
            // Parse the analysis result to extract top recommendation
            // For now, create a mock recommendation based on action type
            NextBestActionDTO nba = new NextBestActionDTO();
            nba.actionType = actionType;
            nba.sellerName = (String)sellerContext.get('sellerName');
            nba.sellerEmail = (String)sellerContext.get('sellerEmail');
            
            if (actionType == 'RENEWALS') {
                nba.product = 'Tableau Cloud Analytics';
                nba.account = (String)sellerContext.get('accountName');
                nba.reason = 'High-value renewal opportunity identified in your pipeline';
                nba.priority = 'High';
                nba.amount = 50000;
            } else if (actionType == 'CROSS_SELL') {
                nba.product = 'Tableau Server';
                nba.account = (String)sellerContext.get('accountName');
                nba.reason = 'Cross-sell opportunity for additional Tableau products';
                nba.priority = 'Medium';
                nba.amount = 25000;
            } else if (actionType == 'UPSELL') {
                nba.product = 'Tableau Prep Builder';
                nba.account = (String)sellerContext.get('accountName');
                nba.reason = 'Upsell opportunity to expand current Tableau usage';
                nba.priority = 'Medium';
                nba.amount = 15000;
            }
            
            nba.opportunityId = (String)sellerContext.get('opportunityId');
            
            return nba;
            
        } catch (Exception e) {
            System.debug('Error getting recommendation for action type ' + actionType + ': ' + e.getMessage());
            return null;
        }
    }

    /**
     * Helper method to get NBA for specific learner profile (for testing)
     */
    public static NextBestActionDTO getNextBestActionForLearner(String learnerProfileId) {
        FeedbackRequest request = new FeedbackRequest();
        request.learnerProfileId = learnerProfileId;
        request.includeCrossSell = true;
        request.includeUpsell = true;
        
        List<FeedbackResponse> responses = getNextBestAction(new List<FeedbackRequest>{request});
        
        if (!responses.isEmpty() && responses[0].success) {
            // Deserialize the JSON string back to DTO
            return (NextBestActionDTO) JSON.deserialize(responses[0].nextBestAction, NextBestActionDTO.class);
        }
        
        return null;
    }
}
ayer to avoind the roadject mater 