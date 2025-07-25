public with sharing class assessmentLink {

    public String assessmentResponseId{get;set;}

    public String getAssessmentLink() {
        String href = System.URL.getSalesforceBaseUrl().toExternalForm().replace('.my.salesforce.com', '.my.site.com');
        href += '/act/s/skills-detail?recordId=' + assessmentResponseId;
        
        return href;
    }

    public String getRandom() {
        return 'hellp';
    }
}