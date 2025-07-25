/**
 * @description Handles queries to find learners who have unenrolled from a specific training.
 * It searches for assignments that are marked as Inactive.
 * @author (Your Name/Team)
 * @date (Current Date)
 */
public class TrainingUnenrollmentListHandler implements ITrainingQueryHandler {

    private TrainingResultFormatter formatter;
    private TrainingQueryRequest request;
    private static final Integer PAGE_SIZE = 20;

    public String process(TrainingQueryRequest queryRequest) {
        this.request = queryRequest;
        this.formatter = new TrainingResultFormatter(this.request);

        String trainingNameInput = this.request.FILTERS?.Training_Name;
        if (String.isBlank(trainingNameInput)) {
            return formatter.formatBooleanResult(false, '', 'Please specify the training name to see who has unenrolled.');
        }

        List<String> keywords = new List<String>();
        if (String.isNotBlank(trainingNameInput)) {
            for (String keyword : trainingNameInput.trim().split(' ')) {
                if (String.isNotBlank(keyword)) {
                    keywords.add(keyword);
                }
            }
        }
        if (keywords.isEmpty()) {
            return 'Could not extract keywords from the provided training name.';
        }

        List<String> searchTargets = new List<String>{'Assigned_Course__c', 'Assigned_Curriculum__c', 'Assignment__c'};
        
        Integer totalMatchingUnenrollments = 0;
        for (String objectApiName : searchTargets) {
            TrainingQueryBuilder countQb = new TrainingQueryBuilder(this.request);
            countQb.selectFrom(objectApiName).clearSelectFields().addSelectField('COUNT()');
            applyUnenrollmentFilters(countQb, getTrainingNameFieldPath(objectApiName), keywords);
            totalMatchingUnenrollments += countQb.executeCountQuery();
        }

        if (this.request.RESPONSE_CRITERIA == null) this.request.RESPONSE_CRITERIA = new TrainingQueryRequest.ResponseCriteria();
        this.request.RESPONSE_CRITERIA.totalRecords = totalMatchingUnenrollments;
        
        if (totalMatchingUnenrollments == 0) {
            return 'I found no learners who have unenrolled from training matching your criteria.';
        }

        Integer offset = this.request.FILTERS?.queryOffset != null ? this.request.FILTERS.queryOffset : 0;
        
        List<SObject> finalResults = new List<SObject>();
        for (String objectApiName : searchTargets) {
            TrainingQueryBuilder qb = new TrainingQueryBuilder(this.request);
            qb.selectFrom(objectApiName)
              .addSelectField('Learner_Profile__r.Name')
              .addSelectField(getTrainingNameFieldPath(objectApiName))
              .orderBy('Learner_Profile__r.Name', 'ASC')
              .setLimit(PAGE_SIZE).setOffset(offset);
            
            applyUnenrollmentFilters(qb, getTrainingNameFieldPath(objectApiName), keywords);
            finalResults.addAll(qb.executeQuery());
        }

        return formatUnenrollmentResults(finalResults, totalMatchingUnenrollments, offset);
    }
    
    private String formatUnenrollmentResults(List<SObject> records, Integer totalRecords, Integer offset) {
        String paginationInfo = String.format('(showing page results {0} to {1} of {2} total)',
                                        new List<Object>{offset + 1, offset + records.size(), totalRecords});

        List<String> responseParts = new List<String>{
            'The following learners have unenrolled ' + paginationInfo + ':'
        };
        
        for(SObject record : records) {
            String trainingName = getActualTrainingNameFromRecord(record);
            String learnerName = (String) record.getSObject('Learner_Profile__r')?.get('Name');
            if(String.isNotBlank(trainingName) && String.isNotBlank(learnerName)) {
                responseParts.add('- ' + learnerName + ' (from ' + trainingName + ')');
            }
        }
        return String.join(responseParts, '\n');
    }

    private void applyUnenrollmentFilters(TrainingQueryBuilder qb, String trainingNameFieldPath, List<String> keywords) {
        // Filter by training name
        Integer keywordIndex = 0;
        for (String keyword : keywords) {
            String bindKey = 'kw' + keywordIndex++;
            qb.addWhereCondition(trainingNameFieldPath + ' LIKE :' + bindKey, bindKey, '%' + keyword + '%');
        }

        // The core logic: find INACTIVE assignments for ACTIVE learners.
        qb.addWhereCondition('Inactive__c = :isInactive', 'isInactive', true);
        qb.addWhereCondition('Learner_Profile__r.Status__c = :lpStatus', 'lpStatus', 'Active');
    }

    private String getTrainingNameFieldPath(String apiName) {
        if (apiName.equalsIgnoreCase('Assigned_Course__c')) return 'Course__r.Name';
        if (apiName.equalsIgnoreCase('Assigned_Curriculum__c')) return 'Curriculum__r.Name';
        if (apiName.equalsIgnoreCase('Assignment__c')) return 'Asset__r.Name';
        return '';
    }

    private String getActualTrainingNameFromRecord(SObject record) {
        String path = getTrainingNameFieldPath(String.valueOf(record.getSObjectType()));
        Object trainingName = TrainingIndividualLearnerQueryHandler.getStaticNestedSObjectValue(record, path);
        return trainingName != null ? String.valueOf(trainingName) : '[Unknown Training]';
    }
}