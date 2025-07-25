@isTest
private class AHMayResultFormatterTest {
    @TestSetup
    static void setupTestData() {
        List<Learner_Profile__c> employees = AHMayTestDataFactory.createTestProfiles(5);
        insert employees;
    }
    
    @isTest
    static void testFormatEmployeeRecords() {
        List<Learner_Profile__c> profiles = [SELECT Id, Name, Primary_Email__c, Manager__c, 
                                           Manager_Email__c, Division__c, Job_Family__c,
                                           Employee_Location__c, Business_Unit_Name__c,
                                           FTE__c, Commissionable__c, Work_Location_Country__c,
                                           Hire_Date__c, Seller_Group__c, Macro_Segment__c,
                                           em_Industry__c
                                           FROM Learner_Profile__c LIMIT 5];
        
        Test.startTest();
        List<AHMayEmployeeRecord> records = AHMayResultFormatter.formatEmployeeRecords(profiles);
        Test.stopTest();
        
        System.assertEquals(profiles.size(), records.size());
        
        for (Integer i = 0; i < records.size(); i++) {
            AHMayEmployeeRecord record = records[i];
            Learner_Profile__c profile = profiles[i];
            
            System.assertEquals(profile.Id, record.recordId);
            System.assertEquals(profile.Name, record.name);
            System.assertEquals(profile.Primary_Email__c, record.email);
            System.assertEquals(profile.Manager__c, record.manager);
            
            // Check metadata map
            System.assertNotEquals(null, record.metadataMap);
            System.assertEquals(profile.Division__c, record.metadataMap.get('division'));
            System.assertEquals(profile.Job_Family__c, record.metadataMap.get('jobFamily'));
            System.assertEquals(profile.FTE__c, record.metadataMap.get('isFTE'));
        }
    }
    
    @isTest
    static void testFormatSuccessMessage() {
        Integer recordCount = 20;
        Integer totalRecords = 150;
        Integer pageNumber = 2;
        
        String message = AHMayResultFormatter.formatSuccessMessage(recordCount, totalRecords, pageNumber);
        
        System.assert(message.contains('20 employees displayed'));
        System.assert(message.contains('Page 2'));
        System.assert(message.contains('150'));
        System.assert(message.contains('show more'));
    }
    
    @isTest
    static void testFormatConciseEmployeeList() {
        List<AHMayEmployeeRecord> records = new List<AHMayEmployeeRecord>();
        
        AHMayEmployeeRecord record1 = new AHMayEmployeeRecord();
        record1.name = 'John Doe';
        record1.email = 'john.doe@test.com';
        record1.manager = 'Jane Smith';
        records.add(record1);
        
        AHMayEmployeeRecord record2 = new AHMayEmployeeRecord();
        record2.name = 'Jane Smith';
        record2.email = null; // Test null handling
        record2.manager = null;
        records.add(record2);
        
        String message = AHMayResultFormatter.formatConciseEmployeeList(records);
        
        System.assert(message.contains('John Doe'));
        System.assert(message.contains('john.doe@test.com'));
        System.assert(message.contains('Jane Smith'));
        System.assert(message.contains('N/A'));
    }
}