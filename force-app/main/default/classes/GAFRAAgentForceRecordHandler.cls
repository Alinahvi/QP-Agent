public class GAFRAAgentForceRecordHandler {

    @InvocableMethod(label='GAFRA AgentForce Record Handler' description='Creates or modifies Salesforce records based on provided object fields and values.')
    public static List<RecordActionResult> handleRecordActions(List<RecordActionRequest> requests) {
        List<RecordActionResult> results = new List<RecordActionResult>();

        for (RecordActionRequest request : requests) {
            try {
                SObject record;

                if (String.isBlank(request.recordId)) {
                    record = Schema.getGlobalDescribe().get(request.objectApiName).newSObject();
                } else {
                    record = Database.query('SELECT Id FROM ' + request.objectApiName + ' WHERE Id = :request.recordId LIMIT 1');
                }

                for (FieldValue fv : request.fieldValues) {
                    record.put(fv.fieldApiName, fv.value);
                }

                if (String.isBlank(request.recordId)) {
                    insert record;
                } else {
                    update record;
                }

                results.add(new RecordActionResult(true, record.Id, null));

            } catch (Exception e) {
                results.add(new RecordActionResult(false, null, e.getMessage()));
            }
        }

        return results;
    }

    public class RecordActionRequest {
        @InvocableVariable(label='Object API Name' description='The API name of the Salesforce object.')
        public String objectApiName;

        @InvocableVariable(label='Record ID' description='The ID of the record to update. Leave blank to create a new record.')
        public String recordId;

        @InvocableVariable(label='Field Values' description='List of field-value pairs for the record.')
        public List<FieldValue> fieldValues;
    }

    public class FieldValue {
        @InvocableVariable(label='Field API Name' description='The API name of the field to set.')
        public String fieldApiName;

        @InvocableVariable(label='Value' description='The value to set for the specified field.')
        public String value;
    }

    public class RecordActionResult {
        @InvocableVariable(label='Success' description='Indicates if the record action succeeded.')
        public Boolean success;

        @InvocableVariable(label='Record ID' description='The ID of the created or updated record.')
        public Id recordId;

        @InvocableVariable(label='Error Message' description='Error message in case the action failed.')
        public String errorMessage;

        public RecordActionResult(Boolean success, Id recordId, String errorMessage) {
            this.success = success;
            this.recordId = recordId;
            this.errorMessage = errorMessage;
        }
    }
}