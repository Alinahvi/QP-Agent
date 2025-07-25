@isTest
private class TrainingQueryHandlerFactoryTest {

    @isTest
    static void testGetHandler_ForCompletion() {
        // Arrange
        String action = 'GET_TRAINING_PARTICIPANTS';
        
        // Act
        ITrainingQueryHandler handler = TrainingQueryHandlerFactory.getHandler(action, new TrainingQueryRequest());

        // Assert
        System.assert(handler instanceof TrainingCompletionQueryHandler, 'Should return TrainingCompletionQueryHandler for action: ' + action);
    }

    @isTest
    static void testGetHandler_ForHierarchy() {
        // Arrange
        String action = 'GET_HIERARCHICAL_TRAINING_COMPLETION';

        // Act
        ITrainingQueryHandler handler = TrainingQueryHandlerFactory.getHandler(action, new TrainingQueryRequest());

        // Assert
        System.assert(handler instanceof TrainingHierarchicalQueryHandler, 'Should return TrainingHierarchicalQueryHandler for action: ' + action);
    }
    
    @isTest
    static void testGetHandler_ForSession() {
        // Arrange
        String action = 'GET_SESSION_PARTICIPANTS';

        // Act
        ITrainingQueryHandler handler = TrainingQueryHandlerFactory.getHandler(action, new TrainingQueryRequest());

        // Assert
        System.assert(handler instanceof TrainingSessionQueryHandler, 'Should return TrainingSessionQueryHandler for action: ' + action);
    }
    
    @isTest
    static void testGetHandler_ForIndividual() {
        // Arrange
        String action = 'CHECK_INDIVIDUAL_TRAINING_STATUS';

        // Act
        ITrainingQueryHandler handler = TrainingQueryHandlerFactory.getHandler(action, new TrainingQueryRequest());

        // Assert
        System.assert(handler instanceof TrainingIndividualLearnerQueryHandler, 'Should return TrainingIndividualLearnerQueryHandler for action: ' + action);
    }
    
    @isTest
    static void testGetHandler_ForMetadata() {
        // Arrange
        String action = 'GET_TRAINING_METADATA';

        // Act
        ITrainingQueryHandler handler = TrainingQueryHandlerFactory.getHandler(action, new TrainingQueryRequest());

        // Assert
        System.assert(handler instanceof TrainingMetadataQueryHandler, 'Should return TrainingMetadataQueryHandler for action: ' + action);
    }
    
    @isTest
    static void testGetHandler_ForUnenrollmentList() {
        // Arrange
        String action = 'GET_TRAINING_UNENROLLMENTS';
        
        // Act
        ITrainingQueryHandler handler = TrainingQueryHandlerFactory.getHandler(action, new TrainingQueryRequest());
        
        // Assert
        System.assert(handler instanceof TrainingUnenrollmentListHandler, 'Should return TrainingUnenrollmentListHandler for action: ' + action);
    }

    @isTest
    static void testGetHandler_ForUnknownAction() {
        // Arrange
        String action = 'SOME_UNKNOWN_ACTION';

        // Act
        ITrainingQueryHandler handler = TrainingQueryHandlerFactory.getHandler(action, new TrainingQueryRequest());

        // Assert
        System.assert(handler instanceof TrainingDefaultQueryHandler, 'Should return TrainingDefaultQueryHandler for an unknown action.');
    }
    
    @isTest
    static void testGetHandler_ForBlankAction() {
        // Arrange
        String action = '';

        // Act
        ITrainingQueryHandler handler = TrainingQueryHandlerFactory.getHandler(action, new TrainingQueryRequest());

        // Assert
        System.assert(handler instanceof TrainingDefaultQueryHandler, 'Should return TrainingDefaultQueryHandler for a blank action.');
    }
}