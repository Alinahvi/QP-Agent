/**
 * Test class for SalesCoachFeedbackService
 */
@IsTest
public class SalesCoachFeedbackServiceTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Create test opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 50000
        );
        insert testOpp;
        
        // Create test renewal record
        Agent_Renewals__c testRenewal = new Agent_Renewals__c(
            learner_profile_id__c = 'TEST_LEARNER_123',
            full_name__c = 'Test Seller',
            emp_email_addr__c = 'test@seller.com',
            emp_id__c = 'EMP123',
            renewal_acct_nm__c = 'Test Account',
            renewal_prod_nm__c = 'Tableau Cloud Analytics',
            renewal_opty_amt__c = 50000
        );
        insert testRenewal;
    }
    
    @IsTest
    static void testGetNextBestActionWithOpportunity() {
        // Test with opportunity ID
        SalesCoachFeedbackService.FeedbackRequest request = new SalesCoachFeedbackService.FeedbackRequest();
        request.learnerProfileId = 'TEST_LEARNER_123';
        request.opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        request.includeCrossSell = true;
        request.includeUpsell = true;
        
        Test.startTest();
        List<SalesCoachFeedbackService.FeedbackResponse> responses = 
            SalesCoachFeedbackService.getNextBestAction(new List<SalesCoachFeedbackService.FeedbackRequest>{request});
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assertEquals(true, responses[0].success, 'Response should be successful');
        System.assertNotEquals(null, responses[0].nextBestAction, 'Next Best Action should not be null');
        System.assertEquals('TEST_LEARNER_123', request.learnerProfileId, 'Learner Profile ID should match');
    }
    
    @IsTest
    static void testGetNextBestActionWithoutOpportunity() {
        // Test without opportunity ID (fallback to pipeline objects)
        SalesCoachFeedbackService.FeedbackRequest request = new SalesCoachFeedbackService.FeedbackRequest();
        request.learnerProfileId = 'TEST_LEARNER_123';
        request.includeCrossSell = true;
        request.includeUpsell = true;
        
        Test.startTest();
        List<SalesCoachFeedbackService.FeedbackResponse> responses = 
            SalesCoachFeedbackService.getNextBestAction(new List<SalesCoachFeedbackService.FeedbackRequest>{request});
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assertEquals(true, responses[0].success, 'Response should be successful');
        System.assertNotEquals(null, responses[0].nextBestAction, 'Next Best Action should not be null');
    }
    
    @IsTest
    static void testGetNextBestActionWithInvalidLearnerProfile() {
        // Test with invalid learner profile ID
        SalesCoachFeedbackService.FeedbackRequest request = new SalesCoachFeedbackService.FeedbackRequest();
        request.learnerProfileId = 'INVALID_LEARNER_123';
        request.includeCrossSell = true;
        request.includeUpsell = true;
        
        Test.startTest();
        List<SalesCoachFeedbackService.FeedbackResponse> responses = 
            SalesCoachFeedbackService.getNextBestAction(new List<SalesCoachFeedbackService.FeedbackRequest>{request});
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assertEquals(false, responses[0].success, 'Response should not be successful');
        System.assertNotEquals(null, responses[0].errorMessage, 'Error message should not be null');
    }
    
    @IsTest
    static void testGetNextBestActionWithBlankLearnerProfile() {
        // Test with blank learner profile ID
        SalesCoachFeedbackService.FeedbackRequest request = new SalesCoachFeedbackService.FeedbackRequest();
        request.learnerProfileId = '';
        request.includeCrossSell = true;
        request.includeUpsell = true;
        
        Test.startTest();
        List<SalesCoachFeedbackService.FeedbackResponse> responses = 
            SalesCoachFeedbackService.getNextBestAction(new List<SalesCoachFeedbackService.FeedbackRequest>{request});
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assertEquals(false, responses[0].success, 'Response should not be successful');
        System.assertEquals('Learner Profile ID is required', responses[0].errorMessage, 'Error message should match');
    }
    
    @IsTest
    static void testGetNextBestActionForLearner() {
        // Test helper method
        Test.startTest();
        SalesCoachFeedbackService.NextBestActionDTO nba = 
            SalesCoachFeedbackService.getNextBestActionForLearner('TEST_LEARNER_123');
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, nba, 'Next Best Action should not be null');
        System.assertNotEquals(null, nba.actionType, 'Action type should not be null');
        System.assertNotEquals(null, nba.product, 'Product should not be null');
        System.assertNotEquals(null, nba.account, 'Account should not be null');
        System.assertNotEquals(null, nba.reason, 'Reason should not be null');
    }
}
