@isTest
public class FRAgentAPMAssetServiceTest {
    @testSetup
    static void setup() {
        // Insert test Courses and Curriculums with various CreatedDates
        Date today = Date.today();
        insert new Course__c(Name='Test Course Today', Status__c='Active', CreatedDate=today);
        insert new Course__c(Name='Test Course Past', Status__c='Active', CreatedDate=today.addDays(-30));
        insert new Course__c(Name='Test Course Future', Status__c='Active', CreatedDate=today.addDays(30));
        insert new Curriculum__c(Name='Test Curriculum Today', Status__c='Active', CreatedDate=today);
        insert new Curriculum__c(Name='Test Curriculum Past', Status__c='Active', CreatedDate=today.addDays(-60));
        insert new Curriculum__c(Name='Test Curriculum Future', Status__c='Active', CreatedDate=today.addDays(60));
    }

    @isTest
    static void testSearchWithDirectDate() {
        Date today = Date.today();
        Map<String, Object> params = new Map<String, Object>{
            'createdDate' => String.valueOf(today)
        };
        Map<String, Object> result = FRAgentAPMAssetService.search(params);
        System.assertEquals(true, result.get('success'));
        System.assert(((String)result.get('summary')).contains('Today'));
    }

    @isTest
    static void testSearchWithDateRange() {
        Date start = Date.today().addDays(-31);
        Date endDate = Date.today().addDays(-29);
        Map<String, Object> params = new Map<String, Object>{
            'createdDate' => String.valueOf(start) + ':' + String.valueOf(endDate)
        };
        Map<String, Object> result = FRAgentAPMAssetService.search(params);
        System.assertEquals(true, result.get('success'));
        System.assert(((String)result.get('summary')).contains('Past'));
    }

    @isTest
    static void testSearchWithLiteral() {
        Map<String, Object> params = new Map<String, Object>{
            'createdDate' => 'LAST_N_DAYS:90'
        };
        Map<String, Object> result = FRAgentAPMAssetService.search(params);
        System.assertEquals(true, result.get('success'));
        System.assert(((String)result.get('summary')).contains('Today'));
    }

    @isTest
    static void testSearchWithFutureDate() {
        Date future = Date.today().addDays(30);
        Map<String, Object> params = new Map<String, Object>{
            'createdDate' => String.valueOf(future)
        };
        Map<String, Object> result = FRAgentAPMAssetService.search(params);
        System.assertEquals(true, result.get('success'));
        System.assert(((String)result.get('summary')).contains('Future'));
    }

    @isTest
    static void testSearchWithInvalidDate() {
        Map<String, Object> params = new Map<String, Object>{
            'createdDate' => '2025-99-99'
        };
        Map<String, Object> result = FRAgentAPMAssetService.search(params);
        System.assertEquals(false, result.get('success'));
        System.assert(((String)result.get('message')).contains('Invalid date format'));
    }
} 