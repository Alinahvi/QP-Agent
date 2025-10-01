@IsTest
private class AgentRecommendationTest {
    @IsTest
    static void buildRecommendations_basic() {
        Account acct = new Account(Name = 'Test Account');
        insert acct;
        Map<String, Object> signals = new Map<String, Object>{
            'intentScore' => 0.85,
            'requiresFollowUp' => true
        };
        List<AgentRecommendation.Recommendation> result = AgentRecommendation.buildRecommendations(acct.Id, 'ServicePlus', signals);
        System.assertEquals(1, result.size(), 'Expected single recommendation');
        System.assertEquals('Recommend ServicePlus', result[0].label);
        System.assertEquals('intentScore', result[0].signalId);
        System.assertEquals(true, result[0].followUpRequired);
        System.assert(result[0].rationale.contains('intentScore'), 'Rationale should reference top signal');
    }

    @IsTest
    static void buildRecommendations_handlesMissingSignals() {
        Account acct = new Account(Name = 'Fallback Account');
        insert acct;
        List<AgentRecommendation.Recommendation> result = AgentRecommendation.buildRecommendations(acct.Id, 'BasePlan', null);
        System.assertEquals(1, result.size(), 'Expected default recommendation');
        System.assertEquals(null, result[0].signalId, 'No signal stored when none provided');
        System.assertEquals(false, result[0].followUpRequired, 'Follow up defaults to false');
    }
}
