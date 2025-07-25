public with sharing class TrainingResultFormatter {

    private TrainingQueryRequest request; 
    public TrainingResultFormatter(TrainingQueryRequest queryRequest) { this.request = queryRequest; }

    // Inner class to hold structured data for easier formatting
    private class FormattedResult {
        String trainingName;
        String trainingType;
        Date completionDate;
        Date dueDate;
        Boolean isSelfAssigned;
    }

    public String formatResults(List<SObject> records) {
        if (records == null || records.isEmpty()) {
            return 'I did not find any results matching your query.';
        }

        // Group results by Learner Name first
        Map<String, List<FormattedResult>> resultsByLearner = new Map<String, List<FormattedResult>>();
        
        for (SObject record : records) {
            String learnerName = (String) getSObjectValue(record, 'Learner_Profile__r.Name');
            if (String.isBlank(learnerName)) continue;

            if (!resultsByLearner.containsKey(learnerName)) {
                resultsByLearner.put(learnerName, new List<FormattedResult>());
            }
            
            FormattedResult fr = new FormattedResult();
            fr.trainingType = getTrainingType(record.getSObjectType());
            fr.trainingName = (String) getSObjectValue(record, getTrainingNameFieldPath(record.getSObjectType()));
            fr.completionDate = (Date) record.get('Completion_Date__c');
            fr.dueDate = (Date) record.get('Due_Date__c');
            fr.isSelfAssigned = (Boolean) record.get('Self_Assigned__c');

            // Add the structured result to the map
            resultsByLearner.get(learnerName).add(fr);
        }

        if (resultsByLearner.isEmpty()) {
            return 'I found matching records but could not extract the necessary details.';
        }

        // Build the rich, multi-line string response
        List<String> responseParts = new List<String>{'Here is the information I found:'};
        List<String> sortedLearnerNames = new List<String>(resultsByLearner.keySet());
        sortedLearnerNames.sort();

        for (String learnerName : sortedLearnerNames) {
            responseParts.add('\n' + learnerName + ':');
            for (FormattedResult fr : resultsByLearner.get(learnerName)) {
                if (fr.trainingName == null) continue;
                
                String detail = '- ' + fr.trainingName + ' (' + fr.trainingType + ')';

                if (fr.completionDate != null) {
                    detail += ' - Completed: ' + fr.completionDate.format();
                } else if (fr.dueDate != null) {
                    detail += ' - Due: ' + fr.dueDate.format();
                }

                if (fr.isSelfAssigned != null && fr.isSelfAssigned) {
                    detail += ' (Self-Assigned)';
                }
                responseParts.add(detail);
            }
        }
        return String.join(responseParts, '\n');
    }
    
    // All helper methods from the previous version are included here
    public String formatBooleanResult(Boolean result, String positiveStatement, String negativeStatement) {
        if (result == null) return negativeStatement;
        return result ? positiveStatement : negativeStatement;
    }

    private String getTrainingType(SObjectType sType) {
        if (sType == Assigned_Course__c.SObjectType) return 'Course';
        if (sType == Assigned_Curriculum__c.SObjectType) return 'Curriculum';
        if (sType == Assignment__c.SObjectType) return 'Event/Asset';
        return 'Training';
    }

    private String getTrainingNameFieldPath(SObjectType sType) {
        if (sType == Assigned_Course__c.SObjectType) return 'Course__r.Name';
        if (sType == Assigned_Curriculum__c.SObjectType) return 'Curriculum__r.Name';
        if (sType == Assignment__c.SObjectType) return 'Asset__r.Name';
        return '';
    }

    private Object getSObjectValue(SObject record, String fieldPath) {
        if (record == null || String.isBlank(fieldPath)) return null;
        if (!fieldPath.contains('.')) return record.get(fieldPath);
        
        List<String> pathElements = fieldPath.split('\\.');
        SObject currentSObject = record;
        try {
            for (Integer i = 0; i < pathElements.size(); i++) {
                String element = pathElements[i];
                if (currentSObject == null) return null;
                if (i == pathElements.size() - 1) {
                    return currentSObject.get(element);
                } else {
                    String relationshipName = element.endsWithIgnoreCase('__c') ? element.substring(0, element.length() - 1) + 'r' : element;
                    currentSObject = currentSObject.getSObject(relationshipName);
                }
            }
        } catch (Exception e) { return null; }
        return null;
    }
}