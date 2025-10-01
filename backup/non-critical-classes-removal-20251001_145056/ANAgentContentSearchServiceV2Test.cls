/**
 * @description Comprehensive unit tests for ANAgentContentSearchServiceV2 with lifecycle management
 * @version 1.0
 */
@isTest
public class ANAgentContentSearchServiceV2Test {

    /**
     * @description Test data setup for lifecycle management testing
     */
    @TestSetup
    static void setupTestData() {
        // Create test courses with lifecycle data
        List<Course__c> testCourses = new List<Course__c>();
        testCourses.add(new Course__c(
            Name = 'Sales Cloud Fundamentals',
            Description__c = 'Learn the basics of Sales Cloud',
            Status__c = 'Active'
        ));
        testCourses.add(new Course__c(
            Name = 'Data Cloud Advanced',
            Description__c = 'Advanced Data Cloud techniques',
            Status__c = 'Active'
        ));
        insert testCourses;

        // Create test assets
        List<Asset__c> testAssets = new List<Asset__c>();
        testAssets.add(new Asset__c(
            Name = 'Tableau Dashboard Guide',
            Description__c = 'Guide to creating Tableau dashboards',
            Status__c = 'Active'
        ));
        insert testAssets;

        // Create test curriculums
        List<Curriculum__c> testCurriculums = new List<Curriculum__c>();
        testCurriculums.add(new Curriculum__c(
            Name = 'Marketing Cloud Certification',
            Description__c = 'Complete Marketing Cloud certification path',
            Status__c = 'Active'
        ));
        insert testCurriculums;

        // Create test assigned courses for lifecycle data
        List<Assigned_Course__c> testAssignments = new List<Assigned_Course__c>();
        
        // Sales Cloud course - 100 learners, 75 completed
        for (Integer i = 0; i < 100; i++) {
            testAssignments.add(new Assigned_Course__c(
                Course__c = testCourses[0].Id,
                Completed__c = (i < 75) // 75% completion rate
            ));
        }
        
        // Data Cloud course - 50 learners, 25 completed
        for (Integer i = 0; i < 50; i++) {
            testAssignments.add(new Assigned_Course__c(
                Course__c = testCourses[1].Id,
                Completed__c = (i < 25) // 50% completion rate
            ));
        }
        
        insert testAssignments;
    }

    /**
     * @description Test basic ACT search functionality
     */
    @isTest
    static void testBasicACTSearch() {
        Test.startTest();
        ANAgentContentSearchServiceV2.ContentSearchResult result = 
            ANAgentContentSearchServiceV2.search('Sales Cloud', null);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(true, result.success, 'Search should be successful');
        System.assertEquals('ACT', result.searchSource, 'Should be ACT source');
        System.assertNotEquals(0, result.records.size(), 'Should find at least one result');
        
        // Verify lifecycle data is populated
        Boolean foundSalesCloudCourse = false;
        for (ANAgentContentSearchServiceV2.UnifiedContent content : result.records) {
            if (content.name == 'Sales Cloud Fundamentals') {
                foundSalesCloudCourse = true;
                System.assertEquals(100, content.learnerCount, 'Should have 100 learners');
                System.assertEquals(75, content.completionCount, 'Should have 75 completions');
                System.assertEquals(75.0, content.completionRate, 'Should have 75% completion rate');
                break;
            }
        }
        System.assertEquals(true, foundSalesCloudCourse, 'Should find Sales Cloud course with lifecycle data');
    }

