/**
 * @description Centralizes collections of fields used in SOQL queries to ensure
 * consistency and ease of maintenance.
 * @author Your Name/Team
 * @date Created Date
 */
public with sharing class Employee_FieldConstants {
    /**
     * @description Returns a list of standard fields for a typical list view or result card.
     * @return List<String> A list of field API names.
     */
    public static List<String> getStandardFields() {
        return new List<String>{
            'Id', 'Name', 'Primary_Email__c', 'Manager__c', 'Manager_Email__c', 
            'Job_Family__c', 'Division__c', 'Employee_Location__c', 'FTE__c', 'Status__c'
        };
    }

    /**
     * @description Returns a comprehensive list of fields for a detailed employee view.
     * @return List<String> A list of field API names.
     */
    public static List<String> getDetailFields() {
        // No changes needed here, as this method already includes the standard fields.
        List<String> fields = getStandardFields();
        fields.addAll(new List<String>{
            'Business_Unit_Name__c', 'Commissionable__c', 'Job_Code__c',
            'Cost_Center_Name__c', 'Hire_Date__c', 'Work_Location_Country__c',
            'Is_FLM__c', 'Seller_Group__c'
        });
        return fields;
    }

    /**
     * @description Returns fields needed for hierarchical queries, including
     * the denormalized management chain fields.
     * @return List<String> A list of field API names.
     */
    public static List<String> getHierarchicalFields() {
        // No changes needed here, as this method already includes the standard fields.
        List<String> fields = getStandardFields();
        // Add all 10 levels of the management chain
        for (Integer i = 1; i <= 10; i++) {
            String level = String.valueOf(i).leftPad(2, '0');
            fields.add('Emp_Mgt_Chain_Lvl_' + level + '_Nm__c');
        }
        return fields;
    }
}