public class GAFRAEnhancedDynamicSchemaRetriever {

    @InvocableMethod(label='GAFRA Retrieve Enhanced Object Schemas' description='Returns comprehensive object schemas with key field details and example data based on user input.')
    public static List<EnhancedSchemaRetrievalResult> retrieveSchemas(List<PromptInputRequest> requests) {
        List<EnhancedSchemaRetrievalResult> results = new List<EnhancedSchemaRetrievalResult>();

        if (requests == null || requests.isEmpty()) {
            throw new AuraHandledException('No request data provided.');
        }

        for (PromptInputRequest req : requests) {
            // Simulate calling the Flex Prompt Template internally
            String promptJson = generatePromptResponse(req.userInput);
            Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(promptJson);

            List<Object> objectsRaw = (List<Object>) parsedJson.get('objects');
            List<EnhancedObjectSchemaDetail> schemaDetails = new List<EnhancedObjectSchemaDetail>();

            for (Object objRaw : objectsRaw) {
                Map<String, Object> objMap = (Map<String, Object>) objRaw;
                String objectApiName = (String) objMap.get('objectApiName');
                String usageInstruction = (String) objMap.get('usage');
                List<String> keyFields = (List<String>) objMap.get('keyFields');

                schemaDetails.add(getEnhancedObjectDetails(objectApiName, usageInstruction, keyFields));
            }

            results.add(new EnhancedSchemaRetrievalResult(
                req.userInput,
                (String)parsedJson.get('taskName'),
                (String)parsedJson.get('description'),
                schemaDetails
            ));
        }
        return results;
    }

    // Placeholder method to simulate prompt template invocation
    private static String generatePromptResponse(String userInput) {
        // Implement actual Flex Prompt Template invocation logic here
        // Currently returns a mock JSON response for testing purposes
        return '{ "taskName": "Mock Task", "description": "Mock description based on user input.", "objects": [] }';
    }

    private static EnhancedObjectSchemaDetail getEnhancedObjectDetails(String objectApiName, String usage, List<String> keyFields) {
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap();
        List<FieldLabel> allFields = new List<FieldLabel>();
        List<KeyFieldDetail> keyFieldDetails = new List<KeyFieldDetail>();

        for (String fieldApiName : fieldsMap.keySet()) {
            Schema.DescribeFieldResult fieldDesc = fieldsMap.get(fieldApiName).getDescribe();
            allFields.add(new FieldLabel(fieldApiName, fieldDesc.getLabel()));

            if (keyFields.contains(fieldApiName)) {
                List<String> picklistVals = new List<String>();
                if (fieldDesc.getType() == Schema.DisplayType.Picklist) {
                    for (Schema.PicklistEntry pe : fieldDesc.getPicklistValues()) {
                        picklistVals.add(pe.getValue());
                    }
                }
                keyFieldDetails.add(new KeyFieldDetail(
                    fieldApiName,
                    fieldDesc.getLabel(),
                    fieldDesc.getType().name(),
                    picklistVals,
                    fetchSampleValues(objectApiName, fieldApiName)
                ));
            }
        }

        return new EnhancedObjectSchemaDetail(objectApiName, usage, allFields, keyFieldDetails);
    }

    private static List<String> fetchSampleValues(String objectApiName, String fieldApiName) {
        List<String> samples = new List<String>();
        String query = 'SELECT ' + fieldApiName + ' FROM ' + objectApiName + ' WHERE ' + fieldApiName + ' != NULL LIMIT 2';

        try {
            List<SObject> records = Database.query(query);
            for (SObject rec : records) {
                Object val = rec.get(fieldApiName);
                samples.add(String.valueOf(val));
            }
        } catch (Exception e) {
            samples.add('No sample data available');
        }

        return samples.isEmpty() ? new List<String>{'No data'} : samples;
    }

    public class PromptInputRequest {
        @InvocableVariable(label='User Input' description='Original user input or instruction for reference and context.')
        public String userInput;
    }

    public class EnhancedSchemaRetrievalResult {
        @InvocableVariable(label='User Input' description='Original user input or instruction for context.')
        public String userInput;

        @InvocableVariable(label='Task Name' description='The name of the task identified by the LLM.')
        public String taskName;

        @InvocableVariable(label='Description' description='Detailed description of the task.')
        public String description;

        @InvocableVariable(label='Object Schemas' description='List of objects with their schema details.')
        public List<EnhancedObjectSchemaDetail> objects;

        public EnhancedSchemaRetrievalResult(String userInput, String taskName, String description, List<EnhancedObjectSchemaDetail> objects) {
            this.userInput = userInput;
            this.taskName = taskName;
            this.description = description;
            this.objects = objects;
        }
    }

    public class EnhancedObjectSchemaDetail {
        @InvocableVariable(label='Object API Name' description='The API name of the Salesforce object.')
        public String objectApiName;

        @InvocableVariable(label='Usage Instruction' description='Instruction detailing how to use this object for the task.')
        public String usage;

        @InvocableVariable(label='All Fields' description='List of all field labels associated with the object.')
        public List<FieldLabel> allFields;

        @InvocableVariable(label='Key Field Details' description='Detailed information on key fields, including data type, picklist values, and sample values.')
        public List<KeyFieldDetail> keyFieldDetails;

        public EnhancedObjectSchemaDetail(String objectApiName, String usage, List<FieldLabel> allFields, List<KeyFieldDetail> keyFieldDetails) {
            this.objectApiName = objectApiName;
            this.usage = usage;
            this.allFields = allFields;
            this.keyFieldDetails = keyFieldDetails;
        }
    }

    public class FieldLabel {
        @InvocableVariable(label='Field API Name' description='The API name of the field.')
        public String fieldApiName;

        @InvocableVariable(label='Field Label' description='The human-readable label of the field.')
        public String fieldLabel;

        public FieldLabel(String api, String label) {
            this.fieldApiName = api;
            this.fieldLabel = label;
        }
    }

    public class KeyFieldDetail {
        @InvocableVariable(label='Field API Name' description='The API name of the key field.')
        public String fieldApiName;

        @InvocableVariable(label='Field Label' description='The label of the key field.')
        public String fieldLabel;

        @InvocableVariable(label='Data Type' description='Data type of the key field.')
        public String dataType;

        @InvocableVariable(label='Picklist Values' description='List of possible picklist values, if applicable.')
        public List<String> picklistValues;

        @InvocableVariable(label='Sample Values' description='Sample values retrieved from existing records for this field.')
        public List<String> sampleValues;

        public KeyFieldDetail(String api, String label, String type, List<String> pickVals, List<String> samples) {
            this.fieldApiName = api;
            this.fieldLabel = label;
            this.dataType = type;
            this.picklistValues = pickVals;
            this.sampleValues = samples;
        }
    }
}