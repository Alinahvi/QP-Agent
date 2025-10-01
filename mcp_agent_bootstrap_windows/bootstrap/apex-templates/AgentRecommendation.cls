public with sharing class AgentRecommendation {
    public class Recommendation {
        @AuraEnabled public String label;
        @AuraEnabled public String rationale;
        @AuraEnabled public String signalId;
        @AuraEnabled public Boolean followUpRequired;
        @AuraEnabled public String notes;
    }

    public static List<Recommendation> buildRecommendations(Id accountId, String productContext, Map<String, Object> signals) {
        if (accountId == null) {
            throw new IllegalArgumentException('accountId is required');
        }
        if (String.isBlank(productContext)) {
            throw new IllegalArgumentException('productContext is required');
        }
        Map<String, Object> safeSignals = signals == null ? new Map<String, Object>() : signals.clone();
        Recommendation rec = new Recommendation();
        rec.label = 'Recommend ' + productContext;
        rec.signalId = pickTopSignal(safeSignals);
        rec.rationale = rec.signalId != null
            ? 'Highest priority signal ' + rec.signalId + ' indicates readiness.'
            : 'Default offer generated without signal weighting.';
        rec.followUpRequired = safeSignals.containsKey('requiresFollowUp') && (Boolean)safeSignals.get('requiresFollowUp');
        rec.notes = 'Generated for Account ' + accountId;
        return new List<Recommendation>{ rec };
    }

    private static String pickTopSignal(Map<String, Object> signals) {
        if (signals == null || signals.isEmpty()) {
            return null;
        }
        String candidate;
        Decimal highestScore = -1;
        for (String key : signals.keySet()) {
            Object value = signals.get(key);
            Decimal score = value instanceof Decimal ? (Decimal)value : (value instanceof Integer ? Decimal.valueOf((Integer)value) : null);
            if (score != null && score > highestScore) {
                highestScore = score;
                candidate = key;
            } else if (candidate == null) {
                candidate = key;
            }
        }
        return candidate;
    }
}
