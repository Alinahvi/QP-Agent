public class GAFRATopicObjectSchemaProvider {

    @InvocableMethod(label='GAFRA Retrieve Topic Objects and Schemas' description='Retrieves Salesforce objects and their detailed schema, including field details and example data for each field.')
    public static List<TopicObjectSchemaResult> getTopicSchemas(List<DummyInput> inputs) {
        List<String> relevantObjects = new List<String>{
            'Audience__c', 'Audience_Member__c', 'Audience_Checklist__c',
            'Checklist__c', 'Checklist_Asset__c', 'Session__c',
            'Assigned_Learning__c', 'Assigned_Session__c', 'Learner_Profile__c'
        };

        List<TopicObjectSchemaResult> topicResults = new List<TopicObjectSchemaResult>();
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

        for (String objectApiName : relevantObjects) {
            if(globalDescribe.containsKey(objectApiName)) {
                Schema.DescribeSObjectResult dsr = globalDescribe.get(objectApiName).getDescribe();
                List<FieldDetail> fieldDetails = new List<FieldDetail>();

                for (Schema.SObjectField field : dsr.fields.getMap().values()) {
                    Schema.DescribeFieldResult dfr = field.getDescribe();
                    List<String> exampleValues = fetchExampleValues(objectApiName, dfr.getName());

                    fieldDetails.add(new FieldDetail(
                        dfr.getName(),
                        dfr.getType().name(),
                        !dfr.isNillable(),
                        dfr.isCreateable(),
                        dfr.isUpdateable(),
                        exampleValues
                    ));
                }

                topicResults.add(new TopicObjectSchemaResult(objectApiName, dsr.getLabel(), fieldDetails));
            }
        }
        return topicResults;
    }

    private static List<String> fetchExampleValues(String objectApiName, String fieldApiName) {
        List<String> examples = new List<String>();
        String query = 'SELECT ' + fieldApiName + ' FROM ' + objectApiName + ' WHERE ' + fieldApiName + ' != NULL LIMIT 2';
        try {
            List<SObject> records = Database.query(query);
            for (SObject rec : records) {
                examples.add(String.valueOf(rec.get(fieldApiName)));
            }
        } catch(Exception e) {
            examples.add('No example data');
        }

        return examples.isEmpty() ? new List<String>{'No example data'} : examples;
    }

    public class DummyInput {
        @InvocableVariable(label='Dummy Input' description='Placeholder input to trigger method execution.')
        public String dummy;
    }

    public class TopicObjectSchemaResult {
        @InvocableVariable(label='Object API Name') public String objectApiName;
        @InvocableVariable(label='Object Label') public String objectLabel;
        @InvocableVariable(label='Field Details') public List<FieldDetail> fields;

        public TopicObjectSchemaResult(String objectApiName, String objectLabel, List<FieldDetail> fields) {
            this.objectApiName = objectApiName;
            this.objectLabel = objectLabel;
            this.fields = fields;
        }
    }

    public class FieldDetail {
        @InvocableVariable(label='Field API Name') public String fieldApiName;
        @InvocableVariable(label='Data Type') public String dataType;
        @InvocableVariable(label='Is Required') public Boolean isRequired;
        @InvocableVariable(label='Is Createable') public Boolean isCreateable;
        @InvocableVariable(label='Is Updateable') public Boolean isUpdateable;
        @InvocableVariable(label='Example Values') public List<String> exampleValues;

        public FieldDetail(String fieldApiName, String dataType, Boolean isRequired, Boolean isCreateable, Boolean isUpdateable, List<String> exampleValues) {
            this.fieldApiName = fieldApiName;
            this.dataType = dataType;
            this.isRequired = isRequired;
            this.isCreateable = isCreateable;
            this.isUpdateable = isUpdateable;
            this.exampleValues = exampleValues;
        }
    }
}