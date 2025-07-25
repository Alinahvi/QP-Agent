public with sharing class AHMayCourseOrgMetricsHandler implements AHMayCourseQueryHandler {
    
    public AHMayQueryResult handleQuery(AHMayQueryRequest request, Map<String, Object> queryData) {
        AHMayQueryResult result = new AHMayQueryResult();
        
        try {
            // Extract course name
            String courseName = (String)queryData.get('COURSE_NAME');
            
            if (String.isBlank(courseName)) {
                result.success = false;
                result.message = 'Course name is required.';
                return result;
            }
            
            // Extract organizational filter
            Map<String, Object> orgFilter = new Map<String, Object>();
            if (queryData.containsKey('ORG_FILTER') && queryData.get('ORG_FILTER') instanceof Map<String, Object>) {
                orgFilter = (Map<String, Object>)queryData.get('ORG_FILTER');
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
            
            // Check for manager org filter
            String managerName = null;
            if (orgFilter.containsKey('MANAGER_NAME')) {
                managerName = (String)orgFilter.get('MANAGER_NAME');
            }
            
            if (String.isBlank(managerName)) {
                result.success = false;
                result.message = 'Manager name is required for organizational metrics.';
                return result;
            }
            
            // This is effectively the same as an org hierarchy query with course filter
            // So we'll reuse that logic but with different result formatting
            
            // Find the manager's email
            String managerEmail = findManagerEmail(managerName);
            
            if (String.isBlank(managerEmail)) {
                result.success = false;
                result.message = 'Could not find manager: ' + managerName;
                return result;
            }
            
            // Build chain conditions for hierarchy query
            List<String> chainConditions = buildChainConditions(managerEmail);
            
            // Get all employees in the org - limited to a reasonable number
            Integer maxEmployeesToCheck = 1000;
            List<Learner_Profile__c> orgEmployees = queryEmployeesInOrg(chainConditions, maxEmployeesToCheck);
            
            if (orgEmployees.isEmpty()) {
                result.success = true;
                result.message = 'No employees found in ' + managerName + '\'s organization.';
                return result;
            }
            
            // Count total employees in the org
            Integer totalOrgEmployees = countEmployeesInOrg(chainConditions);
            
            // Extract employee IDs for course assignment query
            List<Id> employeeIds = new List<Id>();
            for (Learner_Profile__c emp : orgEmployees) {
                employeeIds.add(emp.Id);
            }
            
            // Query course assignments
            List<Assigned_Course__c> assignedCourses = queryOrgCourseAssignments(courses[0].Id, employeeIds);
            
            // Calculate metrics
            Integer assignedCount = assignedCourses.size();
            Integer completedCount = 0;
            Integer inProgressCount = 0;
            Integer requiredCount = 0;
            Integer requiredCompletedCount = 0;
            Integer selfAssignedCount = 0;
            
            // Track average time to completion
            List<Integer> daysToCompletion = new List<Integer>();
            
            for (Assigned_Course__c ac : assignedCourses) {
                // Count completions
                if (ac.Completed__c) {
                    completedCount++;
                    
                    // Calculate days to completion if we have both dates
                    if (ac.Assigned_On__c != null && ac.Completion_Date__c != null) {
                        Integer days = ac.Assigned_On__c.daysBetween(ac.Completion_Date__c);
                        daysToCompletion.add(days);
                    }
                } else {
                    inProgressCount++;
                }
                
                // Count required courses
                if (ac.Required__c) {
                    requiredCount++;
                    if (ac.Completed__c) {
                        requiredCompletedCount++;
                    }
                }
                
                // Count self-assigned courses
                if (ac.Self_Assigned__c) {
                    selfAssignedCount++;
                }
            }
            
            // Calculate average time to completion
            Decimal avgDaysToCompletion = 0;
            if (!daysToCompletion.isEmpty()) {
                Integer totalDays = 0;
                for (Integer days : daysToCompletion) {
                    totalDays += days;
                }
                avgDaysToCompletion = totalDays / (Decimal)daysToCompletion.size();
            }
            
            // Format results
            result.success = true;
            result.totalRecords = assignedCount;
            
            // Create a detailed message with stats
            String message = 'Course metrics for ' + courses[0].Name + ' in ' + managerName + '\'s organization:\n\n';
            
            if (orgEmployees.size() < totalOrgEmployees) {
                message += 'Based on a sample of ' + orgEmployees.size() + ' out of ' + totalOrgEmployees + 
                         ' total employees in the organization:\n\n';
            } else {
                message += 'Based on all ' + totalOrgEmployees + ' employees in the organization:\n\n';
            }
            
            // Calculate percentages
            Double assignedPercentage = (totalOrgEmployees > 0) ? 
                                     (assignedCount * 100.0 / totalOrgEmployees) : 0;
            Double completedPercentage = (assignedCount > 0) ? 
                                      (completedCount * 100.0 / assignedCount) : 0;
            Double requiredCompletionPercentage = (requiredCount > 0) ? 
                                               (requiredCompletedCount * 100.0 / requiredCount) : 0;
            
            message += '• ' + assignedCount + ' employees (' + 
                     String.format('{0, number, #,##0.0}', new List<Object>{assignedPercentage}) + 
                     '%) are assigned to this course\n';
            
            if (assignedCount > 0) {
                message += '• ' + completedCount + ' employees (' + 
                         String.format('{0, number, #,##0.0}', new List<Object>{completedPercentage}) + 
                         '%) have completed the course\n';
                message += '• ' + inProgressCount + ' employees are still in progress\n';
                
                if (requiredCount > 0) {
                    message += '• ' + requiredCompletedCount + ' of ' + requiredCount + ' required assignments (' + 
                             String.format('{0, number, #,##0.0}', new List<Object>{requiredCompletionPercentage}) + 
                             '%) have been completed\n';
                }
                
                if (selfAssignedCount > 0) {
                    Double selfAssignedPercentage = (assignedCount > 0) ? 
                                                  (selfAssignedCount * 100.0 / assignedCount) : 0;
                    message += '• ' + selfAssignedCount + ' assignments (' + 
                             String.format('{0, number, #,##0.0}', new List<Object>{selfAssignedPercentage}) + 
                             '%) were self-assigned\n';
                }
                
                if (avgDaysToCompletion > 0) {
                    message += '• Average days to completion: ' + avgDaysToCompletion.setScale(1) + ' days\n';
                }
                
                message += '\n';
                
                // List the first few assigned employees
                Integer pageSizeForList = 5;
                if (assignedCount > 0) {
                    message += 'Sample of employees assigned to this course:\n\n';
                    
                    for (Integer i = 0; i < Math.min(pageSizeForList, assignedCount); i++) {
                        Assigned_Course__c ac = assignedCourses[i];
                        message += (i+1) + '. ' + ac.Learner_Profile__r.Name;
                        
                        // Add detailed status
                        List<String> details = new List<String>();
                        
                        // Add assignment date if available
                        if (ac.Assigned_On__c != null) {
                            details.add('Assigned on ' + ac.Assigned_On__c.format());
                        }
                        
                        // Add status
                        if (ac.Completed__c) {
                            if (ac.Completion_Date__c != null) {
                                details.add('Completed on ' + ac.Completion_Date__c.format());
                            } else {
                                details.add('Completed');
                            }
                        } else {
                            details.add('In Progress');
                        }
                        
                        // Add required status
                        if (ac.Required__c) {
                            details.add('Required');
                        }
                        
                        // Add self-assigned status
                        if (ac.Self_Assigned__c) {
                            details.add('Self-assigned');
                        }
                        
                        if (!details.isEmpty()) {
                            message += ' (' + String.join(details, ', ') + ')';
                        }
                        
                        message += '\n';
                    }
                    
                    if (assignedCount > pageSizeForList) {
                        message += '\n...and ' + (assignedCount - pageSizeForList) + ' more employees\n';
                    }
                }
            } else {
                message += '\nNo employees in this organization are currently assigned to this course.';
            }
            
            result.message = message;
            
            // Add metadata for client-side usage
            result.metadataMap = new Map<String, Object>{
                'courseName' => courses[0].Name,
                'courseId' => courses[0].Id,
                'managerName' => managerName,
                'totalEmployeesInOrg' => totalOrgEmployees,
                'totalAssigned' => assignedCount,
                'totalCompleted' => completedCount,
                'assignedPercentage' => assignedPercentage,
                'completionPercentage' => completedPercentage,
                'requiredCompletionPercentage' => requiredCompletionPercentage,
                'avgDaysToCompletion' => avgDaysToCompletion
            };
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error processing org metrics query: ' + e.getMessage();
            System.debug(LoggingLevel.ERROR, 'Error: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
        }
        
        return result;
    }
    
    // Helper methods
    
    private List<Course__c> findCoursesByName(String courseName) {
        String searchName = '%' + String.escapeSingleQuotes(courseName) + '%';
        return [
            SELECT Id, Name, Description__c
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
    
    private String findManagerEmail(String managerName) {
        try {
            // First try exact match on Learner_Profile__c
            String exactProfileQuery = 'SELECT Id, Name, Primary_Email__c FROM Learner_Profile__c WHERE ' +
                                    'Status__c = \'Active\' AND ' +
                                    'Name = \'' + String.escapeSingleQuotes(managerName) + '\' LIMIT 1';
            
            List<Learner_Profile__c> exactProfiles = Database.query(exactProfileQuery);
            
            if (!exactProfiles.isEmpty() && exactProfiles[0].Primary_Email__c != null) {
                return exactProfiles[0].Primary_Email__c;
            }
            
            // Try partial match on Learner_Profile__c
            String partialProfileQuery = 'SELECT Id, Name, Primary_Email__c FROM Learner_Profile__c WHERE ' +
                                      'Status__c = \'Active\' AND ' +
                                      'Name LIKE \'%' + String.escapeSingleQuotes(managerName) + '%\' LIMIT 1';
            
            List<Learner_Profile__c> partialProfiles = Database.query(partialProfileQuery);
            
            if (!partialProfiles.isEmpty() && partialProfiles[0].Primary_Email__c != null) {
                return partialProfiles[0].Primary_Email__c;
            }
            
            return '';
        } catch (Exception e) {
            System.debug('Error finding manager email: ' + e.getMessage());
            return '';
        }
    }
    
    private List<String> buildChainConditions(String managerEmail) {
        List<String> chainConditions = new List<String>();
        
        if (String.isBlank(managerEmail)) {
            return chainConditions;
        }
        
        for (Integer i = 1; i <= 10; i++) {
            String fieldName = 'Emp_Mgt_Chain_Lvl_';
            if (i < 10) {
                fieldName += '0' + i;
            } else {
                fieldName += i;
            }
            fieldName += '_Nm__c';
            
            chainConditions.add(fieldName + ' = \'' + String.escapeSingleQuotes(managerEmail) + '\'');
        }
        
        return chainConditions;
    }
    
    private List<Learner_Profile__c> queryEmployeesInOrg(List<String> chainConditions, Integer maxRecords) {
        if (chainConditions == null || chainConditions.isEmpty()) {
            return new List<Learner_Profile__c>();
        }
        
        String query = 'SELECT Id, Name, Primary_Email__c, Manager__c, Division__c ' +
                     'FROM Learner_Profile__c ' +
                     'WHERE Status__c = \'Active\' ' +
                     'AND (' + String.join(chainConditions, ' OR ') + ') ' +
                     'ORDER BY Name ASC ' +
                     'LIMIT ' + maxRecords;
        
        return Database.query(query);
    }
    
    private Integer countEmployeesInOrg(List<String> chainConditions) {
        if (chainConditions == null || chainConditions.isEmpty()) {
            return 0;
        }
        
        String query = 'SELECT COUNT() ' +
                     'FROM Learner_Profile__c ' +
                     'WHERE Status__c = \'Active\' ' +
                     'AND (' + String.join(chainConditions, ' OR ') + ')';
        
        return Database.countQuery(query);
    }
    
    private List<Assigned_Course__c> queryOrgCourseAssignments(Id courseId, List<Id> employeeIds) {
        if (employeeIds == null || employeeIds.isEmpty()) {
            return new List<Assigned_Course__c>();
        }
        
        return [
            SELECT Id, Learner_Profile__c, Learner_Profile__r.Name, 
                   Learner_Profile__r.Division__c, Learner_Profile__r.Manager__c,
                   Completed__c, Completion_Date__c, Self_Assigned__c, Required__c, Assigned_On__c
            FROM Assigned_Course__c
            WHERE Course__c = :courseId
            AND Learner_Profile__c IN :employeeIds
            ORDER BY Completion_Date__c DESC NULLS LAST, Learner_Profile__r.Name ASC
        ];
    }
}