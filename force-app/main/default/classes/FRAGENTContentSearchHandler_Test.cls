/**
 * @isTest
 * @description Test class for the FRAGENTContentSearchHandler.
 * Verifies that content can be successfully searched.
 */
@isTest
private class FRAGENTContentSearchHandler_Test {

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
    static void testHandler_Search() {
        System.runAs(getUser('cru')) {
            FRAGENTContentSearchHandler.Request req = new FRAGENTContentSearchHandler.Request();
            req.action = 'Search';
            req.searchTerm = 'Test';
            
            Test.startTest();
            List<FRAGENTContentSearchHandler.Response> resList = FRAGENTContentSearchHandler.searchContent(new List<FRAGENTContentSearchHandler.Request>{req});
            Test.stopTest();
            
            System.assert(resList[0].success, 'Expected success on valid Search action');
            System.assertEquals(1, resList[0].totalRecordCount);
        }
    }
    
    @isTest
    static void testHandler_NoActionSpecified() {
        System.runAs(getUser('cru')) {
            FRAGENTContentSearchHandler.Request req = new FRAGENTContentSearchHandler.Request();
            req.action = '';
            
            List<FRAGENTContentSearchHandler.Response> resList = FRAGENTContentSearchHandler.searchContent(new List<FRAGENTContentSearchHandler.Request>{req});
            
            System.assert(!resList[0].success, 'Should fail when no action is specified');
            System.assert(resList[0].message.contains('Action must be "Search"'));
        }
    }
}