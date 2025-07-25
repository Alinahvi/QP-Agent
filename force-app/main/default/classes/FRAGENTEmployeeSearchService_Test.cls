@isTest
private class FRAGENTEmployeeSearchService_Test {

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
    static void testSearch_Succeeds() {
        System.runAs(getUser('cru')) {
            Test.startTest();
            FRAGENTEmployeeSearchService.EmployeeSearchResult result = FRAGENTEmployeeSearchService.searchEmployees('Test', null);
            Test.stopTest();
            
            System.assert(result != null, 'Result should not be null');
            System.assert(result.employees.size() > 0, 'Should return at least one record');
        }
    }
}