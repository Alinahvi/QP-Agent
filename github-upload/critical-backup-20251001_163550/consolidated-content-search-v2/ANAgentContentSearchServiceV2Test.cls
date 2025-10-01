@isTest
public class ANAgentContentSearchServiceV2Test {

    @isTest
    static void testACTSearch() {
        Test.startTest();
        ANAgentContentSearchServiceV2.ContentSearchResult result = 
            ANAgentContentSearchServiceV2.search('Sales Cloud', 'Course');
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals('ACT', result.searchSource, 'Search source should be ACT');
        System.assertNotEquals(null, result.records, 'Records should not be null');
        System.assertNotEquals(null, result.errors, 'Errors should not be null');
    }

    @isTest
    static void testConsensusSearch() {
        Test.startTest();
        ANAgentContentSearchServiceV2.ContentSearchResult result = 
            ANAgentContentSearchServiceV2.searchConsensus('Data Cloud');
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals('CONSENSUS', result.searchSource, 'Search source should be CONSENSUS');
        System.assertNotEquals(null, result.records, 'Records should not be null');
        System.assertNotEquals(null, result.errors, 'Errors should not be null');
    }

    @isTest
    static void testBothSearch() {
        Test.startTest();
        ANAgentContentSearchServiceV2.ContentSearchResult result = 
            ANAgentContentSearchServiceV2.searchBoth('Marketing Cloud', 'Course');
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals('BOTH', result.searchSource, 'Search source should be BOTH');
        System.assertNotEquals(null, result.records, 'Records should not be null');
        System.assertNotEquals(null, result.errors, 'Errors should not be null');
    }

    @isTest
    static void testEmptySearchTerm() {
        Test.startTest();
        ANAgentContentSearchServiceV2.ContentSearchResult result = 
            ANAgentContentSearchServiceV2.search('', 'Course');
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(!result.success, 'Should not be successful');
        System.assert(result.errors.size() > 0, 'Should have errors');
    }

    @isTest
    static void testNullSearchTerm() {
        Test.startTest();
        ANAgentContentSearchServiceV2.ContentSearchResult result = 
            ANAgentContentSearchServiceV2.search(null, 'Course');
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(!result.success, 'Should not be successful');
        System.assert(result.errors.size() > 0, 'Should have errors');
    }

    @isTest
    static void testConsensusEmptySearchTerm() {
        Test.startTest();
        ANAgentContentSearchServiceV2.ContentSearchResult result = 
            ANAgentContentSearchServiceV2.searchConsensus('');
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(!result.success, 'Should not be successful');
        System.assert(result.errors.size() > 0, 'Should have errors');
    }

    @isTest
    static void testBothEmptySearchTerm() {
        Test.startTest();
        ANAgentContentSearchServiceV2.ContentSearchResult result = 
            ANAgentContentSearchServiceV2.searchBoth('', 'Course');
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(!result.success, 'Should not be successful');
        System.assert(result.errors.size() > 0, 'Should have errors');
    }

    @isTest
    static void testContentSearchResultConstructor() {
        Test.startTest();
        ANAgentContentSearchServiceV2.ContentSearchResult result1 = new ANAgentContentSearchServiceV2.ContentSearchResult();
        ANAgentContentSearchServiceV2.ContentSearchResult result2 = new ANAgentContentSearchServiceV2.ContentSearchResult(true, new List<ANAgentContentSearchServiceV2.UnifiedContent>(), new List<String>());
        ANAgentContentSearchServiceV2.ContentSearchResult result3 = new ANAgentContentSearchServiceV2.ContentSearchResult(true, new List<ANAgentContentSearchServiceV2.UnifiedContent>(), new List<String>(), 'TEST');
        Test.stopTest();

        System.assertEquals('ACT', result1.searchSource, 'Default search source should be ACT');
        System.assertEquals('ACT', result2.searchSource, 'Default search source should be ACT');
        System.assertEquals('TEST', result3.searchSource, 'Custom search source should be TEST');
    }

    @isTest
    static void testUnifiedContentStructure() {
        Test.startTest();
        ANAgentContentSearchServiceV2.UnifiedContent content = new ANAgentContentSearchServiceV2.UnifiedContent();
        content.id = 'test123';
        content.name = 'Test Content';
        content.description = 'Test Description';
        content.type = 'Course';
        content.status = 'Published';
        content.createdDate = Date.today();
        content.learnerCount = 100;
        content.completionCount = 50;
        content.completionRate = 50.0;
        Test.stopTest();

        System.assertEquals('test123', content.id, 'ID should match');
        System.assertEquals('Test Content', content.name, 'Name should match');
        System.assertEquals('Test Description', content.description, 'Description should match');
        System.assertEquals('Course', content.type, 'Type should match');
        System.assertEquals('Published', content.status, 'Status should match');
        System.assertEquals(Date.today(), content.createdDate, 'Created date should match');
        System.assertEquals(100, content.learnerCount, 'Learner count should match');
        System.assertEquals(50, content.completionCount, 'Completion count should match');
        System.assertEquals(50.0, content.completionRate, 'Completion rate should match');
    }
}