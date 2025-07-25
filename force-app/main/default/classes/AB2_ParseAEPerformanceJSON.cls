public with sharing class AB2_ParseAEPerformanceJSON {

    @InvocableMethod(label='Parse AE Performance JSON' description='Parses a JSON string into a list of AERow records for use in Flows.')
    public static List<AB2_BulkAEPerformanceUpsert.AERow> parse(List<String> jsonInputs) {
        List<AB2_BulkAEPerformanceUpsert.AERow> output = new List<AB2_BulkAEPerformanceUpsert.AERow>();
        for (String jsonInput : jsonInputs) {
            try {
                List<AB2_BulkAEPerformanceUpsert.AERow> parsed = 
                    (List<AB2_BulkAEPerformanceUpsert.AERow>) 
                    JSON.deserialize(jsonInput, List<AB2_BulkAEPerformanceUpsert.AERow>.class);
                output.addAll(parsed);
            } catch (Exception e) {
                System.debug('Error parsing input: ' + e.getMessage());
            }
        }
        return output;
    }
}