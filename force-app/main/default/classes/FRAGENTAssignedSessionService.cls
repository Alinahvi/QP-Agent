/**
 * Service class for Assigned Session operations
 * 
 * This class provides business logic for managing Assigned Session records.
 * It handles all CRUD operations and business rule enforcement.
 * 
 * Key Features:
 * - Business logic for all Assigned Session operations
 * - Duplicate prevention logic
 * - Status filtering for unambiguous searches
 * - Pagination support
 * - Error handling and validation
 * 
 * @author Field Readiness Agent Team
 * @version 3.0
 */
public with sharing class FRAGENTAssignedSessionService extends FRAGENTGeneralService {
    private static final String OBJECT_NAME = 'Assigned_Session__c';

    /**
     * Creates a new Assigned Session record
     * 
     * @param params Map containing Assigned Session field values
     * @return Created Assigned Session record
     */
    public static Map<String, Object> create(Map<String, Object> params) {
        if (!checkPermission('Create', OBJECT_NAME)) {
            return noPermissionResponse();
        }
        String learnerProfileId = (String) params.get('Learner_Profile__c');
        String sessionId = (String) params.get('Session__c');

        // Idempotency Check
        List<Assigned_Session__c> existing = [SELECT Id FROM Assigned_Session__c WHERE Learner_Profile__c = :learnerProfileId AND Session__c = :sessionId LIMIT 1];

        if (!existing.isEmpty()) {
            return new Map<String, Object>{
                'success' => true,
                'message' => 'This learner is already assigned to this session.',
                'record' => existing[0]
            };
        }
        
        Assigned_Session__c assignedSession = new Assigned_Session__c();
        if (params.containsKey('Learner_Profile__c')) assignedSession.Learner_Profile__c = (String) params.get('Learner_Profile__c');
        if (params.containsKey('Session__c')) assignedSession.Session__c = (String) params.get('Session__c');
        if (params.containsKey('Status__c')) assignedSession.Status__c = (String) params.get('Status__c');
        if (params.containsKey('Registration_Type__c')) assignedSession.Registration_Type__c = (String) params.get('Registration_Type__c');
        if (params.containsKey('Registration_Date_Time__c')) assignedSession.Registration_Date_Time__c = (DateTime) params.get('Registration_Date_Time__c');
        if (params.containsKey('Self_Registered__c')) assignedSession.Self_Registered__c = (Boolean) params.get('Self_Registered__c');
        
        Database.SaveResult sr = Database.insert(assignedSession, false);
        if (sr.isSuccess()) {
            return new Map<String, Object>{
                'success' => true,
                'message' => 'Assigned Session created successfully.',
                'record' => assignedSession
            };
        } else {
            return new Map<String, Object>{
                'success' => false,
                'message' => 'Error creating Assigned Session: ' + sr.getErrors()[0].getMessage()
            };
        }
    }
    
    /**
     * Modifies an existing Assigned Session record
     * 
     * @param assignedSessionId ID of the Assigned Session to modify
     * @param params Map containing updated field values
     * @return Modified Assigned Session record
     */
    public static Map<String, Object> modify(String assignedSessionId, Map<String, Object> params) {
        if (!checkPermission('Modify', OBJECT_NAME)) {
            return noPermissionResponse();
        }
        try {
            Assigned_Session__c assignedSession = [SELECT Id FROM Assigned_Session__c WHERE Id = :assignedSessionId LIMIT 1];
            
            if (params.containsKey('Learner_Profile__c')) assignedSession.Learner_Profile__c = (String) params.get('Learner_Profile__c');
            if (params.containsKey('Session__c')) assignedSession.Session__c = (String) params.get('Session__c');
            if (params.containsKey('Status__c')) assignedSession.Status__c = (String) params.get('Status__c');
            if (params.containsKey('Registration_Type__c')) assignedSession.Registration_Type__c = (String) params.get('Registration_Type__c');
            if (params.containsKey('Registration_Date_Time__c')) assignedSession.Registration_Date_Time__c = (DateTime) params.get('Registration_Date_Time__c');
            if (params.containsKey('Self_Registered__c')) assignedSession.Self_Registered__c = (Boolean) params.get('Self_Registered__c');
            
            update assignedSession;

            return new Map<String, Object>{
                'success' => true,
                'message' => 'Assigned Session modified successfully.',
                'record' => assignedSession
            };
        } catch (Exception e) {
            return new Map<String, Object>{
                'success' => false,
                'message' => 'Error modifying Assigned Session: ' + e.getMessage()
            };
        }
    }
    
    /**
     * Retrieves an Assigned Session record by ID
     * 
     * @param assignedSessionId ID of the Assigned Session to retrieve
     * @return Assigned Session record
     */
    public static Map<String, Object> retrieve(String assignedSessionId) {
        if (!checkPermission('Retrieve', OBJECT_NAME)) {
            return noPermissionResponse();
        }
        try {
            return new Map<String, Object>{
                'success' => true,
                'record' => [SELECT Id, Name, Learner_Profile__c, Session__c, Status__c, Registration_Type__c, Registration_Date_Time__c, Self_Registered__c, CreatedDate, LastModifiedDate FROM Assigned_Session__c WHERE Id = :assignedSessionId LIMIT 1]
            };
        } catch (Exception e) {
            return new Map<String, Object>{
                'success' => false,
                'message' => 'Error retrieving Assigned Session: ' + e.getMessage()
            };
        }
    }
    
    /**
     * Searches for Assigned Session records based on criteria
     * 
     * @param params Map containing search criteria
     * @return List of matching Assigned Session records
     */
    public static Map<String, Object> search(Map<String, Object> params) {
        if (!checkPermission('Search', OBJECT_NAME)) {
            return noPermissionResponse();
        }
        try {
            Integer offset = (Integer)params.get('offset');
            Integer recordLimit = (Integer)params.get('recordLimit');

            String query = 'SELECT Id, Name, Learner_Profile__c, Learner_Profile__r.Name, Session__c, Session__r.Name, Status__c, Registration_Type__c, Self_Registered__c, Registration_Date_Time__c, CreatedDate, LastModifiedDate FROM Assigned_Session__c';
            
            Map<String, Object> bindMap = new Map<String, Object>();
            List<String> conditions = new List<String>();

            if (params.containsKey('Learner_Profile__c') && String.isNotBlank((String)params.get('Learner_Profile__c'))) {
                conditions.add('Learner_Profile__c = :learnerProfileId');
                bindMap.put('learnerProfileId', (String)params.get('Learner_Profile__c'));
            }
            if (params.containsKey('Session__c') && String.isNotBlank((String)params.get('Session__c'))) {
                conditions.add('Session__c = :sessionId');
                bindMap.put('sessionId', (String)params.get('Session__c'));
            }
            if (params.containsKey('Status__c') && String.isNotBlank((String)params.get('Status__c'))) {
                conditions.add('Status__c = :status');
                bindMap.put('status', (String)params.get('Status__c'));
            }
            if (params.containsKey('Registration_Type__c') && String.isNotBlank((String)params.get('Registration_Type__c'))) {
                conditions.add('Registration_Type__c = :regType');
                bindMap.put('regType', (String)params.get('Registration_Type__c'));
            }
            if (params.containsKey('Self_Registered__c') && params.get('Self_Registered__c') != null) {
                conditions.add('Self_Registered__c = :selfRegistered');
                bindMap.put('selfRegistered', (Boolean)params.get('Self_Registered__c'));
            }
            
            if (!conditions.isEmpty()) {
                query += ' WHERE ' + String.join(conditions, ' AND ');
            }
            
            query += ' ORDER BY LastModifiedDate DESC';

            if (recordLimit != null && recordLimit > 0) {
                query += ' LIMIT ' + recordLimit;
            }

            if (offset != null && offset >= 0) {
                query += ' OFFSET ' + offset;
            }
            
            return new Map<String, Object>{
                'success' => true,
                'records' => Database.queryWithBinds(query, bindMap, AccessLevel.SYSTEM_MODE)
            };
        } catch (Exception e) {
            return new Map<String, Object>{
                'success' => false,
                'message' => 'Error searching Assigned Sessions: ' + e.getMessage()
            };
        }
    }
    
    /**
     * Inactivates an Assigned Session record
     * 
     * @param assignedSessionId ID of the Assigned Session to inactivate
     * @return Inactivated Assigned Session record
     */
    public static Map<String, Object> remove(String assignedSessionId) {
        if (!checkPermission('Remove', OBJECT_NAME)) {
            return noPermissionResponse();
        }
        try {
            Assigned_Session__c rec = [SELECT Id FROM Assigned_Session__c WHERE Id = :assignedSessionId LIMIT 1];
            delete rec;
            return new Map<String, Object>{
                'success' => true,
                'message' => 'Assigned Session removed successfully.'
            };
        } catch (Exception e) {
            return new Map<String, Object>{
                'success' => false,
                'message' => 'Error removing Assigned Session: ' + e.getMessage()
            };
        }
    }
}