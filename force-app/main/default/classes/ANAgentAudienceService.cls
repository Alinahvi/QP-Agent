/**
 * @description Service class for handling APM nominations for all asset types.
 * Supports dynamic lookup field mapping based on offeringType.
 */
public with sharing class ANAgentAudienceService {
    // Map offering types to APM_Nomination__c lookup fields
    private static final Map<String, String> OFFERING_FIELD_MAP = new Map<String, String>{
        'Course'      => 'Asset_Id_c__c',
        'Program'     => 'Asset_Id_c__c',
        'Asset'       => 'Asset_Id_c__c',
        'Curriculum'  => 'Asset_Id_c__c'
        // Add more as needed
    };

    public class NominationResult {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        public NominationResult(Boolean success, String message) {
            this.success = success;
            this.message = message;
        }
    }

    /**
     * Handles nomination for a given offering and nominator name.
     * @param offeringId The Id of the offering (Course, Program, etc.)
     * @param offeringType The type of the offering (Course, Program, etc.)
     * @param nominatorName The name of the nominator
     * @return NominationResult with success and message
     */
    public static NominationResult nominate(Id offeringId, String offeringType, String nominatorName, String offeringName) {
        if ((offeringId == null && String.isBlank(offeringName)) || String.isBlank(nominatorName)) {
            return new NominationResult(false, 'Offering Id or name and nominator name are required.');
        }
        String field = getOfferingField(offeringType);
        if (field == null) {
            return new NominationResult(false, 'Unsupported offering type: ' + offeringType);
        }
        // If offeringId is not provided, look it up by name
        if (offeringId == null && String.isNotBlank(offeringName)) {
            offeringId = lookupOfferingIdByName(offeringType, offeringName);
            if (offeringId == null) {
                return new NominationResult(false, 'Could not find offering with name: ' + offeringName);
            }
        }
        // Build dynamic SOQL to check for existing nomination
        String query = 'SELECT Id FROM APM_Nomination__c WHERE ' + field + ' = :offeringId AND Nominator_c__c = :nominatorName LIMIT 1';
        List<SObject> existing = Database.query(query);
        if (!existing.isEmpty()) {
            return new NominationResult(true, 'You have already nominated this offering.');
        }
        // Insert new nomination
        SObject nom = Schema.getGlobalDescribe().get('APM_Nomination__c').newSObject();
        nom.put(field, offeringId); // field will be Asset_Id_c__c
        nom.put('Nominator_c__c', nominatorName);
        nom.put('Date_Nominated_c__c', Date.today());
        // Optionally populate more fields if needed, e.g.:
        // nom.put('Asset_Name_c__c', ...);
        // nom.put('Status_c__c', ...);
        insert nom;
        return new NominationResult(true, 'Nomination successful!');
    }

    // Helper to get the correct lookup field for the offering type
    private static String getOfferingField(String offeringType) {
        if (String.isBlank(offeringType)) return 'Asset_Id_c__c'; // Default to Asset_Id_c__c
        String key = offeringType.trim().capitalize();
        return OFFERING_FIELD_MAP.containsKey(key) ? OFFERING_FIELD_MAP.get(key) : null;
    }

    // Helper to look up offering Id by name and type
    private static Id lookupOfferingIdByName(String offeringType, String offeringName) {
        if (String.isBlank(offeringType) || String.isBlank(offeringName)) return null;
        String sobjectName;
        if (offeringType.equalsIgnoreCase('Course')) sobjectName = 'Course__c';
        else if (offeringType.equalsIgnoreCase('Asset')) sobjectName = 'Asset__c';
        else if (offeringType.equalsIgnoreCase('Curriculum')) sobjectName = 'Curriculum__c';
        else return null;
        String query = 'SELECT Id FROM ' + sobjectName + ' WHERE Name = :offeringName LIMIT 1';
        List<SObject> results = Database.query(query);
        return results.isEmpty() ? null : (Id)results[0].get('Id');
    }
} 