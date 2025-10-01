
// Direct SOQL test for Heroku in PRODUCT_L2__c or PRODUCT_L3__c
String testProduct = 'Heroku';
Integer topN = 5;
List<sme_prime_ae__c> topAEs = [
    SELECT Id, Name, PRODUCT_L2__c, PRODUCT_L3__c
    FROM sme_prime_ae__c
    WHERE PRODUCT_L2__c = :testProduct OR PRODUCT_L3__c = :testProduct
    LIMIT :topN
];
System.debug('Top 5 AEs for product ' + testProduct + ' (PRODUCT_L2__c or PRODUCT_L3__c):');
for (sme_prime_ae__c ae : topAEs) {
    System.debug(ae);
}
