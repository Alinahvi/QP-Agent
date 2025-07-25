public with sharing class GAEOA2WorkHandler2 {

    public class Request {
        @InvocableVariable(label='GA-EOA2 Work ID' description='Salesforce Work record ID. Required for Modify action.' required=true)
        public String workId;
        
        // --- agf__ADM_Work__c Fields Part 2 ---
        @InvocableVariable(label='GA-EOA2 Details and Steps to Reproduce' description='Value for the Details and Steps to Reproduce (agf__Details_and_Steps_to_Reproduce__c) field.')
        public String agfDetailsAndStepsToReproduce;
        @InvocableVariable(label='GA-EOA2 Due Date (Do Not Use)' description='Value for the Due Date (Do Not Use) (agf__Due_Date__c) field. Supported formats: YYYY-MM-DD, or Salesforce date literals (e.g., TODAY, LAST_N_DAYS:30).')
        public Datetime agfDueDate;
        @InvocableVariable(label='GA-EOA2 Email2GUS Addresses' description='Value for the Email2GUS Addresses (agf__Email2GUS_Addresses__c) field.')
        public String agfEmail2gusAddresses;
        @InvocableVariable(label='GA-EOA2 Email On Save Copy' description='Value for the Email On Save Copy (agf__Email_On_Save_Copy__c) field.')
        public Boolean agfEmailOnSaveCopy;
        @InvocableVariable(label='GA-EOA2 Email On Save' description='Value for the Email On Save (agf__Email_On_Save__c) field.')
        public Boolean agfEmailOnSave;
        @InvocableVariable(label='GA-EOA2 To' description='Value for the To (agf__Email_Subscription_ID__c) field.')
        public String agfEmailSubscriptionId;
        @InvocableVariable(label='GA-EOA2 Encoded Recipients' description='Value for the Encoded Recipients (agf__Encoded_Recipients_Txt_Area__c) field.')
        public String agfEncodedRecipientsTxtArea;
        @InvocableVariable(label='GA-EOA2 Environment' description='Value for the Environment (agf__Environment__c) field.')
        public String agfEnvironment;
        @InvocableVariable(label='GA-EOA2 Epic Rank' description='Value for the Epic Rank (agf__Epic_Rank__c) field.')
        public Decimal agfEpicRank;
        @InvocableVariable(label='GA-EOA2 Epic' description='Value for the Epic (agf__Epic__c) field.')
        public String agfEpic;
        @InvocableVariable(label='GA-EOA2 Escalation Point' description='Value for the Escalation Point (agf__Escalation_Point__c) field.')
        public Decimal agfEscalationPoint;
        @InvocableVariable(label='GA-EOA2 Estimated Financial Impact' description='Value for the Estimated Financial Impact (agf__Estimated_Financial_Impact__c) field.')
        public Decimal agfEstimatedFinancialImpact;
        @InvocableVariable(label='GA-EOA2 Executive Involved' description='Value for the Executive Involved (agf__Executive_Involved__c) field.')
        public Boolean agfExecutiveInvolved;
        @InvocableVariable(label='GA-EOA2 External ID' description='Value for the External ID (agf__External_ID__c) field.')
        public String agfExternalId;
        @InvocableVariable(label='GA-EOA2 Feature Rank' description='Value for the Feature Rank (agf__Feature_Rank__c) field.')
        public Decimal agfFeatureRank;
        @InvocableVariable(label='GA-EOA2 Feedback' description='Value for the Feedback (agf__Feedback__c) field.')
        public String agfFeedback;
        @InvocableVariable(label='GA-EOA2 Found In Build Copy' description='Value for the Found In Build Copy (agf__Found_In_Build_Copy__c) field.')
        public String agfFoundInBuildCopy;
        @InvocableVariable(label='GA-EOA2 Found in Build' description='Value for the Found in Build (agf__Found_in_Build__c) field.')
        public String agfFoundInBuild;
        @InvocableVariable(label='GA-EOA2 Frequency' description='Value for the Frequency (agf__Frequency__c) field.')
        public String agfFrequency;
        @InvocableVariable(label='GA-EOA2 Goal (I want to...)' description='Value for the Goal (I want to...) (agf__Goal__c) field.')
        public String agfGoal;
        @InvocableVariable(label='GA-EOA2 Help Status' description='Value for the Help Status (agf__Help_Status__c) field.')
        public String agfHelpStatus;
        @InvocableVariable(label='GA-EOA2 Highlight' description='Value for the Highlight (agf__Highlight__c) field.')
        public Boolean agfHighlight;
        @InvocableVariable(label='GA-EOA2 Impact' description='Value for the Impact (agf__Impact__c) field.')
        public String agfImpact;
        @InvocableVariable(label='GA-EOA2 Is Ignorable' description='Value for the Is Ignorable (agf__Is_Ignorable__c) field.')
        public Boolean agfIsIgnorable;
        @InvocableVariable(label='GA-EOA2 Is Template' description='Value for the Is Template (agf__Is_Template__c) field.')
        public Boolean agfIsTemplate;
        @InvocableVariable(label='GA-EOA2 Known Issue ID' description='Value for the Known Issue ID (agf__Known_Issue_ID__c) field.')
        public String agfKnownIssueId;
        @InvocableVariable(label='GA-EOA2 KI Reporting Customers' description='Value for the KI Reporting Customers (agf__Known_Issue_Num_Reporting_Customers__c) field.')
        public Decimal agfKnownIssueNumReportingCustomers;
        @InvocableVariable(label='GA-EOA2 Last Modified By Copy' description='Value for the Last Modified By Copy (agf__Last_Modified_By_Copy__c) field.')
        public String agfLastModifiedByCopy;
        @InvocableVariable(label='GA-EOA2 Last Modified By' description='Value for the Last Modified By (agf__Last_Modified_By__c) field.')
        public String agfLastModifiedBy;
        @InvocableVariable(label='GA-EOA2 Major Func Area' description='Value for the Major Func Area (agf__Major_Func_Area__c) field.')
        public String agfMajorFuncArea;
        @InvocableVariable(label='GA-EOA2 Minor Func Area' description='Value for the Minor Func Area (agf__Minor_Func_Area__c) field.')
        public String agfMinorFuncArea;
        @InvocableVariable(label='GA-EOA2 Mobile Device OS' description='Value for the Mobile Device OS (agf__Mobile_Device_OS__c) field.')
        public String agfMobileDeviceOs;
        @InvocableVariable(label='GA-EOA2 Mobile Device' description='Value for the Mobile Device (agf__Mobile_Device__c) field.')
        public String agfMobileDevice;
        @InvocableVariable(label='GA-EOA2 Mobile Network' description='Value for the Mobile Network (agf__Mobile_Network__c) field.')
        public String agfMobileNetwork;
        @InvocableVariable(label='GA-EOA2 Module(s)' description='Value for the Module(s) (agf__Modules__c) field.')
        public String agfModules;
        @InvocableVariable(label='GA-EOA2 Production Incidents' description='Value for the Production Incidents (agf__Num_Of_Prod_Occ__c) field.')
        public Decimal agfNumOfProdOcc;
        @InvocableVariable(label='GA-EOA2 Cases' description='Value for the Cases (agf__Number_of_Cases__c) field.')
        public Decimal agfNumberOfCases;
    }
    
    public class Response {
        @InvocableVariable(label='GA-EOA2 Success' description='True if the operation succeeded.')
        public Boolean success = false;
        @InvocableVariable(label='GA-EOA2 Message' description='Summary of the operation result.')
        public String message = '';
        @InvocableVariable(label='GA-EOA2 Work Records' description='List of Work records from the operation.')
        public List<agf__ADM_Work__c> workRecords = new List<agf__ADM_Work__c>();
    }

    @InvocableMethod(label='GA-EOA2 Manage Work Records (Part 2)' description='Handles Modify for a subset of Work fields. Use for updating the second group of fields.')
    public static List<Response> manageWork2(List<Request> requests) {
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
        if(req.agfDetailsAndStepsToReproduce != null) work.agf__Details_and_Steps_to_Reproduce__c = req.agfDetailsAndStepsToReproduce;
        if(req.agfDueDate != null) work.agf__Due_Date__c = req.agfDueDate;
        if(req.agfEmail2gusAddresses != null) work.agf__Email2GUS_Addresses__c = req.agfEmail2gusAddresses;
        if(req.agfEmailOnSaveCopy != null) work.agf__Email_On_Save_Copy__c = req.agfEmailOnSaveCopy;
        if(req.agfEmailOnSave != null) work.agf__Email_On_Save__c = req.agfEmailOnSave;
        if(req.agfEmailSubscriptionId != null) work.agf__Email_Subscription_ID__c = req.agfEmailSubscriptionId;
        if(req.agfEncodedRecipientsTxtArea != null) work.agf__Encoded_Recipients_Txt_Area__c = req.agfEncodedRecipientsTxtArea;
        if(req.agfEnvironment != null) work.agf__Environment__c = req.agfEnvironment;
        if(req.agfEpicRank != null) work.agf__Epic_Rank__c = req.agfEpicRank;
        if(req.agfEpic != null) work.agf__Epic__c = req.agfEpic;
        if(req.agfEscalationPoint != null) work.agf__Escalation_Point__c = req.agfEscalationPoint;
        if(req.agfEstimatedFinancialImpact != null) work.agf__Estimated_Financial_Impact__c = req.agfEstimatedFinancialImpact;
        if(req.agfExecutiveInvolved != null) work.agf__Executive_Involved__c = req.agfExecutiveInvolved;
        if(req.agfExternalId != null) work.agf__External_ID__c = req.agfExternalId;
        if(req.agfFeatureRank != null) work.agf__Feature_Rank__c = req.agfFeatureRank;
        if(req.agfFeedback != null) work.agf__Feedback__c = req.agfFeedback;
        if(req.agfFoundInBuildCopy != null) work.agf__Found_In_Build_Copy__c = req.agfFoundInBuildCopy;
        if(req.agfFoundInBuild != null) work.agf__Found_in_Build__c = req.agfFoundInBuild;
        if(req.agfFrequency != null) work.agf__Frequency__c = req.agfFrequency;
        if(req.agfGoal != null) work.agf__Goal__c = req.agfGoal;
        if(req.agfHelpStatus != null) work.agf__Help_Status__c = req.agfHelpStatus;
        if(req.agfHighlight != null) work.agf__Highlight__c = req.agfHighlight;
        if(req.agfImpact != null) work.agf__Impact__c = req.agfImpact;
        if(req.agfIsIgnorable != null) work.agf__Is_Ignorable__c = req.agfIsIgnorable;
        if(req.agfIsTemplate != null) work.agf__Is_Template__c = req.agfIsTemplate;
        if(req.agfKnownIssueId != null) work.agf__Known_Issue_ID__c = req.agfKnownIssueId;
        if(req.agfKnownIssueNumReportingCustomers != null) work.agf__Known_Issue_Num_Reporting_Customers__c = req.agfKnownIssueNumReportingCustomers;
        if(req.agfLastModifiedByCopy != null) work.agf__Last_Modified_By_Copy__c = req.agfLastModifiedByCopy;
        if(req.agfLastModifiedBy != null) work.agf__Last_Modified_By__c = req.agfLastModifiedBy;
        if(req.agfMajorFuncArea != null) work.agf__Major_Func_Area__c = req.agfMajorFuncArea;
        if(req.agfMinorFuncArea != null) work.agf__Minor_Func_Area__c = req.agfMinorFuncArea;
        if(req.agfMobileDeviceOs != null) work.agf__Mobile_Device_OS__c = req.agfMobileDeviceOs;
        if(req.agfMobileDevice != null) work.agf__Mobile_Device__c = req.agfMobileDevice;
        if(req.agfMobileNetwork != null) work.agf__Mobile_Network__c = req.agfMobileNetwork;
        if(req.agfModules != null) work.agf__Modules__c = req.agfModules;
        if(req.agfNumOfProdOcc != null) work.agf__Num_Of_Prod_Occ__c = req.agfNumOfProdOcc;
        if(req.agfNumberOfCases != null) work.agf__Number_of_Cases__c = req.agfNumberOfCases;
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