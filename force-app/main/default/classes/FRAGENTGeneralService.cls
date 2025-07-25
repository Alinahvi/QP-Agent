/**
 * @description A general-purpose, abstract service class providing common utilities
 *              for the Field Readiness Agent's backend services. This class includes
 *              a robust, hierarchical, and namespace-proof permission checking model.
 */
public abstract with sharing class FRAGENTGeneralService {
    // These constants represent the Permission Set LABELS, which are stable.
    public static final String PERM_LABEL_CRU      = 'AEA Field Readiness Agent Cohort Management CRU';
    public static final String PERM_LABEL_CRUD     = 'AEA Field Readiness Agent Cohort Management CRUD';
    public static final String PERM_LABEL_RETRIEVE = 'AEA Field Readiness Agent Cohort Management Retrieve';

    // Alias for checklist manager permissions
    public static final String PERM_LABEL_CHECKLIST_MANAGER = PERM_LABEL_CRUD;

    private static final Map<String, Set<String>> permissionHierarchy = new Map<String, Set<String>>{
        PERM_LABEL_CRUD     => new Set<String>{ PERM_LABEL_CRUD },
        PERM_LABEL_CRU      => new Set<String>{ PERM_LABEL_CRU, PERM_LABEL_CRUD },
        PERM_LABEL_RETRIEVE => new Set<String>{ PERM_LABEL_RETRIEVE, PERM_LABEL_CRU, PERM_LABEL_CRUD }
    };

    private static Map<String, String> permissionSetApiNames = new Map<String, String>();
    
    /**
     * @description Represents the outcome of a service operation.
     * Added the 'virtual' keyword to allow other classes to extend this one.
     */
    public virtual class Result {
        @AuraEnabled public Boolean success;
        @AuraEnabled public List<String> errors;
        @AuraEnabled public List<SObject> records;

        public Result(Boolean success, List<SObject> records, List<String> errors) {
            this.success = success;
            this.records = records;
            this.errors = errors;
        }
    }

    /**
     * @description Safely extracts a Set of Ids from a list of SObjects.
     */
    public static Set<Id> getIdsFromSObjects(List<SObject> recs) {
        Set<Id> ids = new Set<Id>();
        if (recs == null) return ids;
        for (SObject r : recs) if (r.Id != null) ids.add(r.Id);
        return ids;
    }

    /**
     * @description Dynamically queries for the real, namespace-proof API name of a Permission Set using its stable Label.
     */
    private static String getPermissionSetApiName(String permLabel) {
        if (permissionSetApiNames.containsKey(permLabel)) {
            return permissionSetApiNames.get(permLabel);
        }
        try {
            List<PermissionSet> psList = [SELECT Name FROM PermissionSet WHERE Label = :permLabel LIMIT 1];
            if (!psList.isEmpty()) {
                String realApiName = psList[0].Name;
                permissionSetApiNames.put(permLabel, realApiName);
                return realApiName;
            }
        } catch (Exception e) {
            System.debug('Could not find Permission Set with Label: ' + permLabel + '. Error: ' + e.getMessage());
        }
        permissionSetApiNames.put(permLabel, permLabel);
        return permLabel;
    }

    /** 
     * @description Checks if the current user has the required permission level by checking against a defined hierarchy.
     */
    public static Boolean hasPermission(String requiredPermLabel) {
        Set<String> validPermissionLabels = permissionHierarchy.get(requiredPermLabel);
        System.debug('FRAGENTGeneralService.hasPermission: requiredPermLabel = ' + requiredPermLabel);
        System.debug('FRAGENTGeneralService.hasPermission: validPermissionLabels = ' + validPermissionLabels);
        if (validPermissionLabels == null || validPermissionLabels.isEmpty()) {
            System.debug('Unknown permission label checked, or hierarchy not defined: ' + requiredPermLabel);
            return false;
        }
        Set<String> validApiNames = new Set<String>();
        for (String label : validPermissionLabels) {
            validApiNames.add(getPermissionSetApiName(label));
        }
        System.debug('FRAGENTGeneralService.hasPermission: validApiNames = ' + validApiNames);
        try {
            Boolean hasPerm = ![
                SELECT Id 
                FROM PermissionSetAssignment 
                WHERE AssigneeId = :UserInfo.getUserId() 
                AND PermissionSet.Name IN :validApiNames
                LIMIT 1
            ].isEmpty();
            System.debug('FRAGENTGeneralService.hasPermission: hasPerm = ' + hasPerm);
            return hasPerm;
        } catch (Exception e) {
            System.debug('Error checking permission for ' + requiredPermLabel + ': ' + e.getMessage());
            return false;
        }
    }
    
    /**
     * @description Explicitly enforces that the user has the specified permission set, throwing an exception if they do not.
     */
    public static void checkPermission(String permLabel) {
        if (!hasPermission(permLabel)) {
            throw new AuraHandledException('Insufficient permissions: Missing Permission Set "' + permLabel + '"');
        }
    }
}