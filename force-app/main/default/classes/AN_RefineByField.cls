public with sharing class AN_RefineByField {
    @InvocableVariable(label='Field Name' description='The user-friendly name of the filter field.')
    @AuraEnabled
    public String name;
    
    @InvocableVariable(label='Field Description' description='A description of what the filter field is and how to use it.')
    @AuraEnabled
    public String description;

    public AN_RefineByField(String name, String description) {
        this.name = name;
        this.description = description;
    }
} 