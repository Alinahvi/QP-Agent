/**
 * @description Handles queries about the training data model itself, such as listing
 * all available courses or curricula.
 * @author (Your Name/Team)
 * @date (Current Date)
 */
public class TrainingMetadataQueryHandler implements ITrainingQueryHandler {

    private TrainingResultFormatter formatter;
    private TrainingQueryRequest request;

    public String process(TrainingQueryRequest queryRequest) {
        this.request = queryRequest;
        this.formatter = new TrainingResultFormatter(this.request);

        String metadataRequestType = this.request.METADATA_REQUEST_TYPE;
        if (String.isBlank(metadataRequestType)) {
            return formatter.formatBooleanResult(false, '', 'I could not determine the type of metadata you are asking for.');
        }

        try {
            switch on metadataRequestType.toUpperCase() {
                when 'AVAILABLE_COURSES' {
                    return handleAvailableTrainings('Course__c', 'courses');
                }
                when 'AVAILABLE_CURRICULA' {
                    return handleAvailableTrainings('Curriculum__c', 'curricula');
                }
                when 'FIELD_VALUES' {
                    String objApiName = this.request.TARGET_OBJECT_API_NAME;
                    String fieldApiName = this.request.TARGET_FIELD_API_NAME;
                    return handleFieldValues(objApiName, fieldApiName);
                }
                when else {
                    return formatter.formatBooleanResult(false, '', 'I do not support that type of metadata request yet.');
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in TrainingMetadataQueryHandler: ' + e.getMessage());
            return 'I encountered an error while trying to fetch the metadata.';
        }
    }

    /**
     * @description A generic helper to get a list of active training records by object type.
     */
    private String handleAvailableTrainings(String objectApiName, String trainingTypeLabel) {
        TrainingQueryBuilder qb = new TrainingQueryBuilder(this.request);
        qb.selectFrom(objectApiName)
          .addSelectField('Name')
          .addWhereCondition('Status__c = :status', 'status', 'Active')
          .orderBy('Name', 'ASC')
          .setLimit(20); // Return a sample of up to 20

        List<SObject> trainings = qb.executeQuery();
        
        if (trainings.isEmpty()) {
            return 'No ' + trainingTypeLabel + ' are currently available.';
        }
        
        // Set the response criteria so the formatter knows which field to display
        if (this.request.RESPONSE_CRITERIA == null) this.request.RESPONSE_CRITERIA = new TrainingQueryRequest.ResponseCriteria();
        this.request.RESPONSE_CRITERIA.RETURN_FIELDS = new List<String>{'Name'};
        
        return 'Available ' + trainingTypeLabel + ' include: ' + formatter.formatResults(trainings);
    }

    /**
     * @description A helper to dynamically get picklist values for a given field on an object.
     */
    private String handleFieldValues(String objectApiName, String fieldApiName) {
        if (String.isBlank(objectApiName) || String.isBlank(fieldApiName)) {
            return 'Please specify the object and field to get values for.';
        }

        Map<String, SObjectType> globalDescribe = Schema.getGlobalDescribe();
        if (!globalDescribe.containsKey(objectApiName.toLowerCase())) {
             return 'Sorry, I could not find an object named: ' + objectApiName;
        }

        SObjectType sObjectType = globalDescribe.get(objectApiName.toLowerCase());
        Map<String, Schema.SObjectField> fieldMap = sObjectType.getDescribe().fields.getMap();
        if (!fieldMap.containsKey(fieldApiName.toLowerCase())) {
            return 'Sorry, I could not find a field named: ' + fieldApiName + ' on object ' + objectApiName;
        }

        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldApiName.toLowerCase()).getDescribe();
        
        if (fieldDescribe.getType() == Schema.DisplayType.PICKLIST) {
            for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                if (entry.isActive()) { 
                    picklistValues.add(entry.getLabel());
                }
            }
        } else {
            return 'The field ' + fieldDescribe.getLabel() + ' is not a picklist.';
        }

        if (picklistValues.isEmpty()) {
            return 'No active values were found for the ' + fieldDescribe.getLabel() + ' field.';
        }
        
        return 'Possible values for ' + fieldDescribe.getLabel() + ' are: ' + String.join(picklistValues, ', ') + '.';
    }
}