    /**
     * @description Test lifecycle management data accuracy
     */
    @isTest
    static void testLifecycleManagementData() {
        Test.startTest();
        ANAgentContentSearchServiceV2.ContentSearchResult result = 
            ANAgentContentSearchServiceV2.search('Data Cloud', null);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(true, result.success, 'Search should be successful');
        System.assertEquals('ACT', result.searchSource, 'Should be ACT source');
        
        // Find Data Cloud course
        ANAgentContentSearchServiceV2.UnifiedContent dataCloudCourse = null;
        for (ANAgentContentSearchServiceV2.UnifiedContent content : result.records) {
            if (content.name == 'Data Cloud Advanced') {
                dataCloudCourse = content;
                break;
            }
        }
        
        System.assertNotEquals(null, dataCloudCourse, 'Should find Data Cloud course');
        System.assertEquals(50, dataCloudCourse.learnerCount, 'Should have 50 learners');
        System.assertEquals(25, dataCloudCourse.completionCount, 'Should have 25 completions');
        System.assertEquals(50.0, dataCloudCourse.completionRate, 'Should have 50% completion rate');
    }

    /**
     * @description Test search with specific content type
     */
    @isTest
    static void testSearchWithContentType() {
        Test.startTest();
        ANAgentContentSearchServiceV2.ContentSearchResult result = 
            ANAgentContentSearchServiceV2.search('Tableau', 'Asset');
        Test.stopTest();
        
        // Assertions
        System.assertEquals(true, result.success, 'Search should be successful');
        System.assertEquals('ACT', result.searchSource, 'Should be ACT source');
        System.assertEquals(1, result.records.size(), 'Should find one asset');
        System.assertEquals('Asset', result.records[0].type, 'Should be an asset type');
        System.assertEquals('Tableau Dashboard Guide', result.records[0].name, 'Should find the correct asset');
    }

    /**
     * @description Test search with invalid content type
     */
    @isTest
    static void testSearchWithInvalidContentType() {
        Test.startTest();
        ANAgentContentSearchServiceV2.ContentSearchResult result = 
            ANAgentContentSearchServiceV2.search('Sales Cloud', 'InvalidType');
        Test.stopTest();
        
        // Assertions
        System.assertEquals(false, result.success, 'Search should fail');
        System.assertEquals('ACT', result.searchSource, 'Should be ACT source');
        System.assertEquals(1, result.errors.size(), 'Should have one error');
        System.assert(result.errors[0].contains('Invalid content type'), 'Should have invalid type error');
    }

    /**
     * @description Test search with blank search term
     */
    @isTest
    static void testSearchWithBlankSearchTerm() {
        Test.startTest();
        ANAgentContentSearchServiceV2.ContentSearchResult result = 
            ANAgentContentSearchServiceV2.search('', null);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(false, result.success, 'Search should fail');
        System.assertEquals('ACT', result.searchSource, 'Should be ACT source');
        System.assertEquals(1, result.errors.size(), 'Should have one error');
        System.assert(result.errors[0].contains('Search term is required'), 'Should have required error');
    }

    /**
     * @description Test search with null search term
     */
    @isTest
    static void testSearchWithNullSearchTerm() {
        Test.startTest();
        ANAgentContentSearchServiceV2.ContentSearchResult result = 
            ANAgentContentSearchServiceV2.search(null, null);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(false, result.success, 'Search should fail');
        System.assertEquals('ACT', result.searchSource, 'Should be ACT source');
        System.assertEquals(1, result.errors.size(), 'Should have one error');
        System.assert(result.errors[0].contains('Search term is required'), 'Should have required error');
    }

    /**
     * @description Test search across multiple object types
     */
    @isTest
    static void testSearchAcrossMultipleTypes() {
        Test.startTest();
        ANAgentContentSearchServiceV2.ContentSearchResult result = 
            ANAgentContentSearchServiceV2.search('Cloud', null);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(true, result.success, 'Search should be successful');
        System.assertEquals('ACT', result.searchSource, 'Should be ACT source');
        System.assert(result.records.size() >= 3, 'Should find courses, assets, and curriculums');
        
        // Verify different types are found
        Set<String> foundTypes = new Set<String>();
        for (ANAgentContentSearchServiceV2.UnifiedContent content : result.records) {
            foundTypes.add(content.type);
        }
        
        System.assert(foundTypes.contains('Course'), 'Should find courses');
        System.assert(foundTypes.contains('Asset'), 'Should find assets');
        System.assert(foundTypes.contains('Curriculum'), 'Should find curriculums');
    }

