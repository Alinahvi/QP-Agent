public class GAFRAObjectSchemaProvider {
    @InvocableMethod(label='GAFRA Get Object Schemas' description='Retrieves detailed schema information for specified Salesforce objects, including field properties.')
    public static List<ObjectSchemaResult> getSchemas(List<ObjectSchemaRequest> requests) {
        List<ObjectSchemaResult> results = new List<ObjectSchemaResult>();

        for (ObjectSchemaRequest req : requests) {
            Schema.DescribeSObjectResult dsr = Schema.getGlobalDescribe().get(req.objectApiName).getDescribe();
            List<FieldSchema> fields = new List<FieldSchema>();

            for (Schema.SObjectField field : dsr.fields.getMap().values()) {
                Schema.DescribeFieldResult dfr = field.getDescribe();
                fields.add(new FieldSchema(
                    dfr.getName(),
                    dfr.getType().name(),
                    dfr.isNillable(),
                    dfr.isCreateable(),
                    dfr.isUpdateable(),
                    !dfr.isNillable()
                ));
            }

            results.add(new ObjectSchemaResult(req.objectApiName, fields));
        }
        return results;
    }

    public class ObjectSchemaRequest {
        @InvocableVariable(required=true label='Object API Name' description='The Salesforce object API name (e.g., Account, Opportunity, Custom_Object__c) for which schema details are requested.')
        public String objectApiName;
    }

    public class ObjectSchemaResult {
        @InvocableVariable(label='Object API Name' description='The unique API name of the Salesforce object whose schema is retrieved.')
        public String objectApiName;

        @InvocableVariable(label='Field Schemas' description='Detailed schema information for each field on the specified Salesforce object.')
        public List<FieldSchema> fields;

        public ObjectSchemaResult(String objectApiName, List<FieldSchema> fields) {
            this.objectApiName = objectApiName;
            this.fields = fields;
        }
    }

    public class FieldSchema {
        @InvocableVariable(label='Field API Name' description='The unique API name of the Salesforce field.')
        public String fieldApiName;

        @InvocableVariable(label='Data Type' description='The data type of the Salesforce field (e.g., String, Boolean, Date, etc.).')
        public String dataType;

        @InvocableVariable(label='Is Nillable' description='Indicates whether the field can contain null values.')
        public Boolean isNillable;

        @InvocableVariable(label='Is Createable' description='Specifies whether values for this field can be set upon record creation.')
        public Boolean isCreateable;

        @InvocableVariable(label='Is Updateable' description='Specifies whether the field can be updated after the record is created.')
        public Boolean isUpdateable;

        @InvocableVariable(label='Is Required' description='Indicates whether the field is required (cannot be null) when creating or updating a record.')
        public Boolean isRequired;

        public FieldSchema(String fieldApiName, String dataType, Boolean isNillable, Boolean isCreateable, Boolean isUpdateable, Boolean isRequired) {
            this.fieldApiName = fieldApiName;
            this.dataType = dataType;
            this.isNillable = isNillable;
            this.isCreateable = isCreateable;
            this.isUpdateable = isUpdateable;
            this.isRequired = isRequired;
        }
    }
}