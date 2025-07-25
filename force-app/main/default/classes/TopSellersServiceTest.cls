@isTest
public class TopSellersServiceTest {
    @isTest static void testGetTopSellers() {
        // Create test data
        List<sme_prime_ae__c> testRecords = new List<sme_prime_ae__c>();
        for (Integer i = 0; i < 5; i++) {
            testRecords.add(new sme_prime_ae__c(
                Product_L3__c = 'SKU123',
                AE_Name__c = 'Test AE ' + i,
                Total_ACV__c = 1000 - i * 100,
                AE_Rank__c = i + 1
            ));
        }
        insert testRecords;

        Test.startTest();
        List<sme_prime_ae__c> results = TopSellersService.getTopSellers('SKU123', 3);
        Test.stopTest();

        System.assertEquals(3, results.size(), 'Should return top 3 sellers');
        System.assertEquals('Test AE 0', results[0].AE_Name__c);
        System.assertEquals('Test AE 1', results[1].AE_Name__c);
        System.assertEquals('Test AE 2', results[2].AE_Name__c);
    }
}