/**
 * @description Handles queries related to training sessions, such as participants,
 * registration status, and schedules.
 * @author (Your Name/Team)
 * @date (Current Date)
 */
public class TrainingSessionQueryHandler implements ITrainingQueryHandler {

    private TrainingResultFormatter formatter;
    private TrainingQueryRequest request;

    public String process(TrainingQueryRequest queryRequest) {
        this.request = queryRequest;
        this.formatter = new TrainingResultFormatter(this.request);

        TrainingQueryBuilder qb = new TrainingQueryBuilder(this.request);
        qb.selectFrom('Assigned_Session__c')
          .addSelectField('Learner_Profile__r.Name')
          .addSelectField('Session__r.Name')
          .addSelectField('Session__r.Start_Date__c')
          .addSelectField('Status__c');
        
        // Apply filters based on the user's request
        applyFilters(qb);
        
        List<SObject> results = qb.executeQuery();
        return formatter.formatResults(results);
    }

    /**
     * @description Applies WHERE conditions to the query based on the request filters.
     */
    private void applyFilters(TrainingQueryBuilder qb) {
        // Filter by participant status (e.g., Attended, Registered)
        if (String.isNotBlank(this.request.FILTERS?.Session_Participant_Status)) {
            qb.addWhereCondition('Status__c = :pStatus', 'pStatus', this.request.FILTERS.Session_Participant_Status);
        }

        // Filter by a specific session name
        if (String.isNotBlank(this.request.FILTERS?.Session_Name)) {
            String namePattern = '%' + this.request.FILTERS.Session_Name + '%';
            qb.addWhereCondition('Session__r.Name LIKE :sName', 'sName', namePattern);
        }

        // Filter by a specific parent event name
        if (String.isNotBlank(this.request.FILTERS?.Event_Name_For_Session_Filter)) {
            String namePattern = '%' + this.request.FILTERS.Event_Name_For_Session_Filter + '%';
            qb.addWhereCondition('Session__r.Asset__r.Name LIKE :eName', 'eName', namePattern);
        }

        // Filter by a relative date term
        if (String.isNotBlank(this.request.FILTERS?.RELATIVE_DATE_TERM)) {
            TrainingDateHelper.DateRange dateRange = TrainingDateHelper.parseRelativeDateTerm(this.request.FILTERS.RELATIVE_DATE_TERM);
            if (dateRange != null) {
                qb.addWhereCondition('Session__r.Start_Date__c >= :startDate', 'startDate', dateRange.startDate);
                qb.addWhereCondition('Session__r.Start_Date__c <= :endDate', 'endDate', dateRange.endDate);
            }
        }
    }
}