@isTest
private class FRAGENTContentSearchService_Test {

    @testSetup
    static void setupData() {
        User uCru = FRAGENTTestDataFactory.createUsers(1, 'Standard User', true)[0];
        FRAGENTTestDataFactory.assignPermissionSet(uCru, FRAGENTGeneralService.PERM_LABEL_CRU, 'cru');

        System.runAs(uCru) {
            FRAGENTTestDataFactory.createAssets(1, true);
        }
    }

    private static User getUser(String alias) {
        return [SELECT Id FROM User WHERE Alias = :alias ORDER BY CreatedDate DESC LIMIT 1];
    }

    @isTest
    static void testSearch_Succeeds() {
        System.runAs(getUser('cru')) {
            Test.startTest();
            FRAGENTContentSearchService.SearchResult result = FRAGENTContentSearchService.search('Test', 'Asset', null, null, null, null, 10, 0);
            Test.stopTest();
            
            System.assert(result.success, 'Search should succeed for CRU user');
            System.assertEquals(1, result.records.size());
            System.assertEquals(1, result.totalCount);
        }
    }

    @isTest
    static void testSearch_Fuzzy() {
        System.runAs(getUser('cru')) {
            Test.startTest();
            FRAGENTContentSearchService.SearchResult result = FRAGENTContentSearchService.search('Tst Asset 0', 'Asset', null, null, null, null, 10, 0);
            Test.stopTest();

            System.assertEquals(1, result.records.size(), 'Fuzzy search should find the asset');
            System.assertEquals('Test Asset 0', result.records[0].name);
        }
    }
}