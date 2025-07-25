@IsTest
public class LearningMediaAssetBuilderCtrlTest {

    @IsTest
    public static void getAudiencesTest() {
        System.assert(LearningMediaAssetBuilderCtrl.getAudiences().isEmpty() == false);
    }

    @IsTest
    public static void addLinkToLearningMediaAssetTest() {
        /* Remove references to ACT 1 
        scormanywhere__Course__c media            = new scormanywhere__Course__c(Name = 'Test Media');
        slj__Learning_Offering__c     learningOffering = new slj__Learning_Offering__c(Name = 'Test Offering');

        insert new List<SObject>{media, learningOffering};

        LearningMediaAssetBuilderCtrl.addLinkToLearningMediaAsset(learningOffering.Id, media.Id, Constants.AUDIENCE_ID_INTERNAL);

        learningOffering = [SELECT slj__Url__c FROM slj__Learning_Offering__c WHERE Id = :learningOffering.Id];

        System.assert(String.isBlank(learningOffering.slj__Url__c)); 
        */
        
        scormanywhere__Course__c media            = new scormanywhere__Course__c(Name = 'Test Media');
        Asset__c     learningOffering = new Asset__c(Name = 'Test Offering');

        insert new List<SObject>{media, learningOffering};

        LearningMediaAssetBuilderCtrl.addLinkToLearningMediaAsset(learningOffering.Id, media.Id, Constants.AUDIENCE_ID_INTERNAL);

        learningOffering = [SELECT Url__c FROM Asset__c WHERE Id = :learningOffering.Id];

        System.assert(String.isBlank(learningOffering.Url__c));
    }
}