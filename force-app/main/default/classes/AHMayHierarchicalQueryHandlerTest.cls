@isTest
private class AHMayHierarchicalQueryHandlerTest {
    @TestSetup
    static void setupTestData() {
        // Create hierarchical test data
        List<Learner_Profile__c> employees = new List<Learner_Profile__c>();
        
        // Create CEO
        Learner_Profile__c ceo = new Learner_Profile__c(
            Name = 'CEO Test',
            Primary_Email__c = 'ceo@test.com',
            Status__c = 'Active',
            Division__c = 'Global'
        );
        employees.add(ceo);
        
        // Create managers
        for (Integer i = 0; i < 3; i++) {
            Learner_Profile__c manager = new Learner_Profile__c(
                Name = 'Manager ' + i,
                Primary_Email__c = 'manager' + i + '@test.com',
                Manager__c = 'CEO Test',
                Manager_Email__c = 'ceo@test.com',
                Status__c = 'Active',
                Division__c = 'AMER'
            );
            
            // Set management chain
            manager.Emp_Mgt_Chain_Lvl_01_Nm__c = 'ceo@test.com';
            employees.add(manager);
        }
        
        insert employees;
        
        // Create employees under managers
        List<Learner_Profile__c> staff = new List<Learner_Profile__c>();
        for (Learner_Profile__c manager : employees) {
            if (manager.Name.startsWith('Manager')) {
                for (Integer j = 0; j < 5; j++) {
                    Learner_Profile__c employee = new Learner_Profile__c(
                        Name = manager.Name + ' Employee ' + j,
                        Primary_Email__c = manager.Name.replace(' ', '.').toLowerCase() + '.emp' + j + '@test.com',
                        Manager__c = manager.Name,
                        Manager_Email__c = manager.Primary_Email__c,
                        Status__c = 'Active',
                        Division__c = 'AMER',
                        Job_Family__c = 'Engineer',
                        FTE__c = true,
                        Hire_Date__c = Date.today().addYears(-1)
                    );
                    
                    // Set management chain
                    employee.Emp_Mgt_Chain_Lvl_01_Nm__c = 'ceo@test.com';
                    employee.Emp_Mgt_Chain_Lvl_02_Nm__c = manager.Primary_Email__c;
                    staff.add(employee);
                }
            }
        }
        insert staff;
    }
    
    @isTest
    static void testBasicHierarchicalQuery() {
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.pageNumber = 1;
        
        Map<String, Object> queryData = new Map<String, Object>{
            'Status__c' => 'Active',
            'HIERARCHICAL_QUERY' => 'CEO Test'
        };
        
        AHMayHierarchicalQueryHandler handler = new AHMayHierarchicalQueryHandler();
        Test.startTest();
        AHMayQueryResult result = handler.handleQuery(request, queryData);
        Test.stopTest();
        
        System.assertEquals(true, result.success);
        System.assert(result.totalRecords > 0);
        System.assert(result.message.contains('Organization for: CEO Test'));
    }
    
    @isTest
    static void testFilteredHierarchicalQuery() {
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.pageNumber = 1;
        
        Map<String, Object> queryData = new Map<String, Object>{
            'Status__c' => 'Active',
            'HIERARCHICAL_QUERY' => 'CEO Test',
            'Division__c' => 'AMER',
            'FTE__c' => true
        };
        
        AHMayHierarchicalQueryHandler handler = new AHMayHierarchicalQueryHandler();
        Test.startTest();
        AHMayQueryResult result = handler.handleQuery(request, queryData);
        Test.stopTest();
        
        System.assertEquals(true, result.success);
        System.assert(result.message.contains('Filtered organization'));
    }
    
    @isTest
    static void testHierarchicalWithDateRange() {
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.pageNumber = 1;
        
        Map<String, Object> queryData = new Map<String, Object>{
            'Status__c' => 'Active',
            'HIERARCHICAL_QUERY' => 'CEO Test',
            'Hire_Date__c_RANGE' => new Map<String, Object>{
                'start' => String.valueOf(Date.today().addYears(-2)),
                'end' => String.valueOf(Date.today())
            }
        };
        
        AHMayHierarchicalQueryHandler handler = new AHMayHierarchicalQueryHandler();
        Test.startTest();
        AHMayQueryResult result = handler.handleQuery(request, queryData);
        Test.stopTest();
        
        System.assertEquals(true, result.success);
    }
    
    @isTest
    static void testMultipleManagersHierarchy() {
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.pageNumber = 1;
        
        Map<String, Object> queryData = new Map<String, Object>{
            'Status__c' => 'Active',
            'HIERARCHICAL_QUERY_OR' => new List<String>{'Manager 0', 'Manager 1'}
        };
        
        AHMayHierarchicalQueryHandler handler = new AHMayHierarchicalQueryHandler();
        Test.startTest();
        AHMayQueryResult result = handler.handleQuery(request, queryData);
        Test.stopTest();
        
        System.assertEquals(true, result.success);
        System.assert(result.message.contains('Organization for: Manager 0 or Manager 1'));
    }
    
    @isTest
    static void testManagerNotFound() {
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.pageNumber = 1;
        
        Map<String, Object> queryData = new Map<String, Object>{
            'Status__c' => 'Active',
            'HIERARCHICAL_QUERY' => 'Nonexistent Manager'
        };
        
        AHMayHierarchicalQueryHandler handler = new AHMayHierarchicalQueryHandler();
        Test.startTest();
        AHMayQueryResult result = handler.handleQuery(request, queryData);
        Test.stopTest();
        
        System.assertEquals(false, result.success);
        System.assert(result.message.contains('Could not find manager'));
    }
}