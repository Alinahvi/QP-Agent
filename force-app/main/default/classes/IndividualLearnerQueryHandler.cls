/**
 * @description Handles queries related to a single learner's training records.
 * The detailed logic will be implemented later, but this version includes a
 * helper method required by other classes.
 * @author (Your Name/Team)
 * @date (Current Date)
 */
public class IndividualLearnerQueryHandler implements ITrainingQueryHandler {

    public String process(TrainingQueryRequest request) {
        // Full implementation for this handler will be done in a later step.
        return 'Individual Learner Query Handler logic not yet implemented.';
    }

    /**
     * @description REQUIRED HELPER METHOD. Safely retrieves a value from a nested SObject relationship.
     * For example, it can get 'Name' from 'Course__r.Name'. This is required by other handlers.
     * @param record The parent SObject record.
     * @param fieldPath The full API path to the desired field (e.g., 'Relationship__r.FieldName').
     * @return Object The retrieved value, or null if not found.
     */
    public static Object getStaticNestedSObjectValue(SObject record, String fieldPath) {
        if (record == null || String.isBlank(fieldPath)) return null;
        
        List<String> pathElements = fieldPath.split('\\.');
        SObject currentSObject = record;

        try {
            for (Integer i = 0; i < pathElements.size(); i++) {
                String element = pathElements[i];
                if (currentSObject == null) return null;

                // If this is the last element, it's the field we want.
                if (i == pathElements.size() - 1) {
                    return currentSObject.get(element);
                } else {
                    // Otherwise, it's a relationship, so traverse to the next SObject.
                    currentSObject = currentSObject.getSObject(element);
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'getStaticNestedSObjectValue error for path ' + fieldPath + ': ' + e.getMessage());
            return null;
        }
        return null;
    }
}