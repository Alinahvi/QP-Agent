/**
 * FPA Data Audit Script
 * Checks field availability and data quality for Future Pipeline Analysis Intelligence
 */
System.debug('=== FPA DATA AUDIT START ===');

// Check Agent_Renewals__c fields
System.debug('=== RENEWALS OBJECT AUDIT ===');
Map<String, Schema.SObjectField> renewalFields = Schema.SObjectType.Agent_Renewals__c.fields.getMap();
Map<String, Boolean> renewalAudit = new Map<String, Boolean>();

// Core fields for Renewal Risk Scoring
renewalAudit.put('Id', renewalFields.containsKey('Id'));
renewalAudit.put('full_name__c', renewalFields.containsKey('full_name__c'));
renewalAudit.put('ou_name__c', renewalFields.containsKey('ou_name__c'));
renewalAudit.put('renewal_opty_amt__c', renewalFields.containsKey('renewal_opty_amt__c'));
renewalAudit.put('renewal_prod_nm__c', renewalFields.containsKey('renewal_prod_nm__c'));
renewalAudit.put('renewal_acct_nm__c', renewalFields.containsKey('renewal_acct_nm__c'));
renewalAudit.put('work_location_country__c', renewalFields.containsKey('work_location_country__c'));

// Check for CloseDate field (needed for renewal risk)
renewalAudit.put('CloseDate', renewalFields.containsKey('CloseDate'));

// Check for product hierarchy fields
renewalAudit.put('PRODUCT_L2__c', renewalFields.containsKey('PRODUCT_L2__c'));
renewalAudit.put('PRODUCT_L3__c', renewalFields.containsKey('PRODUCT_L3__c'));

// Check for AE performance fields
renewalAudit.put('AE_Score__c', renewalFields.containsKey('AE_Score__c'));
renewalAudit.put('Coverage__c', renewalFields.containsKey('Coverage__c'));

// Check for Learner Profile linkage
renewalAudit.put('learner_profile_id__c', renewalFields.containsKey('learner_profile_id__c'));

for (String field : renewalAudit.keySet()) {
    System.debug('Renewals ' + field + ': ' + (renewalAudit.get(field) ? '✅' : '❌'));
}

// Check Agent_Cross_Sell__c fields
System.debug('=== CROSS-SELL OBJECT AUDIT ===');
Map<String, Schema.SObjectField> crossSellFields = Schema.SObjectType.Agent_Cross_Sell__c.fields.getMap();
Map<String, Boolean> crossSellAudit = new Map<String, Boolean>();

crossSellAudit.put('Id', crossSellFields.containsKey('Id'));
crossSellAudit.put('full_name__c', crossSellFields.containsKey('full_name__c'));
crossSellAudit.put('ou_name__c', crossSellFields.containsKey('ou_name__c'));
crossSellAudit.put('cross_sell_next_best_product__c', crossSellFields.containsKey('cross_sell_next_best_product__c'));
crossSellAudit.put('cross_sell_acct_nm__c', crossSellFields.containsKey('cross_sell_acct_nm__c'));
crossSellAudit.put('work_location_country__c', crossSellFields.containsKey('work_location_country__c'));

// Check for amount field (may not exist)
crossSellAudit.put('cross_sell_amount__c', crossSellFields.containsKey('cross_sell_amount__c'));

// Check for product hierarchy
crossSellAudit.put('PRODUCT_L2__c', crossSellFields.containsKey('PRODUCT_L2__c'));
crossSellAudit.put('PRODUCT_L3__c', crossSellFields.containsKey('PRODUCT_L3__c'));

// Check for AE performance fields
crossSellAudit.put('AE_Score__c', crossSellFields.containsKey('AE_Score__c'));
crossSellAudit.put('Coverage__c', crossSellFields.containsKey('Coverage__c'));

// Check for Learner Profile linkage
crossSellAudit.put('learner_profile_id__c', crossSellFields.containsKey('learner_profile_id__c'));

for (String field : crossSellAudit.keySet()) {
    System.debug('Cross-Sell ' + field + ': ' + (crossSellAudit.get(field) ? '✅' : '❌'));
}

