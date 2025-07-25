@isTest
private class FRAGENTEmployeeSearchHandler_Test {

    @testSetup
    static void setupData() {
        User uCru = FRAGENTTestDataFactory.createUsers(1, 'Standard User', true)[0];
        FRAGENTTestDataFactory.assignPermissionSet(uCru, FRAGENTGeneralService.PERM_LABEL_CRU, 'cru');
        
        FRAGENTTestDataFactory.createLearnerProfiles(1, true);
    }

    private static User getUser(String alias) {
        return [SELECT Id FROM User WHERE Alias = :alias ORDER BY CreatedDate DESC LIMIT 1];
    }
    
    @isTest
    static void testHandler_Search() {
        System.runAs(getUser('cru')) {
            FRAGENTEmployeeSearchHandler.Request req = new FRAGENTEmployeeSearchHandler.Request();
            req.action = 'Search';
            req.searchTerm = 'Test';
            
            Test.startTest();
            List<FRAGENTEmployeeSearchHandler.Response> resList = FRAGENTEmployeeSearchHandler.searchEmployees(new List<FRAGENTEmployeeSearchHandler.Request>{req});
            Test.stopTest();
            
            System.assert(resList[0].success, 'Expected success on valid Search action');
            System.assert(resList[0].totalRecordCount > 0, 'Should return at least one record');
        }
    }
    
    @isTest
    static void testHandler_NoActionSpecified() {
        System.runAs(getUser('cru')) {
            FRAGENTEmployeeSearchHandler.Request req = new FRAGENTEmployeeSearchHandler.Request();
            req.action = '';
            
            List<FRAGENTEmployeeSearchHandler.Response> resList = FRAGENTEmployeeSearchHandler.searchEmployees(new List<FRAGENTEmployeeSearchHandler.Request>{req});
            
            System.assert(!resList[0].success, 'Should fail when no action is specified');
            System.assert(resList[0].message.contains('Action parameter is required'));
        }
    }
}