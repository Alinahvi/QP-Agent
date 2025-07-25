public with sharing class TopSellersService {
    @AuraEnabled(cacheable=true)
    public static List<sme_prime_ae__c> getTopSellers(String productSKU, Integer n) {
        return [
            SELECT AE_Rank__c, AE_Name__c, Total_ACV__c, Product_L2__c, OU__c
            FROM sme_prime_ae__c
            WHERE Product_L3__c = :productSKU
            ORDER BY Total_ACV__c DESC
            LIMIT :n
        ];
    }
}