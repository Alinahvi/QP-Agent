/**
 * @description Factory for creating an instance of a specific training query handler
 * based on the AGENT_ACTION provided by the NLU service.
 * @author (Your Name/Team)
 * @date (Current Date)
 */
public with sharing class TrainingQueryHandlerFactory {

    /**
     * @description Returns an instance of the appropriate handler based on the agentAction string.
     * @param agentAction The primary intent identified by the NLU service.
     * @param request The full request object, for potential future logic.
     * @return ITrainingQueryHandler An instance of a class that implements the handler interface.
     */
    public static ITrainingQueryHandler getHandler(String agentAction, TrainingQueryRequest request) {
        if (String.isBlank(agentAction)) {
            System.debug(LoggingLevel.WARN, 'TrainingQueryHandlerFactory: AGENT_ACTION is blank. Returning DefaultQueryHandler.');
            return new TrainingDefaultQueryHandler();
        }

        // CORRECTED: Trim whitespace from the action string and convert to uppercase for a robust match.
        String action = agentAction.trim().toUpperCase();

        // Use a switch statement on the cleaned action string.
        switch on action {
            when 'GET_TRAINING_PARTICIPANTS' {
                return new TrainingCompletionQueryHandler();
            }
            when 'GET_HIERARCHICAL_TRAINING_COMPLETION' {
                return new TrainingHierarchicalQueryHandler();
            }
            when 'GET_SESSION_PARTICIPANTS', 'CHECK_SESSION_PARTICIPATION', 'GET_SESSION_PARTICIPANT_COUNT' {
                return new TrainingSessionQueryHandler();
            }
            when 'CHECK_INDIVIDUAL_TRAINING_STATUS', 'GET_INDIVIDUAL_ASSIGNED_TRAINING', 'CHECK_INDIVIDUAL_UNENROLLMENT' {
                return new TrainingIndividualLearnerQueryHandler();
            }
            when 'GET_TRAINING_METADATA' {
                return new TrainingMetadataQueryHandler();
            }
            when 'GET_TRAINING_UNENROLLMENTS' {
                return new TrainingUnenrollmentListHandler();
            }
            when else {
                System.debug(LoggingLevel.WARN, 'TrainingQueryHandlerFactory: Unrecognized AGENT_ACTION "' + agentAction + '". Returning DefaultQueryHandler.');
                return new TrainingDefaultQueryHandler();
            }
        }
    }
}