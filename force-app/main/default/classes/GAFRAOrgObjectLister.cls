public class GAFRAOrgObjectLister {
    @InvocableMethod(label='GAFRA Audience Management Object List' description='Returns specific Salesforce objects used for audience management and related tasks.')
    public static List<OrgObjectsWrapper> getAudienceObjects(List<DummyInput> inputs) {
        List<String> relevantObjects = new List<String>{
            'Audience__c', 'Audience_Member__c', 'Audience_Checklist__c',
            'Checklist__c', 'Checklist_Asset__c', 'Session__c',
            'Assigned_Learning__c', 'Assigned_Session__c', 'Learner_Profile__c'
        };

        List<OrgObjectResult> results = new List<OrgObjectResult>();
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

        for (String objectApiName : relevantObjects) {
            if(globalDescribe.containsKey(objectApiName)) {
                Schema.DescribeSObjectResult describeResult = globalDescribe.get(objectApiName).getDescribe();
                results.add(new OrgObjectResult(
                    objectApiName,
                    describeResult.getLabel(),
                    describeResult.isCustom(),
                    describeResult.isQueryable(),
                    describeResult.isCreateable()
                ));
            }
        }

        List<String> summary = new List<String>{
            'Specific to audience management and the tasks associated with that topic, here are the objects to use for tasks in this topic:'
        };

        for (OrgObjectResult result : results) {
            summary.add(result.objectApiName + ' (' + result.objectLabel + ')');
        }

        OrgObjectsWrapper wrapper = new OrgObjectsWrapper(results, summary);
        return new List<OrgObjectsWrapper>{wrapper};
    }

    public class DummyInput {
        @InvocableVariable(label='Dummy Input' description='A placeholder input to trigger this method from flows or external tools.')
        public String dummy;
    }

    public class OrgObjectsWrapper {
        @InvocableVariable(label='Objects' description='List containing metadata details for each Salesforce object relevant to audience management.')
        public List<OrgObjectResult> objectResults;

        @InvocableVariable(label='Summary' description='Contextual summary message and list of relevant object API names and labels.')
        public List<String> summary;

        public OrgObjectsWrapper(List<OrgObjectResult> objectResults, List<String> summary) {
            this.objectResults = objectResults;
            this.summary = summary;
        }
    }

    public class OrgObjectResult {
        @InvocableVariable(label='Object API Name' description='The unique API name of the Salesforce object (e.g., Audience__c).')
        public String objectApiName;

        @InvocableVariable(label='Object Label' description='The human-readable label of the Salesforce object.')
        public String objectLabel;

        @InvocableVariable(label='Is Custom Object' description='Indicates whether the object is custom or standard Salesforce object.')
        public Boolean isCustomObject;

        @InvocableVariable(label='Is Queryable' description='Specifies if the object is queryable via SOQL.')
        public Boolean isQueryable;

        @InvocableVariable(label='Is Createable' description='Specifies if new records can be created for this object.')
        public Boolean isCreateable;

        public OrgObjectResult(String objectApiName, String objectLabel, Boolean isCustomObject, Boolean isQueryable, Boolean isCreateable) {
            this.objectApiName = objectApiName;
            this.objectLabel = objectLabel;
            this.isCustomObject = isCustomObject;
            this.isQueryable = isQueryable;
            this.isCreateable = isCreateable;
        }
    }
}