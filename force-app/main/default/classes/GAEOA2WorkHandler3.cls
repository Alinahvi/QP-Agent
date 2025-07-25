public with sharing class GAEOA2WorkHandler3 {

    public class Request {
        @InvocableVariable(label='GA-EOA2 Work ID' description='Salesforce Work record ID. Required for Modify action.' required=true)
        public String workId;
        
        // --- agf__ADM_Work__c Fields Part 3 ---
        @InvocableVariable(label='GA-EOA2 Number of Change Lists' description='Value for the Number of Change Lists (agf__Number_of_Change_Lists__c) field.')
        public Decimal agfNumberOfChangeLists;
        @InvocableVariable(label='GA-EOA2 Number of Orgs affected' description='Value for the Number of Orgs affected (agf__Number_of_Orgs_affected__c) field.')
        public Decimal agfNumberOfOrgsAffected;
        @InvocableVariable(label='GA-EOA2 Number of Tests/Classes affected' description='Value for the Number of Tests/Classes affected (agf__Number_of_Tests_Classes_affected__c) field.')
        public Decimal agfNumberOfTestsClassesAffected;
        @InvocableVariable(label='GA-EOA2 Origin' description='Value for the Origin (agf__Origin__c) field.')
        public String agfOrigin;
        @InvocableVariable(label='GA-EOA2 transfer Other Recipients' description='Value for the transfer Other Recipients (agf__Other_Recipients__c) field.')
        public String agfOtherRecipients;
        @InvocableVariable(label='GA-EOA2 Out of SLA' description='Value for the Out of SLA (agf__Out_of_SLA__c) field.')
        public Boolean agfOutOfSla;
        @InvocableVariable(label='GA-EOA2 Add Parent ID' description='Value for the Add Parent ID (agf__Parent_ID__c) field.')
        public String agfParentId;
        @InvocableVariable(label='GA-EOA2 Source Control Status' description='Value for the Source Control Status (agf__Perforce_Status__c) field.')
        public String agfPerforceStatus;
        @InvocableVariable(label='GA-EOA2 Preserve Formatting Copy' description='Value for the Preserve Formatting Copy (agf__Preserve_Formatting_Copy__c) field.')
        public Boolean agfPreserveFormattingCopy;
        @InvocableVariable(label='GA-EOA2 Preserve Formatting' description='Value for the Preserve Formatting (agf__Preserve_Formatting__c) field.')
        public Boolean agfPreserveFormatting;
        @InvocableVariable(label='GA-EOA2 transfer Previous Comments' description='Value for the transfer Previous Comments (agf__Previous_Comments__c) field.')
        public String agfPreviousComments;
        @InvocableVariable(label='GA-EOA2 Priority (default)' description='Value for the Priority (default) (agf__Priority_Default__c) field.')
        public String agfPriorityDefault;
        @InvocableVariable(label='GA-EOA2 Priority Mapping Copy' description='Value for the Priority Mapping Copy (agf__Priority_Mapping_Copy__c) field.')
        public String agfPriorityMappingCopy;
        @InvocableVariable(label='GA-EOA2 Priority Mapping' description='Value for the Priority Mapping (agf__Priority_Mapping__c) field.')
        public String agfPriorityMapping;
        @InvocableVariable(label='GA-EOA2 Priority Override Explanation Copy' description='Value for the Priority Override Explanation Copy (agf__Priority_Override_Explanation_Copy__c) field.')
        public String agfPriorityOverrideExplanationCopy;
        @InvocableVariable(label='GA-EOA2 Priority Override Explanation' description='Value for the Priority Override Explanation (agf__Priority_Override_Explanation__c) field.')
        public String agfPriorityOverrideExplanation;
        @InvocableVariable(label='GA-EOA2 Backlog Rank' description='Value for the Backlog Rank (agf__Priority_Rank__c) field.')
        public Decimal agfPriorityRank;
        @InvocableVariable(label='GA-EOA2 Priority' description='Value for the Priority (agf__Priority__c) field.')
        public String agfPriority;
        @InvocableVariable(label='GA-EOA2 Product Area' description='Value for the Product Area (agf__Product_Area__c) field.')
        public String agfProductArea;
        @InvocableVariable(label='GA-EOA2 Product Child' description='Value for the Product Child (agf__Product_Child__c) field.')
        public String agfProductChild;
        @InvocableVariable(label='GA-EOA2 Product Owner' description='Value for the Product Owner (agf__Product_Owner__c) field.')
        public String agfProductOwner;
        @InvocableVariable(label='GA-EOA2 Product Tag' description='Value for the Product Tag (agf__Product_Tag__c) field.')
        public String agfProductTag;
        @InvocableVariable(label='GA-EOA2 QA Engineer' description='Value for the QA Engineer (agf__QA_Engineer__c) field.')
        public String agfQaEngineer;
        @InvocableVariable(label='GA-EOA2 Readme Notes' description='Value for the Readme Notes (agf__Readme_Notes__c) field.')
        public String agfReadmeNotes;
    }
    
    public class Response {
        @InvocableVariable(label='GA-EOA2 Success' description='True if the operation succeeded.')
        public Boolean success = false;
        @InvocableVariable(label='GA-EOA2 Message' description='Summary of the operation result.')
        public String message = '';
        @InvocableVariable(label='GA-EOA2 Work Records' description='List of Work records from the operation.')
        public List<agf__ADM_Work__c> workRecords = new List<agf__ADM_Work__c>();
    }

    @InvocableMethod(label='GA-EOA2 Manage Work Records (Part 3)' description='Handles Modify for a subset of Work fields. Use for updating the third group of fields.')
    public static List<Response> manageWork3(List<Request> requests) {
        List<agf__ADM_Work__c> toUpdate = new List<agf__ADM_Work__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            responseMap.put(i, new Response());
            Request req = requests.get(i);
            if (String.isBlank(req.workId)) {
                responseMap.get(i).message = 'Error: Work ID is required for Modify.';
            } else {
                idsToProcess.add(req.workId);
            }
        }

        if (!idsToProcess.isEmpty()) {
            Map<Id, agf__ADM_Work__c> worksFromDb = new Map<Id, agf__ADM_Work__c>([SELECT Id FROM agf__ADM_Work__c WHERE Id IN :idsToProcess]);
            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                if (String.isNotBlank(req.workId) && worksFromDb.containsKey(req.workId)) {
                    toUpdate.add(mapRequestToWork(req, worksFromDb.get(req.workId)));
                }
            }
        }
        
        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] updateResults = Database.update(toUpdate, false);
            handleDmlResults(updateResults, toUpdate, 'Modify', requests, responseMap);
        }
        
        return new List<Response>(responseMap.values());
    }

    private static agf__ADM_Work__c mapRequestToWork(Request req, agf__ADM_Work__c work) {
        work.Id = req.workId;
        if(req.agfNumberOfChangeLists != null) work.agf__Number_of_Change_Lists__c = req.agfNumberOfChangeLists;
        if(req.agfNumberOfOrgsAffected != null) work.agf__Number_of_Orgs_affected__c = req.agfNumberOfOrgsAffected;
        if(req.agfNumberOfTestsClassesAffected != null) work.agf__Number_of_Tests_Classes_affected__c = req.agfNumberOfTestsClassesAffected;
        if(req.agfOrigin != null) work.agf__Origin__c = req.agfOrigin;
        if(req.agfOtherRecipients != null) work.agf__Other_Recipients__c = req.agfOtherRecipients;
        if(req.agfOutOfSla != null) work.agf__Out_of_SLA__c = req.agfOutOfSla;
        if(req.agfParentId != null) work.agf__Parent_ID__c = req.agfParentId;
        if(req.agfPerforceStatus != null) work.agf__Perforce_Status__c = req.agfPerforceStatus;
        if(req.agfPreserveFormattingCopy != null) work.agf__Preserve_Formatting_Copy__c = req.agfPreserveFormattingCopy;
        if(req.agfPreserveFormatting != null) work.agf__Preserve_Formatting__c = req.agfPreserveFormatting;
        if(req.agfPreviousComments != null) work.agf__Previous_Comments__c = req.agfPreviousComments;
        if(req.agfPriorityDefault != null) work.agf__Priority_Default__c = req.agfPriorityDefault;
        if(req.agfPriorityMappingCopy != null) work.agf__Priority_Mapping_Copy__c = req.agfPriorityMappingCopy;
        if(req.agfPriorityMapping != null) work.agf__Priority_Mapping__c = req.agfPriorityMapping;
        if(req.agfPriorityOverrideExplanationCopy != null) work.agf__Priority_Override_Explanation_Copy__c = req.agfPriorityOverrideExplanationCopy;
        if(req.agfPriorityOverrideExplanation != null) work.agf__Priority_Override_Explanation__c = req.agfPriorityOverrideExplanation;
        if(req.agfPriorityRank != null) work.agf__Priority_Rank__c = req.agfPriorityRank;
        if(req.agfPriority != null) work.agf__Priority__c = req.agfPriority;
        if(req.agfProductArea != null) work.agf__Product_Area__c = req.agfProductArea;
        if(req.agfProductChild != null) work.agf__Product_Child__c = req.agfProductChild;
        if(req.agfProductOwner != null) work.agf__Product_Owner__c = req.agfProductOwner;
        if(req.agfProductTag != null) work.agf__Product_Tag__c = req.agfProductTag;
        if(req.agfQaEngineer != null) work.agf__QA_Engineer__c = req.agfQaEngineer;
        if(req.agfReadmeNotes != null) work.agf__Readme_Notes__c = req.agfReadmeNotes;
        return work;
    }
    
    private static void handleDmlResults(Database.SaveResult[] results, List<agf__ADM_Work__c> records, String action, List<Request> requests, Map<Integer, Response> responseMap) {
        Integer recordIndex = 0;
        for (Integer i = 0; i < requests.size(); i++) {
            if (String.isNotBlank(requests.get(i).workId)) {
                if (recordIndex < results.size()) {
                    Database.SaveResult sr = results[recordIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Work modified successfully.';
                        res.workRecords.add(records[recordIndex]);
                    } else {
                        res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                    }
                    recordIndex++;
                }
            }
        }
    }
}