// Check Agent_Upsell__c fields
System.debug('=== UPSELL OBJECT AUDIT ===');
Map<String, Schema.SObjectField> upsellFields = Schema.SObjectType.Agent_Upsell__c.fields.getMap();
Map<String, Boolean> upsellAudit = new Map<String, Boolean>();

upsellAudit.put('Id', upsellFields.containsKey('Id'));
upsellAudit.put('full_name__c', upsellFields.containsKey('full_name__c'));
upsellAudit.put('ou_name__c', upsellFields.containsKey('ou_name__c'));
upsellAudit.put('upsell_sub_category__c', upsellFields.containsKey('upsell_sub_category__c'));
upsellAudit.put('upsell_acct_nm__c', upsellFields.containsKey('upsell_acct_nm__c'));
upsellAudit.put('work_location_country__c', upsellFields.containsKey('work_location_country__c'));

// Check for amount field (may not exist)
upsellAudit.put('upsell_amount__c', upsellFields.containsKey('upsell_amount__c'));

// Check for product hierarchy
upsellAudit.put('PRODUCT_L2__c', upsellFields.containsKey('PRODUCT_L2__c'));
upsellAudit.put('PRODUCT_L3__c', upsellFields.containsKey('PRODUCT_L3__c'));

// Check for AE performance fields
upsellAudit.put('AE_Score__c', upsellFields.containsKey('AE_Score__c'));
upsellAudit.put('Coverage__c', upsellFields.containsKey('Coverage__c'));

// Check for Learner Profile linkage
upsellAudit.put('learner_profile_id__c', upsellFields.containsKey('learner_profile_id__c'));

for (String field : upsellAudit.keySet()) {
    System.debug('Upsell ' + field + ': ' + (upsellAudit.get(field) ? '✅' : '❌'));
}

// Check Learner_Profile__c object
System.debug('=== LEARNER PROFILE OBJECT AUDIT ===');
try {
    Map<String, Schema.SObjectField> learnerFields = Schema.SObjectType.Learner_Profile__c.fields.getMap();
    Map<String, Boolean> learnerAudit = new Map<String, Boolean>();
    
    learnerAudit.put('Id', learnerFields.containsKey('Id'));
    learnerAudit.put('Name', learnerFields.containsKey('Name'));
    learnerAudit.put('External_Profile_Id__c', learnerFields.containsKey('External_Profile_Id__c'));
    learnerAudit.put('Email__c', learnerFields.containsKey('Email__c'));
    learnerAudit.put('Manager__c', learnerFields.containsKey('Manager__c'));
    learnerAudit.put('Work_Location_Country__c', learnerFields.containsKey('Work_Location_Country__c'));
    
    for (String field : learnerAudit.keySet()) {
        System.debug('Learner Profile ' + field + ': ' + (learnerAudit.get(field) ? '✅' : '❌'));
    }
} catch (Exception e) {
    System.debug('❌ Learner_Profile__c object not accessible: ' + e.getMessage());
}

// Sample data counts
System.debug('=== DATA VOLUME AUDIT ===');
try {
    Integer renewalCount = [SELECT COUNT() FROM Agent_Renewals__c LIMIT 1];
    System.debug('Renewals records: ' + renewalCount);
} catch (Exception e) {
    System.debug('❌ Cannot query Agent_Renewals__c: ' + e.getMessage());
}

try {
    Integer crossSellCount = [SELECT COUNT() FROM Agent_Cross_Sell__c LIMIT 1];
    System.debug('Cross-Sell records: ' + crossSellCount);
} catch (Exception e) {
    System.debug('❌ Cannot query Agent_Cross_Sell__c: ' + e.getMessage());
}

try {
    Integer upsellCount = [SELECT COUNT() FROM Agent_Upsell__c LIMIT 1];
    System.debug('Upsell records: ' + upsellCount);
} catch (Exception e) {
    System.debug('❌ Cannot query Agent_Upsell__c: ' + e.getMessage());
}

System.debug('=== FPA DATA AUDIT COMPLETE ===');
