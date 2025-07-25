@isTest
public class FRAgentAPMAssetHandlerTest {
    @isTest static void testSearchAssetsHandler() {
        // Create test Courses
        Course__c course1 = new Course__c(Name='Handler Test Course 1', Status__c='Active', Share_Url__c='http://handlercourse1', Description__c='Handler Desc 1');
        Course__c course2 = new Course__c(Name='Handler Test Course 2', Status__c='Draft', Share_Url__c='http://handlercourse2', Description__c='Handler Desc 2');
        insert new List<Course__c>{course1, course2};

        // Create test Curriculums
        Curriculum__c curr1 = new Curriculum__c(Name='Handler Test Curriculum 1', Status__c='Active', Share_Url__c='http://handlercurr1', Description__c='Handler Curr Desc 1');
        Curriculum__c curr2 = new Curriculum__c(Name='Handler Test Curriculum 2', Status__c='Draft', Share_Url__c='http://handlercurr2', Description__c='Handler Curr Desc 2');
        insert new List<Curriculum__c>{curr1, curr2};

        // Test: search with no filters
        FRAgentAPMAssetHandler.Request req = new FRAgentAPMAssetHandler.Request();
        req.recordLimit = 10;
        List<FRAgentAPMAssetHandler.Request> reqs = new List<FRAgentAPMAssetHandler.Request>{req};
        List<FRAgentAPMAssetHandler.Response> responses = FRAgentAPMAssetHandler.searchAssets(reqs);
        System.assertEquals(1, responses.size());
        System.assertEquals(true, responses[0].success);
        System.assert(responses[0].assets.size() >= 4, 'Should return at least 4 assets');

        // Test: search by keyword
        req = new FRAgentAPMAssetHandler.Request();
        req.keyword = 'Handler Test Course 1';
        req.recordLimit = 10;
        responses = FRAgentAPMAssetHandler.searchAssets(new List<FRAgentAPMAssetHandler.Request>{req});
        System.assertEquals(true, responses[0].success);
        Boolean foundCourse = false;
        for (FRAgentAPMAssetWrapper a : responses[0].assets) {
            if (a.assetName == 'Handler Test Course 1') foundCourse = true;
        }
        System.assert(foundCourse, 'Handler Test Course 1 should be in results');

        // Test: search by status
        req = new FRAgentAPMAssetHandler.Request();
        req.status = 'Draft';
        req.recordLimit = 10;
        responses = FRAgentAPMAssetHandler.searchAssets(new List<FRAgentAPMAssetHandler.Request>{req});
        System.assertEquals(true, responses[0].success);
        Boolean foundDraft = false;
        for (FRAgentAPMAssetWrapper a : responses[0].assets) {
            if (a.status == 'Draft') foundDraft = true;
        }
        System.assert(foundDraft, 'Should find at least one Draft asset');

        // Test: empty request list
        responses = FRAgentAPMAssetHandler.searchAssets(new List<FRAgentAPMAssetHandler.Request>());
        System.assertEquals(false, responses[0].success);
        System.assertEquals('No requests provided.', responses[0].message);
    }

    @isTest static void testRetrieveAssetById() {
        // Create an active course
        Course__c activeCourse = new Course__c(Name='Retrieve Test Course', Status__c='Active', Share_Url__c='http://retrievecourse', Description__c='Retrieve Desc');
        insert activeCourse;
        // Create a draft course
        Course__c draftCourse = new Course__c(Name='Retrieve Draft Course', Status__c='Draft', Share_Url__c='http://retrievedraft', Description__c='Draft Desc');
        insert draftCourse;
        // Valid active asset
        FRAgentAPMAssetHandler.RetrieveRequest req = new FRAgentAPMAssetHandler.RetrieveRequest();
        req.assetId = String.valueOf(activeCourse.Id);
        req.assetType = 'Course';
        List<FRAgentAPMAssetHandler.RetrieveResponse> responses = FRAgentAPMAssetHandler.retrieveAssetById(new List<FRAgentAPMAssetHandler.RetrieveRequest>{req});
        System.assertEquals(1, responses.size());
        System.assertEquals(true, responses[0].success);
        System.assertEquals('Asset found and is active.', responses[0].message);
        System.assertNotEquals(null, responses[0].asset);
        System.assertEquals(activeCourse.Id, responses[0].asset.assetId);
        // Non-existent Id
        req = new FRAgentAPMAssetHandler.RetrieveRequest();
        req.assetId = 'a6J000000000000AAA'; // unlikely to exist
        req.assetType = 'Course';
        responses = FRAgentAPMAssetHandler.retrieveAssetById(new List<FRAgentAPMAssetHandler.RetrieveRequest>{req});
        System.assertEquals(false, responses[0].success);
        System.assertEquals('Asset not found: ID does not exist.', responses[0].message);
        // Not active asset
        req = new FRAgentAPMAssetHandler.RetrieveRequest();
        req.assetId = String.valueOf(draftCourse.Id);
        req.assetType = 'Course';
        responses = FRAgentAPMAssetHandler.retrieveAssetById(new List<FRAgentAPMAssetHandler.RetrieveRequest>{req});
        System.assertEquals(false, responses[0].success);
        System.assertEquals('Asset is not active/outdated.', responses[0].message);
    }
} 