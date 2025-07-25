public with sharing class PicklistOptionWrapper {

    @AuraEnabled public String label = '';
    @AuraEnabled public String value = '';

    public PicklistOptionWrapper(String label, String value) {
        this.label = label;
        this.value = value;
    }
}