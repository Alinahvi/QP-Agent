/**
 * @description Handles queries about training completion status. This final version
 * searches across all assignment types and filters for "top-level" assignments.
 * @author (Your Name/Team)
 * @date (Current Date)
 */
public class TrainingCompletionQueryHandler implements ITrainingQueryHandler {

    private TrainingResultFormatter formatter;
    private TrainingQueryRequest request;

    public String process(TrainingQueryRequest queryRequest) {
        this.request = queryRequest;
        this.formatter = new TrainingResultFormatter(this.request);

        String learnerName = this.request.LEARNER_CONTEXT?.LEARNER_NAME;
        String trainingNameInput = this.request.FILTERS?.Training_Name;

        if (String.isBlank(learnerName) && String.isBlank(trainingNameInput)) {
            return 'Please specify either a learner or a training name for this query.';
        }
        
        List<SObject> allResults = new List<SObject>();
        // Query for Curricula first, as they are always top-level.
        allResults.addAll(queryAssignments('Assigned_Curriculum__c', trainingNameInput, learnerName));
        // Then query for Courses that are NOT part of a curriculum assignment.
        allResults.addAll(queryAssignments('Assigned_Course__c', trainingNameInput, learnerName));
        // Then query for Assets that are not part of a course or curriculum.
        allResults.addAll(queryAssignments('Assignment__c', trainingNameInput, learnerName));

        return formatter.formatResults(allResults);
    }

    private List<SObject> queryAssignments(String objectApiName, String trainingName, String learnerName) {
        TrainingQueryBuilder qb = new TrainingQueryBuilder(this.request);
        qb.selectFrom(objectApiName)
          .addSelectField('Learner_Profile__r.Name')
          .addSelectField(getTrainingNameFieldPath(objectApiName))
          .addSelectField('Completion_Date__c')
          .addSelectField('Due_Date__c')
          .addSelectField('Self_Assigned__c')
          .orderBy('Learner_Profile__r.Name', 'ASC');

        // CORRECTED: Pass the objectApiName to the helper method
        applyCommonFilters(qb, trainingName, learnerName, objectApiName);
        
        if (objectApiName.equalsIgnoreCase('Assigned_Course__c')) {
            qb.addWhereConditionRaw('Assigned_Curriculum__c = null');
        } else if (objectApiName.equalsIgnoreCase('Assignment__c')) {
            qb.addWhereConditionRaw('Assigned_Course__c = null AND Assigned_Curriculum__c = null');
        }
        return qb.executeQuery();
    }
    
    // CORRECTED: Method signature now accepts objectApiName
    private void applyCommonFilters(TrainingQueryBuilder qb, String trainingName, String learnerName, String objectApiName) {
        String completionStatus = this.request.FILTERS?.Completion_Status;
        String statusCategory = this.request.FILTERS?.Assignment_Status_Category;

        if ('ACTIVE_PENDING'.equalsIgnoreCase(statusCategory)) {
            qb.addWhereCondition('Completed__c = :isCompleted', 'isCompleted', false);
            qb.addWhereCondition('Inactive__c = :isInactive', 'isInactive', false);
        } else {
            Boolean isCompleted = 'COMPLETED'.equalsIgnoreCase(completionStatus);
            qb.addWhereCondition('Completed__c = :isCompleted', 'isCompleted', isCompleted);
            qb.addWhereCondition('Inactive__c = :isInactive', 'isInactive', false);
        }

        if (String.isNotBlank(learnerName)) {
            qb.addWhereCondition('Learner_Profile__r.Name = :lName', 'lName', learnerName);
        }
        if (String.isNotBlank(trainingName)) {
            // CORRECTED: Uses the objectApiName passed as a parameter
            qb.addWhereCondition(getTrainingNameFieldPath(objectApiName) + ' LIKE :tName', 'tName', '%' + trainingName + '%');
        }
        qb.addWhereCondition('Learner_Profile__r.Status__c = :activeLP', 'activeLP', 'Active');
        qb.addWhereCondition('Self_Assigned__c = :saFalse', 'saFalse', false);
    }

    private String getTrainingNameFieldPath(String apiName) {
        if (apiName.equalsIgnoreCase('Assigned_Course__c')) return 'Course__r.Name';
        if (apiName.equalsIgnoreCase('Assigned_Curriculum__c')) return 'Curriculum__r.Name';
        if (apiName.equalsIgnoreCase('Assignment__c')) return 'Asset__r.Name';
        return '';
    }
}