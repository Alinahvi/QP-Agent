/**
 * @isTest
 * @description Test class for FRAGENTCSVGeneratorHandler.
 * Verifies that CSV content is correctly generated from a SOQL query.
 */
@isTest
private class FRAGENTCSVGeneratorHandler_Test {

    /**
     * @description Sets up two Account records to be used for the CSV generation test.
     */
    @TestSetup
    static void makeData() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'GenePoint'),
            new Account(Name = 'United Oil & Gas Corp.')
        };
        insert accounts;
    }

    /**
     * @description Verifies that a valid SOQL query produces the correct CSV output, including headers and data.
     */
    @isTest
    static void testGenerateCSV_Success() {
        String query = 'SELECT Name, Id FROM Account ORDER BY Name ASC';
        FRAGENTCSVGeneratorHandler.Request request = new FRAGENTCSVGeneratorHandler.Request();
        request.objectType = 'Account';
        request.query = query;

        Test.startTest();
        FRAGENTCSVGeneratorHandler.Response result = FRAGENTCSVGeneratorHandler.generateCSV(
            new List<FRAGENTCSVGeneratorHandler.Request>{ request }
        )[0];
        Test.stopTest();

        System.assertEquals(true, result.success, 'The CSV generation should be successful.');
        System.assertEquals(2, result.recordCount, 'Should process the two created accounts.');
        
        // Verify headers
        System.assert(result.csvContent.startsWith('"Name","Id"'), 'CSV should start with the correct headers.');
        
        // Verify content
        System.assert(result.csvContent.contains('"GenePoint"'), 'CSV should contain the first account name.');
        System.assert(result.csvContent.contains('"United Oil & Gas Corp."'), 'CSV should contain the second account name.');
    }

    /**
     * @description A negative test to confirm that providing an invalid SOQL query results in a failure.
     */
    @isTest
    static void testGenerateCSV_InvalidQuery_Fails() {
        String invalidQuery = 'SELECT NonExistentField FROM Account';
        FRAGENTCSVGeneratorHandler.Request request = new FRAGENTCSVGeneratorHandler.Request();
        request.objectType = 'Account';
        request.query = invalidQuery;
        
        Test.startTest();
        FRAGENTCSVGeneratorHandler.Response result = FRAGENTCSVGeneratorHandler.generateCSV(
            new List<FRAGENTCSVGeneratorHandler.Request>{ request }
        )[0];
        Test.stopTest();
        
        System.assertEquals(false, result.success, 'Operation should fail with an invalid query.');
        System.assert(result.message.contains('Error'), 'The message should indicate an error occurred.');
    }
}