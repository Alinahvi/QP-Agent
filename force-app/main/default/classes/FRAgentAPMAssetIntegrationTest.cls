@isTest
public class FRAgentAPMAssetIntegrationTest {
    @isTest static void testServiceAndHandlerIntegration() {
        // Create test Courses
        Course__c course1 = new Course__c(Name='Integration Test Course 1', Status__c='Active', Share_Url__c='http://integrationcourse1', Description__c='Integration Desc 1');
        Course__c course2 = new Course__c(Name='Integration Test Course 2', Status__c='Draft', Share_Url__c='http://integrationcourse2', Description__c='Integration Desc 2');
        insert new List<Course__c>{course1, course2};

        // Create test Curriculums
        Curriculum__c curr1 = new Curriculum__c(Name='Integration Test Curriculum 1', Status__c='Active', Share_Url__c='http://integrationcurr1', Description__c='Integration Curr Desc 1');
        Curriculum__c curr2 = new Curriculum__c(Name='Integration Test Curriculum 2', Status__c='Draft', Share_Url__c='http://integrationcurr2', Description__c='Integration Curr Desc 2');
        insert new List<Curriculum__c>{curr1, curr2};

        // Step 1: Use handler to search for all assets
        FRAgentAPMAssetHandler.Request handlerReq = new FRAgentAPMAssetHandler.Request();
        handlerReq.recordLimit = 10;
        List<FRAgentAPMAssetHandler.Response> handlerResponses = FRAgentAPMAssetHandler.searchAssets(new List<FRAgentAPMAssetHandler.Request>{handlerReq});
        System.assertEquals(1, handlerResponses.size());
        System.assertEquals(true, handlerResponses[0].success);
        System.assert(handlerResponses[0].assets.size() >= 4, 'Handler should return at least 4 assets');

        // Step 2: Use output from handler as input for service (e.g., search by asset name)
        FRAgentAPMAssetWrapper firstAsset = handlerResponses[0].assets[0];
        Map<String, Object> serviceParams = new Map<String, Object>{'keyword' => firstAsset.assetName, 'recordLimit' => 10};
        Map<String, Object> serviceResult = FRAgentAPMAssetService.search(serviceParams);
        System.assertEquals(true, serviceResult.get('success'));
        List<FRAgentAPMAssetWrapper> serviceAssets = (List<FRAgentAPMAssetWrapper>)serviceResult.get('records');
        Boolean found = false;
        for (FRAgentAPMAssetWrapper a : serviceAssets) {
            if (a.assetName == firstAsset.assetName) found = true;
        }
        System.assert(found, 'Service should find the asset returned by handler');

        // Step 3: Use handler to search by status of the first asset
        FRAgentAPMAssetHandler.Request statusReq = new FRAgentAPMAssetHandler.Request();
        statusReq.status = firstAsset.status;
        statusReq.recordLimit = 10;
        List<FRAgentAPMAssetHandler.Response> statusResponses = FRAgentAPMAssetHandler.searchAssets(new List<FRAgentAPMAssetHandler.Request>{statusReq});
        System.assertEquals(true, statusResponses[0].success);
        Boolean foundByStatus = false;
        for (FRAgentAPMAssetWrapper a : statusResponses[0].assets) {
            if (a.status == firstAsset.status) foundByStatus = true;
        }
        System.assert(foundByStatus, 'Handler should find assets by status');
    }
} 