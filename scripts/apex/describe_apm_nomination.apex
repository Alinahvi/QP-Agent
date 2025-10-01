System.debug('--- apm_nomination__c Field API Names ---');
Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get('apm_nomination__c').getDescribe().fields.getMap();
for (String fieldName : fields.keySet()) {
    System.debug(fieldName);
}
