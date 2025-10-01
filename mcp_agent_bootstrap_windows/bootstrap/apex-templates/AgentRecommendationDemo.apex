Account demoAccount;
try {
    demoAccount = [SELECT Id, Name FROM Account LIMIT 1];
} catch (QueryException ex) {
    System.debug('No account records available: ' + ex.getMessage());
}
if (demoAccount == null) {
    System.debug('ACTION NEEDED: create an Account before running AgentRecommendationDemo.');
} else {
    Map<String, Object> signals = new Map<String, Object>{
        'intentScore' => 0.82,
        'requiresFollowUp' => false,
        'lastInteractionDays' => 4
    };
    List<AgentRecommendation.Recommendation> recs = AgentRecommendation.buildRecommendations(
        demoAccount.Id,
        'ServicePlus',
        signals
    );
    System.debug(JSON.serializePretty(recs));
}