    /**
     * @description Test lifecycle data for courses without assignments
     */
    @isTest
    static void testLifecycleDataForUnassignedCourses() {
        // Create a course without any assignments
        Course__c unassignedCourse = new Course__c(
            Name = 'Unassigned Course',
            Description__c = 'Course with no assignments',
            Status__c = 'Active'
        );
        insert unassignedCourse;
        
        Test.startTest();
        ANAgentContentSearchServiceV2.ContentSearchResult result = 
            ANAgentContentSearchServiceV2.search('Unassigned', null);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(true, result.success, 'Search should be successful');
        System.assertEquals(1, result.records.size(), 'Should find one course');
        
        ANAgentContentSearchServiceV2.UnifiedContent course = result.records[0];
        System.assertEquals(0, course.learnerCount, 'Should have 0 learners');
        System.assertEquals(0, course.completionCount, 'Should have 0 completions');
        System.assertEquals(0.0, course.completionRate, 'Should have 0% completion rate');
    }

    /**
     * @description Test search with no results
     */
    @isTest
    static void testSearchWithNoResults() {
        Test.startTest();
        ANAgentContentSearchServiceV2.ContentSearchResult result = 
            ANAgentContentSearchServiceV2.search('NonExistentContent', null);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(true, result.success, 'Search should be successful');
        System.assertEquals('ACT', result.searchSource, 'Should be ACT source');
        System.assertEquals(0, result.records.size(), 'Should find no results');
        System.assertEquals(1, result.errors.size(), 'Should have one error');
        System.assert(result.errors[0].contains('No content found matching'), 'Should have no results error');
    }

    /**
     * @description Test error handling for inaccessible objects
     */
    @isTest
    static void testErrorHandlingForInaccessibleObjects() {
        // This test ensures the service handles cases where objects might not be accessible
        // In a real scenario, this would test with different user permissions
        
        Test.startTest();
        ANAgentContentSearchServiceV2.ContentSearchResult result = 
            ANAgentContentSearchServiceV2.search('Sales Cloud', 'Course');
        Test.stopTest();
        
        // Assertions - should still work with accessible objects
        System.assertEquals(true, result.success, 'Search should be successful');
        System.assertEquals('ACT', result.searchSource, 'Should be ACT source');
    }

    /**
     * @description Test that lifecycle management doesn't break existing functionality
     */
    @isTest
    static void testLifecycleManagementPreservation() {
        // Test that the enhanced service still works exactly like the original
        Test.startTest();
        ANAgentContentSearchServiceV2.ContentSearchResult result = 
            ANAgentContentSearchServiceV2.search('Marketing Cloud', null);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(true, result.success, 'Search should be successful');
        System.assertEquals('ACT', result.searchSource, 'Should be ACT source');
        
        // Find Marketing Cloud curriculum
        ANAgentContentSearchServiceV2.UnifiedContent curriculum = null;
        for (ANAgentContentSearchServiceV2.UnifiedContent content : result.records) {
            if (content.name == 'Marketing Cloud Certification') {
                curriculum = content;
                break;
            }
        }
        
        System.assertNotEquals(null, curriculum, 'Should find Marketing Cloud curriculum');
        System.assertEquals('Curriculum', curriculum.type, 'Should be curriculum type');
        // Curriculums don't have learner data, so these should be 0
        System.assertEquals(0, curriculum.learnerCount, 'Curriculum should have 0 learners');
        System.assertEquals(0, curriculum.completionCount, 'Curriculum should have 0 completions');
        System.assertEquals(0.0, curriculum.completionRate, 'Curriculum should have 0% completion rate');
    }
}
