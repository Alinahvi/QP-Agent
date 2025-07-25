global class deleteAssessments implements Database.Batchable<sObject>, Database.Stateful {
    private List<String> errors = new List<String>();

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM case';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Case> records) {
        // Perform delete operation with allOrNone set to false
        // 
        try {
            delete records;
        } catch(exception e) {
			this.errors.add(e.getMessage());
        }

        System.debug('Errors during execute: ' + JSON.serialize(this.errors));
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Errors during batch execution: ' + JSON.serialize(this.errors));
        for (String errorMessage : this.errors) {
            String recordId = extractIdFromErrorMessage(errorMessage);
            Id batchJobId = Database.executeBatch(new deleteChildRecords(recordId), 200);

            //if (errorMessage.contains('certifier mappings')) {
            //	Id batchJobId = Database.executeBatch(new deleteCertifiedMappings(recordId), 200);
            //}
            //else if(errorMessage.contains('Response')) {
            //	Id batchJobId = Database.executeBatch(new deleteResponses(recordId), 200);
            //} else {
			//	Id batchJobId = Database.executeBatch(new deleteChildRecords(recordId), 200);
            //}
        }
        /*
        for (String errorMessage : this.errors) {
            if (errorMessage.contains('cascading to Assignment')) {
                System.debug('Starting deleteChildRecords batch job.');
                for (String recordId : erRecordIds) {
                    Id batchJobId = Database.executeBatch(new deleteChildRecords(recordId), 200);
                }
            } else if (errorMessage.contains('cascading to Assigned Course')) {
                System.debug('Starting deleteChildAssignedRecords batch job.');
                for (String recordId : erRecordIds) {
                    Id batchJobId = Database.executeBatch(new deleteChildAssignedRecords(recordId), 200);
                }
            }
        }
		*/
    }
    
    private static String extractIdFromErrorMessage(String errorMessage) {
        // Regular expression pattern to match the ID
        Pattern p = Pattern.compile('id (\\w{15,18})');
        Matcher m = p.matcher(errorMessage);

        if (m.find()) {
            return m.group(1); // Extract the first capturing group (the ID)
        }
        return null;
    }
}