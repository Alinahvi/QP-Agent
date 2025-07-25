/**
 * @description Handles queries that combine organizational hierarchy with training status.
 * @author (Your Name/Team)
 * @date (Current Date)
 */
public class TrainingHierarchicalQueryHandler implements ITrainingQueryHandler {
    private TrainingResultFormatter formatter;
    private TrainingQueryRequest request;

    public String process(TrainingQueryRequest queryRequest) {
        this.request = queryRequest;
        this.formatter = new TrainingResultFormatter(this.request);

        TrainingQueryRequest.HierarchyContext hx = this.request.HIERARCHY_CONTEXT;
        if (hx == null || String.isBlank(hx.ANCHOR_NAME) || String.isBlank(hx.TYPE)) {
            return 'Please specify a manager or team to run this query for.';
        }

        try {
            Set<Id> learnerIdsInHierarchy = getLearnerIdsInHierarchy(hx.ANCHOR_NAME, hx.TYPE);
            if (learnerIdsInHierarchy.isEmpty()) {
                return 'I could not find any employees in the hierarchy of ' + hx.ANCHOR_NAME;
            }

            String trainingName = this.request.FILTERS?.Training_Name;

            List<SObject> allResults = new List<SObject>();
            allResults.addAll(queryAssignments('Assigned_Curriculum__c', trainingName, learnerIdsInHierarchy));
            allResults.addAll(queryAssignments('Assigned_Course__c', trainingName, learnerIdsInHierarchy));
            allResults.addAll(queryAssignments('Assignment__c', trainingName, learnerIdsInHierarchy));
            
            return formatter.formatResults(allResults);

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'TrainingHierarchicalQueryHandler Error: ' + e.getMessage());
            return 'An error occurred while processing the hierarchy query.';
        }
    }

    private List<SObject> queryAssignments(String objectApiName, String trainingName, Set<Id> learnerIds) {
        TrainingQueryBuilder qb = new TrainingQueryBuilder(this.request);
        qb.selectFrom(objectApiName)
          .addSelectField('Learner_Profile__r.Name')
          .addSelectField(getTrainingNameFieldPath(objectApiName))
          .addSelectField('Completion_Date__c')
          .addSelectField('Due_Date__c')
          .addSelectField('Self_Assigned__c')
          .orderBy('Learner_Profile__r.Name', 'ASC');

        qb.addWhereCondition('Learner_Profile__c IN :learnerIds', 'learnerIds', learnerIds);
        
        // CORRECTED: Pass the objectApiName to the helper method
        applyCommonFilters(qb, trainingName, objectApiName);
        
        if (objectApiName.equalsIgnoreCase('Assigned_Course__c')) {
            qb.addWhereConditionRaw('Assigned_Curriculum__c = null');
        } else if (objectApiName.equalsIgnoreCase('Assignment__c')) {
            qb.addWhereConditionRaw('Assigned_Course__c = null AND Assigned_Curriculum__c = null');
        }
        return qb.executeQuery();
    }

    // CORRECTED: Method signature now accepts objectApiName
    private void applyCommonFilters(TrainingQueryBuilder qb, String trainingName, String objectApiName) {
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
        
        if (String.isNotBlank(trainingName)) {
            // CORRECTED: Uses the objectApiName passed as a parameter
            qb.addWhereCondition(getTrainingNameFieldPath(objectApiName) + ' LIKE :tName', 'tName', '%' + trainingName + '%');
        }
        qb.addWhereCondition('Self_Assigned__c = :saFalse', 'saFalse', false);
    }

    private Set<Id> getLearnerIdsInHierarchy(String anchorName, String hierarchyType) {
        Set<Id> learnerIds = new Set<Id>();
        if ('DIRECT_REPORTS'.equalsIgnoreCase(hierarchyType)) {
            for(Learner_Profile__c lp : [SELECT Id FROM Learner_Profile__c WHERE Manager__c = :anchorName AND Status__c = 'Active']) {
                learnerIds.add(lp.Id);
            }
        } else if ('ORGANIZATION_MEMBERS'.equalsIgnoreCase(hierarchyType)) {
            String managerEmail = findManagerEmail(anchorName);
            if(String.isBlank(managerEmail)) return learnerIds;
            
            String safeManagerEmail = String.escapeSingleQuotes(managerEmail);
            List<String> conditions = new List<String>();
            for (Integer i = 1; i <= 10; i++) {
                conditions.add('Emp_Mgt_Chain_Lvl_' + String.valueOf(i).leftPad(2, '0') + '_Nm__c = \'' + safeManagerEmail + '\'');
            }
            String whereClause = ' Status__c = \'Active\' AND (' + String.join(conditions, ' OR ') + ')';
            for(Learner_Profile__c lp : Database.query('SELECT Id FROM Learner_Profile__c WHERE ' + whereClause)) {
                learnerIds.add(lp.Id);
            }
        }
        return learnerIds;
    }

    private String findManagerEmail(String managerName) {
        List<Learner_Profile__c> profiles = [SELECT Primary_Email__c FROM Learner_Profile__c WHERE Name = :managerName AND Status__c = 'Active' LIMIT 1];
        return profiles.isEmpty() ? '' : profiles[0].Primary_Email__c;
    }

    private String getTrainingNameFieldPath(String apiName) {
        if (apiName.equalsIgnoreCase('Assigned_Course__c')) return 'Course__r.Name';
        if (apiName.equalsIgnoreCase('Assigned_Curriculum__c')) return 'Curriculum__r.Name';
        if (apiName.equalsIgnoreCase('Assignment__c')) return 'Asset__r.Name';
        return '';
    }
}