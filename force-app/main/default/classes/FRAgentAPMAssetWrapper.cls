public with sharing class FRAgentAPMAssetWrapper {
    @AuraEnabled public Id assetId { get; set; }
    @AuraEnabled public String assetName { get; set; }
    @AuraEnabled public String assetType { get; set; } // 'Course' or 'Curriculum'
    @AuraEnabled public String status { get; set; }
    @AuraEnabled public String shareUrl { get; set; }
    @AuraEnabled public String description { get; set; }

    public FRAgentAPMAssetWrapper() {}
    public FRAgentAPMAssetWrapper(Id assetId, String assetName, String assetType, String status, String shareUrl, String description) {
        this.assetId = assetId;
        this.assetName = assetName;
        this.assetType = assetType;
        this.status = status;
        this.shareUrl = shareUrl;
        this.description = description;
    }

    public Map<String, Object> toNominationInput(Id nominatorId) {
        Map<String, Object> input = new Map<String, Object>();
        input.put('Asset_Id_c__c', String.valueOf(this.assetId));
        input.put('Asset_Name_c__c', this.assetName);
        input.put('Asset_Type_c__c', this.assetType);
        input.put('Nominator_c__c', String.valueOf(nominatorId));
        input.put('Status_c__c', this.status);
        // Optionally add more fields if needed
        return input;
    }
}