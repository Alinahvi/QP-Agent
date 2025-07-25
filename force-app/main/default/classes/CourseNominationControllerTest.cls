@isTest(SeeAllData=true)
public class CourseNominationControllerTest {
    static final Id INVALID_COURSE_ID = 'a6AHu000001ZZZZZZZ'; // Valid format, not in sample

    @isTest static void testSearchCoursesNoFilters() {
        Test.startTest();
        List<CourseNominationController.SearchRequest> reqs = new List<CourseNominationController.SearchRequest>();
        CourseNominationController.SearchRequest req = new CourseNominationController.SearchRequest();
        reqs.add(req);
        List<CourseNominationController.SearchResponse> results = CourseNominationController.searchCoursesInvocable(reqs);
        Test.stopTest();
        System.assert(!results.isEmpty(), 'Should return courses');
        System.assert(results.size() <= 11, 'Should return up to 11 results (10 + more prompt)');
    }

    @isTest static void testSearchCoursesByKeyword() {
        Course__c anyCourse = [SELECT Name FROM Course__c WHERE IsDeleted = false LIMIT 1];
        Test.startTest();
        List<CourseNominationController.SearchRequest> reqs = new List<CourseNominationController.SearchRequest>();
        CourseNominationController.SearchRequest req = new CourseNominationController.SearchRequest();
        req.keyword = anyCourse.Name;
        reqs.add(req);
        List<CourseNominationController.SearchResponse> results = CourseNominationController.searchCoursesInvocable(reqs);
        Test.stopTest();
        Boolean found = false;
        for (CourseNominationController.SearchResponse cs : results) {
            if (cs.summary != null && cs.summary.contains(anyCourse.Name)) found = true;
        }
        System.assert(found, 'Should find course by keyword');
    }

    @isTest static void testSearchCoursesLimitAndMorePrompt() {
        // Only run if there are more than 10 courses
        Integer courseCount = [SELECT count() FROM Course__c WHERE IsDeleted = false];
        if (courseCount > 10) {
            Test.startTest();
            List<CourseNominationController.SearchRequest> reqs = new List<CourseNominationController.SearchRequest>();
            CourseNominationController.SearchRequest req = new CourseNominationController.SearchRequest();
            reqs.add(req);
            List<CourseNominationController.SearchResponse> results = CourseNominationController.searchCoursesInvocable(reqs);
            Test.stopTest();
            System.assertEquals(11, results.size(), 'Should return 10 results plus a more prompt');
            System.assert(results[10].summary != null && results[10].summary.contains('More courses available...'), 'Last result should be the more prompt');
        }
    }

    @isTest static void testGetCourseDetailsValid() {
        Course__c anyCourse = [SELECT Id FROM Course__c WHERE IsDeleted = false LIMIT 1];
        Test.startTest();
        CourseNominationController.CourseSummary details = CourseNominationController.getCourseDetails(anyCourse.Id);
        Test.stopTest();
        System.assertNotEquals(null, details, 'Should return course details');
        System.assertEquals(anyCourse.Id, details.id, 'Returned Id should match');
    }

    @isTest static void testGetCourseDetailsInvalid() {
        Test.startTest();
        CourseNominationController.CourseSummary details = CourseNominationController.getCourseDetails(INVALID_COURSE_ID);
        Test.stopTest();
        System.assertEquals(null, details, 'Should return null for invalid Id');
    }
}