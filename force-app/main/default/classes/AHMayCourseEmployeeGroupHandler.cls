public with sharing class AHMayCourseEmployeeGroupHandler implements AHMayCourseQueryHandler {
    
    public AHMayQueryResult handleQuery(AHMayQueryRequest request, Map<String, Object> queryData) {
        AHMayQueryResult result = new AHMayQueryResult();
        
        try {
            // Extract course name and query type
            String courseName = (String)queryData.get('COURSE_NAME');
            String queryType = (String)queryData.get('QUERY_TYPE');
            
            if (String.isBlank(courseName)) {
                result.success = false;
                result.message = 'Course name is required.';
                return result;
            }
            
            // Default to 'ASSIGNED' if query type not specified
            if (String.isBlank(queryType)) {
                queryType = 'ASSIGNED';
            }
            
            // Find the course by name
            List<Course__c> courses = findCoursesByName(courseName);
            
            if (courses.isEmpty()) {
                result.success = false;
                result.message = 'Could not find course: ' + courseName;
                return result;
            }
            
            // Check for ambiguous course matches
            if (courses.size() > 1) {
                return handleAmbiguousCourseMatch(courses, queryData);
            }
            
            // Check if we should use previously segmented employees
            Boolean useSegmentedEmployees = queryData.containsKey('USE_SEGMENTED_EMPLOYEES') && 
                                         (Boolean)queryData.get('USE_SEGMENTED_EMPLOYEES') &&
                                         !String.isBlank(request.sessionId);
            
            List<Assigned_Course__c> assignedCourses;
            Integer totalCount;
            
            if (useSegmentedEmployees) {
                // Get previously segmented employees
                List<Id> segmentedEmployeeIds = AHMayCrossTopicContext.getSegmentedEmployeeIds(request.sessionId);
                
                if (segmentedEmployeeIds.isEmpty()) {
                    result.success = true;
                    result.message = 'No previously segmented employees found. Please find employees first.';
                    return result;
                }
                
                // Query assigned courses filtered by the segmented employees
                assignedCourses = queryCoursesForSegmentedEmployees(
                    courses[0].Id, segmentedEmployeeIds, queryType, request.pageNumber);
                
                // Get count for pagination
                totalCount = countCoursesForSegmentedEmployees(
                    courses[0].Id, segmentedEmployeeIds, queryType);
                
            } else {
                // Apply standard group filters if any
                Map<String, Object> groupFilter = new Map<String, Object>();
                if (queryData.containsKey('GROUP_FILTER') && queryData.get('GROUP_FILTER') instanceof Map<String, Object>) {
                    groupFilter = (Map<String, Object>)queryData.get('GROUP_FILTER');
                }
                
                // Query based on type
                if (queryType == 'COMPLETED') {
                    assignedCourses = queryCompletedCourses(courses[0].Id, groupFilter, request.pageNumber);
                    totalCount = countCompletedCourses(courses[0].Id, groupFilter);
                } else if (queryType == 'NOT_COMPLETED') {
                    assignedCourses = queryNotCompletedCourses(courses[0].Id, groupFilter, request.pageNumber);
                    totalCount = countNotCompletedCourses(courses[0].Id, groupFilter);
                } else {
                    // Default to ASSIGNED
                    assignedCourses = queryAssignedCourses(courses[0].Id, groupFilter, request.pageNumber);
                    totalCount = countAssignedCourses(courses[0].Id, groupFilter);
                }
            }
            
            // Format the result
            String queryTypeLabel = (queryType == 'COMPLETED') ? 'completed' : 
                                  (queryType == 'NOT_COMPLETED') ? 'not completed' : 'assigned to';
            
            if (assignedCourses.isEmpty()) {
                result.success = true;
                result.totalRecords = 0;
                result.message = 'No employees found who are ' + queryTypeLabel + ' ' + courses[0].Name + '.';
            } else {
                result = formatEmployeeGroupResult(assignedCourses, courses[0], queryTypeLabel, totalCount, request.pageNumber);
                
                // Also store these employees for potential follow-up queries
                if (!String.isBlank(request.sessionId)) {
                    List<Id> employeeIds = new List<Id>();
                    for (Assigned_Course__c ac : assignedCourses) {
                        employeeIds.add(ac.Learner_Profile__c);
                    }
                    AHMayCrossTopicContext.storeSegmentedEmployees(request.sessionId, employeeIds);
                }
            }
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error processing query: ' + e.getMessage();
            System.debug(LoggingLevel.ERROR, 'Error: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
        }
        
        return result;
    }
    
    private List<Course__c> findCoursesByName(String courseName) {
        String searchName = '%' + String.escapeSingleQuotes(courseName) + '%';
        return [
            SELECT Id, Name
            FROM Course__c
            WHERE Name LIKE :searchName
            LIMIT 5
        ];
    }
    
    private AHMayQueryResult handleAmbiguousCourseMatch(List<Course__c> courses, Map<String, Object> queryData) {
        AHMayQueryResult result = new AHMayQueryResult();
        result.success = true;
        result.message = 'Found multiple courses matching "' + queryData.get('COURSE_NAME') + '":\n\n';
        
        for (Course__c course : courses) {
            result.message += '- ' + course.Name + '\n';
        }
        
        result.message += '\nPlease specify which course you meant.';
        return result;
    }
    
    /**
     * Query courses specifically for previously segmented employees
     * @param courseId The ID of the course
     * @param employeeIds List of previously segmented employee IDs
     * @param queryType The type of query (COMPLETED, NOT_COMPLETED, ASSIGNED)
     * @param pageNumber Page number for pagination
     * @return List of assigned courses filtered by the segmented employees
     */
    private List<Assigned_Course__c> queryCoursesForSegmentedEmployees(
        Id courseId, List<Id> employeeIds, String queryType, Integer pageNumber) {
        
        Integer pageSize = 20;
        Integer offset = (pageNumber != null ? pageNumber - 1 : 0) * pageSize;
        
        String query = 'SELECT Id, Learner_Profile__c, Learner_Profile__r.Name, ' +
                      'Learner_Profile__r.Primary_Email__c, Learner_Profile__r.Division__c, ' +
                      'Learner_Profile__r.Manager__c, Course__c, Course__r.Name, ' +
                      'Completed__c, Completion_Date__c, Self_Assigned__c, Required__c, Assigned_On__c ' +
                      'FROM Assigned_Course__c ' +
                      'WHERE Course__c = :courseId AND Learner_Profile__c IN :employeeIds';
        
        // Add completion filter based on query type
        if (queryType == 'COMPLETED') {
            query += ' AND Completed__c = true';
        } else if (queryType == 'NOT_COMPLETED') {
            query += ' AND Completed__c = false';
        }
        
        // Add pagination
        query += ' ORDER BY Learner_Profile__r.Name ASC LIMIT ' + pageSize + ' OFFSET ' + offset;
        
        System.debug('Executing segmented employees course query: ' + query);
        System.debug('Employee IDs count: ' + employeeIds.size());
        
        return Database.query(query);
    }
    
    /**
     * Count courses for previously segmented employees
     * @param courseId The ID of the course
     * @param employeeIds List of previously segmented employee IDs
     * @param queryType The type of query (COMPLETED, NOT_COMPLETED, ASSIGNED)
     * @return Count of matching records
     */
    private Integer countCoursesForSegmentedEmployees(
        Id courseId, List<Id> employeeIds, String queryType) {
        
        String query = 'SELECT COUNT() FROM Assigned_Course__c ' +
                      'WHERE Course__c = :courseId AND Learner_Profile__c IN :employeeIds';
        
        // Add completion filter based on query type
        if (queryType == 'COMPLETED') {
            query += ' AND Completed__c = true';
        } else if (queryType == 'NOT_COMPLETED') {
            query += ' AND Completed__c = false';
        }
        
        System.debug('Executing segmented employees count query: ' + query);
        
        return Database.countQuery(query);
    }
    
    private List<Assigned_Course__c> queryAssignedCourses(Id courseId, Map<String, Object> filters, Integer pageNumber) {
        Integer pageSize = 20;
        Integer offset = (pageNumber != null ? pageNumber - 1 : 0) * pageSize;
        
        String query = 'SELECT Id, Learner_Profile__c, Learner_Profile__r.Name, ' +
                      'Learner_Profile__r.Primary_Email__c, Learner_Profile__r.Division__c, ' +
                      'Learner_Profile__r.Manager__c, Course__c, Course__r.Name, ' +
                      'Completed__c, Completion_Date__c, Self_Assigned__c, Required__c, Assigned_On__c ' +
                      'FROM Assigned_Course__c ' +
                      'WHERE Course__c = :courseId';
        
        // Add filters
        query += buildFilterConditions(filters);
        
        // Add pagination
        query += ' ORDER BY Learner_Profile__r.Name ASC LIMIT ' + pageSize + ' OFFSET ' + offset;
        
        return Database.query(query);
    }
    
    private List<Assigned_Course__c> queryCompletedCourses(Id courseId, Map<String, Object> filters, Integer pageNumber) {
        Integer pageSize = 20;
        Integer offset = (pageNumber != null ? pageNumber - 1 : 0) * pageSize;
        
        String query = 'SELECT Id, Learner_Profile__c, Learner_Profile__r.Name, ' +
                      'Learner_Profile__r.Primary_Email__c, Learner_Profile__r.Division__c, ' +
                      'Learner_Profile__r.Manager__c, Course__c, Course__r.Name, ' +
                      'Completed__c, Completion_Date__c, Self_Assigned__c, Required__c, Assigned_On__c ' +
                      'FROM Assigned_Course__c ' +
                      'WHERE Course__c = :courseId AND Completed__c = true';
        
        // Add filters
        query += buildFilterConditions(filters);
        
        // Add pagination
        query += ' ORDER BY Completion_Date__c DESC LIMIT ' + pageSize + ' OFFSET ' + offset;
        
        return Database.query(query);
    }
    
    private List<Assigned_Course__c> queryNotCompletedCourses(Id courseId, Map<String, Object> filters, Integer pageNumber) {
        Integer pageSize = 20;
        Integer offset = (pageNumber != null ? pageNumber - 1 : 0) * pageSize;
        
        String query = 'SELECT Id, Learner_Profile__c, Learner_Profile__r.Name, ' +
                      'Learner_Profile__r.Primary_Email__c, Learner_Profile__r.Division__c, ' +
                      'Learner_Profile__r.Manager__c, Course__c, Course__r.Name, ' +
                      'Completed__c, Completion_Date__c, Self_Assigned__c, Required__c, Assigned_On__c ' +
                      'FROM Assigned_Course__c ' +
                      'WHERE Course__c = :courseId AND Completed__c = false';
        
        // Add filters
        query += buildFilterConditions(filters);
        
        // Add pagination
        query += ' ORDER BY Learner_Profile__r.Name ASC LIMIT ' + pageSize + ' OFFSET ' + offset;
        
        return Database.query(query);
    }
    
    private Integer countAssignedCourses(Id courseId, Map<String, Object> filters) {
        String query = 'SELECT COUNT() FROM Assigned_Course__c WHERE Course__c = :courseId';
        query += buildFilterConditions(filters);
        return Database.countQuery(query);
    }
    
    private Integer countCompletedCourses(Id courseId, Map<String, Object> filters) {
        String query = 'SELECT COUNT() FROM Assigned_Course__c WHERE Course__c = :courseId AND Completed__c = true';
        query += buildFilterConditions(filters);
        return Database.countQuery(query);
    }
    
    private Integer countNotCompletedCourses(Id courseId, Map<String, Object> filters) {
        String query = 'SELECT COUNT() FROM Assigned_Course__c WHERE Course__c = :courseId AND Completed__c = false';
        query += buildFilterConditions(filters);
        return Database.countQuery(query);
    }
    
    private String buildFilterConditions(Map<String, Object> filters) {
        String conditions = '';
        
        if (filters != null && !filters.isEmpty()) {
            // Check for organizational hierarchy query
            if (filters.containsKey('MANAGER_ORG') && filters.get('MANAGER_ORG') != null) {
                String managerName = String.escapeSingleQuotes((String)filters.get('MANAGER_ORG'));
                
                // Find the manager's email first
                List<Learner_Profile__c> managers = [
                    SELECT Id, Name, Primary_Email__c 
                    FROM Learner_Profile__c 
                    WHERE Name LIKE :('%' + managerName + '%')
                    AND Status__c = 'Active'
                    LIMIT 1
                ];
                
                if (!managers.isEmpty() && managers[0].Primary_Email__c != null) {
                    String managerEmail = managers[0].Primary_Email__c;
                    
                    // Build hierarchical condition using management chain fields
                    List<String> hierarchyConditions = new List<String>();
                    for (Integer i = 1; i <= 10; i++) {
                        String fieldName = 'Emp_Mgt_Chain_Lvl_';
                        if (i < 10) {
                            fieldName += '0' + i;
                        } else {
                            fieldName += i;
                        }
                        fieldName += '_Nm__c';
                        hierarchyConditions.add('Learner_Profile__r.' + fieldName + ' = \'' + managerEmail + '\'');
                    }
                    
                    conditions += ' AND (' + String.join(hierarchyConditions, ' OR ') + ')';
                }
            }
            // Regular manager filter (direct reports only)
            else if (filters.containsKey('MANAGER_NAME') && filters.get('MANAGER_NAME') != null) {
                String managerName = String.escapeSingleQuotes((String)filters.get('MANAGER_NAME'));
                conditions += ' AND Learner_Profile__r.Manager__c = \'' + managerName + '\'';
            }
            
            // Division filter
            if (filters.containsKey('DIVISION') && filters.get('DIVISION') != null) {
                String division = String.escapeSingleQuotes((String)filters.get('DIVISION'));
                conditions += ' AND Learner_Profile__r.Division__c = \'' + division + '\'';
            }
            
            // Location filter
            if (filters.containsKey('LOCATION') && filters.get('LOCATION') != null) {
                String location = String.escapeSingleQuotes((String)filters.get('LOCATION'));
                conditions += ' AND Learner_Profile__r.Employee_Location__c = \'' + location + '\'';
            }
            
            // Required filter
            if (filters.containsKey('REQUIRED') && filters.get('REQUIRED') != null) {
                Boolean required = (Boolean)filters.get('REQUIRED');
                conditions += ' AND Required__c = ' + required;
            }
            
            // Self-assigned filter
            if (filters.containsKey('SELF_ASSIGNED') && filters.get('SELF_ASSIGNED') != null) {
                Boolean selfAssigned = (Boolean)filters.get('SELF_ASSIGNED');
                conditions += ' AND Self_Assigned__c = ' + selfAssigned;
            }
        }
        
        return conditions;
    }
    
    private AHMayQueryResult formatEmployeeGroupResult(List<Assigned_Course__c> assignedCourses, Course__c course, 
                                                   String queryTypeLabel, Integer totalCount, Integer pageNumber) {
        AHMayQueryResult result = new AHMayQueryResult();
        Integer pageSize = 20;
        
        result.success = true;
        result.totalRecords = totalCount;
        result.pageNumber = pageNumber != null ? pageNumber : 1;
        result.hasMore = (totalCount > (result.pageNumber - 1) * pageSize + assignedCourses.size());
        
        Integer totalPages = Math.max(1, (Integer) Math.ceil(totalCount / (Double)pageSize));
        
        // Format the message
        result.message = 'Employees who are ' + queryTypeLabel + ' ' + course.Name + ':\n\n';
        
        Integer count = 1;
        for (Assigned_Course__c ac : assignedCourses) {
            result.message += count + '. ' + ac.Learner_Profile__r.Name;
            
            // Add extra details
            List<String> details = new List<String>();
            if (ac.Learner_Profile__r.Division__c != null) {
                details.add(ac.Learner_Profile__r.Division__c);
            }
            if (ac.Learner_Profile__r.Manager__c != null) {
                details.add('Manager: ' + ac.Learner_Profile__r.Manager__c);
            }
            
            if (!details.isEmpty()) {
                result.message += ' (' + String.join(details, ', ') + ')';
            }
            
            // Add assignment and completion info
            List<String> dateInfo = new List<String>();
            
            // Add assignment date
            if (ac.Assigned_On__c != null) {
                dateInfo.add('Assigned on ' + ac.Assigned_On__c.format());
            }
            
            // For completed courses, show completion date
            if (ac.Completed__c && ac.Completion_Date__c != null) {
                dateInfo.add('Completed on ' + ac.Completion_Date__c.format());
            } else if (ac.Completed__c) {
                dateInfo.add('Completed');
            }
            
            // Add required status if important
            if (ac.Required__c) {
                dateInfo.add('Required');
            }
            
            if (!dateInfo.isEmpty()) {
                result.message += ' - ' + String.join(dateInfo, ', ');
            }
            
            result.message += '\n';
            count++;
        }
        
        // Add pagination information
        result.message += '\nShowing ' + assignedCourses.size() + ' of ' + totalCount + 
                         ' employees (Page ' + result.pageNumber + ' of ' + totalPages + ')';
        
        if (result.hasMore) {
            result.message += '\n\nYou can ask for "more results" or "next page" to see additional employees.';
        }
        
        return result;
    }
}