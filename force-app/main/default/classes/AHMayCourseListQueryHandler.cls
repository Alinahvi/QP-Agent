/**
 * Handler for course list queries (what courses is someone assigned to)
 */
public with sharing class AHMayCourseListQueryHandler implements AHMayCourseQueryHandler {
    
    /**
     * Handle course list queries
     * @param request The query request object
     * @param queryData The structured data from the parsed query
     * @return AHMayQueryResult with list of assigned courses
     */
    public AHMayQueryResult handleQuery(AHMayQueryRequest request, Map<String, Object> queryData) {
        AHMayQueryResult result = new AHMayQueryResult();
        
        try {
            // Extract employee name
            String employeeName = (String)queryData.get('EMPLOYEE_NAME');
            
            if (String.isBlank(employeeName)) {
                result.success = false;
                result.message = 'Employee name is required.';
                return result;
            }
            
            // Find the employee by name
            List<Learner_Profile__c> employees = findEmployeesByName(employeeName);
            
            if (employees.isEmpty()) {
                result.success = false;
                result.message = 'Could not find employee: ' + employeeName;
                return result;
            }
            
            // Check for ambiguous employee matches
            if (employees.size() > 1) {
                return handleAmbiguousEmployeeMatch(employees, queryData);
            }
            
            // Determine filter type (default to ASSIGNED)
            String filterType = 'ASSIGNED';
            if (queryData.containsKey('FILTER_TYPE')) {
                filterType = (String)queryData.get('FILTER_TYPE');
            }
            
            // Query the assigned courses
            List<Assigned_Course__c> assignedCourses = [
                SELECT Id, Course__c, Course__r.Name, Completed__c, 
                       Completion_Date__c, Self_Assigned__c, Required__c, Assigned_On__c
                FROM Assigned_Course__c
                WHERE Learner_Profile__c = :employees[0].Id
                ORDER BY Required__c DESC, Course__r.Name ASC
                LIMIT 100
            ];
            
            // Format the result based on filter type
            if (assignedCourses.isEmpty()) {
                result.success = true;
                result.message = employees[0].Name + ' is not assigned to any courses.';
            } else {
                result = formatCourseListResult(employees[0], assignedCourses, filterType);
            }
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error retrieving course list: ' + e.getMessage();
            System.debug(LoggingLevel.ERROR, 'Error: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
        }
        
        return result;
    }
    
    /**
     * Find employees by name with LIKE query
     * @param employeeName Name to search for
     * @return List of matching employee records
     */
    private List<Learner_Profile__c> findEmployeesByName(String employeeName) {
        String searchName = '%' + String.escapeSingleQuotes(employeeName) + '%';
        return [
            SELECT Id, Name, Primary_Email__c, Manager__c, Division__c
            FROM Learner_Profile__c
            WHERE Name LIKE :searchName
            AND Status__c = 'Active'
            LIMIT 5
        ];
    }
    
    /**
     * Handle case where multiple employees match the name
     * @param employees List of matching employees
     * @param queryData Original query data
     * @return Result with disambiguation information
     */
    private AHMayQueryResult handleAmbiguousEmployeeMatch(List<Learner_Profile__c> employees, Map<String, Object> queryData) {
        AHMayQueryResult result = new AHMayQueryResult();
        result.success = true;
        result.message = 'Found multiple employees matching "' + queryData.get('EMPLOYEE_NAME') + '":\n\n';
        
        for (Learner_Profile__c emp : employees) {
            result.message += '- ' + emp.Name;
            if (emp.Division__c != null) {
                result.message += ' (' + emp.Division__c;
                if (emp.Manager__c != null) {
                    result.message += ', Manager: ' + emp.Manager__c;
                }
                result.message += ')';
            } else if (emp.Manager__c != null) {
                result.message += ' (Manager: ' + emp.Manager__c + ')';
            }
            result.message += '\n';
        }
        
        result.message += '\nPlease specify which employee you meant.';
        return result;
    }
    
    /**
     * Format result for course list queries
     * @param employee The employee record
     * @param assignedCourses List of assigned courses
     * @param filterType Type of filter to apply
     * @return Formatted result
     */
    private AHMayQueryResult formatCourseListResult(Learner_Profile__c employee, List<Assigned_Course__c> assignedCourses, String filterType) {
        AHMayQueryResult result = new AHMayQueryResult();
        result.success = true;
        
        // Apply filters based on filter type
        List<Assigned_Course__c> filteredCourses = new List<Assigned_Course__c>();
        
        if (filterType == 'COMPLETED') {
            for (Assigned_Course__c ac : assignedCourses) {
                if (ac.Completed__c) {
                    filteredCourses.add(ac);
                }
            }
        } else if (filterType == 'INCOMPLETE') {
            for (Assigned_Course__c ac : assignedCourses) {
                if (!ac.Completed__c) {
                    filteredCourses.add(ac);
                }
            }
        } else if (filterType == 'REQUIRED') {
            for (Assigned_Course__c ac : assignedCourses) {
                if (ac.Required__c) {
                    filteredCourses.add(ac);
                }
            }
        } else if (filterType == 'SELF_ASSIGNED') {
            for (Assigned_Course__c ac : assignedCourses) {
                if (ac.Self_Assigned__c) {
                    filteredCourses.add(ac);
                }
            }
        } else {
            // Default to all assigned courses
            filteredCourses = assignedCourses;
        }
        
        // Format the message
        String filterDescription = '';
        if (filterType == 'COMPLETED') {
            filterDescription = 'completed ';
        } else if (filterType == 'INCOMPLETE') {
            filterDescription = 'incomplete ';
        } else if (filterType == 'REQUIRED') {
            filterDescription = 'required ';
        } else if (filterType == 'SELF_ASSIGNED') {
            filterDescription = 'self-assigned ';
        }
        
        if (filteredCourses.isEmpty()) {
            if (filterType != 'ASSIGNED') {
                result.message = employee.Name + ' has no ' + filterDescription + 'courses.';
            } else {
                result.message = employee.Name + ' is not assigned to any courses.';
            }
        } else {
            result.message = 'Courses ' + (filterType != 'ASSIGNED' ? filterDescription : '') + 
                             'assigned to ' + employee.Name + ':\n\n';
            
            Integer count = 1;
            for (Assigned_Course__c ac : filteredCourses) {
                result.message += count + '. ' + ac.Course__r.Name;
                
                List<String> details = new List<String>();
                
                // Add assignment date
                if (ac.Assigned_On__c != null) {
                    details.add('Assigned on ' + ac.Assigned_On__c.format());
                }
                
                // Add status info
                if (ac.Completed__c) {
                    details.add('Completed' + (ac.Completion_Date__c != null ? 
                                ' on ' + ac.Completion_Date__c.format() : ''));
                } else {
                    details.add('In Progress');
                }
                
                if (ac.Required__c) {
                    details.add('Required');
                }
                
                if (ac.Self_Assigned__c) {
                    details.add('Self-assigned');
                }
                
                if (!details.isEmpty()) {
                    result.message += ' (' + String.join(details, ', ') + ')';
                }
                
                result.message += '\n';
                count++;
            }
            
            result.message += '\nTotal: ' + filteredCourses.size() + ' course' + 
                             (filteredCourses.size() != 1 ? 's' : '');
        }
        
        return result;
    }
}