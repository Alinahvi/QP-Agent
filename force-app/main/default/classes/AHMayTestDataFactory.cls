@isTest
public class AHMayTestDataFactory {
    public static List<Learner_Profile__c> createTestProfiles(Integer count) {
        List<Learner_Profile__c> profiles = new List<Learner_Profile__c>();
        
        List<String> divisions = new List<String>{'AMER', 'EMEA', 'APAC', 'LATAM'};
        List<String> jobFamilies = new List<String>{'Engineer', 'Sales', 'Marketing', 'Support'};
        List<String> locations = new List<String>{'New York', 'London', 'Tokyo', 'Sydney'};
        List<String> sellerGroups = new List<String>{'BDR', 'Prime AE', 'SE', 'Specialist AE'};
        List<String> macroSegments = new List<String>{'CMRCL', 'ENTR', 'ESMB', 'MID'};
        
        for (Integer i = 0; i < count; i++) {
            Learner_Profile__c profile = new Learner_Profile__c(
                Name = 'Test Employee ' + i,
                Primary_Email__c = 'test.employee' + i + '@test.com',
                Manager__c = 'Test Manager ' + Math.mod(i, 5),
                Manager_Email__c = 'test.manager' + Math.mod(i, 5) + '@test.com',
                Division__c = divisions[Math.mod(i, divisions.size())],
                Job_Family__c = jobFamilies[Math.mod(i, jobFamilies.size())],
                Employee_Location__c = locations[Math.mod(i, locations.size())],
                FTE__c = Math.random() > 0.2,
                Commissionable__c = Math.random() > 0.5,
                Status__c = 'Active',
                Hire_Date__c = Date.today().addDays(-Math.round(Math.random() * 1825)),
                Work_Location_Country__c = 'United States',
                Is_FLM__c = Math.random() > 0.8,
                Seller_Group__c = sellerGroups[Math.mod(i, sellerGroups.size())],
                Macro_Segment__c = macroSegments[Math.mod(i, macroSegments.size())],
                em_Industry__c = 'Technology',
                Job_Code__c = 'JC-' + String.valueOf(1000 + i),
                Cost_Center_ID__c = 'CC-' + String.valueOf(5000 + Math.mod(i, 10)),
                Cost_Center_Name__c = 'Cost Center ' + Math.mod(i, 10),
                Business_Unit_Name__c = 'BU-' + divisions[Math.mod(i, divisions.size())]
            );
            
            // Set management chain for hierarchical queries
            for (Integer j = 1; j <= 10; j++) {
                String fieldName = 'Emp_Mgt_Chain_Lvl_';
                if (j < 10) {
                    fieldName += '0' + j;
                } else {
                    fieldName += j;
                }
                fieldName += '_Nm__c';
                
                profile.put(fieldName, 'manager' + (Math.mod(i, 5) + j) + '@test.com');
            }
            
            profiles.add(profile);
        }
        
        return profiles;
    }
    
    public static List<Course__c> createTestCourses(Integer count) {
        List<Course__c> courses = new List<Course__c>();
        
        for (Integer i = 0; i < count; i++) {
            courses.add(new Course__c(
                Name = 'Test Course ' + i,
                Description__c = 'This is test course ' + i
            ));
        }
        
        return courses;
    }
    
    public static List<Assigned_Course__c> createTestAssignments(List<Learner_Profile__c> employees, List<Course__c> courses) {
        List<Assigned_Course__c> assignments = new List<Assigned_Course__c>();
        
        for (Learner_Profile__c emp : employees) {
            for (Course__c course : courses) {
                if (Math.random() > 0.5) { // Randomly assign courses
                    assignments.add(new Assigned_Course__c(
                        Learner_Profile__c = emp.Id,
                        Course__c = course.Id,
                        Completed__c = Math.random() > 0.3,
                        Required__c = Math.random() > 0.5,
                        Self_Assigned__c = Math.random() > 0.7,
                        Assigned_On__c = Date.today().addDays(-Math.round(Math.random() * 180)),
                        Completion_Date__c = Math.random() > 0.3 ? Date.today().addDays(-Math.round(Math.random() * 30)) : null
                    ));
                }
            }
        }
        
        return assignments;
    }
}