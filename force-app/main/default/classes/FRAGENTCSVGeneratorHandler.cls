/**
 * TEMPLATE HANDLER - This class acts as agent instructions in our handler/service template.
 * Business Requirement: Responses include both Ids and Names when applicable to meet user-friendly output requirements.
 * The handler validates requests and delegates business logic to the service layer.
 * Handler class for CSV Generation operations
 *
 * This agent-facing class provides a robust interface for generating CSV data from Salesforce records.
 * It uses a modern DTO-based approach for clear, type-safe operations. The handler
 * is responsible for validating incoming requests and dispatching them to the
 * appropriate method in the FRAGENTUtility.
 *
 * Generated CSVs include the fields specified in the request using the
 * `FRAGENTUtility.buildSafeQuery` method.
 */
public with sharing class FRAGENTCSVGeneratorHandler {
    
    public class Request {
        @InvocableVariable(label='Action' description='The action to perform: Generate' required=true)
        public String action;
        
        @InvocableVariable(label='Object API Name' description='The API name of the object to query (e.g., Account, Contact, Custom_Object__c)' required=true)
        public String objectApiName;
        
        @InvocableVariable(label='Field List' description='Comma-separated list of field API names to include in the CSV (e.g., Id,Name,Email__c)' required=true)
        public String fieldList;
        
        @InvocableVariable(label='Where Clause' description='Optional SOQL WHERE clause to filter records (e.g., "Name LIKE \'%Test%\'")')
        public String whereClause;
        
        @InvocableVariable(label='Order By' description='Optional SOQL ORDER BY clause (e.g., "Name ASC")')
        public String orderBy;
        
        @InvocableVariable(label='Record Limit' description='Maximum number of records to return (default: 1000)')
        public Integer recordLimit = 1000;
    }
    
    public class Response {
        @InvocableVariable(label='Success' description='Indicates whether the operation was completed successfully. True if the operation succeeded, false if there was an error.')
        public Boolean success;
        
        @InvocableVariable(label='Message' description='Provides detailed feedback about the operation result. Contains success messages, error details, or informational text about what happened during the operation.')
        public String message;
        
        @InvocableVariable(label='CSV Data' description='The generated CSV content as a string. This contains all the requested data in comma-separated value format, ready for export or further processing.')
        public String csvData;
        
        @InvocableVariable(label='Record Count' description='The total number of records that were processed and included in the generated CSV data.')
        public Integer recordCount;
        
        public Response() {
            this.success = false;
            this.recordCount = 0;
        }
    }

    @InvocableMethod(label='FRAGENT Generate CSV' description='Generates CSV data from Salesforce records based on specified criteria.')
    public static List<Response> generateCSV(List<Request> requests) {
        List<Response> responses = new List<Response>();

        for (Request req : requests) {
            Response res = new Response();
            
            try {
                // Validate action parameter
                if (String.isBlank(req.action)) {
                    res.message = 'Action parameter is required. Valid actions: Generate';
                    responses.add(res);
                    continue;
                }
                
                String action = req.action.toLowerCase();
                
                // Route to appropriate service method based on action
                switch on action {
                    when 'generate' {
                        res = handleGenerate(req);
                    }
                    when else {
                        res.message = 'Invalid action: ' + req.action + '. Valid actions: Generate';
                    }
                }
                
            } catch (Exception e) {
                res.success = false;
                res.message = 'An unexpected error occurred: ' + e.getMessage();
            }
            
            responses.add(res);
        }

        return responses;
    }
    
    private static Response handleGenerate(Request req) {
        Response res = new Response();
        
        // Validate required fields for Generate
        if (String.isBlank(req.objectApiName)) {
            res.message = 'Object API Name is required for Generate action';
            return res;
        }
        
        if (String.isBlank(req.fieldList)) {
            res.message = 'Field List is required for Generate action';
            return res;
        }
        
        try {
            // Parse field list from comma-separated string to list
            List<String> fieldList = new List<String>();
            if (String.isNotBlank(req.fieldList)) {
                fieldList = req.fieldList.split(',');
                for (Integer i = 0; i < fieldList.size(); i++) {
                    fieldList[i] = fieldList[i].trim();
                }
            }
            
            // Build a safe query
            String query = FRAGENTUtility.buildSafeQuery(req.objectApiName, fieldList);
            
            // Add WHERE clause if provided
            if (String.isNotBlank(req.whereClause)) {
                query += ' WHERE ' + req.whereClause;
            }
            
            // Add ORDER BY clause if provided
            if (String.isNotBlank(req.orderBy)) {
                query += ' ORDER BY ' + req.orderBy;
            }
            
            // Add LIMIT clause
            query += ' LIMIT ' + req.recordLimit;
            
            // Execute query and generate CSV
            List<SObject> records = Database.query(query);
            String csv = FRAGENTUtility.serializeToCsv(records, fieldList);
            
            res.success = true;
            res.message = 'CSV generated successfully. Found ' + records.size() + ' record(s).';
            res.csvData = csv;
            res.recordCount = records.size();
            
        } catch (Exception e) {
            res.success = false;
            res.message = 'Error generating CSV: ' + e.getMessage();
        }
        
        return res;
    }
}