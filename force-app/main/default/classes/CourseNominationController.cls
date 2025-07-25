// Apex controller for agent-driven course nomination
public with sharing class CourseNominationController {
    public class CourseSummary {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String description;
        @AuraEnabled public DateTime createdDate;
        @AuraEnabled public String status;
        @AuraEnabled public String shareUrl;
    }

    public class SearchRequest {
        @InvocableVariable public String keyword;
        @InvocableVariable public Id ownerId;
        @InvocableVariable public String status; // New
        @InvocableVariable public Date createdDate; // New
    }
    public class SearchResponse {
        @InvocableVariable public String summary;
    }

    @InvocableMethod(label='Search Courses' description='Search for courses by keyword, owner, status, and/or created date')
    public static List<SearchResponse> searchCoursesInvocable(List<SearchRequest> requests) {
        List<SearchResponse> responses = new List<SearchResponse>();
        for (SearchRequest req : requests) {
            List<CourseSummary> found = searchCourses(req.keyword, req.ownerId, req.status, req.createdDate, 11);
            Integer maxToShow = 10;
            Integer count = Math.min(found.size(), maxToShow);
            String summary = '';
            for (Integer i = 0; i < count; i++) {
                CourseSummary cs = found[i];
                summary += '- Course Name: ' + (cs.name != null ? cs.name : '(none)') + '\n'
                    + '  Description: ' + (cs.description != null ? cs.description : '(none)') + '\n'
                    + '  Status: ' + (cs.status != null ? cs.status : '(none)') + '\n'
                    + '  Created Date: ' + (cs.createdDate != null ? String.valueOf(cs.createdDate) : '(none)') + '\n'
                    + '  Link: ' + (cs.shareUrl != null ? cs.shareUrl : '(none)') + '\n\n';
            }
            if (found.size() > maxToShow) {
                summary += '- More courses available...\n  There are more than 10 results. Would you like to see more?';
            }
            if (found.isEmpty()) {
                summary = 'No courses found matching your criteria.';
            } else if (found.size() == 1) {
                summary = 'Course found:\n' + summary;
            }
            SearchResponse resp = new SearchResponse();
            resp.summary = summary;
            responses.add(resp);
        }
        return responses;
    }

    // Overload searchCourses to accept a limit
    public static List<CourseSummary> searchCourses(String keyword, Id ownerId, String status, Date createdDate, Integer limitSize) {
        List<CourseSummary> results = new List<CourseSummary>();
        try {
            String soql = 'SELECT Id, Name, Description__c, CreatedDate, Status__c, Share_Url__c FROM Course__c WHERE IsDeleted = false';
            List<String> filters = new List<String>();
            if (ownerId != null) {
                filters.add('OwnerId = :ownerId');
            }
            if (!String.isBlank(keyword)) {
                filters.add('(Name LIKE :kw OR Description__c LIKE :kw)');
            }
            if (!String.isBlank(status)) {
                filters.add('Status__c = :status');
            }
            if (createdDate != null) {
                filters.add('DAY_ONLY(CreatedDate) = :createdDate');
            }
            if (!filters.isEmpty()) {
                soql += ' AND ' + String.join(filters, ' AND ');
            }
            soql += ' ORDER BY CreatedDate DESC LIMIT ' + String.valueOf(limitSize);
            String kw = '%' + keyword + '%';
            List<Course__c> courses = (List<Course__c>)Database.query(soql);
            for (Course__c c : courses) {
                CourseSummary cs = new CourseSummary();
                cs.id = c.Id;
                cs.name = c.Name;
                cs.description = c.Description__c;
                cs.createdDate = c.CreatedDate;
                cs.status = c.Status__c;
                cs.shareUrl = c.Share_Url__c;
                results.add(cs);
            }
        } catch (Exception e) {
            System.debug('Error in searchCourses: ' + e.getMessage());
            // Optionally, add user-friendly error handling here
        }
        return results;
    }
    // ... keep the original searchCourses for backward compatibility ...
    public static List<CourseSummary> searchCourses(String keyword, Id ownerId, String status, Date createdDate) {
        return searchCourses(keyword, ownerId, status, createdDate, 5);
    }

    @AuraEnabled(cacheable=true)
    public static CourseSummary getCourseDetails(Id courseId) {
        try {
            List<Course__c> courses = [SELECT Id, Name, Description__c, CreatedDate, Status__c, Share_Url__c FROM Course__c WHERE Id = :courseId LIMIT 1];
            if (courses.isEmpty()) return null;
            Course__c c = courses[0];
            CourseSummary cs = new CourseSummary();
            cs.id = c.Id;
            cs.name = c.Name;
            cs.description = c.Description__c;
            cs.createdDate = c.CreatedDate;
            cs.status = c.Status__c;
            cs.shareUrl = c.Share_Url__c;
            return cs;
        } catch (Exception e) {
            System.debug('Error in getCourseDetails: ' + e.getMessage());
            // Optionally, add user-friendly error handling here
            return null;
        }
    }
}