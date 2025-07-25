/**
 * @description Handles various queries about a single learner's training record, such as
 * their completions, pending assignments, or status for a specific course.
 * @author (Your Name/Team)
 * @date (Current Date)
 */
public class TrainingIndividualLearnerQueryHandler implements ITrainingQueryHandler {

    private TrainingResultFormatter formatter;
    private TrainingQueryRequest request;

    public String process(TrainingQueryRequest queryRequest) {
        this.request = queryRequest;
        this.formatter = new TrainingResultFormatter(this.request);

        String learnerName = this.request.LEARNER_CONTEXT?.LEARNER_NAME;
        if (String.isBlank(learnerName)) {
            return 'Please specify a learner to run this query for.';
        }

        // Route to a specific helper method based on the agent's identified action
        switch on this.request.AGENT_ACTION.toUpperCase() {
            when 'CHECK_INDIVIDUAL_TRAINING_STATUS' {
                return handleCheckTrainingStatus(learnerName);
            }
            when 'GET_INDIVIDUAL_ASSIGNED_TRAINING' {
                return handleGetAssignedTraining(learnerName);
            }
            when 'CHECK_INDIVIDUAL_UNENROLLMENT' {
                return handleCheckUnenrollment(learnerName);
            }
            when else {
                return 'I do not know how to handle that specific request for an individual learner.';
            }
        }
    }
    
    /**
     * @description Handles general queries for a learner's assignments (e.g., all completed or all pending).
     */
    private String handleGetAssignedTraining(String learnerName) {
        TrainingQueryBuilder qb = new TrainingQueryBuilder(this.request);
        qb.selectFrom('Assigned_Course__c')
          .addSelectField('Course__r.Name')
          .addSelectField('Due_Date__c')
          .addSelectField('Completion_Date__c')
          .addWhereCondition('Learner_Profile__r.Name = :lName', 'lName', learnerName);
        
        if ('ACTIVE_PENDING'.equalsIgnoreCase(this.request.FILTERS?.Assignment_Status_Category)) {
            // CORRECTED: Using bind variables for the query conditions.
            qb.addWhereCondition('Completed__c = :isCompleted', 'isCompleted', false);
            qb.addWhereCondition('Inactive__c = :isInactive', 'isInactive', false);
        }
        
        List<SObject> results = qb.executeQuery();
        return formatter.formatResults(results);
    }
    
    /**
     * @description Handles a query to check the status of a specific training for a learner.
     */
    private String handleCheckTrainingStatus(String learnerName) {
        String trainingName = this.request.FILTERS?.Training_Name;
        if (String.isBlank(trainingName)) {
            return 'Please specify which training you are asking about.';
        }

        TrainingQueryBuilder qb = new TrainingQueryBuilder(this.request);
        qb.selectFrom('Assigned_Course__c')
          .addSelectField('Id')
          .addSelectField('Completed__c')
          .addSelectField('Inactive__c')
          .addWhereCondition('Learner_Profile__r.Name = :lName', 'lName', learnerName)
          .addWhereCondition('Course__r.Name LIKE :tName', 'tName', '%' + trainingName + '%')
          .setLimit(1);
          
        List<SObject> results = qb.executeQuery();

        if (results.isEmpty()) {
            return 'It does not look like ' + learnerName + ' is assigned to ' + trainingName + '.';
        }

        Assigned_Course__c assignment = (Assigned_Course__c) results[0];
        if (assignment.Inactive__c) {
            return 'Yes, ' + learnerName + ' was previously assigned but has unenrolled from ' + trainingName + '.';
        } else if (assignment.Completed__c) {
            return 'Yes, ' + learnerName + ' has completed ' + trainingName + '.';
        } else {
            return 'No, ' + learnerName + ' has not yet completed ' + trainingName + '. It is still pending.';
        }
    }

    /**
     * @description Handles a query to check if a learner has unenrolled from a training.
     */
    private String handleCheckUnenrollment(String learnerName) {
        String trainingName = this.request.FILTERS?.Training_Name;
        if (String.isBlank(trainingName)) {
            return 'Please specify the training to check for unenrollment.';
        }

        TrainingQueryBuilder qb = new TrainingQueryBuilder(this.request);
        qb.selectFrom('Assigned_Course__c')
          .addSelectField('COUNT()')
          .addWhereCondition('Learner_Profile__r.Name = :lName', 'lName', learnerName)
          .addWhereCondition('Course__r.Name LIKE :tName', 'tName', '%' + trainingName + '%')
          // CORRECTED: Using a bind variable for the query condition.
          .addWhereCondition('Inactive__c = :isInactive', 'isInactive', true);
        
        Integer unenrollmentCount = qb.executeCountQuery();
        
        return formatter.formatBooleanResult(unenrollmentCount > 0, 'Yes, ' + learnerName + ' has unenrolled.', 'No, I did not find an unenrollment record.');
    }

    /**
     * @description REQUIRED HELPER METHOD. Safely retrieves a value from a nested SObject relationship.
     */
    public static Object getStaticNestedSObjectValue(SObject record, String fieldPath) {
        if (record == null || String.isBlank(fieldPath)) return null;
        if (!fieldPath.contains('.')) return record.get(fieldPath);
        
        List<String> pathElements = fieldPath.split('\\.');
        SObject currentSObject = record;
        try {
            for (Integer i = 0; i < pathElements.size(); i++) {
                String element = pathElements[i];
                if (currentSObject == null) return null;
                if (i == pathElements.size() - 1) return currentSObject.get(element);
                else currentSObject = currentSObject.getSObject(element);
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }
}